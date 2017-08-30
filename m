From: Chris Mi <chrism@mellanox.com>
Subject: [patch net-next v2 0/3] net/sched: Improve getting objects by indexes
Date: Wed, 30 Aug 2017 02:31:56 -0400
Message-ID: <1504074719-15147-1-git-send-email-chrism@mellanox.com>
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        davem@davemloft.net, mawilcox@microsoft.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37916 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750746AbdH3GcP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 02:32:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using current TC code, it is very slow to insert a lot of rules.

In order to improve the rules update rate in TC,
we introduced the following two changes:
        1) changed cls_flower to use IDR to manage the filters.
        2) changed all act_xxx modules to use IDR instead of
           a small hash table

But IDR has a limitation that it uses int. TC handle uses u32.
To make sure there is no regression, we add several new IDR APIs
to support unsigned long.

v2
==

Addressed Hannes's comment:
express idr_alloc in terms of idr_alloc_ext and most of the other functions

Chris Mi (3):
  idr: Add new APIs to support unsigned long
  net/sched: Change cls_flower to use IDR
  net/sched: Change act_api and act_xxx modules to use IDR

 include/linux/idr.h        |  69 ++++++++++++-
 include/linux/radix-tree.h |  21 +++-
 include/net/act_api.h      |  76 +++++---------
 lib/idr.c                  |  66 ++++++------
 lib/radix-tree.c           |   6 +-
 net/sched/act_api.c        | 251 ++++++++++++++++++++++-----------------------
 net/sched/act_bpf.c        |  17 ++-
 net/sched/act_connmark.c   |  16 ++-
 net/sched/act_csum.c       |  16 ++-
 net/sched/act_gact.c       |  16 ++-
 net/sched/act_ife.c        |  20 ++--
 net/sched/act_ipt.c        |  26 +++--
 net/sched/act_mirred.c     |  19 ++--
 net/sched/act_nat.c        |  16 ++-
 net/sched/act_pedit.c      |  18 ++--
 net/sched/act_police.c     |  18 ++--
 net/sched/act_sample.c     |  17 ++-
 net/sched/act_simple.c     |  20 ++--
 net/sched/act_skbedit.c    |  18 ++--
 net/sched/act_skbmod.c     |  18 ++--
 net/sched/act_tunnel_key.c |  20 ++--
 net/sched/act_vlan.c       |  22 ++--
 net/sched/cls_flower.c     |  55 +++++-----
 23 files changed, 427 insertions(+), 414 deletions(-)

-- 
1.8.3.1

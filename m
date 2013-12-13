From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH net-next v2 0/6] net_sched: some cleanup and improvments
Date: Thu, 12 Dec 2013 20:56:38 -0800
Message-ID: <1386910604-1870-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:64505 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805Ab3LME5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 23:57:00 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so1843720pbb.32
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 20:57:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are some cleanup and improvements for tc filters
and tc actions.

v1 -> v2:
* fix a smatch warning and a checkpatch warning
* add a cover letter
* add a missing synchronize_rcu()

Cong Wang (6):
  net_sched: remove get_stats from tc_action_ops
  net_sched: act: use standard struct list_head
  net_sched: mirred: remove action when the target device is gone
  net_sched: cls: refactor out struct tcf_ext_map
  net_sched: init struct tcf_hashinfo at register time
  net_sched: convert tcf_hashinfo to hlist and use rcu

 include/net/act_api.h          |  41 +++++++---
 include/net/pkt_cls.h          |  37 +++++----
 include/net/tc_act/tc_mirred.h |   4 +-
 net/sched/act_api.c            | 180 ++++++++++++++++++-----------------------
 net/sched/act_csum.c           |  13 ++-
 net/sched/act_gact.c           |  13 ++-
 net/sched/act_ipt.c            |  21 +++--
 net/sched/act_mirred.c         |  31 ++++---
 net/sched/act_nat.c            |  12 ++-
 net/sched/act_pedit.c          |  12 ++-
 net/sched/act_police.c         |  65 +++++++--------
 net/sched/act_simple.c         |  20 ++---
 net/sched/act_skbedit.c        |  13 ++-
 net/sched/cls_api.c            |  80 +++++++++---------
 net/sched/cls_basic.c          |  13 ++-
 net/sched/cls_bpf.c            |  13 ++-
 net/sched/cls_cgroup.c         |  14 ++--
 net/sched/cls_flow.c           |  13 ++-
 net/sched/cls_fw.c             |  13 ++-
 net/sched/cls_route.c          |  13 ++-
 net/sched/cls_rsvp.h           |  13 ++-
 net/sched/cls_tcindex.c        |  17 ++--
 net/sched/cls_u32.c            |  13 ++-
 23 files changed, 304 insertions(+), 360 deletions(-)

-- 
1.8.1.4

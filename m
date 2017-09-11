From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v3 0/3] net_sched: fix filter chain reference counting
Date: Mon, 11 Sep 2017 16:33:29 -0700
Message-ID: <20170911233332.7594-1-xiyou.wangcong@gmail.com>
Cc: jiri@mellanox.com, jakub.kicinski@netronome.com, jhs@mojatatu.com,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35408 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750957AbdIKXdu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 19:33:50 -0400
Received: by mail-pg0-f65.google.com with SMTP id j16so2231490pga.2
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 16:33:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes tc filter chain reference counting and nasty race
conditions with RCU callbacks. Please see each patch for details.

---

v3: Rebase on the latest -net
    Add code comment in patch 1
    Improve comment and changelog for patch 2
    Add patch 3

v2: Add patch 1
    Get rid of more ugly code in patch 2

Cong Wang (3):
  net_sched: get rid of tcfa_rcu
  net_sched: fix reference counting of tc filter chain
  net_sched: carefully handle tcf_block_put()

 include/net/act_api.h |  2 --
 net/sched/act_api.c   | 17 +++++++-------
 net/sched/cls_api.c   | 63 ++++++++++++++++++++++++++++++++-------------------
 3 files changed, 48 insertions(+), 34 deletions(-)

-- 
2.13.0

From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH net-next v4 0/8] net_sched: some cleanup and improvments
Date: Sun, 15 Dec 2013 20:15:03 -0800
Message-ID: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:35582 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265Ab3LPEPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 23:15:22 -0500
Received: by mail-pd0-f177.google.com with SMTP id q10so4791915pdj.36
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 20:15:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are some cleanup and improvements for tc filters
and tc actions.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

v3 -> v4:
* fix tcf_exts_is_predicative()
* rename 'head' to 'actions'
* use spinlock instead of spinlock+RCU
* add two more patches

v2 -> v3:
* fix a typo introduced during rebase

v1 -> v2:
* fix a smatch warning and a checkpatch warning
* add a cover letter
* add a missing synchronize_rcu()

Cong Wang (8):
  net_sched: remove get_stats from tc_action_ops
  net_sched: act: use standard struct list_head
  net_sched: mirred: remove action when the target device is gone
  net_sched: cls: refactor out struct tcf_ext_map
  net_sched: init struct tcf_hashinfo at register time
  net_sched: convert tcf_hashinfo to hlist and use spinlock
  net_sched: convert tc_action_ops to use struct list_head
  net_sched: convert tcf_proto_ops to use struct list_head

 include/net/act_api.h          |  43 ++++++---
 include/net/pkt_cls.h          |  37 ++++----
 include/net/sch_generic.h      |   2 +-
 include/net/tc_act/tc_mirred.h |   4 +-
 net/sched/act_api.c            | 198 +++++++++++++++++------------------------
 net/sched/act_csum.c           |  13 ++-
 net/sched/act_gact.c           |  13 ++-
 net/sched/act_ipt.c            |  21 +++--
 net/sched/act_mirred.c         |  31 +++----
 net/sched/act_nat.c            |  12 ++-
 net/sched/act_pedit.c          |  12 ++-
 net/sched/act_police.c         |  63 ++++++-------
 net/sched/act_simple.c         |  20 +++--
 net/sched/act_skbedit.c        |  13 ++-
 net/sched/cls_api.c            |  99 ++++++++++-----------
 net/sched/cls_basic.c          |  13 ++-
 net/sched/cls_bpf.c            |  13 ++-
 net/sched/cls_cgroup.c         |  14 ++-
 net/sched/cls_flow.c           |  13 ++-
 net/sched/cls_fw.c             |  13 ++-
 net/sched/cls_route.c          |  13 ++-
 net/sched/cls_rsvp.h           |  13 ++-
 net/sched/cls_tcindex.c        |  17 ++--
 net/sched/cls_u32.c            |  13 ++-
 24 files changed, 320 insertions(+), 383 deletions(-)

-- 
1.8.1.4

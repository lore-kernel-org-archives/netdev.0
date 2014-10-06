From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v1 0/3] net sched rcu updates
Date: Sun, 05 Oct 2014 21:27:25 -0700
Message-ID: <20141006042335.6010.27000.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:45920 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855AbaJFE1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 00:27:45 -0400
Received: by mail-ob0-f178.google.com with SMTP id wn1so3372048obc.9
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 21:27:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the use of tcf_proto from RCU callbacks it requires
moving the unbind calls out of the callbacks and removing the
tcf_proto argument from the tcf_em_tree_destroy().

This is a rework of two previous series and addresses comments
from Cong. And should apply against latest net-next.

The previous series links below for reference:

(1/2) net: sched: do not use tcf_proto 'tp' argument from call_rcu
http://patchwork.ozlabs.org/patch/396149/ 

(2/2) net: sched: replace ematch calls to use struct net
http://patchwork.ozlabs.org/patch/396150/


net: sched: cls_cgroup tear down exts and ematch from rcu callback
http://patchwork.ozlabs.org/patch/396307/

---

John Fastabend (3):
      net: sched: remove tcf_proto from ematch calls
      net: sched: cls_cgroup tear down exts and ematch from rcu callback
      net: sched: do not use tcf_proto 'tp' argument from call_rcu


 include/net/pkt_cls.h  |   10 +++++-----
 net/sched/cls_basic.c  |    7 ++++---
 net/sched/cls_bpf.c    |    4 +++-
 net/sched/cls_cgroup.c |    6 ++----
 net/sched/cls_flow.c   |    4 ++--
 net/sched/cls_fw.c     |    5 +++--
 net/sched/cls_route.c  |    8 +++++---
 net/sched/em_canid.c   |    4 ++--
 net/sched/em_ipset.c   |    7 +++----
 net/sched/em_meta.c    |    4 ++--
 net/sched/em_nbyte.c   |    2 +-
 net/sched/em_text.c    |    4 ++--
 net/sched/ematch.c     |   10 ++++++----
 13 files changed, 40 insertions(+), 35 deletions(-)

-- 
Signature

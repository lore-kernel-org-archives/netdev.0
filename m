From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net 0/9] net/sched: init failure fixes
Date: Wed, 30 Aug 2017 12:48:56 +0300
Message-ID: <1504086545-7777-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: edumazet@google.com, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, roopa@cumulusnetworks.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:33837 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751298AbdH3JtS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 05:49:18 -0400
Received: by mail-wm0-f49.google.com with SMTP id 137so334135wmj.1
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 02:49:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
I went over all qdiscs' init, destroy and reset callbacks and found the
issues fixed in each patch. Mostly they are null pointer dereferences due
to uninitialized timer (qdisc watchdog) or double frees due to ->destroy
cleaning up a second time. There's more information in each patch.
I've tested these by either sending wrong attributes from user-spaces, no
attributes or by simulating memory alloc failure where applicable. Also
tried all of the qdiscs as a default qdisc.

Most of these bugs were present before commit 87b60cfacf9f, I've tried to
include proper fixes tags in each patch.

I haven't included individual patch acks in the set, I'd appreciate it if
you take another look and resend them.

Thanks,
 Nik

Nikolay Aleksandrov (9):
  sch_htb: fix crash on init failure
  sch_multiq: fix double free on init failure
  sch_hhf: fix null pointer dereference on init failure
  sch_hfsc: fix null pointer deref and double free on init failure
  sch_cbq: fix null pointer dereferences on init failure
  sch_fq_codel: avoid double free on init failure
  sch_netem: avoid null pointer deref on init failure
  sch_sfq: fix null pointer dereference on init failure
  sch_tbf: fix two null pointer dereferences on init failure

 net/sched/sch_cbq.c      | 10 +++++++---
 net/sched/sch_fq_codel.c |  4 +---
 net/sched/sch_hfsc.c     | 10 +++-------
 net/sched/sch_hhf.c      |  3 +++
 net/sched/sch_htb.c      |  5 +++--
 net/sched/sch_multiq.c   |  7 +------
 net/sched/sch_netem.c    |  4 ++--
 net/sched/sch_sfq.c      |  6 +++---
 net/sched/sch_tbf.c      |  5 +++--
 9 files changed, 26 insertions(+), 28 deletions(-)

-- 
2.1.4

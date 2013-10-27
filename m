From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/2] net_sched: Remove broken tc actions
Date: Sun, 27 Oct 2013 06:40:54 -0700
Message-ID: <87fvrmu909.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, alexander.h.duyck@intel.com,
	jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34788 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074Ab3J0NlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 09:41:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While auditing the code to make certain it would be safe to enable the
user namespace root to use tc actions I stumbled on the strange fact
that two of the tc modules in the kernel have been broken for more
years than I care to think about.

In particular neither of these two modules implements the tc_action_ops
lookup method.  Which means that in practice neither RTM_GETACTION nor
RTM_DELACTION work.  And with RTM_DELACTION broken that looks like a
permanent leak of kernel memory to me.

A leak I am not happy at root having and certainly not something I want
to allow unprivileged users access to.

On the premise that 5+ years is too long to wait for someone to notice,
complain and get this code fixed let's just remove these broken tc
modules.

Eric W. Biederman (2):
      net_sched: Remove broken act_skbedit
      net_sched: Remove broken act_simple

 include/net/tc_act/tc_defact.h         |   14 --
 include/net/tc_act/tc_skbedit.h        |   36 -----
 include/uapi/linux/tc_act/Kbuild       |    2 -
 include/uapi/linux/tc_act/tc_defact.h  |   19 ---
 include/uapi/linux/tc_act/tc_skbedit.h |   46 -------
 net/sched/Kconfig                      |   25 ----
 net/sched/Makefile                     |    2 -
 net/sched/act_simple.c                 |  225 --------------------------------
 net/sched/act_skbedit.c                |  224 -------------------------------
 9 files changed, 0 insertions(+), 593 deletions(-)

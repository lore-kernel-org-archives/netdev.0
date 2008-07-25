From: Ingo Molnar <mingo@elte.hu>
Subject: [patch] signalfd: fix undefined reference to `compat_sys_signalfd4'
Date: Fri, 25 Jul 2008 13:06:16 +0200
Message-ID: <20080725110616.GA29447@elte.hu>
References: <200805062118.m46LI7hn004047@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:55744 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750706AbYGYLGm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 07:06:42 -0400
Content-Disposition: inline
In-Reply-To: <200805062118.m46LI7hn004047@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ulrich Drepper <drepper@redhat.com> wrote:

> This patch adds the new signalfd4 syscall.  It extends the old 
> signalfd syscall by one parameter which is meant to hold a flag value.  
> In this patch the only flag support is SFD_CLOEXEC which causes the 
> close-on-exec flag for the returned file descriptor to be set.

this patch causes the following build failure on !CONFIG_SIGNALFD:

 arch/x86/ia32/built-in.o: In function `ia32_sys_call_table':
 (.rodata+0xa38): undefined reference to `compat_sys_signalfd4'
 make: *** [.tmp_vmlinux1] Error 1

tested fix below.

	Ingo

-------------->
>From 72dc5d608422e80ad5e1aac2d7b9bd16b7dbc6e0 Mon Sep 17 00:00:00 2001
From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 25 Jul 2008 13:02:37 +0200
Subject: [PATCH] signalfd: fix undefined reference to `compat_sys_signalfd4'

fix:

arch/x86/ia32/built-in.o: In function `ia32_sys_call_table':
(.rodata+0xa38): undefined reference to `compat_sys_signalfd4'

on !CONFIG_SIGNALFD.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 kernel/sys_ni.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 55eca15..08d6e1b 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -160,6 +160,7 @@ cond_syscall(sys_ioprio_get);
 cond_syscall(sys_signalfd);
 cond_syscall(sys_signalfd4);
 cond_syscall(compat_sys_signalfd);
+cond_syscall(compat_sys_signalfd4);
 cond_syscall(sys_timerfd_create);
 cond_syscall(sys_timerfd_settime);
 cond_syscall(sys_timerfd_gettime);

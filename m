From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bug 10238] Re: [PATCH] Re: netconsole still hangs
Date: Tue, 18 Mar 2008 22:05:42 +0100
Message-ID: <20080318210542.GA2764@ami.dom.local>
References: <20080318015006.3f0efb8e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, rjw@sisk.pl,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:9028 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932518AbYCSUVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 16:21:44 -0400
Received: by nf-out-0910.google.com with SMTP id g13so330635nfb.21
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 13:21:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080318015006.3f0efb8e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote, On 03/18/2008 09:50 AM:
...
> As a last resort.  But it'd surely be better if a net developer could
> reproduce this and do some work on it.  It's bog-trivial to reproduce here
> and afaik nobody has even tried.  Perhaps you have...
> 
> service syslog stop
> while true
> do
> 	echo t > /proc/sysrq-trigger
> done
> 
> and that's it.

Alas my testing possibilities, especially with real network, are very
limited, I can confirm: yes, the above test really hangs my box, yet
with syslog on and netconsole off. So, maybe I miss something, but I
don't understand why do you expect netconsole should endure this?

IMHO, after the below patch to sched.c you can't compare netconsole to
2.6.24 with this sysrq-trigger test; any bugs found with this could be
something old and not necessarily in netconsole (could be only exposed
by netconsole like this earlier mentioned, unexplained, probably after
double kfree OOPS).

Regards,
Jarek P.

From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 25 Jan 2008 20:08:34 +0000 (+0100)
Subject: sched: print backtrace of running tasks too
X-Git-Tag: v2.6.25-rc1~1237^2~3
X-Git-Url: http://git.kernel.org/?p=linux%2Fkernel%2Fgit%2Ftorvalds%2Flinux-2.6.git;a=commitdiff_plain;h=5fb5e6de55860a99c2d8fe7e0c8222d5c53d8464

sched: print backtrace of running tasks too

The attached patch is something really simple that can sometimes help
in getting more info out of a hung system.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---

diff --git a/kernel/sched.c b/kernel/sched.c
index 4d3a5a7..524285e 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -5161,8 +5161,7 @@ void sched_show_task(struct task_struct *p)
 	printk(KERN_CONT "%5lu %5d %6d\n", free,
 		task_pid_nr(p), task_pid_nr(p->real_parent));
 
-	if (state != TASK_RUNNING)
-		show_stack(p, NULL);
+	show_stack(p, NULL);
 }
 
 void show_state_filter(unsigned long state_filter)

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=5fb5e6de55860a99c2d8fe7e0c8222d5c53d8464

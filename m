From: sukadev@us.ibm.com
Subject: Re: [PATCH] Remove write-only variable from pktgen_thread
Date: Wed, 29 Aug 2007 14:33:56 -0700
Message-ID: <20070829213356.GC18542@us.ibm.com>
References: <46D572FA.9090302@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Oleg Nesterov <oleg@tv-sign.ru>,
	Linux Containers <containers@lists.osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:39936 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013AbXH2Vd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 17:33:58 -0400
Content-Disposition: inline
In-Reply-To: <46D572FA.9090302@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov [xemul@openvz.org] wrote:
| The pktgen_thread.pid is set to current->pid and is never used
| after this. So remove this at all.
| 
| Found during isolating the explicit pid/tgid usage.
| 
| Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Good observation that its not being used :-)

Acked-by: Sukadev Bhattiprolu <sukadev@us.ibm.com>
| 
| ---
| 
| diff --git a/net/core/pktgen.c b/net/core/pktgen.c
| index 3a3154e..93695c2 100644
| --- a/net/core/pktgen.c
| +++ b/net/core/pktgen.c
| @@ -380,7 +380,6 @@ struct pktgen_thread {
| 	/* Field for thread to receive "posted" events terminate, stop ifs 
| 	etc. */
| 
| 	u32 control;
| -	int pid;
| 	int cpu;
| 
| 	wait_queue_head_t queue;
| @@ -3462,8 +3461,6 @@ static int pktgen_thread_worker(void *ar
| 
| 	init_waitqueue_head(&t->queue);
| 
| -	t->pid = current->pid;
| -
| 	pr_debug("pktgen: starting pktgen/%d:  pid=%d\n", cpu, 
| 	task_pid_nr(current));
| 
| 	max_before_softirq = t->max_before_softirq;

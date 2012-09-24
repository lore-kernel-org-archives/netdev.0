From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next v1] gianfar: Change default HW Tx queue
 scheduling mode
Date: Mon, 24 Sep 2012 16:25:40 -0400 (EDT)
Message-ID: <20120924.162540.215430525974484885.davem@redhat.com>
References: <1348475948-22721-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4495 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757947Ab2IXUZn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 16:25:43 -0400
In-Reply-To: <1348475948-22721-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Mon, 24 Sep 2012 11:39:08 +0300

> This is primarily to address transmission timeout occurrences, when
> multiple H/W Tx queues are being used concurrently. Because in
> the priority scheduling mode the controller does not service the
> Tx queues equally (but in ascending index order), Tx timeouts are
> being triggered rightaway for a basic test with multiple simultaneous
> connections like:
> iperf -c <server_ip> -n 100M -P 8
> 
> resulting in kernel trace:
> NETDEV WATCHDOG: eth1 (fsl-gianfar): transmit queue <X> timed out
> ------------[ cut here ]------------
> WARNING: at net/sched/sch_generic.c:255
> ...
> and controller reset during intense traffic, and possibly further
> complications.
> 
> This patch changes the default H/W Tx scheduling setting (TXSCHED)
> for multi-queue devices, from priority scheduling mode to a weighted
> round robin mode with equal weights for all H/W Tx queues, and
> addresses the issue above.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied, thanks.

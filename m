From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Fri, 14 Jun 2013 00:29:13 +0200
Message-ID: <1371162553.8335.28.camel@jlt4.sipsolutions.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
	 <20130613222411.GA5396@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com, romieu@fr.zoreil.com
To: Johannes Stezenbach <js@sig21.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:48072 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757878Ab3FMW3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 18:29:22 -0400
In-Reply-To: <20130613222411.GA5396@sig21.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-14 at 00:24 +0200, Johannes Stezenbach wrote:

> [    0.939189] INFO: trying to register non-static key.
> [    0.939787] the code is fine but needs lockdep annotation.
> [    0.940387] turning off the locking correctness validator.
> [    0.940992] Pid: 1, comm: swapper/0 Not tainted 3.9.6 #2
> [    0.941589] Call Trace:
> [    0.942179]  [<ffffffff8108cead>] __lock_acquire.isra.24+0x710/0xa47
> [    0.942781]  [<ffffffff8108d87f>] lock_acquire+0xc0/0x142

I *think* this is probably the missing spin_lock_init I had forgotten.

> and after "ifconfig eth0 up":
> 
> [  539.482153] alx 0000:03:00.0: irq 45 for MSI/MSI-X
> [  539.482249] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
> [  539.483169] alx 0000:03:00.0 eth0: NIC Up: 1 Gbps Full
> [  539.483354] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> [  544.801438] ------------[ cut here ]------------
> [  544.801458] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x19b/0x201()
> [  544.801462] Hardware name: System Product Name
> [  544.801464] NETDEV WATCHDOG: eth0 (alx): transmit queue 0 timed out

Hmm, this is odd. I might just be forgetting to set something.

> 03:00.0 Ethernet controller: Qualcomm Atheros AR8161 Gigabit Ethernet (rev 08)

OTOH, I have a 8171, so maybe I messed up with my simplifications or it
simply doesn't work.

> Any idea what to try?

Does it still pass traffic after that? Or is it actually dead?

johannes

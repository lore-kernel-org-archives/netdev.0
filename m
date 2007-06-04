From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] Failover-friendly TCP retransmission
Date: 04 Jun 2007 16:55:13 +0200
Message-ID: <p738xazbwha.fsf@bingen.suse.de>
References: <XNM1$2$0$3$$2$8$4$A$2004314U46640bd2@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: noboru.obata.ar@hitachi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:48694 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752778AbXFDN6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 09:58:42 -0400
In-Reply-To: <XNM1$2$0$3$$2$8$4$A$2004314U46640bd2@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

noboru.obata.ar@hitachi.com writes:

> Please note first that I want to address physical failures by
> the failover-capable network devices, which are increasingly
> becoming important as Xen-based VM systems are getting popular.
> Reducing a single-point-of-failure (physical device) is vital on
> such VM systems.

Just you typically still have lots of other single points of failures in 
a single system, some of them quite less reliable than your typical
NIC. But at least it gives impressive demos when pulling ethernet cables @)

> 1. Network device layer detects a failure first and switch to a
>    backup device (say, in 20sec).
> 
> 2. TCP layer timeout & retransmission comes next, _hopefully_
>    before the application layer timeout.
> 
> 3. Application layer detects a network failure last (by, say,
>    30sec timeout) and may trigger a system-level failover.
> 
> It should be noted that the timeouts for #1 and #2 are handled
> independently and there is no relationship between them.

> If TCP retransmission misses the time frame between event #1 and
> #3 in Background above (between 20 and 30sec since network
> failure), a failure causes the system-level failover where the
> network-device-level failover should be enough.

You should probably make sure that the device ends up returning the
right NET_XMIT_* code for such drops to TCP, in particular
NET_XMIT_DROP. This might require slight driver interface
changes. Also right now it only affects the congestion window, I think, 
it  might be reasonable to let it affect the timer backoff too.

-Andi

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 29 Feb 2016 10:24:39 -0800
Message-ID: <1456770279.648.85.camel@edumazet-ThinkPad-T530>
References: <56D1E8B6.6090003@hurleysoftware.com>
	 <1456638957.3676.12.camel@gmail.com>
	 <20160228170109.GA16322@electric-eye.fr.zoreil.com>
	 <1456721889.3488.67.camel@gmail.com> <56D45DAF.5070709@hurleysoftware.com>
	 <1456759153.648.61.camel@edumazet-ThinkPad-T530>
	 <56D469B2.2070707@hurleysoftware.com>
	 <1456762914.648.76.camel@edumazet-ThinkPad-T530>
	 <56D48869.1000106@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <umgwanakikbuti@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34902 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbcB2SZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 13:25:42 -0500
In-Reply-To: <56D48869.1000106@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On lun., 2016-02-29 at 10:05 -0800, Peter Hurley wrote:

> While I appreciate the attempt, that's not the problem.
> 
> Just to be clear
> 
> 		if (time_before(jiffies, end) && !need_resched() &&
> 		    --max_restart)
> 			goto restart;
> 
> aborts softirq *even if 0ns have elapsed*, if NET_RX has woken a process.


Sure, now remove the 1st and 2nd condition.

You would still 'abort' (ie wakeup ksoftirqd really) when --max_restart
becomes 0

So, instead of some subtle load dependent bug, you know have a reliable
trigger.

The fact it took 3 years for someone to complain about this change
should tell us something really.

The only way for your bug to hide would be to remove all the 'break
infinite loop' logic.

And this is not going to happen.

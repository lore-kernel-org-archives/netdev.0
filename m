From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: what are txqueuelen and nic ring parameters exactly?
Date: Thu, 13 Jan 2011 10:21:13 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1101131009420.17215@ask.diku.dk>
References: <AANLkTi=_hbmvgO9wrX6sg7Q=Wh+iVaqGdga08M-ypqae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: MK <stardust496@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:35054 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752713Ab1AMJVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jan 2011 04:21:18 -0500
In-Reply-To: <AANLkTi=_hbmvgO9wrX6sg7Q=Wh+iVaqGdga08M-ypqae@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Jan 2011, MK wrote:

> I often come across two variables that can be tuned for networking -
>
> 1) txqueuelen (via ifconfig )
> 2) NIC ring parameters for tx and rx (via ethtool)
>
> Can someone please tell me where these queues are exactly? Are both
> the same (seems not since their current values are different on my
> computer) . Is txqueuelen somehow part of the linux networking
> subsystem whereas the other is purely a h/w device construct?

You are spot on.

The txqueuelen is a Linux network stack thing, and is related to the 
traffic control subsystem, BUT only when using the default qdisc 
(pfifo_fast or mq).
If you add another qdisc, then its that specific qdiscs limits which 
counts, not the device txqueuelen.

When tuning these queue lengths, you probably decrease these queue sizes, 
NOT increase!

See the bufferbloat debate:
   http://netoptimizer.blogspot.com/2010/12/buffer-bloat-calculations.html
   http://netoptimizer.blogspot.com/2011/01/bufferbloat-wireless-is-worse-than.html
   http://gettys.wordpress.com/bufferbloat-faq/

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------

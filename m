From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] NET: Fix locking issues in PPP, 6pack, mkiss and strip
 line disciplines.
Date: Mon, 13 Jul 2009 20:27:25 +0100
Message-ID: <20090713202725.32618249@lxorguk.ukuu.org.uk>
References: <20090712234854.10cfcef2@lxorguk.ukuu.org.uk>
	<20090712.210730.170014470.davem@davemloft.net>
	<20090713091928.7e89bab8@lxorguk.ukuu.org.uk>
	<20090713.103139.188324296.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org,
	guido@trentalancia.com, paulus@samba.org,
	linux-hams@vger.kernel.org, hans@esrac.ele.tue.nl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:58690 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755196AbZGMT3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 15:29:40 -0400
In-Reply-To: <20090713.103139.188324296.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>	spin_lock_bh() --> BH disable in hard IRQ, OH NOEZ!

No I didn't see his original message just the patch - his original is a
fixed bug.

> mkiss_receive_buf(), the problematic code path, is invoked by
> the TTY layer directly from LDISC flushing and the TTY device's
> IRQ handler here.
> 
> How does networking's TX policy have anything to do with this?

Sorry I'd been looking at the other side stuff with ppp which is a
sleeping v bh issue and misinterpreted Ralf's post.

In fact Ralf's fix isn't needed. The incorrect uses of tty->low_latency
all got killed and the pty code got rewritten which was the other case
that could occur.


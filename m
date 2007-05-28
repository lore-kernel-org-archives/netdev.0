From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PCNET32] Lock solid with netconsole
Date: Mon, 28 May 2007 23:05:55 +0200
Message-ID: <20070528210555.GA4494@electric-eye.fr.zoreil.com>
References: <JIRC73$62E39331D73FCF49870995034400C560@laposte.net> <20070528183148.GA10009@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Emmanuel Fust? <emmanuel.fuste@laposte.net>,
	tsbogend <tsbogend@alpha.franken.de>,
	pcnet32 <pcnet32@verizon.net>, netdev <netdev@vger.kernel.org>
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58484 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822AbXE1VIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 17:08:00 -0400
Content-Disposition: inline
In-Reply-To: <20070528183148.GA10009@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennart Sorensen <lsorense@csclub.uwaterloo.ca> :
[...]
> Hmm, I have been seeing lockups too and asked about doing something
> almost exactly the same as this recently, but was told that it shouldn't
> need irqs disabled at this point.

Yes. The patch should not be needed.

OTOH, it is still interesting to know if it makes a difference, though
I do not really figure why afterwards (the local irq thread could get
interrupted and the interrupting thread printk() before returning but
I doubt that it is realistic).

> Well if it makes netconsole more stable, I think I will try adding it to
> and see if it makes the problems go away for good (my problem only happens
> at random and can be days between it happening).

One must ensure that pcnet32_{interrupt/hard_start_xmit} do not try to
printk() too.

-- 
Ueimor

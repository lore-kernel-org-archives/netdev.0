From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 0/9]: tcp-2.6 patchset
Date: Sun, 27 May 2007 19:56:02 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705271933440.2832@kivilampi-30.cs.helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070526.164418.115928217.davem@davemloft.net>
 <Pine.LNX.4.64.0705271039060.2532@kivilampi-30.cs.helsinki.fi>
 <20070527.021104.74747736.davem@davemloft.net>
 <Pine.LNX.4.64.0705271319310.2663@kivilampi-30.cs.helsinki.fi>
 <20070527140430.GA30299@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: Baruch Even <baruch@ev-en.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52820 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755396AbXE0Q4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 12:56:07 -0400
In-Reply-To: <20070527140430.GA30299@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 27 May 2007, Baruch Even wrote:

> * Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi> [070527 14:16]:
> > 
> > Thus, my original question basically culminates in this: should cc
> > modules be passed number of packets acked or number of skbs acked?
> > ...The latter makes no sense to me unless the value is intented to
> > be interpreted as number of timestamps acked or something along those 
> > lines. ...I briefly tried looking up for documentation for cc module 
> > interface but didn't find anything useful about this, and thus asked in 
> > the first place...
> 
> At least the htcp module that I wrote assumes that the number is actual
> number of tcp packets so GSO should be considered.

Thanks for the info! It is what I suspected... ...I'll write a patch for 
it tomorrow against net-2.6... Dave, beware that it will partially 
overlap with the changes made in the patch 8, so you might choose to put 
the patch 8 on hold until this issue is first resolved...

> The consequences of this bug are not too large but it does make all
> congestion control algorithms a lot less aggressive. On my machines GSO
> is disabled by default (e1000 at 100mbps & Tigon3 @ 1Gbps).

Agreed, that's my impression too. However, some algorithms do things
like > 0 checks for it, so it might disturb their dynamics even more
than in the "too small value" cases...


-- 
 i.

From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 0/9]: tcp-2.6 patchset
Date: Tue, 29 May 2007 23:07:00 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705292150390.23565@kivilampi-30.cs.helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070526.164418.115928217.davem@davemloft.net>
 <Pine.LNX.4.64.0705271039060.2532@kivilampi-30.cs.helsinki.fi>
 <20070527.021104.74747736.davem@davemloft.net>
 <Pine.LNX.4.64.0705271319310.2663@kivilampi-30.cs.helsinki.fi>
 <20070527140430.GA30299@galon.ev-en.org> <Pine.LNX.4.64.0705271933440.2832@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0705281253340.14736@kivilampi-30.cs.helsinki.fi>
 <20070529091415.03a14216@freepuppy>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-2138999917-1180465102=:23565"
Cc: Baruch Even <baruch@ev-en.org>, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34608 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757797AbXE2UHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2007 16:07:03 -0400
In-Reply-To: <20070529091415.03a14216@freepuppy>
Content-ID: <Pine.LNX.4.64.0705292256350.23565@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2138999917-1180465102=:23565
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0705292158461.23565@kivilampi-30.cs.helsinki.fi>

On Tue, 29 May 2007, Stephen Hemminger wrote:

> On Mon, 28 May 2007 13:27:03 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > On Sun, 27 May 2007, Ilpo Järvinen wrote:
> > 
> > [PATCH] [TCP]: Fix GSO ignorance of pkts_acked arg (cong.cntrl modules)
> 
> Yes, thanks for fixing this. Wonder how it affects measurements.

...It's a bit hard to tell since dynamics change so dramatically 
in > 0 check cases, the resulting behavior in too small value cases
may be easier to predict... It's possible that this could explain some 
anomalities you've been seeing in your measurements.

> > It is not very clear how SYN segments should be handled, so I
> > choose to follow the previous implementation in this respect.
> 
> Since we don't invoke congestion control modules until after the SYN
> handshake this is not a problem.

Just curious, do you mean that cc modules cannot measure, e.g., initial
RTT through this mechanism (though they could do that in init() cb then
I suppose)... Or do you mean that they are called already for the ACK
that completes the SYN handshake and therefore its skb is being cleaned 
from the queue right now (this is the case I above refer to)? 
In the first case the decrementer code is NOP. If the latter, then it
is just interface specification question, i.e., if SYNs are treated as 
zero or one in num_acked for the pkts_acked callback (I have no opinion
on this but was just trying to make sure cc modules get what they
expect :-)). 


-- 
 i.
---696243703-2138999917-1180465102=:23565--

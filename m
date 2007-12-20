From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TSO trimming question
Date: Thu, 20 Dec 2007 14:35:19 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712201417470.11007@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712192336130.27945@kivilampi-30.cs.helsinki.fi>
 <20071219.235450.170670042.davem@davemloft.net>
 <Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi>
 <20071220.040037.48002365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1385512550-1198153698=:11007"
Cc: Netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33630 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760130AbXLTMfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 07:35:21 -0500
In-Reply-To: <20071220.040037.48002365.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0712201428220.11007@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1385512550-1198153698=:11007
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712201428221.11007@kivilampi-30.cs.helsinki.fi>

On Thu, 20 Dec 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Thu, 20 Dec 2007 13:40:51 +0200 (EET)
> 
> > That's not the only case, IMHO if there's odd boundary due to 
> > snd_una+snd_wnd - skb->seq limit (done in tcp_window_allows()), we don't 
> > consider it as odd but break the skb at arbitary point resulting
> > two small segments to the network, and what's worse, when the later skb 
> > resulting from the first split is matching skb->len < limit check as well 
> > causing an unnecessary small skb to be created for nagle purpose too, 
> > solving it fully requires some thought in case the mss_now != mss_cache 
> > even if non-odd boundaries are honored in the middle of skb.
> 
> In the most ideal sense, tcp_window_allows() should probably
> be changed to only return MSS multiples.

That's what Herbert suggested already, I'll send a patch later
on... :-)

> Unfortunately this would add an expensive modulo operation,
> however I think it would elimiate this problem case.

Yes. Should we still call tcp_minshall_update() if split in the middle of 
wq results in smaller than MSS tail (occurs only if mss_now != mss_cache)?

-- 
 i.
---696243703-1385512550-1198153698=:11007--

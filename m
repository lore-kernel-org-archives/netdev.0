From: David Miller <davem@davemloft.net>
Subject: Re: TSO trimming question
Date: Wed, 19 Dec 2007 23:55:27 -0800 (PST)
Message-ID: <20071219.235527.231281143.davem@davemloft.net>
References: <Pine.LNX.4.64.0712200000050.27945@kivilampi-30.cs.helsinki.fi>
	<E1J5C38-0004kh-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60675
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759216AbXLTHz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 02:55:29 -0500
In-Reply-To: <E1J5C38-0004kh-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 20 Dec 2007 11:26:18 +0800

> Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
> >
> >> is the limitting factor? For latter IMHO this would be necessary:
> >> 
> >>                       if (skb->len > limit)
> >>                               limit -= limit % mss_now;
> 
> Good catch! But how about putting this logic into tcp_window_allows
> since then you can avoid the divide for the case when we're not
> bound by the receiver window.

Because the purpose of this calculation is different, as I
described in my other reply, I don't think this change is
correct, regardless of where it is placed :-)

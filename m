From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 10:15:34 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi>
References: <E1LCl3n-00052k-6h@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, ptesarik@suse.cz
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59797 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbYLQIPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 03:15:37 -0500
In-Reply-To: <E1LCl3n-00052k-6h@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Dec 2008, Herbert Xu wrote:

> Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > 
> > I should have noticed this earlier... :-) The previous solution
> > to URG+GSO/TSO will cause SACK block tcp_fragment to do zig-zig
> > patterns, or even worse, a steep downward slope into packet
> > counting because each skb pcount would be truncated to pcount
> > of 2 and then the following fragments of the later portion would
> > restore the window again.
> 
> How about just handling it, URG isn't that hard.  If anyone is
> bored you can do this for GRO as well.
>
> tcp: Add GSO support for urgent data
> 
> When segmenting packets with urgent data we need to clear the
> urgent flag/pointer once we move past the end of the urgent data.
> This was not handled correctly in GSO or (presumably) in existing
> hardware.
>
> This patch adds a new GSO flag for TCP urgent data and also fixes
> its handling in GSO.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

This is certainly nice and possible but as mention earlier, the harder 
problem is that the urg_ptr is only 16-bits so there will be still be 
problem if the urgent seq-64k mark is within a super-skb as tail segments 
need urg while the head ones won't. I think we would need out-of-band 
means to communicate the extra bit (17th) from tcp if we want to solve 
that one. It would be rather easy to change TCP to only do splitting for 
that particular skb though and keep everything else intact.

...The same consideration applies to gro as well.


-- 
 i.

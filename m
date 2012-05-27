From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: compute a more reasonable default ip6_rt_max_size
Date: Sun, 27 May 2012 15:18:28 +0200
Message-ID: <1338124708.3670.11.camel@edumazet-glaptop>
References: <4FC0063E.8080209@fb.com>
	 <20120525.185131.2017517041016424794.davem@davemloft.net>
	 <4FC01F1B.1080009@fb.com>
	 <20120525.201150.1782581593120395710.davem@davemloft.net>
	 <4FC02777.5070003@fb.com> <1338003580.10135.6.camel@edumazet-glaptop>
	 <4FC1A57A.7080807@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arun Sharma <asharma@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:32888 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975Ab2E0NSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2012 09:18:33 -0400
In-Reply-To: <4FC1A57A.7080807@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-05-26 at 20:54 -0700, Arun Sharma wrote:
> On 5/25/12 8:39 PM, Eric Dumazet wrote:
> >
> > But your patch is not a  "modest increase", so whats the deal ?
> >
> > A modest increase would be 8192 instead of 4096, regardless of RAM size.
> >
> 
> Yes - 8192 solves our immediate problem, but I was worrying that the 
> problem might resurface as ipv6 adoption becomes more widespread.
> 

Going from 4096 to 8192 is modest increase. If you put 65536, it should
be enough for the next years.

Your patch was increasing 4096 to 524288 (for 2GB of ram), which sounds
not modest at all.

> We were testing a pre-3.0 kernel that didn't have Dave's DST_NOCOUNT 
> patch. Will retest with that patch applied.

Good

> 
>  > More over, a boot parameter to tweak it is absolutely not needed
> 
> Agreed. Will remove that part.
> 
> Still not sure why you'd like to go for one size regardless of 
> totalram_pages.

Because size of IPv6 route table is not depending on RAM size, but on
number or IPv6 routes.

A router runs a piece of software complex enough to be able to adjust
the limit when needed, don't you think so ?

Your patch basically removes the whole idea of having a limit in the
first place. Why do we have a limit if you set it to four order of
magnitudes bigger than necessary ?

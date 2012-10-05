From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: kernel 3.2.27 on arm: WARNING: at mm/page_alloc.c:2109
 __alloc_pages_nodemask+0x1d4/0x68c()
Date: Fri, 05 Oct 2012 17:15:51 +0200
Message-ID: <1349450151.28867.33.camel@sakura.staff.proxad.net>
References: <20120829002548.GA7063@aldebaran.gro-tsen.net>
	 <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
	 <1349366521.2532.12.camel@sakura.staff.proxad.net>
	 <1349368171.16011.79.camel@edumazet-glaptop>
	 <1349422868.21172.38.camel@edumazet-glaptop>
	 <1349434194.16710.44.camel@sakura.staff.proxad.net>
	 <1349439732.21172.52.camel@edumazet-glaptop>
	 <1349441509.28867.17.camel@sakura.staff.proxad.net>
	 <1349442173.21172.66.camel@edumazet-glaptop>
	 <1349448659.28867.27.camel@sakura.staff.proxad.net>
	 <1349449440.21172.118.camel@edumazet-glaptop>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: David Madore <david+ml@madore.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:55998 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750973Ab2JEPPw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2012 11:15:52 -0400
In-Reply-To: <1349449440.21172.118.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2012-10-05 at 17:04 +0200, Eric Dumazet wrote:
> 
> 
> What I plan is to not shrink size, unless specifically asked.
> 
> Its 3.8 material anyway, so a stable fix is needed on skb_recycle()
> and NET_SKB_PAD minimal value.

You think removing skb_recycle() is too big a change for stable ?

Driver change is simple, as recycling is not guaranteed today you have
this:

 if (!try_recycle(skb))
    skb = alloc_skb()
> 
we just remove the try_recycle part, we are not adding any new code
path.


I'm not the right person to give you a correct NET_SKB_PAD value, I have
a lot of out of tree patches in my kernels, some custom drivers as well
that needs quite a lot of headroom, and uncommon network setup.

-- 
Maxime

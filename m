From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen/netfront: improve truesize tracking
Date: Mon, 7 Jan 2013 14:22:45 +0000
Message-ID: <1357568565.7989.96.camel@zakaz.uk.xensource.com>
References: <1355838711-5473-1-git-send-email-ian.campbell@citrix.com>
	 <1355843525.9380.18.camel@edumazet-glaptop>
	 <1355844398.14620.254.camel@zakaz.uk.xensource.com>
	 <55633610.20121219123427@eikelenboom.it>
	 <1355933869.21834.13.camel@edumazet-glaptop>
	 <1797374383.20121220135139@eikelenboom.it>
	 <1356017968.21834.2859.camel@edumazet-glaptop>
	 <1609010645.20121221122100@eikelenboom.it> <50D4AB87.8050601@hp.com>
	 <561084196.20130103214030@eikelenboom.it>
	 <1357566063.7989.68.camel@zakaz.uk.xensource.com>
	 <606842712.20130107151133@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	annie li <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:27227 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884Ab3AGOWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 09:22:48 -0500
In-Reply-To: <606842712.20130107151133@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-07 at 14:11 +0000, Sander Eikelenboom wrote:
> Monday, January 7, 2013, 2:41:03 PM, you wrote:
> 
> > On Thu, 2013-01-03 at 20:40 +0000, Sander Eikelenboom wrote:
> >> Friday, December 21, 2012, 7:33:43 PM, you wrote:
> >> 
> >> > I'm guessing that trusize checks matter more on the "inbound" path than 
> >> > the outbound path?  If that is indeed the case, then instead of, or in 
> >> > addition to using the -s option to set the local (netperf side) socket 
> >> > buffer size, you should use a -S option to set the remote (netserver 
> >> > side) socket buffer size.
> >> 
> >> > happy benchmarking,
> >> 
> >> > rick jones
> >> 
> >> 
> >> OK, ran them with -S as well:
> 
> > Are these all from domU -> dom0 ? Did you try traffic going the other
> > way?
> 
> Yes running netperf in domU and netserver in dom0, but i must say i'm far from a netperf expert.
> So i don't even know for sure if the tests i ran give a good picture.
> 
> >> "current" is with netfront as is        (skb->truesize += skb->data_len - RX_COPY_THRESHOLD;)
> >> "patched" is with IanC's latest patch   (skb->truesize += PAGE_SIZE * skb_shinfo(skb)->nr_frags;)
> 
> skb->>truesize += skb->data_len - NETFRONT_SKB_CB(skb)->pull_to; is
> > probably more interesting to compare against since we know the current
> > one is buggy.
> 
> Will see if i can run against that as well, although i thought Eric
> said to prefer the "skb->truesize += PAGE_SIZE *
> skb_shinfo(skb)->nr_frags;"

Right, I meant to compare "PAGE_SIZE * skb_shinfo(skb)->nr_frags" vs
"skb->data_len - NETFRONT_SKB_CB(skb)->pull_to". TBH I trust Eric so I'm
inclined to just go with what he suggests.

Ian.

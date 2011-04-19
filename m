From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Add NAPI support to ll_temac driver
Date: Tue, 19 Apr 2011 14:14:58 +0100
Message-ID: <1303218898.3464.59.camel@localhost>
References: <4DAD5753.4040108@monstr.eu>
	 <1303209787.3480.9.camel@edumazet-laptop>
	 <1303215925.3464.54.camel@localhost>  <4DAD84B1.9020405@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:57483 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497Ab1DSNPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 09:15:02 -0400
In-Reply-To: <4DAD84B1.9020405@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-19 at 14:48 +0200, Michal Simek wrote:
> Ben Hutchings wrote:
> > On Tue, 2011-04-19 at 12:43 +0200, Eric Dumazet wrote:
> > [...]
> >> One possible way to get better performance is to change driver to
> >> allocate skbs only right before calling netif_rx(), so that you dont
> >> have to access cold sk_buff data twice (once when allocating skb and put
> >> it in ring buffer, a second time when receiving frame)
> >>
> >> drivers/net/niu.c is a good example for this (NAPI + netdev_alloc_skb()
> >> just in time + pull in skbhead only first cache line of packet)
> > [...]
> > 
> > If the hardware can do RX checksumming (it's not clear) then the driver
> > should pass the paged buffers into GRO and that will take care of skb
> > allocation as necessary.
> 
> Hardware supports RX and TX partial checksumming. I can enable it. The driver 
> has also this option and from my tests there is of course some performance 
> improvemetn.
> 
> Just for sure - here are links on documentation.
> http://www.xilinx.com/support/documentation/ip_documentation/xps_ll_temac.pdf
> or
> http://www.xilinx.com/support/documentation/ip_documentation/axi_ethernet/v2_01_a/ds759_axi_ethernet.pdf

I'm not going to read those.  Just providing brief advice.

> About SKB allocation. I fixed our non mainline driver to allocate skb based on 
> current mtu size. Mainline driver allocate max mtu (9k). This has also impact on 
> performance because Microblaze works with smaller SKBs.
> 
> Can you please be more specific about passing the paged buffers into GRO?
> Or point me to any documentation or code which can help me to understand what 
> that means.

You would use napi_get_frags() to get a new or recycled skb, fill in
skb->frags, then call napi_gro_frags() to pass it into GRO.  The benet,
cxgb3 and sfc drivers do this.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: question about UFO behavior for bridge device
Date: Fri, 13 May 2011 14:06:52 +0100
Message-ID: <1305292012.4065.441.camel@localhost>
References: <4DCCF803.5020805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51027 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759242Ab1EMNGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 09:06:55 -0400
In-Reply-To: <4DCCF803.5020805@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-05-13 at 17:21 +0800, Shan Wei wrote:
> UDP protocol creates a big packet(skb) in which the data length is greater than MTU.
> 
> If device(eth0, lo) does not supports UFO, This big skb will be fragmented to
> many fragments in IP protocol, and fragments are sent one by one by device.
> 
> But, if device(eth0, lo) supports UFO, IP protocol don't fragment it, and
> device directly sends it out.
> 
> For bridge device which enable UFO, and Ethernet device(eth0) which not 
> support UFO, IP protocol also doesn't fragment it, and bridge forwards original
> skb to eth0. For this UFO disabled eth0, kernel needs to perform segmentation
> on so big skb in dev_gso_segment(), and link segmented skbs to next field
> of original skb. Then device sends segmented skbs out, but not original skb.

Right, it does that just before calling the driver's ndo_start_xmit().

> But, actually, i saw original big skb in eth0's tcpdump file, but not segmented skbs.
> The behavior is right or what we want?
> Is there anything missed about my analysis?

I assume that packet capturing is handled earlier in the transmit path.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


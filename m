From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: VLAN driver question
Date: Fri, 21 Jun 2013 16:42:31 +0100
Message-ID: <1371829351.3570.48.camel@bwh-desktop.uk.level5networks.com>
References: <51BF5F81.2040207@mentor.com>
	  <1371566484.1956.16.camel@bwh-desktop.uk.level5networks.com>
	  <51C1D4D7.1000904@mentor.com>
	 <1371659635.1956.45.camel@bwh-desktop.uk.level5networks.com>
	 <51C3527D.1030304@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23564 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423053Ab3FUPmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 11:42:35 -0400
In-Reply-To: <51C3527D.1030304@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-20 at 20:05 +0100, Jim Baxter wrote:
[...]
> Thank you for that information, I have decided to extract the data
> before copying the data into the skb->data structure.
> 
> This is the put of the packet showing my removal of the data correctly,
> however the network is not receiving any data on the VLAN.
> 
> - data buffer from the Network card
> ff ff ff ff ff ff 00 26 b9 d4 19 01 81 00 00 0a 08 06 00 01 08 00 06 04
> 00 01 00 26 b9 d4
> 
> - skb->data after I have only copied data to it and removed the vlan 4
> octet header using skb_copy_to_linear_data and
> skb_copy_to_linear_data_offset.
> ff ff ff ff ff ff 00 26 b9 d4 19 01 08 06 00 01 08 00 06 04 00 01 00 26
> b9 d4 19 01 c0 a8
> 
> - skb-data after eth_type_trans()
> 00 01 08 00 06 04 00 01 00 26 b9 d4 19 01 c0 a8 01 67 00 00 00 00 00 00
> c0 a8 01 64 00 00
> 
> After this point I send the packet into the network stack with:
> 	__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
> 
> 	napi_gro_receive(&fep->napi, skb);
> 
> Am I missing a kernel call or doing something wrong to cause the packet
> to be rejected in the kernel?

That looks about right to me, but perhaps vlan_tag has the wrong byte
order?  __vlan_hwaccel_put_tag() expects it in host byte order.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

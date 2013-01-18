From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: check if dereference of ipv6 header is safe
Date: Thu, 17 Jan 2013 21:08:24 -0500 (EST)
Message-ID: <20130117.210824.1695115756452352857.davem@davemloft.net>
References: <20130117035652.GB23782@order.stressinduktion.org>
	<20130118020612.GA14833@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56679 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab3ARCI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 21:08:27 -0500
In-Reply-To: <20130118020612.GA14833@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 18 Jan 2013 03:06:12 +0100

> On Thu, Jan 17, 2013 at 04:56:52AM +0100, Hannes Frederic Sowa wrote:
>> When ipip6_rcv gets called we are sure that we have a full blown
>> ipv4 packet header in the linear skb buffer (this is checked by
>> xfrm4_mode_tunnel_input). Because we dereference fields of the inner
>> ipv6 header we should actually check for the length of the sum of the
>> ipv4 and ipv6 header.
>> 
>> If the skb is too short this packet could very well be destined for
>> another tunnel. So we should notify the caller accordingly (albeit
>> currently xfrm4_mode_tunnel_input does not care; this could need another
>> patch).
> 
> While grepping for xfrm_tunnel and handler I studied the wrong
> call stack. ipip6_rcv is not called by xfrm_mode_tunnel_input but by
> tunnel64_rcv. This function already ensures that we can safely dereference
> the ipv6 header. I got confused by xfrm_mode_tunnel only checking for
> the size of an ipv4 header and assumed that the data section of the
> skb had not been rolled forward. This patch brings ipip6_rcv in line
> with ipip_rcv.
> 
> This patch superseds the old one:

Don't post new patches using replies to old threads.  Create entirely
new patch postings.

> [PATCH] ipv6: remove unneeded check to pskb_may_pull

This is an ambiguous commit header line, it doesn't say that you're
modifying the SIT tunnel driver at all.  Please fix this.

Thanks.

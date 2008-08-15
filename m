From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH 2/2] tun: fallback if skb_alloc() fails on big packets
Date: Fri, 15 Aug 2008 11:09:07 -0700
Message-ID: <48A5C643.8020506@qualcomm.com>
References: <200808121624.56948.rusty@rustcorp.com.au> <200808121625.53703.rusty@rustcorp.com.au> <20080812101409.GA22114@gondor.apana.org.au> <200808131324.56071.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:26407 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbYHOSJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 14:09:08 -0400
In-Reply-To: <200808131324.56071.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> On Tuesday 12 August 2008 20:14:09 Herbert Xu wrote:
>> On Tue, Aug 12, 2008 at 04:25:53PM +1000, Rusty Russell wrote:
>>> skb_alloc produces linear packets (using kmalloc()).  That can fail,
>>> so should we fall back to making paged skbs.
>> I'm not sure that this is really a good idea.  If anything then
>> tries to expand the head of this skb, they may fail and be forced
>> to drop the packet.
> 
> Yes, but it's no worse than now.  virtio_net keeps a cache of allocated pages, 
> but that's more code; and if I'm going to generalize that I really should 
> create a shrinker callback, which produces locking issues.

I agree with Rusty. It's no worse than what we have now (ie flat by default)
and improves the case were large GSO would otherwise cause packet drops.

TUN changes look good to me. Ack.
I did not get a chance to read through the new skb_copy_datagram_from_iovec()
code. At first glance looks good.

Max

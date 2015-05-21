From: David Miller <davem@davemloft.net>
Subject: Re: Looking for a lost patch
Date: Thu, 21 May 2015 17:25:24 -0400 (EDT)
Message-ID: <20150521.172524.1057695410816294973.davem@davemloft.net>
References: <20150519075724.GI8928@secunet.com>
	<555B81AF.5050401@redhat.com>
	<20150520063223.GM8928@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, alexander.duyck@gmail.com,
	netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39987 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422646AbbEUVZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 17:25:26 -0400
In-Reply-To: <20150520063223.GM8928@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 20 May 2015 08:32:23 +0200

> On Tue, May 19, 2015 at 11:32:15AM -0700, Alexander Duyck wrote:
>> On 05/19/2015 12:57 AM, Steffen Klassert wrote:
>> >The MTU should be 1500. All the IPsec overhead is handled by PMTU
>> >discovery, just like in the case we use IPsec without vti tunnels.
>> >The IPv6 side of vti does it like that.
>> 
>> The problem is the PMTU isn't communicated to things that make use
>> of the tunnel.  For example if I do a "ping -s 2000 x.x.x.x" across
>> an IPv6 VTI interface it will fail currently as it assumes the MTU
>> is 1500 and so it is fragmenting the ping packet at sizes that won't
>> be communicated across the underlying interface.
> 
> Well, the problem is that the local socket is still attached on the
> skb. The socket gets an error notification if the packet is too big,
> but ping does not care much about these error notifications.
> 
> One option to get such applications to work is to orphan the skb
> in the vti xmit function. Then the packet is not assumed to be
> local, so PMTU discovery is triggered on that route.
> 
> Something like this should work for IPv6:

When a packet traverses software layered devices, we should not orphan
the socket.

In fact, we have taken great pains to make sure this works so that the
socket memory accounting is done correctly on the original top-level
socket.

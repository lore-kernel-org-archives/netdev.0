From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/3] Avoid making inappropriate requests of
 NETIF_F_V[46]_CSUM devices
Date: Wed, 16 Jan 2013 18:00:44 -0500 (EST)
Message-ID: <20130116.180044.630688719598008373.davem@davemloft.net>
References: <1358165431.27054.62.camel@shinybook.infradead.org>
	<20130116.155406.351676228334066120.davem@davemloft.net>
	<1358375658.2397.69.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40358 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757773Ab3APXAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 18:00:48 -0500
In-Reply-To: <1358375658.2397.69.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 16 Jan 2013 22:34:18 +0000

> On Wed, 2013-01-16 at 15:54 -0500, David Miller wrote:
>> 
>> My opinion on this is that the injectors of packets are responsible
>> for ensuring checksum types are set on SKBs in an appropriate way.
>> 
>> So we ensure this in the local protocol stacks that generate packets,
>> and if foreign alien entities can inject SKBs with these checksum
>> settings (like the tun device can) the burdon of verification falls
>> upon whatever layer allows that to happen.
>> 
>> So really, the fix is in the tun device and the virtio layer.
> 
> The virtio layer (and the tun device) expose the equivalent of the
> NETIF_F_HW_CSUM capability to the guest. In the case where we have a
> real device on the host which *also* has NETIF_F_HW_CSUM capability, are
> you saying that the tun driver should do the checksum for non-UDP/TCP
> packets in software *anyway*, just because the packet might end up going
> out a device *without* that capability, and the check in
> harmonize_features() isn't sophisticated enough to cope properly?

I'm saying that tun can't inject unchecked crap into our stack.

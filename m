From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: Don't depend on per socket memory for neighbour discovery messages
Date: Wed, 28 Aug 2013 15:31:00 +0200
Message-ID: <20130828133100.GA12353@order.stressinduktion.org>
References: <361d4275efc79e3048191306df25ad003ed497d7.1377644830.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51535 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896Ab3H1NbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 09:31:03 -0400
Content-Disposition: inline
In-Reply-To: <361d4275efc79e3048191306df25ad003ed497d7.1377644830.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 28, 2013 at 01:07:25AM +0200, Thomas Graf wrote:
> Allocating skbs when sending out neighbour discovery messages
> currently uses sock_alloc_send_skb() based on a per net namespace
> socket and thus share a socket wmem buffer space.
> 
> If a netdevice is temporarily unable to transmit due to carrier
> loss or for other reasons, the queued up ndisc messages will cosnume
> all of the wmem space and will thus prevent from any more skbs to
> be allocated even for netdevices that are able to transmit packets.
> 
> The number of neighbour discovery messages sent is very limited,
> simply use alloc_skb() and don't depend on any socket wmem space any
> longer.
> 
> This patch has orginally been posted by Eric Dumazet in a modified
> form.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

This fixes a real bug (I also had this issue) and thus would propose it
for stable, too.

Thanks!

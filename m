From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Don't depend on per socket memory for neighbour
 discovery messages
Date: Wed, 28 Aug 2013 07:23:09 -0700
Message-ID: <1377699789.8277.2.camel@edumazet-glaptop>
References: <361d4275efc79e3048191306df25ad003ed497d7.1377644830.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:47124 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736Ab3H1OXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 10:23:11 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so6316659pbb.41
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 07:23:11 -0700 (PDT)
In-Reply-To: <361d4275efc79e3048191306df25ad003ed497d7.1377644830.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-28 at 01:07 +0200, Thomas Graf wrote:
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
> ---

Seems good to me, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>

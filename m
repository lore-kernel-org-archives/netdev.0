From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4_en: call gro handler for encapsulated
 frames
Date: Thu, 09 Jan 2014 14:57:26 -0800
Message-ID: <1389308246.31367.70.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJZOPZ+U=q==kyYzqgObrmPwj_qYXvon2o40FxkU6AmsprG2og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jerry Chu <hkchu@google.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:41494 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaAIW53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 17:57:29 -0500
Received: by mail-yh0-f53.google.com with SMTP id b20so1109409yha.40
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 14:57:29 -0800 (PST)
In-Reply-To: <CAJZOPZ+U=q==kyYzqgObrmPwj_qYXvon2o40FxkU6AmsprG2og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-10 at 00:24 +0200, Or Gerlitz wrote:
> On Thu, Jan 9, 2014 at 8:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > In order to use the native GRO handling of encapsulated protocols on
> > mlx4, we need to call napi_gro_receive() instead of netif_receive_skb()
> > unless busy polling is in action.
> >
> > While we are at it, rename mlx4_en_cq_ll_polling() to
> > mlx4_en_cq_busy_polling()
> >
> > Tested with GRE tunnel : GRO aggregation is now performed on the
> > ethernet device instead of being done later on gre device.
> 
> Hi Eric,
> 
> Just to make clear, this patch serves (very nicely!) encapsulated
> frames for which the HW is not able to do checksum check. For
> non-encapsulated packets or (e.g) vxlan encapsulated packets which are
> checksummed  by the HW we already go to the GRO path of the ethernet
> device.

Yes : mlx4 has two different paths, one calling napi_gro_frags(), and
one calling netif_receive_skb()

Obviously, the path calling napi_gro_frags() is already GRO enabled ;)

So if you are saying vxlan hits napi_gro_frags(), thats good to know,
but doesn't seem to be the case for GRE, IPIP, SIT tunnels.

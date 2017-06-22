From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net v2 2/2] esp6_offload: Fix IP6CB(skb)->nhoff for ESP
 GRO
Date: Thu, 22 Jun 2017 12:52:13 +0200
Message-ID: <20170622105213.GW2631@secunet.com>
References: <1498120631-4291-1-git-send-email-yossiku@mellanox.com>
 <1498120631-4291-2-git-send-email-yossiku@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <yossiku@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51186 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751818AbdFVKwQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 06:52:16 -0400
Content-Disposition: inline
In-Reply-To: <1498120631-4291-2-git-send-email-yossiku@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 22, 2017 at 11:37:11AM +0300, yossiku@mellanox.com wrote:
> From: Yossi Kuperman <yossiku@mellanox.com>
> 
> IP6CB(skb)->nhoff is the offset of the nexthdr field in an IPv6
> header, unless there are extension headers present, in which case
> nhoff points to the nexthdr field of the last extension header.
> 
> In non-GRO code path, nhoff is set by ipv6_rcv before any XFRM code
> is executed. Conversely, in GRO code path (when esp6_offload is loaded),
> nhoff is not set. The following functions fail to read the correct value
> and eventually the packet is dropped:
> 
>     xfrm6_transport_finish
>     xfrm6_tunnel_input
>     xfrm6_rcv_tnl
> 
> Set nhoff to the proper offset of nexthdr in esp6_gro_receive.
> 
> Fixes: 7785bba299a8 ("esp: Add a software GRO codepath")
> Signed-off-by: Yossi Kuperman <yossiku@mellanox.com>

Both patches applied, thanks for your work Yossi!

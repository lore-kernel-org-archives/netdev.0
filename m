From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next] net: xfrm: support setting an output mark.
Date: Fri, 11 Aug 2017 12:55:12 +0200
Message-ID: <20170811105511.GD22049@secunet.com>
References: <20170810171133.69254-1-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <jhs@mojatatu.com>, <herbert@gondor.apana.org.au>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:53634 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751618AbdHKKzP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 06:55:15 -0400
Content-Disposition: inline
In-Reply-To: <20170810171133.69254-1-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 11, 2017 at 02:11:33AM +0900, Lorenzo Colitti wrote:
> On systems that use mark-based routing it may be necessary for
> routing lookups to use marks in order for packets to be routed
> correctly. An example of such a system is Android, which uses
> socket marks to route packets via different networks.
> 
> Currently, routing lookups in tunnel mode always use a mark of
> zero, making routing incorrect on such systems.
> 
> This patch adds a new output_mark element to the xfrm state and
> a corresponding XFRMA_OUTPUT_MARK netlink attribute. The output
> mark differs from the existing xfrm mark in two ways:
> 
> 1. The xfrm mark is used to match xfrm policies and states, while
>    the xfrm output mark is used to set the mark (and influence
>    the routing) of the packets emitted by those states.
> 2. The existing mark is constrained to be a subset of the bits of
>    the originating socket or transformed packet, but the output
>    mark is arbitrary and depends only on the state.
> 
> The use of a separate mark provides additional flexibility. For
> example:
> 
> - A packet subject to two transforms (e.g., transport mode inside
>   tunnel mode) can have two different output marks applied to it,
>   one for the transport mode SA and one for the tunnel mode SA.
> - On a system where socket marks determine routing, the packets
>   emitted by an IPsec tunnel can be routed based on a mark that
>   is determined by the tunnel, not by the marks of the
>   unencrypted packets.
> - Support for setting the output marks can be introduced without
>   breaking any existing setups that employ both mark-based
>   routing and xfrm tunnel mode. Simply changing the code to use
>   the xfrm mark for routing output packets could xfrm mark could
>   change behaviour in a way that breaks these setups.
> 
> If the output mark is unspecified or set to zero, the mark is not
> set or changed.
> 
> Tested: make allyesconfig; make -j64
> Tested: https://android-review.googlesource.com/452776
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Patch applied to ipsec-next, thanks Lorenzo!

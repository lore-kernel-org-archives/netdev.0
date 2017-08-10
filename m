From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] net: xfrm: support setting an output mark.
Date: Thu, 10 Aug 2017 12:56:47 +0200
Message-ID: <20170810105647.GZ2631@secunet.com>
References: <20170809170852.141745-1-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <jhs@mojatatu.com>, <herbert@gondor.apana.org.au>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49694 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751373AbdHJK4u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Aug 2017 06:56:50 -0400
Content-Disposition: inline
In-Reply-To: <20170809170852.141745-1-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 10, 2017 at 02:08:52AM +0900, Lorenzo Colitti wrote:
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

I'm fine with the patch, but it does not apply to ipsec-next.
Could you rebase the patch onto:

git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git

Thanks!

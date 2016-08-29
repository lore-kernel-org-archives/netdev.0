From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next v1] gso: Support partial splitting at the
 frag_list pointer
Date: Mon, 29 Aug 2016 14:02:31 +0200
Message-ID: <20160829120231.GZ3735@gauss.secunet.com>
References: <20160823052030.GI3735@gauss.secunet.com>
 <CAKgT0UdATK8LUiTQ3sn0nrJTtk9oo29k7CrNdZavsPie_Pte0w@mail.gmail.com>
 <20160824093226.GN3735@gauss.secunet.com>
 <CAKgT0Ucp_M-oCDjvi2Aay=aNBTH=-sGEVxUgq0b=5KrX8j3O9Q@mail.gmail.com>
 <f108e80d-e8ee-4d59-ac65-e98df66c98d3@gmail.com>
 <20160825073126.GQ3735@gauss.secunet.com>
 <20160825121718.GA13235@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "Alexander Duyck" <alexander.h.duyck@intel.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:56318 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757279AbcH2MCe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 08:02:34 -0400
Content-Disposition: inline
In-Reply-To: <20160825121718.GA13235@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 09:17:18AM -0300, Marcelo Ricardo Leitner wrote:
> On Thu, Aug 25, 2016 at 09:31:26AM +0200, Steffen Klassert wrote:
> > 
> > Just to understand what you are doing. You generate MTU sized linear
> > buffers in sctp and then, skb_gro_receive() chains up these buffers
> > at the frag_list pointer. skb_gro_receive() does this because
> > skb_gro_offset is null and skb->head_frag is not set in your case.
> > 
> > At segmentation, you just need to split at the frag_list pointer
> > because you know that the chained buffers fit the MTU, right?
> > 
> 
> Correct. Just note that these buffers fit the MTU, but not necessary
> uses all of it. That is main point in here, variable segmentation size.

Thanks for the info. This is a very interesting concept, maybe I can use
it for IPsec too.

From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Sun, 16 Sep 2007 11:50:07 +0300
Message-ID: <46ECEE3F.60301@voltaire.com>
References: <adahclymos8.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	"Michael S. Tsirkin" <mst@mellanox.co.il>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:34173 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751540AbXIPJuV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Sep 2007 05:50:21 -0400
In-Reply-To: <adahclymos8.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
> With 2.6.24 probably opening in the not-too-distant future, it's
> probably a good time to review what my plans are for when the merge
> window opens.

> Core:
>  - Sean's QoS changes.  These look fine at first glance, and I just
>    plan to understand the backwards compatibility story (ie how this
>    works with an old SM) and merge.  Anyone who objects let me know.

Hi Roland,

I have reviewed the qos patches and provided comments which were 
deployed in v2 of the series. I also tested it (ipoib and iser which is 
rdma-cm based) against the Voltaire SM/SA to see that nothing was 
broken. I will send you a "reviewed by:" signature.

> ULPs:

> [ofa-general] [PATCH RFC] IB/ipoib: enable IGMP for userpsace multicast IB apps
The IGMP enabling patch posted by me on September 2nd isn't on your list
http://lists.openfabrics.org/pipermail/general/2007-September/040250.html
can you add it?


>  - Moni's IPoIB bonding support.  This seems mostly an issue of
>    getting the core bonding maintainer's attention.  However getting a
>    Reviewed-by: for the IPoIB changes wouldn't hurt too.

Jay Vosburgh, the bonding driver maintainer just sent an ack on all 
patch series. As for the IPoIB changes, there are three patches, where 
two of them, namely
> [PATCH 02/11] IB/ipoib: Notify the world before doing unregister
> [PATCH 04/11] IB/ipoib: Verify address handle validity on send
are handling a corner-case problems pointed by Michael Tsirkin.
Michael, will you be able to look on it and provide a reviewed-by 
signature? the third patch
> [PATCH 03/11] IB/ipoib: Bound the net device to the ipoib_neigh structue
is somehow much more simple, I don't think more review is needed for it.

>  - Eli and Michael's IPoIB stateless offload (checksum offload, LSO,
>    LRO, etc).  It's a big series that makes quite a few core changes.
>    I think it needs some careful review and is probably at risk of
>    missing this merge window.  Sorting in order of invasiveness so we
>    can merge at least some of it (if splitting it makes sense) might
>    be a good idea.

Just for the record, the 'etc' above relates to the interrupt moderation 
support (mlx4, core, ipoib {config through ethertool, usage). Among 
other things, what is not clear to me here is if/how this goes 
hand-in-hand with NAPI.

As you saw the patch adding checksum offload support had a long thread, 
and I think the discussion has reached the point where Michael is 
waiting for your take on it.

As for the LSO, LRO patches, I did not see any review comment.

I will see that I can review from the series, to begin with, will send 
Eli some comments and questions.

> HW specific:
>  - Jack and Michael's mlx4 FMR support.  Will merge I guess, although
>    I do hope to have time to address the DMA API abuse that is being
>    copied from mthca, so that mlx4 and mthca work in Xen domU.

This patch series is somehow important as without them iser is useless 
over connectx. Can be nice if you merge this and at max fix the abuse later.

Or.


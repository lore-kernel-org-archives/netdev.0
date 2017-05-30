From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: fix incorrect cim_la output for T6
Date: Tue, 30 May 2017 17:23:34 +0530
Message-ID: <20170530115333.GA12626@chelsio.com>
References: <1495188738-20546-1-git-send-email-ganeshgr@chelsio.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFFABCB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "nirranjan@chelsio.com" <nirranjan@chelsio.com>,
        "indranil@chelsio.com" <indranil@chelsio.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:11050 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750912AbdE3Lx5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 07:53:57 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFFABCB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, May 05/19/17, 2017 at 14:17:11 +0000, David Laight wrote:
> From: Ganesh Goudar
> > Sent: 19 May 2017 11:12
> T6
> > 
> > take care of UpDbgLaRdPtr[0-3] restriction for T6
> > 
> > Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> > ---
> >  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 7 +++++++
> >  1 file changed, 7 insertions(+)
> > 
> > diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> > index aded42b96..917b46b 100644
> > --- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> > +++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> > @@ -8268,6 +8268,13 @@ int t4_cim_read_la(struct adapter *adap, u32 *la_buf, unsigned int *wrptr)
> >  		if (ret)
> >  			break;
> >  		idx = (idx + 1) & UPDBGLARDPTR_M;
> > +
> > +		/* Bits 0-3 of UpDbgLaRdPtr can be between 0000 to 1001 to
> > +		 * identify the 32-bit portion of the full 312-bit data
> > +		 */
> > +		if (is_t6(adap->params.chip))
> > +			while ((idx & 0xf) > 9)
> > +				idx = (idx + 1) % UPDBGLARDPTR_M;
> 
> Why the loop, maybe:
> 		if (is_t6(adap->params.chip) && (idx & 0xf) >= 9)
> 			idx = (idx & 0xf0) + 0x10;
> 		else
> 			idx++;
> 		idx &= UPDBGLARDPTR_M;
> 
> 	David
>
Yes, it is sensible I will send a v2, thanks David.

Thanks 

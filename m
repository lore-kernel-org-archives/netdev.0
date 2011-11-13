From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH v2 net-next 07/12] bnx2x: simplify definition of
 RX_SGE_MASK_LEN and use it.
Date: Sun, 13 Nov 2011 15:37:44 +0200
Message-ID: <1321191464.4651.4.camel@lb-tlvb-dmitry>
References: <1321188449-5822-1-git-send-email-dmitry@broadcom.com>
 <1321188449-5822-8-git-send-email-dmitry@broadcom.com>
 <1321189845.2069.4.camel@Joe-Laptop>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2918 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753783Ab1KMNhv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Nov 2011 08:37:51 -0500
In-Reply-To: <1321189845.2069.4.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-11-13 at 05:10 -0800, Joe Perches wrote:
> On Sun, 2011-11-13 at 14:47 +0200, Dmitry Kravkov wrote:
> > diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
> []
> > @@ -874,8 +874,7 @@ static inline void bnx2x_clear_sge_mask_next_elems(struct bnx2x_fastpath *fp)
> >  static inline void bnx2x_init_sge_ring_bit_mask(struct bnx2x_fastpath *fp)
> >  {
> >  	/* Set the mask to all 1-s: it's faster to compare to 0 than to 0xf-s */
> > -	memset(fp->sge_mask, 0xff,
> > -	       (NUM_RX_SGE >> BIT_VEC64_ELEM_SHIFT)*sizeof(u64));
> > +	memset(fp->sge_mask, 0xff, RX_SGE_MASK_LEN * sizeof(u64));
> 
> drivers/net/ethernet/broadcom/bnx2x/bnx2x.h:
> 	u64			sge_mask[RX_SGE_MASK_LEN];
> 
> perhaps this is more readable as:
> 	memset(fp->sge_mask, 0xff, sizeof(fp->sge_mask));
> 
> 

You're right, I'll fix it. Thanks.

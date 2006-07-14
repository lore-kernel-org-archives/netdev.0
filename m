From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 2/2] correct dev_alloc_skb kerneldoc
Date: Fri, 14 Jul 2006 10:27:27 +0300
Message-ID: <20060714072726.GB6458@sortiz.org>
References: <20060707155255.10f2e10f@dxpl.pdx.osdl.net> <20060707.165527.77037268.davem@davemloft.net> <20060708104811.GB31751@lst.de> <20060708.133738.123994596.davem@davemloft.net> <20060713203615.GA26954@lst.de>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	netdev@vger.kernel.org, support@pathscale.com, kkeil@suse.de,
	kai.germaschewski@gmx.de, chas@cmf.nrl.navy.mil, paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.pp.htv.fi ([213.243.153.37]:29375 "EHLO smtp1.pp.htv.fi")
	by vger.kernel.org with ESMTP id S1161151AbWGNAPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2006 20:15:34 -0400
To: Christoph Hellwig <hch@lst.de>
Content-Disposition: inline
In-Reply-To: <20060713203615.GA26954@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 13, 2006 at 10:36:16PM +0200, Christoph Hellwig wrote:
>  - net/irda/*:
>    	They allocate the skb in protocol code for TX.  Should probably
> 	do a normal alloc_skb like all the other protocol code.
Agreed. I will come up with a patch replacing all the useless dev_alloc_skb()
calls from the IrDA stack.


> The patchkit for this is at http://verein.lst.de/~hch/patches.skb.tgz, it
> includes the first two cleanup patches I posted previously (Any plans
> to put them in?), a patch to move __dev_alloc_skb out of line because
> otherwise we'd need to include netdevice.h in skbuff.h which creates
> lots of problems (and moving it out of lines shaves 10kb off a
> allyesconfig), the dev_alloc_skb prototype changes and some experimental
> patches to make dev_alloc_skb nodeaware.
In those patches you change dev_alloc_skb prototype, but then the new netdev
argument is not used by __dev_alloc_skb() to allocate the sk_buff on the
correct node. Do you plan to introduce an alloc_skb_node() later or am I 
missing something ? 

Cheers,
Samuel.


From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] [IrDA]: small read past the end of array in debug code
Date: Sat, 20 Apr 2013 23:39:16 +0300
Message-ID: <20130420203916.GA8936@mwanda>
References: <20130417071038.GA7923@elgon.mountain>
 <20130419.173329.1993060022855519678.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32958 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755026Ab3DTUkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Apr 2013 16:40:24 -0400
Content-Disposition: inline
In-Reply-To: <20130419.173329.1993060022855519678.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 19, 2013 at 05:33:29PM -0400, David Miller wrote:
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Wed, 17 Apr 2013 10:10:38 +0300
> 
> > The "reason" can come from skb->data[] and it hasn't been capped so it
> > can be from 0-255 instead of just 0-6.  For example in irlmp_state_dtr()
> > the code does:
> > 
> > 	reason = skb->data[3];
> > 	...
> > 	irlmp_disconnect_indication(self, reason, skb);
> > 
> > Also LMREASON has a couple other values which don't have entries in the
> > irlmp_reasons[] array.  And 0xff is a valid reason as well which means
> > "unknown".
> > 
> > So far as I can see we don't actually care about "reason" except for in
> > the debug code.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Applied but please put the subsystem prefix outside of [] which get
> stripped by git am and other tools.  I fixed it up to be "irda: ".
> 

Sorry about that.  I won't do it again.

It's weird because the prefix was cut and pasted from an earlier
commit.  Also [media] and [SCSI] use square brackets in their
subsystems.  I tried some experiments with "git am" and you're right
that "git am" always strips out the square bracket stuff.  Odd.

regards,
dan carpenter

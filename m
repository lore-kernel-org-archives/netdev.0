From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: Re: [resend PATCH 1/1] b44: fix ethool link settings support
Date: Wed, 24 May 2006 03:21:06 -0700
Message-ID: <1148466066.2982.17.camel@dhcp-10-7-81-7.broadcom.com>
References: <1146065509.28067.52.camel@dhcp-10-7-81-7.broadcom.com>
 <4474000E.6070804@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:65037 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S932446AbWEXRW4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 13:22:56 -0400
To: "Jeff Garzik" <jgarzik@pobox.com>
In-Reply-To: <4474000E.6070804@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The first test is to check if any advertising value is given.
The else path is when advertising == 0.
The b44->flags do not have the same values as the given advertising bits.
When any (or all) of the ADVERTISE_ALL bits are passed to the driver the b44->flags 
are set accordingly.
I think it's ok. 

Thanks,
Gary


On Wed, 2006-05-24 at 02:41 -0400, Jeff Garzik wrote:
> Gary Zambrano wrote:
> > +		if (cmd->advertising & ADVERTISE_ALL) {
> > +			if (cmd->advertising & ADVERTISE_10HALF)
> > +				bp->flags |= B44_FLAG_ADV_10HALF;
> > +			if (cmd->advertising & ADVERTISE_10FULL)
> > +				bp->flags |= B44_FLAG_ADV_10FULL;
> > +			if (cmd->advertising & ADVERTISE_100HALF)
> > +				bp->flags |= B44_FLAG_ADV_100HALF;
> > +			if (cmd->advertising & ADVERTISE_100FULL)
> > +				bp->flags |= B44_FLAG_ADV_100FULL;
> > +		} else {
> > +			bp->flags |= (B44_FLAG_ADV_10HALF |
> > +				      B44_FLAG_ADV_10FULL |
> > +				      B44_FLAG_ADV_100HALF |
> > +				      B44_FLAG_ADV_100FULL);
> > +		}
> 
> The logic above is backwards.  I presume the first test should be
> 	if (!(cmd->advertising & ADVERTISE_ALL))
> 
> The rest looks OK.
> 
> 	Jeff
> 
> 
> 


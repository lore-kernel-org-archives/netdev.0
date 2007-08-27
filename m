From: Karsten Keil <kkeil@suse.de>
Subject: Re: [PATCH] isdn capi driver broken on 64 bit.
Date: Mon, 27 Aug 2007 13:02:26 +0200
Message-ID: <20070827110226.GA15362@pingi.kke.suse.de>
References: <20070824110811.32f266f8@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:53634 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753794AbXH0LC1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 07:02:27 -0400
Content-Disposition: inline
In-Reply-To: <20070824110811.32f266f8@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 24, 2007 at 11:08:11AM -0700, Stephen Hemminger wrote:
> The following driver API is broken on any architecture with 64 bit addresses.
> because of cast that loses high bits.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> 
> --- a/drivers/isdn/capi/capidrv.c	2007-06-25 09:03:12.000000000 -0700
> +++ b/drivers/isdn/capi/capidrv.c	2007-08-24 11:06:46.000000000 -0700
> @@ -1855,6 +1855,9 @@ static int if_sendbuf(int id, int channe
>  		return 0;
>  	}
>  	datahandle = nccip->datahandle;
> +
> +	/* This won't work on 64 bit! */
> +	BUILD_BUG_ON(sizeof(skb->data) > sizeof(u32));
>  	capi_fill_DATA_B3_REQ(&sendcmsg, global.ap.applid, card->msgid++,
>  			      nccip->ncci,	/* adr */
>  			      (u32) skb->data,	/* Data */


NACK.

It is not a BUG.

This is OK, since this field must have a value and on 32 it has the correct
one) On 64 bit this field is ignored (but also need a value, random data is
bad as well).


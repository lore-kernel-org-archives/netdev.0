From: Oliver Neukum <oliver@neukum.org>
Subject: Re: usbnet transmit path problems
Date: Wed, 11 Sep 2013 12:11:52 +0200
Message-ID: <1378894312.28160.15.camel@linux-fkkt.site>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7325@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:40840 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631Ab3IKKLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 06:11:54 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7325@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-11 at 10:10 +0100, David Laight wrote:
> I've been looking at the code in drivers/net/usb/usbnet.c that
> processes tx data after the tx_fixup() function has run.
> 
> The code currently looks like:

> 1) I can't see where skb_linearize() gets called if 'can_dma_sg' is unset.

That is the job of subdrivers.

> 2) If 'length % dev->maxpacket == 0' for a multi-fragment packet then
>    the extra byte isn't added correctly (the code probably falls off
>    the end of the scatter-gather list).

Indeed. Ming Lei, should usbnet handle this in the sg case or better
leave it to the subdriver you introduced this for?

> 4) I read that USB3 has a different scheme for terminating bulk data
>    that is a multiple of the packet size.
>    Does this mean that the pad byte isn't needed for USB3?
>    (Or are USB3 controllers/targets just as buggy?)

We don't have enough examples to tell.

	Regards
		Oliver

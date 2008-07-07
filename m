From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 1/2][RFC] vlan: use pskb_copy() when inserting a vlan tag by hand
Date: Mon, 7 Jul 2008 23:07:02 +0200
Message-ID: <20080707210701.GD12997@xi.wantstofly.org>
References: <20080707205646.GB12997@xi.wantstofly.org> <4872841E.1030609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@cam.org>,
	Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:40818 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756241AbYGGVHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 17:07:06 -0400
Content-Disposition: inline
In-Reply-To: <4872841E.1030609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 07, 2008 at 11:01:18PM +0200, Patrick McHardy wrote:

> >When inserting a vlan tag into an skb by hand (in the case the
> >target network device hardware does not support inserting a vlan
> >tag by passing it in via the TX descriptor), making a copy of the
> >skb to be modified by calling skb_copy() is overkill, since
> >skb_copy() will needlessly linearize the skb, copying of all of
> >the fragmented data around, and checksumming the paket in software
> >even if the hardware is perfectly capable of doing that by itself.
> >
> >For this case, pskb_copy() does exactly what is needed and no more,
> >so use that instead.
> >
> >Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> 
> This looks fine to me.

OK.  Since the mv643xx_eth patch (2/2) depends on both this patch
and the one you/I sent previously, could you merge the mv643xx_eth
patch (2/2) via your tree as well?

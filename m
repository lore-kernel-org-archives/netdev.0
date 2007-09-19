From: 'Christoph Hellwig' <hch@infradead.org>
Subject: Re: [PATCH] tehuti: driver for Tehuti 10GbE network adapters
Date: Wed, 19 Sep 2007 18:41:03 +0100
Message-ID: <20070919174103.GB22795@infradead.org>
References: <20070919155258.GA14850@infradead.org> <20070919173724.C810375CC7@mail.tehutinetworks.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Christoph Hellwig' <hch@infradead.org>, jeff@garzik.org,
	davem@davemloft.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, 'Nadav Shemer' <nadav@tehutinetworks.net>,
	'Andy Gospodarek' <andy@greyhouse.net>
To: Alexander Indenbaum <baum@tehutinetworks.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:47662 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763485AbXISRlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 13:41:19 -0400
Content-Disposition: inline
In-Reply-To: <20070919173724.C810375CC7@mail.tehutinetworks.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 07:37:18PM +0200, Alexander Indenbaum wrote:
> In my understanding unregister_netdev(), in case netdev is still IFF_UP and
> holds irq, will call dev_close() which will call netdev->stop(), bdx_close()
> in our case. bdx_close() releases all netdev resources among others calls
> free_irq().
> 
> That's why I'm pretty sure that we do not hold any reference to netdev after
> unregister_netdev() finishes and we can free_netdev() without any worry :)
> 
> What do you think, does it still look fishy?

Ok, so you do irq acquire/release in open/close so that bit is fine.
The code might actually work as is, sorry for the noise.

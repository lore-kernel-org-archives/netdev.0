From: "Alexander Indenbaum" <baum@tehutinetworks.net>
Subject: RE: [PATCH] tehuti: driver for Tehuti 10GbE network adapters
Date: Wed, 19 Sep 2007 19:37:18 +0200
Message-ID: <20070919173724.C810375CC7@mail.tehutinetworks.co.il>
References: <20070919155258.GA14850@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <jeff@garzik.org>, <davem@davemloft.org>,
	<akpm@linux-foundation.org>, <netdev@vger.kernel.org>,
	"'Nadav Shemer'" <nadav@tehutinetworks.net>,
	"'Andy Gospodarek'" <andy@greyhouse.net>
To: "'Christoph Hellwig'" <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bzq-219-225-50.pop.bezeqint.net ([62.219.225.50]:45700 "EHLO
	mail.tehutinetworks.co.il" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754671AbXISSIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 14:08:46 -0400
In-Reply-To: <20070919155258.GA14850@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: 'Christoph Hellwig' [mailto:hch@infradead.org]
> Sent: Wednesday, September 19, 2007 5:53 PM
>
> > Putting dual-port issue aside, could you elaborate what is the problem
> in
> > your opinion in bdx_remove() implementation? What is wrong with calling
> > free_netdev() right after unregister_netdev()? Could you provide
> pointers
> > for docs and examples to correct PCI network device remove interface
> > implementation?
> 
> free_netdev can only be called if you're sure you don't reference your
> netdevice anymore.  Most notably that means you need to call free_irq
> first.

In my understanding unregister_netdev(), in case netdev is still IFF_UP and
holds irq, will call dev_close() which will call netdev->stop(), bdx_close()
in our case. bdx_close() releases all netdev resources among others calls
free_irq().

That's why I'm pretty sure that we do not hold any reference to netdev after
unregister_netdev() finishes and we can free_netdev() without any worry :)

What do you think, does it still look fishy?

Alexander Indenbaum



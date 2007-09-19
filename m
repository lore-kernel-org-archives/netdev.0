From: 'Christoph Hellwig' <hch@infradead.org>
Subject: Re: [PATCH] tehuti: driver for Tehuti 10GbE network adapters
Date: Wed, 19 Sep 2007 16:52:58 +0100
Message-ID: <20070919155258.GA14850@infradead.org>
References: <20070918094723.GA2539@infradead.org> <20070919104438.B1FF775CAD@mail.tehutinetworks.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Christoph Hellwig' <hch@infradead.org>, jeff@garzik.org,
	davem@davemloft.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, 'Nadav Shemer' <nadav@tehutinetworks.net>,
	'Andy Gospodarek' <andy@greyhouse.net>
To: Alexander Indenbaum <baum@tehutinetworks.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34563 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761441AbXISPxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 11:53:41 -0400
Content-Disposition: inline
In-Reply-To: <20070919104438.B1FF775CAD@mail.tehutinetworks.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 12:44:33PM +0200, Alexander Indenbaum wrote:
> >  - please don't redefine the dma mask constants
> >  - please use the firmware loader instead of mebedding a firmware
> >    image
> 
> Could you give us some pointers to docs and examples of "firmware loader"?
> I'm not sure I'm familiar with such mechanism in Linux kernel.

Documentation/firmware_class/ in the kernel tree has the documentation
for it.  Grep the kernel tree for request_firmware to find various users.

> Putting dual-port issue aside, could you elaborate what is the problem in
> your opinion in bdx_remove() implementation? What is wrong with calling
> free_netdev() right after unregister_netdev()? Could you provide pointers
> for docs and examples to correct PCI network device remove interface
> implementation? 

free_netdev can only be called if you're sure you don't reference your
netdevice anymore.  Most notably that means you need to call free_irq
first.


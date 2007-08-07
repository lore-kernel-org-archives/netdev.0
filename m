From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC][BNX2X]: New driver for Broadcom 10Gb Ethernet.
Date: Wed, 8 Aug 2007 00:04:59 +0100
Message-ID: <20070807230458.GA9883@infradead.org>
References: <1185957077.5552.22.camel@dell> <200708020006.13457.mb@bu3sch.de> <46B8EF13.40109@garzik.org> <200708080020.35701.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Michael Chan <mchan@broadcom.com>,
	davem@davemloft.net, netdev@vger.kernel.org, eliezert@broadcom.com,
	lusinsky@broadcom.com, eilong@broadcom.com
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:43116 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756120AbXHGXFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 19:05:20 -0400
Content-Disposition: inline
In-Reply-To: <200708080020.35701.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2007 at 12:20:35AM +0200, Michael Buesch wrote:
> On Wednesday 08 August 2007 00:15:47 Jeff Garzik wrote:
> > Michael Buesch wrote:
> > > On Wednesday 01 August 2007 10:31:17 Michael Chan wrote:
> > >> +static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
> > >> +{
> > >> +	struct net_device *dev = dev_instance;
> > > 
> > > You need to check if dev==NULL and bail out.
> > > Another driver sharing the IRQ with this might choose to pass the dev
> > > pointer as NULL.
> > 
> > NAK that advice:  It is pointless having such a check in the hottest of 
> > driver hot paths, since a large majority of drivers do not have such a 
> > check.
> > 
> > It is better to fix the extremely rare oddball that passes NULL to 
> > request_irq(), than to update all drivers to be slower due to the oddballs.
> 
> Ah, well. IMO one should better go safe than Oops. ;)
> It's not that an if branch takes more than 2 or 3 CPU cycles at worst.
> But well, if you don't like it, I can live without it, too.

Please take a look at kernel/irq/handle.c.  The irq handler is
always called with the right dev_id argument.  Everything would be a complete
nightmare to handle because you usually need to access the device private
data to check whether the shared irq is for this device.

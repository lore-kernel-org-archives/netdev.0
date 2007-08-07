From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [RFC][BNX2X]: New driver for Broadcom 10Gb Ethernet.
Date: Wed, 8 Aug 2007 00:20:35 +0200
Message-ID: <200708080020.35701.mb@bu3sch.de>
References: <1185957077.5552.22.camel@dell> <200708020006.13457.mb@bu3sch.de> <46B8EF13.40109@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org, eliezert@broadcom.com,
	lusinsky@broadcom.com, eilong@broadcom.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:52230
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936613AbXHGWV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 18:21:58 -0400
In-Reply-To: <46B8EF13.40109@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 08 August 2007 00:15:47 Jeff Garzik wrote:
> Michael Buesch wrote:
> > On Wednesday 01 August 2007 10:31:17 Michael Chan wrote:
> >> +static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
> >> +{
> >> +	struct net_device *dev = dev_instance;
> > 
> > You need to check if dev==NULL and bail out.
> > Another driver sharing the IRQ with this might choose to pass the dev
> > pointer as NULL.
> 
> NAK that advice:  It is pointless having such a check in the hottest of 
> driver hot paths, since a large majority of drivers do not have such a 
> check.
> 
> It is better to fix the extremely rare oddball that passes NULL to 
> request_irq(), than to update all drivers to be slower due to the oddballs.

Ah, well. IMO one should better go safe than Oops. ;)
It's not that an if branch takes more than 2 or 3 CPU cycles at worst.
But well, if you don't like it, I can live without it, too.

-- 
Greetings Michael.

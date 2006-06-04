From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [linux-usb-devel] [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Sun, 4 Jun 2006 21:06:17 +0200
Message-ID: <200606042106.17870.oliver@neukum.org>
References: <44817083.508@gentoo.org> <200606041917.55496.oliver@neukum.org> <ada605fb0606041122w36ad8320wa0a5d8241c98644c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Daniel Drake" <dsd@gentoo.org>,
	linux-usb-devel@lists.sourceforge.net,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, "Ulrich Kunitz" <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.kontent.de ([81.88.34.36]:47291 "EHLO Mail1.KONTENT.De")
	by vger.kernel.org with ESMTP id S1750986AbWFDTGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2006 15:06:03 -0400
To: "John Que" <qwejohn@gmail.com>
In-Reply-To: <ada605fb0606041122w36ad8320wa0a5d8241c98644c@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Sonntag, 4. Juni 2006 20:22 schrieb John Que:
> Hello Oliver,
> 
>     I am sorry, but I think I don't understand ,
> You said:
> >A USB driver never will request an irq. Interrupt handling is done in
> > the core usb layer. Individual drivers have no business there.
> 
> but in the zd1211 driver (not the rewrite version) I found this
> call to request an irq:
> request_irq(dev->irq, &zd1205_intr, SA_SHIRQ, dev->name, dev)
> 
> Also when looking in the linux tree, I see some request_irq() calls in USB
> drivers, for exmaple in some drivers under usb/gadgaets, and more.
> 
> Can you please elaborate a bit ? What do you mean by saying
> "A USB driver never will request an irq"?

The architecture is as follows:

device driver <---> USB core <---> host driver <=== USB ===> gadget driver <---> function driver

Only those drivers that deal with the hardware directly request interrupts.
A device driver submits URBs and deals with callbacks.

	Regards
		Oliver

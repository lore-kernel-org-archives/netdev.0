From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [linux-usb-devel] [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Sun, 04 Jun 2006 22:45:47 +0100
Message-ID: <4483548B.9010400@gentoo.org>
References: <44817083.508@gentoo.org> <200606031951.09135.oliver@neukum.org>	 <4481E497.2000505@gentoo.org> <200606040025.32275.oliver@neukum.org> <ada605fb0606040929p7a6ea69aw9488a75d611b23e5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver@neukum.org>,
	linux-usb-devel@lists.sourceforge.net,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta09-winn.ispmail.ntl.com ([81.103.221.49]:46791 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932265AbWFDVpS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jun 2006 17:45:18 -0400
To: John Que <qwejohn@gmail.com>
In-Reply-To: <ada605fb0606040929p7a6ea69aw9488a75d611b23e5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Que wrote:
>  I had noticed that the zd1211 driver does call request_irq() in 
> zd1205_open(),
> file zd1205.c; 

Look at it in context:

#ifndef HOST_IF_USB	
	if ((rc = request_irq(dev->irq, &zd1205_intr, SA_SHIRQ, dev->name, 
dev)) != 0) {
		printk(KERN_ERR "zd1205: failed to request_irq\n");	

The ZD1211 vendor driver appears to be an adapted version of another 
ZyDAS driver which supports a PCI wifi chip, presumably there are some 
similarities. There are many such headaches when trying to read through 
this driver...

request_irq never happens because HOST_IF_USB gets defined.

Daniel


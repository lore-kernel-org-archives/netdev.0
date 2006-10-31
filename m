From: David Brownell <david-b@pacbell.net>
Subject: Re: [linux-usb-devel] [PATCH 2/2] usbnet: use MII hooks only if CONFIG_MII is enabled
Date: Tue, 31 Oct 2006 11:36:52 -0800
Message-ID: <200610311136.54058.david-b@pacbell.net>
References: <Pine.LNX.4.64.0610231618510.3962@g5.osdl.org> <200610310940.16619.david-b@pacbell.net> <20061031180712.GQ27968@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-devel@lists.sourceforge.net,
	Randy Dunlap <randy.dunlap@oracle.com>, akpm@osdl.org,
	zippel@linux-m68k.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, link@miggy.org,
	Christoph Hellwig <hch@infradead.org>, torvalds@osdl.org,
	greg@kroah.com, toralf.foerster@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp111.sbc.mail.mud.yahoo.com ([68.142.198.210]:34933 "HELO
	smtp111.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1423824AbWJaThF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Oct 2006 14:37:05 -0500
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061031180712.GQ27968@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > 		...
> > 		depends on MII if MII != n
> > 
> > except that Kconfig doesn't comprehend conditionals like that.
> 
> You can express this in Kconfig:
> 	depends MII || MII=n

Except that:

Warning! Found recursive dependency: USB_USBNET USB_NET_AX8817X MII USB_USBNET

I think this is another case where Kconfig gets in the way and forces
introduction of a pseudovariable.  I'll give that a try.


> But my suggestion was:
> #if defined(CONFIG_MII) || (defined(CONFIG_MII_MODULE) && defined(MODULE))
>
> Or simply select MII ...

Nope; those both prevent completely legit configurations.
MII is not required, except for those two adapter options.



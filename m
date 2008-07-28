From: Jaswinder Singh <jaswinder@infradead.org>
Subject: Re: [PATCH] typhoon: use request_firmware
Date: Mon, 28 Jul 2008 08:46:49 +0530
Message-ID: <1217215009.2970.7.camel@jaswinder.satnam>
References: <1217170232.3537.6.camel@jaswinder.satnam>
	 <1217209400.22789.47.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, becker@scyld.com,
	davidpmclean@yahoo.com, Jeff Garzik <jeff@garzik.org>,
	netdev <netdev@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50793 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002AbYG1DS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2008 23:18:28 -0400
In-Reply-To: <1217209400.22789.47.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

On Sun, 2008-07-27 at 21:43 -0400, David Dillow wrote:

> >  MODULE_LICENSE("GPL");
> > +MODULE_LICENSE("3com/typhoon.bin");
>=20
> Uhm, MODULE_FIRMWARE()?
>=20

Sorry, Fixed. Thanks.

> > @@ -1368,8 +1371,14 @@ typhoon_download_firmware(struct typhoon *tp=
)
> >  	int i;
> >  	int err;
> > =20
> > +	err =3D request_firmware(&fw, fw_name, &tp->pdev->dev);
> > +	if (err) {
> > +		printk(KERN_ERR "%s: Failed to load firmware \"%s\"\n",
> > +		       tp->name, fw_name);
> > +		return err;
> > +	}
> >  	err =3D -EINVAL;
> > -	fHdr =3D (struct typhoon_file_header *) typhoon_firmware_image;
> > +	fHdr =3D (struct typhoon_file_header *) fw->data;
> >  	image_data =3D (u8 *) fHdr;
> > =20
> >  	if(memcmp(fHdr->tag, "TYPHOON", 8)) {
> > @@ -1494,6 +1503,7 @@ err_out_irq:
> >  	pci_free_consistent(pdev, PAGE_SIZE, dpage, dpage_dma);
> > =20
> >  err_out:
> > +	release_firmware(fw);
> >  	return err;
> >  }
>=20
> It is not quite this simple. By not loading the firmware on device
> probe, you have opened the door to a broken resume, and the driver wi=
ll
> now try to sleep in an atomic context, when typhoon_tx_timeout() is
> called at the very least.
>=20

I just added the request_firmware support and
replaced =EF=BB=BFtyphoon_firmware_image with =EF=BB=BFfw->data.
I do not think this will make any difference in rest of driver.

If you like to change the driver then it should be in another patch.

David Woodhouse, any comments.

> I've said that I was thinking about doing the conversion myself, and =
I
> think the firmware loader makes some sense for new drivers. But the m=
ore
> I think about converting old -- fairly static -- drivers such as
> typhoon, I wonder "what's the point?" We don't save memory, we add co=
de,
> and we add failure points that weren't there before. Where's the upsi=
de?
>=20

=EF=BB=BFDavid Woodhouse, any comments.

Thank you,

Jaswinder Singh.


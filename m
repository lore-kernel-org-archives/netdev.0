From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH] typhoon: use request_firmware
Date: Mon, 28 Jul 2008 08:36:25 -0400
Message-ID: <1217248585.22789.58.camel@obelisk.thedillows.org>
References: <1217170232.3537.6.camel@jaswinder.satnam>
	 <1217209400.22789.47.camel@obelisk.thedillows.org>
	 <1217215009.2970.7.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, becker@scyld.com,
	davidpmclean@yahoo.com, Jeff Garzik <jeff@garzik.org>,
	netdev <netdev@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>
To: Jaswinder Singh <jaswinder@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:54481 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753134AbYG1Mg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2008 08:36:28 -0400
In-Reply-To: <1217215009.2970.7.camel@jaswinder.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-07-28 at 08:46 +0530, Jaswinder Singh wrote:
> On Sun, 2008-07-27 at 21:43 -0400, David Dillow wrote:
> > It is not quite this simple. By not loading the firmware on device
> > probe, you have opened the door to a broken resume, and the driver =
will
> > now try to sleep in an atomic context, when typhoon_tx_timeout() is
> > called at the very least.
> >=20
>=20
> I just added the request_firmware support and
> replaced =EF=BB=BFtyphoon_firmware_image with =EF=BB=BFfw->data.
> I do not think this will make any difference in rest of driver.

Please re-read what I said -- you broke error handling and potentially
resume. Previously, the firmware was available without a sleeping call
to user space to get it. Now, it is not. You cannot sleep in
typhoon_tx_timeout(), and trying to get a firmware image in resume is
going to be a problem if your file system is NFS mounted over the NIC
you're trying to resume.

http://marc.info/?l=3Dlinux-kernel&m=3D121608383506190&w=3D2
http://marc.info/?l=3Dlinux-kernel&m=3D121608255704704&w=3D2



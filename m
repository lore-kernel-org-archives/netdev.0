From: Olaf Hering <olaf@aepfle.de>
Subject: Re: revert mv643xx change from ubuntu tree
Date: Fri, 20 Oct 2006 07:38:56 +0200
Message-ID: <20061020053856.GA3277@aepfle.de>
References: <20061019121836.GA26319@aepfle.de> <1161318901.31915.21.camel@gullible>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@osdl.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from natklopstock.rzone.de ([81.169.145.174]:48261 "EHLO
	natklopstock.rzone.de") by vger.kernel.org with ESMTP
	id S2992502AbWJTFjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 01:39:22 -0400
To: Ben Collins <ben.collins@ubuntu.com>
Content-Disposition: inline
In-Reply-To: <1161318901.31915.21.camel@gullible>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 20, Ben Collins wrote:

> On Thu, 2006-10-19 at 14:18 +0200, Olaf Hering wrote:
> > Somehow the Ubuntu guys managed to sneak this compile error into th=
e
> > tree:
> >=20
> > commit ce9e3d9953c8cb67001719b5516da2928e956be4
> >=20
> >       [mv643xx] Add pci device table for auto module loading.
> >=20
> > drivers/net/mv643xx_eth.c:1560: error: array type has incomplete el=
ement type
> > drivers/net/mv643xx_eth.c:1561: warning: implicit declaration of fu=
nction =E2=80=98PCI_DEVICE=E2=80=99
> > drivers/net/mv643xx_eth.c:1561: error: =E2=80=98PCI_VENDOR_ID_MARVE=
LL=E2=80=99 undeclared here (not in a function)
> > drivers/net/mv643xx_eth.c:1561: error: =E2=80=98PCI_DEVICE_ID_MARVE=
LL_MV64360=E2=80=99 undeclared here (not in a function)
>=20
> Correct, I missed the include for linux/pci.h.
>=20
> This patch has been trailing our tree since 2.6.12. Could you help me=
 to
> understand what in this driver will cause it to be autoloaded by udev
> when compiled as a module?

See commit ce9e3d9953c8cb67001719b5516da2928e956be4, platform devices
have now a modalias entry in sysfs. The network card is not a PCI
device.

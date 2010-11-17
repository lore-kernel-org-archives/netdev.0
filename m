From: Namhyung Kim <namhyung@gmail.com>
Subject: Re: [PATCH] 3c59x: fix build failure on !CONFIG_PCI
Date: Wed, 17 Nov 2010 11:22:12 +0900
Message-ID: <1289960532.1663.24.camel@leonhard>
References: <1289921271-15295-1-git-send-email-namhyung@gmail.com>
	 <20101116091408.abd36ec8.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101116091408.abd36ec8.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2010-11-16 (=ED=99=94), 09:14 -0800, Randy Dunlap:
> Hi,
>=20

Hi, Randy


> Interesting patch.  I have reported this build error and looked
> into fixing it, but did not come up with this solution.
>=20
> Looking at it more:  if CONFIG_PCI is not enabled, DEVICE_PCI() is NU=
LL.
> That makes VORTEX_PCI() (with or without your patch) have a value of =
NULL.
>=20
> Is the line with the reported syntax error (3211) executed in
> function acpi_set_WOL() ?  If so, let's assume that vp->enable_wol is=
 true.
> Then what happens on line 3211 (or 3213 after your patch)?
>=20
> 		if (VORTEX_PCI(vp)->current_state < PCI_D3hot)
> 			return;
>=20
> or if I am really confuzed this morning, please tell me how it works.
>=20

At first glance, I've noticed that the code above could make a NULL
dereference so I added NULL check prior to the line.

But after reading more code I realized that other pci-functions called
in acpi_set_WOL() would not work with NULL pci_dev pointer also. And I
found all callers of the acpi_set_WOL() already checked NULL pointer
before the call. Finally I could remove the NULL check and leave the
code as is. That's how it works. :)

Thanks.

--=20
Regards,
Namhyung Kim

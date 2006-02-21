From: Carlos =?iso-8859-1?q?Mart=EDn?= <carlos@cmartin.tk>
Subject: Re: From: Carlos   Mart??n <carlos@cmartin.tk>
Date: Tue, 21 Feb 2006 21:24:23 +0100
Message-ID: <200602212124.23572.carlos@cmartin.tk>
References: <11403021213131-git-send-email-carlos@cmartin.tk> <20060221192601.GA28560@infradead.org>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, acx100-devel@lists.sourceforge.net
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060221192601.GA28560@infradead.org>
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Tuesday 21 February 2006 20:26, Christoph Hellwig wrote:
> On Sat, Feb 18, 2006 at 11:35:21PM +0100, Carlos Martin wrote:
> > [PATCH] acxsm: Fix Kconfig option check
> >=20
> > This check never actually worked because CONFIG_ACX_{ACX,USB} are
> > tristate. With Adrian Bunk's patch to the Kconfig, this works with the
> > _BOOL hidden Kconfig options.
> > Also update error message adding that this shouldn't happen anymore.
>=20
> All the fixes discussed so far are not very nice at all.  The right
> fix is the following:
>=20
>=20
>  - split the module into three:
> 	acx-common.ko
> 	acx-pci.ko
> 	acx-usb.ko

I don't really like this method. It's not for any real reason though, so I'=
ll=20
go with it if people want it. I've used this for the rt2x00 driver by loadi=
ng=20
it manually, which was really annoying, but I suppose when it's properly=20
installed it works well.

>=20
>  - make CONFIG_ACX_PCI and CONFIG_ACX_USB user-visible tristate
>    varibles in the Kconfig.
>  - build acx-common.ko when either of those is selected, with the
>    following makefile:
>=20
> ---- snip ----
> acx-common-y		+=3D wlan.o conv.o ioctl.o common.o
> acx-pci-y		+=3D pci.o
> acx-usb-y		+=3D usb.o
>=20
> obj-$(CONFIG_ACX_PCI)	+=3D acx-common.o acx-pci.o
> obj-$(CONFIG_ACX_USB)	+=3D acx-common.o acx-usb.o

This is how we had it before, which leads to having a lot of the same code =
on=20
both modules. The unified driver is not much larger so it was made this way=
,=20
and that's where all the problem comes from.

Wouldn't this lead to duplicated function definitions at link time if both =
are=20
compiled-in? From your module split above I understood you wanted acx-commo=
n=20
to be another module, but here I see it goes into the modules.

> ---- snip ----
>=20
>  - kill the IS_PCI/IS_USB macros and add a acx_operations structure that
>    handles the different hardware without branches all over and allows
>    the hw-specific code to be in separate modules.

There aren't that many IS_{PCI,USB} uses and most if not all are justified=
=20
(extra step for one case). It might be a good idea to do that for the=20
IS_ACX{100,111} macros instead of calling the generic function which then=20
calls the chip-specific one.

   cmn
=2D-=20
Carlos Mart=EDn Nieto    |   http://www.cmartin.tk
Hobbyist programmer    |


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642

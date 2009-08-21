From: Dan Williams <dcbw@redhat.com>
Subject: Re: sd8686 linux system hang: not always
Date: Fri, 21 Aug 2009 08:04:16 -0500
Message-ID: <1250859856.2876.11.camel@localhost.localdomain>
References: <20090819185605.GA19345@kaos.fbx.proxad.net>
	 <1250710797.5351.89.camel@localhost.localdomain>
	 <20090820204051.GA24491@kaos.fbx.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Beno=EEt?= Vaillant <benoit.vaillant@no-log.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42413 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755618AbZHUNEH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 09:04:07 -0400
In-Reply-To: <20090820204051.GA24491@kaos.fbx.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-08-20 at 22:40 +0200, Beno=C3=AEt Vaillant wrote:
> On Wed, Aug 19, 2009 at 02:39:57PM -0500, Dan Williams wrote:
> > On Wed, 2009-08-19 at 20:56 +0200, Beno=C3=AEt Vaillant wrote:
> > > /*
> > > Just a bit of context information:
> > > I'm using an MID (quite close to an Aigo, although bios differs,
> > > probably some hardware too, yet I've not checked much on that). I=
'm
> > > trying to use my Marvell card to get wifi access on a debian
> > > installation. The other OS installed (midinux) successfully gets =
a
> > > connection using the 8686_v9 mobilin driver, so I'd not go for an=
y
> > > hardware issue. This driver failing to compile 'out of the box' o=
n
> > > fresh kernels, I thought getting the libertas module working woul=
d be
> > > a better way to get through.
> > > */
> > > <snip>
> >=20
> > Just for context, what SDIO controller are you using on this platfo=
rm?
>=20
> Sure, i can provide that!
>=20
> lspci claims i's an:
> 00:e1.0 SD Host controler: Intel Corporation System Controller Hub (S=
CH Poulsbo) SDIO Controller #1 (rev 06)
> 00:e1.1 SD Host controler: Intel Corporation System Controller Hub (S=
CH Poulsbo) SDIO Controller #2 (rev 06)
>=20
> Complete `lspci -vvv` is attached.
>=20
> Could this lead to anything already known which i have might missed?

Well, besides the fact that the Poulsbo SDHC driver hasn't actually
passed review for the kernel yet...  That doesn't mean the Poulsbo
driver isn't a fine driver, but if Pierre hasn't acked it, I don't
really trust it.  The largest # of problems people have had with
Libertas SDIO have been with the host controller with things like
transfer widths, clocking, interrupt vs. polled mode, chunk size, etc.
When the SDHC driver and hardware they are using actually starts workin=
g
well, then libertas actually starts working well.

So I don't mean to brush you off, but we know the chip works pretty wel=
l
with the Ricoh line (which I'm typing this on right now with an sd8686)
and a few other embedded-type controllers.  So I'd start diving down
into the SDHC driver code for Poulsbo and try to figure out what's goin=
g
on there and in the MMC layer.

Dan



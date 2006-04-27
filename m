From: Sven Schuster <schuster.sven@gmx.de>
Subject: Re: Fw: Bug: PPP dropouts in >=2.6.16
Date: Thu, 27 Apr 2006 07:48:38 +0200
Message-ID: <20060427054838.GA18309@zion.homelinux.com>
References: <20060421010809.6c3cfc34.akpm@osdl.org> <4807377b0604211015j16b40cccpe215668f8fdcfc24@mail.gmail.com> <200604220202.59434.ak@suse.de> <20060424074148.GB23340@zion.homelinux.com> <Pine.LNX.4.64.0604260126020.12542@pc> <20060426212542.GA9287@zion.homelinux.com> <20060426150733.53cc9032.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pWyiEgJYm5f9v55/"
Cc: lkml@jawad.org, ak@suse.de, jesse.brandeburg@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.de ([213.165.64.20]:14784 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S964941AbWD0Fsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 01:48:50 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060426150733.53cc9032.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--pWyiEgJYm5f9v55/
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hi Andrew,

On Wed, Apr 26, 2006 at 03:07:33PM -0700, Andrew Morton told us:
> So there's something in -mm which fixes your kernel?  It's usually the
> other way around ;)

actually this was the first time that I tried a "normal" kernel.
I haven't chosen to run -mm because it fixed something for me
originally, I just run -mm for a matter of taste ;)

> And it sounds like something which has been in -mm for a long time, so it
> might not be a patch which I was planning on sending upstream.
>
> Can you think of a way in which we can identify which patch does the good
> deed?

My first thought was it had something to do with pata_via, as
mkinitrd complained it cannot find that module in 2.6.16.9
when I installed it. Taking a closer look, it doesn't even seem
like pata_via is really used, its use count in lsmod output is 0.
But, in the last few releases of -mm I had problems every now and
then where my box didn't want to boot complaining about lost
interrupts on hdb (hdb here, not hda) or it just froze after some
days of uptime (I was able to do sysrq though). Later on I ran
SMART self tests on both my hard drives which didn't reveal any
errors. Google told me some other guys with VIA based boards had
similar problems which went away when using a board with another
vendor's chipset. Being a lazy bastard and having no real time I
stopped digging into this...
How to debug? I might try unapplying VIA and/or IDE related patches
=66rom -mm until I get the same problem like with the stable series.
If one would tell me which patches I should try :-)

Here's the dmesg output concerning my IDE controller:

Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=3D=
xx
VP_IDE: IDE controller at PCI slot 0000:00:07.1
PCI: Via IRQ fixup for 0000:00:07.1, from 255 to 0
VP_IDE: chipset revision 6
VP_IDE: not 100% native mode: will probe irqs later
VP_IDE: VIA vt82c686b (rev 40) IDE UDMA100 controller on pci0000:00:07.1
    ide0: BM-DMA at 0xd000-0xd007, BIOS settings: hda:DMA, hdb:DMA
    ide1: BM-DMA at 0xd008-0xd00f, BIOS settings: hdc:DMA, hdd:pio
Probing IDE interface ide0...
hda: Maxtor 6Y120L0, ATA DISK drive
hdb: Maxtor 6Y120L0, ATA DISK drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Probing IDE interface ide1...
hdc: AOPEN CD-RW CRW4852 1.00 20030123, ATAPI CD/DVD-ROM drive
ide1 at 0x170-0x177,0x376 on irq 15
hda: max request size: 128KiB
hda: 240121728 sectors (122942 MB) w/2048KiB Cache, CHS=3D65535/16/63, UDMA=
(100)
hda: cache flushes supported
 hda: hda1 hda2 hda3 hda4 < hda5 hda6 hda7 hda8 hda9 hda10 hda11 >
hdb: max request size: 128KiB
hdb: 240121728 sectors (122942 MB) w/2048KiB Cache, CHS=3D65535/16/63, UDMA=
(100)
hdb: cache flushes supported
 hdb: hdb1 hdb2 hdb3 hdb4 < hdb5 hdb6 hdb7 hdb8 >
hdc: ATAPI 40X CD-ROM CD-R/RW drive, 2048kB Cache, UDMA(33)
Uniform CD-ROM driver Revision: 3.20

If someone wants me to provide more info, test patches or anything
please tell me :-)


Thanks

Sven

--
Linux zion.homelinux.com 2.6.17-rc1-mm1_31 #31 Sat Apr 8 16:18:23 CEST 2006=
 i686 athlon i386 GNU/Linux
 07:19:57 up 12:02,  2 users,  load average: 0.19, 0.10, 0.13

--pWyiEgJYm5f9v55/
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFEUFs1o4FAdB2PneQRAoxsAJ0XgZgb8UY5BlCHtqn8TLl/5ySG2ACdEjRo
t6mCNVp5zw0BiTwIn40oDRs=
=RUos
-----END PGP SIGNATURE-----

--pWyiEgJYm5f9v55/--

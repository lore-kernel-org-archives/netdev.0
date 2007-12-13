From: Adrian Bunk <bunk@kernel.org>
Subject: Re: 2.6.24-rc5-mm1
Date: Thu, 13 Dec 2007 18:54:42 +0100
Message-ID: <20071213175442.GA21616@stusta.de>
References: <20071213024050.7d6e5f3e.akpm@linux-foundation.org> <47613F18.6080601@bull.net> <4761494E.1050704@bull.net> <20071213160744.GA4509@gollum.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: bbpetkov@yahoo.de, Benjamin Thery <benjamin.thery@bull.net>,
	Pierre Peiffer <pierre.peiffer@bull.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:37933 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762997AbXLMRyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 12:54:39 -0500
Content-Disposition: inline
In-Reply-To: <20071213160744.GA4509@gollum.tnic>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2007 at 05:07:44PM +0100, Borislav Petkov wrote:
> On Thu, Dec 13, 2007 at 04:01:34PM +0100, Benjamin Thery wrote:
> > The problem comes from the new macro UDPX_INC_STATS_BH introduced
> > by Herbert, which was a nice addition to increment the correct=20
> > UDP MIB depending on the socket family, but unfortunately=20
> > the use of this macro from kernel code (I mean code not compiled=20
> > as module) requires that IPv6 is also compiled in kernel=20
> > (CONFIG_IPv6=3Dy) in order to have udp_stats_in6 defined at link=20
> > time.
> >=20
> > Benjamin
> >=20
> > Pierre Peiffer wrote:
> > > Hi,
> > >=20
> > > 	My config does not link any more:
> > >=20
> > > ...
> > >   CHK     include/linux/compile.h
> > >   UPD     include/linux/compile.h
> > >   CC      init/version.o
> > >   LD      init/built-in.o
> > >   LD      .tmp_vmlinux1
> > > net/built-in.o: In function `xs_udp_data_ready':
> > > /home/peifferp/containers/kernel/linux-2.6.24-rc5-mm1/net/sunrpc/=
xprtsock.c:842:
> > > undefined reference to `udp_stats_in6'
> > > /home/peifferp/containers/kernel/linux-2.6.24-rc5-mm1/net/sunrpc/=
xprtsock.c:846:
> > > undefined reference to `udp_stats_in6'
> > > make[1]: *** [.tmp_vmlinux1] Error 1
> > > make: *** [sub-make] Error 2
> > >=20
> > > After a first look, udp_stats_in6 seems to be defined in ipv6 (fi=
le
> > > net/ipv6/udp.c) but I have
> > >=20
> > > CONFIG_IPV6=3Dm
> > > and
> > > CONFIG_SUNRPC=3Dy
> > >=20
> > > So, SUNRPC uses something defined in a module in my case ?
> > >=20
> > > ... looking more, this dependency seems to have been introduced b=
y the patch
> > > [UDP]: Restore missing inDatagrams increments
> > > ( http://thread.gmane.org/gmane.linux.network/79716/focus=3D79831=
 )
> > >=20
> > > (I cc netdev)
> > >=20
> > > I don't know what is the right way to fix this ... ?
>=20
> you might do "select IPV6" in the SUNRPC section of fs/Kconfig, howev=
er select is
> evil...

select itself isn't evil.

Nonsensical selects like the one you suggest (sunrpc does not require=20
IPV6) are evil.

> Regards/Gru=C3=9F,
>     Boris.

cu
Adrian

--=20

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed


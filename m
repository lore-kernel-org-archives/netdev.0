From: Borislav Petkov <bbpetkov@yahoo.de>
Subject: Re: 2.6.24-rc5-mm1
Date: Thu, 13 Dec 2007 17:07:44 +0100
Message-ID: <20071213160744.GA4509@gollum.tnic>
References: <20071213024050.7d6e5f3e.akpm@linux-foundation.org> <47613F18.6080601@bull.net> <4761494E.1050704@bull.net>
Reply-To: bbpetkov@yahoo.de
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pierre Peiffer <pierre.peiffer@bull.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762426AbXLMQJh@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4761494E.1050704@bull.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 13, 2007 at 04:01:34PM +0100, Benjamin Thery wrote:
> The problem comes from the new macro UDPX_INC_STATS_BH introduced
> by Herbert, which was a nice addition to increment the correct=20
> UDP MIB depending on the socket family, but unfortunately=20
> the use of this macro from kernel code (I mean code not compiled=20
> as module) requires that IPv6 is also compiled in kernel=20
> (CONFIG_IPv6=3Dy) in order to have udp_stats_in6 defined at link=20
> time.
>=20
> Benjamin
>=20
> Pierre Peiffer wrote:
> > Hi,
> >=20
> > 	My config does not link any more:
> >=20
> > ...
> >   CHK     include/linux/compile.h
> >   UPD     include/linux/compile.h
> >   CC      init/version.o
> >   LD      init/built-in.o
> >   LD      .tmp_vmlinux1
> > net/built-in.o: In function `xs_udp_data_ready':
> > /home/peifferp/containers/kernel/linux-2.6.24-rc5-mm1/net/sunrpc/xp=
rtsock.c:842:
> > undefined reference to `udp_stats_in6'
> > /home/peifferp/containers/kernel/linux-2.6.24-rc5-mm1/net/sunrpc/xp=
rtsock.c:846:
> > undefined reference to `udp_stats_in6'
> > make[1]: *** [.tmp_vmlinux1] Error 1
> > make: *** [sub-make] Error 2
> >=20
> > After a first look, udp_stats_in6 seems to be defined in ipv6 (file
> > net/ipv6/udp.c) but I have
> >=20
> > CONFIG_IPV6=3Dm
> > and
> > CONFIG_SUNRPC=3Dy
> >=20
> > So, SUNRPC uses something defined in a module in my case ?
> >=20
> > ... looking more, this dependency seems to have been introduced by =
the patch
> > [UDP]: Restore missing inDatagrams increments
> > ( http://thread.gmane.org/gmane.linux.network/79716/focus=3D79831 )
> >=20
> > (I cc netdev)
> >=20
> > I don't know what is the right way to fix this ... ?

you might do "select IPV6" in the SUNRPC section of fs/Kconfig, however=
 select is
evil...

--=20
Regards/Gru=DF,
    Boris.
--
To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

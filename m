From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: Re: why usr/include/linux/if_frad.h is required
Date: Sat, 24 Jan 2009 18:55:33 +0530
Message-ID: <1232803533.17900.4.camel@localhost.localdomain>
References: <20090121053310.GA26395@uranus.ravnborg.org>
	 <20090120.221504.264090722.davem@davemloft.net>
	 <20090121173838.3390e5c9@s6510>
	 <20090121.153712.84781438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, sam@ravnborg.org, jaswinderlinux@gmail.com,
	khc@pm.waw.pl, arnd@arndb.de, mingo@elte.hu,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:50832 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755246AbZAXN0O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Jan 2009 08:26:14 -0500
In-Reply-To: <20090121.153712.84781438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-21 at 15:37 -0800, David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 21 Jan 2009 17:38:38 +1100
>=20
> > There are no references if_frad.h in the version of Sangoma (out of
> > tree) code that we use in Vyatta.
>=20
> frad-0.20:src/dlcicfg.c
>=20
> It includes linux/if_frad.h and also performs the DLCI_SET_CONF
> ioctl.
>=20
> Enough evidence to show we need to keep this header in the
> export set.  Let's just kill the bogus CONFIG_* ifdef
> tests in there.

After killing CONFIG_DLCI and CONFIG_DLCI_MODULE, it is also killing th=
e
kernel:

  CC      net/socket.o
In file included from net/socket.c:75:
include/linux/if_frad.h:170: error: =E2=80=98CONFIG_DLCI_MAX=E2=80=99 u=
ndeclared here (not in a function)
make[1]: *** [net/socket.o] Error 1
make: *** [net] Error 2

because these things still depends on CONFIG_DLCI:

struct frad_local
{
   struct net_device_stats stats;

   /* devices which this FRAD is slaved to */
   struct net_device     *master[CONFIG_DLCI_MAX];
   short             dlci[CONFIG_DLCI_MAX];

Are you still sure we do not need CONFIG_DLCI.

--
JSR


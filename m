From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/2] net: Add network priority cgroup (v4)
Date: Wed, 23 Nov 2011 06:49:26 -0500
Message-ID: <20111123114926.GA27968@hmsreliant.think-freely.org>
References: <1321974652-8318-1-git-send-email-nhorman@tuxdriver.com>
 <20111122.152315.2256366823688148380.davem@davemloft.net>
 <20111122203938.GB4207@hmsreliant.think-freely.org>
 <20111122.154516.228225371031125826.davem@davemloft.net>
 <20111122210008.GC4207@hmsreliant.think-freely.org>
 <20111123101933.GA10127@tugrik.mns.mnsspb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	john.r.fastabend@intel.com, robert.w.love@intel.com
To: Kirill Smelkov <kirr@mns.spb.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41494 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314Ab1KWLts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 06:49:48 -0500
Content-Disposition: inline
In-Reply-To: <20111123101933.GA10127@tugrik.mns.mnsspb.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2011 at 02:19:34PM +0400, Kirill Smelkov wrote:
> On Tue, Nov 22, 2011 at 04:00:08PM -0500, Neil Horman wrote:
> > On Tue, Nov 22, 2011 at 03:45:16PM -0500, David Miller wrote:
> > > From: Neil Horman <nhorman@tuxdriver.com>
> > > Date: Tue, 22 Nov 2011 15:39:38 -0500
> > >=20
> > > > On Tue, Nov 22, 2011 at 03:23:15PM -0500, David Miller wrote:
> > > >> From: Neil Horman <nhorman@tuxdriver.com>
> > > >> Date: Tue, 22 Nov 2011 10:10:50 -0500
> > > >>=20
> > > >> > (v2)
> > > >> > Based on reviews from John F., Amerigo Wang and Neerav Parik=
h, I've cleaned up
> > > >> > the rcu locking, fixed a memory leak in an error path, and c=
orrected some typos.
> > > >> >=20
> > > >> > (v3)
> > > >> > Converted rcu_dereference to rntl_dereference where appropri=
ate as per request
> > > >> > from John F.
> > > >> >=20
> > > >> > (v4)
> > > >> > Cleaned up some spacing issues, and optimized the skb_update=
_priority path as
> > > >> > per request from Dave M.
> > > >> >=20
> > > >> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > > >> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> > > >> > CC: Robert Love <robert.w.love@intel.com>
> > > >> > CC: "David S. Miller" <davem@davemloft.net>
> > > >>=20
> > > >> Applied and going through some build testing now, thanks Neil.
> > > > Thanks Dave!  I tested here building separately with:
> > > > CONFIG_CGROUPS=3Dn
> > > > CONFIG_CROUPS=3Dy && CONFIG_NETPRIO_CGROUP=3Dy
> > > > CONFIG_CROUPS=3Dy && CONFIG_NETPRIO_CGROUP=3Dm
> > > >=20
> > > > So you should be square, but theres rarely any valid accounting=
 for my ability
> > > > to screw something up :)
> > >=20
> > > I want to be absolutely sure, because I had to apply your changes=
 by hand,
> > > in particular the linux/netdevice.h changes had line offsets of u=
p to 67.
> > Really?  Thats odd, I've got thse changes here applied to a local c=
opy of the
> > net-next tree.  I branched from commit 8b3408f8ee994973869d8ba32c5b=
f482bc4ddca4
> > and it applies cleanly.  Perhaps something wen't in while I was dev=
eloping this?
>=20
> The patch broke the build with CONFIG_CGROUPS=3Dn (testing on today's
> net-next v3.2-rc2-714-g1f2149c):
>=20
> kirr@mini:~/src/linux/linux-net-next$ make
>   CHK     include/linux/version.h
>   CHK     include/generated/utsrelease.h
>   CALL    scripts/checksyscalls.sh
>   CHK     include/generated/compile.h
>   CC      init/do_mounts.o
> In file included from include/linux/netdevice.h:53,
>                  from include/linux/icmpv6.h:173,
>                  from include/linux/ipv6.h:220,
>                  from include/net/ipv6.h:16,
>                  from include/linux/sunrpc/clnt.h:26,
>                  from include/linux/nfs_fs.h:50,
>                  from init/do_mounts.c:20:
> include/net/netprio_cgroup.h:23: error: field =E2=80=98css=E2=80=99 h=
as incomplete type
> scripts/Makefile.build:305: recipe for target `init/do_mounts.o' fail=
ed
> make[1]: *** [init/do_mounts.o] Error 1
> Makefile:945: recipe for target `init' failed
> make: *** [init] Error 2
>=20
>=20
> Config attached.
>=20
Damn, I apologize.  I had tested with CGROUP_CONFIG=3Dn, but when I did=
 a make
oldconfig, since I had cgroup subsystems enabled, it re-selected CGROUP=
_CONFIG,
instead of squashing the subsystems.  I'll fix this immediately. =20
Neil

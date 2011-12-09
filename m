From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net-next PATCH] net: netprio_cgroup: make net_prio_subsys static
Date: Fri, 9 Dec 2011 11:40:25 -0500
Message-ID: <20111209164025.GA18564@hmsreliant.think-freely.org>
References: <20111208051717.20236.41881.stgit@jf-dev1-dcblab>
 <20111208114555.GA1246@hmsreliant.think-freely.org>
 <20111208.195339.152346047030004418.davem@davemloft.net>
 <1323446704.2336.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <4EE237FF.20409@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34033 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737Ab1LIQkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 11:40:37 -0500
Content-Disposition: inline
In-Reply-To: <4EE237FF.20409@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 09, 2011 at 08:31:59AM -0800, John Fastabend wrote:
> On 12/9/2011 8:05 AM, Eric Dumazet wrote:
> > Le jeudi 08 d=C3=A9cembre 2011 =C3=A0 19:53 -0500, David Miller a =C3=
=A9crit :
> >> From: Neil Horman <nhorman@tuxdriver.com>
> >> Date: Thu, 8 Dec 2011 06:45:55 -0500
> >>
> >>> On Wed, Dec 07, 2011 at 09:17:17PM -0800, John Fastabend wrote:
> >>>> net_prio_subsys can be made static this removes the sparse
> >>>> warning it was throwing.
> >>>>
> >>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> >>  ...
> >>> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> >>
> >> Applied.
> >> --
> >=20
> > But it trivialy breaks the build ? Or am I mistaken ?
> >=20
>=20
> Dang. No your right. When its not built as a module it breaks. Sorry
> I'll revert it.
>=20
Yeah, I'd say revert it for now, but I think the real problem is that t=
he SUBSYS
macro in the cgroup core code automatically defines a subsys structure =
as
extern.  We should look into fixing that properly instead long term.

> >=20
> > $ grep CONFIG_NETPRIO_CGROUP .config
> > CONFIG_NETPRIO_CGROUP=3Dy
> >=20
> > $ make net/core/netprio_cgroup.o
> >   CC      net/core/netprio_cgroup.o
> > net/core/netprio_cgroup.c:31:29: error: static declaration of =E2=80=
=98net_prio_subsys=E2=80=99 follows non-static declaration
> > include/linux/cgroup_subsys.h:71:1: note: previous declaration of =E2=
=80=98net_prio_subsys=E2=80=99 was here
> > make[1]: *** [net/core/netprio_cgroup.o] Error 1
> > make: *** [net/core/netprio_cgroup.o] Error 2
> >=20
> >=20
> >=20
>=20
>=20

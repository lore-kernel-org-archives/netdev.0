From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Tue, 30 Jan 2007 08:02:08 -0500
Message-ID: <20070130130208.GA3723@hmsreliant.homelinux.net>
References: <45BA75D1.6040005@hp.com> <20070129163447.GB21938@hmsreliant.homelinux.net> <20070129213013.GA26841@hmsreliant.homelinux.net> <20070130.072536.129403235.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4970 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965365AbXA3NZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 08:25:45 -0500
Content-Disposition: inline
In-Reply-To: <20070130.072536.129403235.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 30, 2007 at 07:25:36AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20070129213013.GA26841@hmsreliant.homelinux.net> (at Mon,=
 29 Jan 2007 16:30:13 -0500), Neil Horman <nhorman@tuxdriver.com> says:
>=20
> > Quick reality check here.  In thinking about how best to go about t=
his
> > redirection of frames to the default router, based on Dave M.s inpu=
t, I think
> > that the best solution would be in ndisc_send_ns.  What I was think=
ing was that
> > in ndisc_send_ns, we already detect if a source address is optimist=
ic and squash
> > the transmission of the frame there.  What if in addition to that s=
upression, we
> :
>=20
> Well...I think it is okay if sending NS is deferred (or omit) in
> ndisc_send_ns() (or in ndisc_solicit(), probably) if the source is
Agreed, the code already does this, per the RFC.

> optimistic address, but... I'm not sure so far if it is appropriate
> from design POV. The ndisc_send_ns() nor ndisc_solicit() is not about
> our current neigh state machine, at all.
>=20
Thats true, but I'm not sure how we can avoid that.

> I do not think we should copy neighbor information from (one of)
> default routers, but use temporary neigh entry (or neigh in new state=
)
> for such datagrams in stead.  We should aware that:
>=20
Not sure how that is different from what I'm proposing.  a neighbor ent=
ry that
maps a given host on the current subnet to the MAC of the default route=
r, that
then gets flushed when DAD completes is temporary, as far as I can see.

>  1) default router's link-layer address may change.
True, but if this changes, all our network connectivity is lost, until =
the
normal neighbor solicitation process completes anyway.

>  2) we may have more than one default routers.
True, but I would think we could select any of them and this would work=
=2E
Granted, we wouldn't use all the default routers in the table as we wou=
ld with
routed frames, but I'm not sure how we avoid that.

>  3) the default router's link-layer may be invalidated.
>=20
yes, but this would be bad for the same reason as (1)

> Anyway, I'm start thinking about CONFIG_IPV6_OPTIMISTIC_DAD to=20
> make sure the new code path will not break anything else...
>=20
Agreed, I'll add in the config option with my next patch.

> --yoshfuji
>=20

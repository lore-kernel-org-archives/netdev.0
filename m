From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Fri, 26 Jan 2007 14:03:37 -0500
Message-ID: <20070126190337.GB15916@hmsreliant.homelinux.net>
References: <20070125212651.GB12136@hmsreliant.homelinux.net> <45B92BA5.1050505@hp.com> <20070126142730.GA15916@hmsreliant.homelinux.net> <20070127.004429.96717403.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2185 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161197AbXAZTSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 14:18:33 -0500
Content-Disposition: inline
In-Reply-To: <20070127.004429.96717403.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 27, 2007 at 12:44:29AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20070126142730.GA15916@hmsreliant.homelinux.net> (at Fri,=
 26 Jan 2007 09:27:30 -0500), Neil Horman <nhorman@tuxdriver.com> says:
>=20
> > I'm looking for it at the moment, but I too had assumed that redire=
cting the
> > outgoing packet to the default router would happen automatically wi=
thin the
> > routing code as a result of not having a completed neighbor entry a=
vailable.
> > Since I've modified ndisc_send_ns such that we will never send Neig=
hbor
> > solicitations from an optimistic address, as per section 3.2, we'll=
 never get a
> > completed neightbor entry while the address is optimistic.  If that=
s not the
> > case, I'd welcome some suggestions on how to implement this (given =
that I'm not
> > overly familiar with the code right now).  From what I see, I think=
 the routing
> > code will select the default route when rti6_nexthop is null during=
 route
> > selection, which it will be if the neighbor entry doesn't get resol=
ved.  Not
> > 100% sure though.  Let me know what you think.
>=20
> (Now I remember that I hit similar issue before when I once
> tried to implement this....)
>=20
> Well... no, you cannot assume that routing code solves this issue.
> This is not so trivial, and I am not aware clean solution yet...
>=20
> On reason of this issue is because the source address may not be
> probided by user, and the source address selection will be done
> after looking up routing table.
>=20
> One possibiliy is to solve by rt->rt6i_nexthop->output(),
> but I guess we will hit some race condition.
>=20
> Hmm...
>=20
Is this perhaps something we can do in ip6_output2?  We can test the in=
terface
flags there and if the interface is optimistic, we can lookup the defau=
lt route
(perhaps via rt6_lookup, using the unspecified address for the daddr), =
and then
replace skb->dst with the dst_entry retrieved from the lookup, which sh=
ould give
us the proper mac header construction starting in ip6_output_finish.

What do you think?
Neil


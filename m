From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Tue, 13 Feb 2007 13:22:08 -0500
Message-ID: <20070213182208.GA25362@hmsreliant.homelinux.net>
References: <20070207205503.GB20804@hmsreliant.homelinux.net> <20070208.065206.107341055.yoshfuji@linux-ipv6.org> <20070208130715.GA27267@hmsreliant.homelinux.net> <20070213.082759.69474746.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2586 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751511AbXBMScp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 13:32:45 -0500
Content-Disposition: inline
In-Reply-To: <20070213.082759.69474746.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 13, 2007 at 08:27:59AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20070208130715.GA27267@hmsreliant.homelinux.net> (at Thu,=
 8 Feb 2007 08:07:15 -0500), Neil Horman <nhorman@tuxdriver.com> says:
>=20
> > > I still have a question.  Now, who will install the kernel route =
for
> > > the incoming packet?  Can we get packet for our unicast address d=
uring
> > > optimistic DAD period?
> > >=20
> > Not sure what you're getting at here.  RFC 4429 makes no distinctio=
n between
> > optimistic and non-optimistic packets for recevied frames, so route=
s for
> > received packets will be added by the same code that does it curren=
tly (which I
> > admittedly haven't looked into to closely).  Packets received for o=
ur unicast
> > address (even if it is optimistic) are handled just as any other pa=
cket is (same
> > as it is for TENTATIVE addresses, as I understand it).=20
>=20
> I think it is clear.
>=20
> In tentative state, we do not receive any packet.
> After finishind DAD process, we install kernel route for that address
> in net/ipv6/addrconf.c:__ipv6_ifa_notify(), and we start receiving
> packet for that address.
>=20
> On the other hand, optimistic addresses are like in deprecated state.
> So, we should be able to receive frames for those addresses.
>=20
I'm sorry, you're right, it is clear now.  I hadn't considered the need=
 for a
route to receive frames, and the point at which we insert it.  I'm puti=
ng
together a new patch for this right now and will post it as soon as I'v=
e built
and started testing it.

Thanks & Regards
Neil


> --yoshfuji
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

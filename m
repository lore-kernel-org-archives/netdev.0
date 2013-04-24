From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] ipv6: separate out procfs code from mcast.c
Date: Wed, 24 Apr 2013 11:29:41 +0800
Message-ID: <1366774181.3849.6.camel@cr0>
References: <1366701302.21136.19.camel@cr0>
	 <20130423.031805.544535198246859192.davem@davemloft.net>
	 <1366702220.21136.23.camel@cr0>
	 <20130423.033620.1101068519499870853.davem@davemloft.net>
	 <1366702893.21136.28.camel@cr0> <87d2tlv32i.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11326 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757473Ab3DXD36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 23:29:58 -0400
In-Reply-To: <87d2tlv32i.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 14:33 +0200, Bj=C3=B8rn Mork wrote:
> Cong Wang <amwang@redhat.com> writes:
>=20
> > On Tue, 2013-04-23 at 03:36 -0400, David Miller wrote:
> >> From: Cong Wang <amwang@redhat.com>
> >> Date: Tue, 23 Apr 2013 15:30:20 +0800
> >>=20
> >> > This is hard to do, as in the email I replied to Stephen. So I
> >> > prefer to just add a Kconfig dependency, at least for now.
> >>=20
> >> A Kconfig hack is exactly what I've told you is an unacceptable
> >> solution.
> >
> > Please enlighten me for a third solution. :)
>=20
> This is an completely untested idea....
>=20
> I note that vxlan_init_net requires a successful sock_create_kern().
> That implies a request_module("net-pf-...") followed by try_module_ge=
t.
>=20
> So if the sock_create_kern(PF_INET6, ..) succeeds then you *know* you
> have IPv6. If it fails with -EAFNOSUPPORT, then you could fall back t=
o
> sock_create_kern(PF_INET, ..) and set a flag indicating that runtime
> IPv6 support is disabled.  Then use this flag to allow/deny configuri=
ng
> any IPv6 destinations.

Excellent point! You are certainly right. I will give it a try.

>=20
> You may also have to protect the IPv6 modular symbols you use with
> symbol_request() or similar to prevent vxlan from depending on IPv6. =
 I
> dunno...
>=20

This sounds a bit crazy.

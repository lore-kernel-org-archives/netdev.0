From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch net-next] ipv6: separate out procfs code from mcast.c
Date: Tue, 23 Apr 2013 13:26:27 -0400
Message-ID: <OF8FAF5C90.C6D83D68-ON85257B56.005F1762-85257B56.005FCD21@us.ibm.com>
References: <1366701302.21136.19.camel@cr0>	<20130423.031805.544535198246859192.davem@davemloft.net>
	<1366702220.21136.23.camel@cr0>	<20130423.033620.1101068519499870853.davem@davemloft.net>
	<1366702893.21136.28.camel@cr0> <87d2tlv32i.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <amwang@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:57959 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756718Ab3DWR3x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 13:29:53 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Tue, 23 Apr 2013 11:29:49 -0600
In-Reply-To: <87d2tlv32i.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 04/23/2013 08:33:57 AM:

> From: Bj=F8rn Mork <bjorn@mork.no>
=20
> Cong Wang <amwang@redhat.com> writes:

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

BTW, another thing I thought of after I sent my patch comments -- you
also need to consider the state of net.ipv6.bindv6only. When v6 is
enabled, you use one socket for v4 and v6, but if bindv6only=3D1, you
actually need a separate socket for v4 receives. If you want to support
both v4 and v6 with bindv6only=3D1, you need two sockets. Or even if yo=
u
want to support v4-only VXLAN and the sysadmin has set bindv6only=3D1.

                                                                +-DLS

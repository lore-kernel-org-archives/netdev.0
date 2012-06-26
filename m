From: David McCullough <david_mccullough@mcafee.com>
Subject: [PATCH v2] net/ipv6/route.c: packets originating on device match lo
Date: Tue, 26 Jun 2012 11:42:26 +1000
Message-ID: <20120626014226.GB3455@mcafee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dnvwsmailout1.mcafee.com ([161.69.31.173]:27274 "EHLO
	DNVWSMAILOUT1.mcafee.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757942Ab2FZBnE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 21:43:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

=46ix to allow IPv6 packets originating locally to match rules with the=
 "iff"
set to "lo".  This allows IPv6 rule matching work the same as it does f=
or
IPv4.  From the iproute2 man page:

   iif NAME
		  select  the incoming device to match.  If the interface is loop=E2=80=
=90
		  back, the rule only matches packets originating from this  host.
		  This  means that you may create separate routing tables for for=E2=80=
=90
		  warded and local packets and, hence, completely segregate them.

Cheers,
Davidm

Signed-off-by: David McCullough <david_mccullough@mcafee.com>

diff -u -p -r1.1.1.59 route.c
--- linux-3.4/net/ipv6/route.c	21 May 2012 23:15:01 -0000	1.1.1.59
+++ linux-3.4/net/ipv6/route.c	26 Jun 2012 01:41:15 -0000
@@ -931,6 +931,8 @@ struct dst_entry * ip6_route_output(stru
 {
 	int flags =3D 0;
=20
+	fl6->flowi6_iif =3D net->loopback_dev->ifindex;
+
 	if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl6->daddr))
 		flags |=3D RT6_LOOKUP_F_IFACE;
=20
=20
--=20
David McCullough,      david_mccullough@mcafee.com,  Ph:+61 734352815
McAfee - SnapGear      http://www.mcafee.com         http://www.uCdot.o=
rg

From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with no
 group
Date: Wed, 26 Mar 2014 08:47:19 -0600
Message-ID: <OF687EFECB.536163E6-ON87257CA7.00513C78-87257CA7.00513C81@us.ibm.com>
References: <20140326094754.GA19337@zed>,
	<OFD0C40ED9.015A05DD-ON87257CA2.003E72F3-87257CA2.003E7300@us.ibm.com> <CAF1J0HOd9D1t4hxjMe7Muad71o_pgKQsn3jLxqR5ZFPpj2_Nrw@mail.gmail.com> <CAJZOPZL9h0q3iiN7Q2jJWW+uEs0EpNaWqVMqQMyL+-5QGxGWPg@mail.gmail.com> <20140325.205324.1845346581147557473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:47650 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369AbaCZOrZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 10:47:25 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 26 Mar 2014 08:47:24 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 007EE3E40026
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 08:47:21 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2QCiR1G7143856
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 13:44:27 +0100
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2QElKEq019943
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 08:47:20 -0600
In-Reply-To: <20140326094754.GA19337@zed>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike Rapoport <mike.rapoport@ravellosystems.com> wrote on 03/26/2014 05=
:47:54 AM:

>=20
> It fixes the instant crashes occurring when vxlan interface goes up, =
but
> I have other crashes with custom vxlan configuration, e.g. in the
> following scenario:
>=20
> Node A:
> $ ip link add vxlan1 type vxlan id 1 dev ethA
> $ ip addr add dev vxlan1 10.0.0.1/24
> $ ip link set up dev vxlan1
> $ bridge fdb append 00:00:00:00:00:00 dev vxlan1 dst <ethB IPv4 addre=
ss>

I thought this MAC address would be an error, but I just noticed that y=
ou
submitted a patch adding interpretation of the all zeroes MAC address a=
s
a default FDB.

That patch, IMO, should've either not gone in, or should've replaced (e=
ntirely)
the existing default_dst. I think the problems you are seeing are due t=
o having
two "defaults".

Since the existing default_dst could be either a multicast group or a s=
pecific
destination, I don't understand the point of your patch:
=A0=A0=A0 afbd8bae9c798c5cdbe4439d3a50536b5438247c

except possibly to support it as a list. In that case, at least that pa=
tch should've
removed default_dst and used the all-zeroes fdb entry instead, includin=
g group
joins and leaves when it is a multicast IP address.

I certainly don't see the point of having both.

=A0=A0=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=A0=A0=A0=A0=
 +-DLS

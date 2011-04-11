From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: RE: [PATCH] net: ksz884x: convert to hw_features
Date: Mon, 11 Apr 2011 11:21:24 -0700
Message-ID: <14385191E87B904DBD836449AA30269DABBFEC@MORGANITE.micrel.com>
References: <20110410131321.BE47D13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c11o147.mxlogic.net ([208.65.144.70]:59715 "EHLO
	p01c11o147.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754851Ab1DKS2X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 14:28:23 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20110410131321.BE47D13909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=B3 Miros=B3aw wrote:
> This also fixes possible race when changing receive checksum state an=
d removes
> IPV6_CSUM_GEN_HACK as it's always set.=20
>=20
> BTW, The claim about fake IPV6 checksum looks dubious. If that were t=
rue, then there's a problem
> in networking core and should be fixed there and not in random driver=
s.=20
>=20
> BTW#2, there's no MAINTAINERS entry for this driver. I assume this dr=
iver is supported by Micrel?
>=20
> Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> ---

Micrel KSZ884X PCI Ethernet Controller does not support generating chec=
ksums on IPv6 packets.  But if the driver advertises IPv6 checksum gene=
ration support and uses the skb_copy_and_csum_dev function to consolida=
te the socket buffer, the network performance is actually better than t=
he normal method.  Common sense seems to dictate that using the normal =
method is faster than the scatter/gather then consolidation method,  bu=
t actually this method is faster.  Indeed that is another network drive=
r in the kernel that advertises IPv4 checksum generation support but do=
es not do anything special in hardware and just uses the skb_copy_and_c=
sum_dev function.  If this method is no longer faster or workable, then=
 KSZ884X driver should not advertise IPv6 checksum generation.

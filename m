From: Wolfgang Walter <linux@stwm.de>
Subject: Re: sit: Set SKB_GSO_SIT bit when performing GRO
Date: Mon, 20 Jul 2015 11:39:52 +0200
Message-ID: <2740217.XDs18yAg2Z@stwm.de>
References: <17762800.UBb5paxXY3@h2o.as.studentenwerk.mhn.de> <10491450.MOzxZjY76n@stwm.de> <20150720061459.GA12023@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Tom Herbert <tom@herbertland.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:37048 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753341AbbGTJjz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2015 05:39:55 -0400
In-Reply-To: <20150720061459.GA12023@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 20. Juli 2015, 14:14:59 schrieb Herbert Xu:
> On Fri, Jul 17, 2015 at 05:38:30PM +0200, Wolfgang Walter wrote:
> > eth1 stops sending with the patch after some time
> > disabling gro on eth0 helps
> > disabling tso or gso on eth0 and/or eth1 or both does not help
> >=20
> > eth0 and eth1 are both intel I350.
>=20
> What does ethtool -k eth1 say?

With TSO enabled:

# ethtool -k eth0
=46eatures for eth0:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-ip-generic: off [fixed]
        tx-checksum-ipv6: on
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: on
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]                                 =
        =20
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]
hw-switch-offload: off [fixed]

>=20
> Can you confirm that disabling tso on eth1 does not help?

Disabling TSO on eth1 does not help.

>=20
> Because the most plausible explanation is that we're feeding
> some bogus TSO packet to the hardware causing a tx lockup.

I run the unpatched 4.1.2 again since saturday without look. With your =
patch=20
the network card hangs within 10 minutes or so.

On the other hand I run the the patched kernel on serveral other router=
s (same=20
hardware, by the way) without problems.

So maybe the problem is that the former one routes GRE-tunnel-packets w=
hich=20
contains ISATAP packets. I don't know how deep GRO/GSO inspects a packe=
t.

>=20
> But in any case if it is a hardware lockup then it's no longer
> just a pure software bug.  No matter what we do in the stack
> the hardware should not lock up (unless of course we're feeding
> it something that's completely bogus).
>=20
> If we can't figure this out then the safest solution would be
> to disable tunnel GRO completely because it's broken as it stands.
>=20
> Cheers,

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts

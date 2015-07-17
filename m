From: Wolfgang Walter <linux@stwm.de>
Subject: Re: sit: Set SKB_GSO_SIT bit when performing GRO
Date: Fri, 17 Jul 2015 17:38:30 +0200
Message-ID: <10491450.MOzxZjY76n@stwm.de>
References: <17762800.UBb5paxXY3@h2o.as.studentenwerk.mhn.de> <2115027.IFUsFvOUns@stwm.de> <20150717015651.GA19315@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Tom Herbert <tom@herbertland.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:57354 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758446AbbGQPid convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 11:38:33 -0400
In-Reply-To: <20150717015651.GA19315@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 17. Juli 2015, 09:56:51 schrieb Herbert Xu:
> On Thu, Jul 16, 2015 at 12:58:45PM +0200, Wolfgang Walter wrote:
> > Am Donnerstag, 16. Juli 2015, 08:23:50 schrieb Herbert Xu:
> > > On Wed, Jul 15, 2015 at 02:25:59PM +0200, Wolfgang Walter wrote:
> > > > Yes. Switching TSO off and leaving GRO on works, too.
> > >=20
> > > OK, could you please try this patch?
> >=20
> > Patch works here.
>=20
> Thanks for the confirmation.  Let's add a tag for patchwork:
>=20
> Tested-by: Wolfgang Walter <linux@stwm.de>

It seems that this patch may cause a problem with another one of our ro=
uters.=20
Without the patch it had no problem, so I didn't tested it there.

With that patch one interface blocks after some time. Not even arp requ=
ests=20
get answered. It still receives packets though. Restarting the interfac=
e fixes=20
the problem.

Switching off gro for the other interface helps.

This router is different from the other ones. It does not directly rout=
e=20
isatap packets. It may routes isatap packets encapsulated in GRE packet=
s,=20
though. It is itself not an GRE-endpoint.

The router does NAT. Basically it routes the GRE-tunnel packets unatted=
 and=20
NATs most of the rest.
Not doing NAT and conntrack (and unloading all modules like nf_conntrac=
k_ipv4,=20
nf_defrag_ipv4) does not help.

eth0: extern
eth1: intern

One (IPv4) GRE-tunnel is routed between eth0 und eth1.
IPv6 ESP-tunnels are routed between eth0 and eth1
IPv4 UDP/TCP/ICMP from intern is natted with netfilter.

eth1 stops sending with the patch after some time
disabling gro on eth0 helps
disabling tso or gso on eth0 and/or eth1 or both does not help

eth0 and eth1 are both intel I350.


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts

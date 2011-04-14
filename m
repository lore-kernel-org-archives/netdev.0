From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: Re: [PATCH] ip: ip_options_compile() resilient to NULL skb route
Date: Thu, 14 Apr 2011 12:30:58 +0900
Message-ID: <20110414123058.d4ffe7fb.shimoda.hiroaki@gmail.com>
References: <4DA522B2.90200@scotdoyle.com>
	<4DA5BCF7.9020606@scotdoyle.com>
	<1302708487.3725.0.camel@edumazet-laptop>
	<20110413.144812.116375845.davem@davemloft.net>
	<1302748276.3549.20.camel@edumazet-laptop>
	<20110413195424.1d2393c6@s6510>
	<1302750214.3549.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, lkml@scotdoyle.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:46659 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758677Ab1DNDbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 23:31:04 -0400
Received: by gxk21 with SMTP id 21so550479gxk.19
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 20:31:02 -0700 (PDT)
In-Reply-To: <1302750214.3549.34.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Apr 2011 05:03:34 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 13 avril 2011 =C3=A0 19:54 -0700, Stephen Hemminger a =C3=
=A9crit :
>=20
> > I like this because it lets the bridge be transparent.
> > The existing options code adds entry in record route, and which
> > is not desirable.
>=20
> OK then, I realize I should have submitted a full patch, here it is.
>=20
> Thanks !
>=20
> [PATCH] ip: ip_options_compile() resilient to NULL skb route
>=20
> Scot Doyle demonstrated ip_options_compile() could be called with an =
skb
> without an attached route, using a setup involving a bridge, netfilte=
r,
> and forged IP packets.
>=20
> Let's make ip_options_compile() a bit more robust, instead of changin=
g
> bridge/netfilter code.

And ip_options_rcv_srr() in br_parse_ip_options() also=20
expects an skb with attached route, so below patch is needed ?

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 28a736f..3af1968 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -603,7 +603,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 	unsigned long orefdst;
 	int err;
=20
-	if (!opt->srr)
+	if (!opt->srr || !rt)
 		return 0;
=20
 	if (skb->pkt_type !=3D PACKET_HOST)

Thanks.

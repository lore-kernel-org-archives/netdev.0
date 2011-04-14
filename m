From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ip: ip_options_compile() resilient to NULL skb route
Date: Thu, 14 Apr 2011 05:03:34 +0200
Message-ID: <1302750214.3549.34.camel@edumazet-laptop>
References: <4DA522B2.90200@scotdoyle.com> <4DA5BCF7.9020606@scotdoyle.com>
	 <1302708487.3725.0.camel@edumazet-laptop>
	 <20110413.144812.116375845.davem@davemloft.net>
	 <1302748276.3549.20.camel@edumazet-laptop>  <20110413195424.1d2393c6@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, lkml@scotdoyle.com,
	shimoda.hiroaki@gmail.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63276 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758639Ab1DNDDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 23:03:39 -0400
Received: by wwa36 with SMTP id 36so1464649wwa.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 20:03:37 -0700 (PDT)
In-Reply-To: <20110413195424.1d2393c6@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 13 avril 2011 =C3=A0 19:54 -0700, Stephen Hemminger a =C3=A9=
crit :

> I like this because it lets the bridge be transparent.
> The existing options code adds entry in record route, and which
> is not desirable.

OK then, I realize I should have submitted a full patch, here it is.

Thanks !

[PATCH] ip: ip_options_compile() resilient to NULL skb route

Scot Doyle demonstrated ip_options_compile() could be called with an sk=
b
without an attached route, using a setup involving a bridge, netfilter,
and forged IP packets.

Let's make ip_options_compile() a bit more robust, instead of changing
bridge/netfilter code.

Reported-by: Scot Doyle <lkml@scotdoyle.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
---
 net/ipv4/ip_options.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 28a736f..c10ad63 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -329,7 +329,7 @@ int ip_options_compile(struct net *net,
 					pp_ptr =3D optptr + 2;
 					goto error;
 				}
-				if (skb) {
+				if (rt) {
 					memcpy(&optptr[optptr[2]-1], &rt->rt_spec_dst, 4);
 					opt->is_changed =3D 1;
 				}
@@ -371,7 +371,7 @@ int ip_options_compile(struct net *net,
 						goto error;
 					}
 					opt->ts =3D optptr - iph;
-					if (skb) {
+					if (rt)  {
 						memcpy(&optptr[optptr[2]-1], &rt->rt_spec_dst, 4);
 						timeptr =3D (__be32*)&optptr[optptr[2]+3];
 					}



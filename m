From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH RFC 3/9] net: Add fast receive encapsulation
Date: Fri, 25 Mar 2016 15:31:11 -0700
Message-ID: <1458945071.6263.2.camel@perches.com>
References: <1458772618-845742-1-git-send-email-tom@herbertland.com>
	 <1458772618-845742-4-git-send-email-tom@herbertland.com>
	 <20160325.164042.1532577255302949895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: David Miller <davem@davemloft.net>, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0217.hostedemail.com ([216.40.44.217]:42630 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754328AbcCYWbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 18:31:15 -0400
In-Reply-To: <20160325.164042.1532577255302949895.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-03-25 at 16:40 -0400, David Miller wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Wed, 23 Mar 2016 15:36:52 -0700
>=20
> > +{
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct udp_sock *up =3D udp_sk(sk);
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0int is_udplite =3D IS_UDPLITE(sk);
> > +
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0int (*encap_rcv)(struct sock *sk, st=
ruct sk_buff *skb);
> > +
>=20
> Small nit, please put this encap_rcv function pointer declaration at
> the top of the local variable list.

It might also be nice to remove the equivalent typedef and
use the same form in udp_tunnel.h
---
=C2=A0include/net/udp_tunnel.h | 7 ++-----
=C2=A01 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index b831140..71885b1 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -62,15 +62,12 @@ static inline int udp_sock_create(struct net *net,
=C2=A0	return -EPFNOSUPPORT;
=C2=A0}
=C2=A0
-typedef int (*udp_tunnel_encap_rcv_t)(struct sock *sk, struct sk_buff =
*skb);
-typedef void (*udp_tunnel_encap_destroy_t)(struct sock *sk);
-
=C2=A0struct udp_tunnel_sock_cfg {
=C2=A0	void *sk_user_data;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/* user data us=
ed by encap_rcv call back */
=C2=A0	/* Used for setting up udp_sock fields, see udp.h for details */
=C2=A0	__u8=C2=A0=C2=A0encap_type;
-	udp_tunnel_encap_rcv_t encap_rcv;
-	udp_tunnel_encap_destroy_t encap_destroy;
+	int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
+	void (*encap_destroy)(struct sock *sk);
=C2=A0};
=C2=A0
=C2=A0/* Setup the given (UDP) sock to receive UDP encapsulated packets=
 */

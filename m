From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] tcp: RST: binding oif to iif for tcp v4
Date: Sat, 04 Feb 2012 20:09:50 +0100
Message-ID: <1328382590.2731.45.camel@edumazet-laptop>
References: <1328300212-18836-1-git-send-email-shawn.lu@ericsson.com>
	 <1328304719.2480.5.camel@edumazet-laptop>
	 <62162DF05402B341B3DB59932A1FA992B5B5C9FB94@EUSAACMS0702.eamcs.ericsson.se>
	 <1328342816.2577.8.camel@edumazet-laptop>
	 <62162DF05402B341B3DB59932A1FA992B5B5C9FCF6@EUSAACMS0702.eamcs.ericsson.se>
	 <1328380194.2731.33.camel@edumazet-laptop>
	 <62162DF05402B341B3DB59932A1FA992B5B5C9FCFC@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:60350 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753381Ab2BDTKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 14:10:02 -0500
Received: by werb13 with SMTP id b13so3439294wer.19
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2012 11:10:01 -0800 (PST)
In-Reply-To: <62162DF05402B341B3DB59932A1FA992B5B5C9FCFC@EUSAACMS0702.eamcs.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 f=C3=A9vrier 2012 =C3=A0 13:42 -0500, Shawn Lu a =C3=A9cri=
t :
> Eric:
>=20
> Yes, you are right.  It helps if we do as your suggested.
>=20
> Do you want to send out a patch to address this?=20
>=20

All I was saying was that if sk is not NULL, it must have precedence.

So you could prepare/submit a patch amended by what I said, so that we
can make progress ?

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 90e4793..ca2348f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -676,6 +676,7 @@ static void tcp_v4_send_reset(struct sock *sk, stru=
ct sk_buff *skb)
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
 	arg.csumoffset =3D offsetof(struct tcphdr, check) / 2;
 	arg.flags =3D (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRCCH=
ECK : 0;
+	arg.bound_dev_if =3D sk ? sk->sk_bound_dev_if : inet_iif(skb);
=20
 	net =3D dev_net(skb_dst(skb)->dev);
 	arg.tos =3D ip_hdr(skb)->tos;

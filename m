From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Fri, 31 Dec 2010 11:35:12 +0100
Message-ID: <1293791712.2973.38.camel@edumazet-laptop>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 31 d=C3=A9cembre 2010 =C3=A0 10:29 +0100, stefani@seibold.n=
et a
=C3=A9crit :
> 		/*
> +			 * set a flag for UDPCP message
> +			 */
> +			skb->cb[sizeof(struct udp_skb_cb)] =3D 1;


Dont do that. This hides an important thing : you use one extra byte in
skb->cb[] without being explicit.

As we have one byte hole in struct udp_skb_cbn, you could use it
instead.

diff --git a/include/net/udp.h b/include/net/udp.h
index bb967dd..ceafbbf 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -47,6 +47,7 @@ struct udp_skb_cb {
 	} header;
 	__u16		cscov;
 	__u8		partial_cov;
+	__u8		udpcp_flag;
 };
 #define UDP_SKB_CB(__skb)	((struct udp_skb_cb *)((__skb)->cb))
=20

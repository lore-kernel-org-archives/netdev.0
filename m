From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.9 failed assertion in tcp_timer.c
Date: Sat, 23 Oct 2004 07:50:40 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022215040.GA13309@gondor.apana.org.au>
References: <20041019215054.GA17565@linuxace.com> <E1CK3Az-0004P2-00@gondolin.me.apana.org.au> <20041020164748.GA20905@linuxace.com> <20041020212651.GA8534@gondor.apana.org.au> <20041020225536.GA22179@linuxace.com> <20041021130339.GA19345@gondor.apana.org.au> <20041021165224.GA25399@linuxace.com> <20041021215743.GA23062@gondor.apana.org.au> <20041022185435.GA30709@linuxace.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3MwIy2ne0vdjdPXF"
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Phil Oester <kernel@linuxace.com>
Content-Disposition: inline
In-Reply-To: <20041022185435.GA30709@linuxace.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Oct 22, 2004 at 11:54:35AM -0700, Phil Oester wrote:
> 
> This patch gets it a bit further, but still panics (divide by 0?):

Oops, I forgot that this gets called on non-TSO packets as well.
So we don't really know whether it went further or not :)

We should only set the TSO size if the packet was TSO to start with.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- linux-2.6/net/ipv4/tcp_output.c.orig	2004-10-22 07:56:45.000000000 +1000
+++ linux-2.6/net/ipv4/tcp_output.c	2004-10-23 07:48:15.000000000 +1000
@@ -588,7 +588,8 @@
 	/* Any change of skb->len requires recalculation of tso
 	 * factor and mss.
 	 */
-	tcp_set_skb_tso_segs(skb, tcp_skb_mss(skb));
+	if (tcp_skb_mss(skb))
+		tcp_set_skb_tso_segs(skb, tcp_skb_mss(skb));
 
 	return 0;
 }

--3MwIy2ne0vdjdPXF--

From: bert hubert <ahu@ds9a.nl>
Subject: [IPSEC PATCH] missing break in UDP decap code Re: (udp-en/decap broken in 2.6.8-rc2?) Re: ipsec, nat-t, iproute2?
Date: Sat, 31 Jul 2004 15:08:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040731130853.GA30481@outpost.ds9a.nl>
References: <20040731083456.GA24761@outpost.ds9a.nl> <E1Bqr9r-0004av-00@gondolin.me.apana.org.au> <20040731112048.GA27893@outpost.ds9a.nl> <20040731115230.GA18537@gondor.apana.org.au> <20040731121828.GA29497@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040731121828.GA29497@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I've tried it both ways, both don't work. I should have mentioned that.

Against 2.6.8-rc2, neatly solves the problem. The missing break causes the
packet to be tested against both encapsulation types, one will always fail.

--- linux-2.6.8-rc2/net/ipv4/udp.c~orig	2004-07-31 15:04:56.000000000 +0200
+++ linux-2.6.8-rc2/net/ipv4/udp.c	2004-07-31 15:05:19.000000000 +0200
@@ -975,7 +975,7 @@
 		} else
 			/* Must be an IKE packet.. pass it through */
 			return 1;
-
+		break;
 	case UDP_ENCAP_ESPINUDP_NON_IKE:
 		/* Check if this is a keepalive packet.  If so, eat it. */
 		if (len == 1 && udpdata[0] == 0xff) {
@@ -988,6 +988,7 @@
 		} else
 			/* Must be an IKE packet.. pass it through */
 			return 1;
+		break;
 	}
 
 	/* At this point we are sure that this is an ESPinUDP packet,


-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO

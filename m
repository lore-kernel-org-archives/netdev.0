From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NAT-T] NON-IKE encapsulation
Date: Thu, 24 Jun 2004 22:36:03 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040624123603.GA1241@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="OgqxwSJOaUobr8KG"
Return-path: <netdev-bounce@oss.sgi.com>
To: agruen@suse.de, "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

I'm having trouble understanding why we need to increase alen by
two bytes for NON-IKE.  As far as I can see it's adding two bytes
of random data to the end of the packet.  Is there something
obvious that I'm missing?

If not then we'll need this patch.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/esp4.c 1.41 vs edited =====
--- 1.41/net/ipv4/esp4.c	2004-06-23 06:53:57 +10:00
+++ edited/net/ipv4/esp4.c	2004-06-24 22:26:50 +10:00
@@ -106,7 +106,6 @@
 				udpdata32 = (u32*)(uh+1);
 				udpdata32[0] = udpdata32[1] = 0;
 				esph = (struct ip_esp_hdr*)(udpdata32+2);
-				alen += 2;
 				top_iph->protocol = IPPROTO_UDP;
 				break;
 			default:
@@ -149,7 +148,6 @@
 				udpdata32 = (u32*)(uh+1);
 				udpdata32[0] = udpdata32[1] = 0;
 				esph = (struct ip_esp_hdr*)(udpdata32+2);
-				alen += 2;
 				top_iph->protocol = IPPROTO_UDP;
 				break;
 			default:

--OgqxwSJOaUobr8KG--

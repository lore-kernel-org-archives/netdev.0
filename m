From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Drop bogus NAT-T printks in esp_input
Date: Sat, 26 Jun 2004 20:07:18 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040626100718.GA28367@gondor.apana.org.au>
References: <20040625121147.GA11231@gondor.apana.org.au> <20040625123527.GA11685@gondor.apana.org.au> <20040625103928.3b1b3275.davem@redhat.com> <20040626015715.GA16496@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040626015715.GA16496@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jun 26, 2004 at 11:57:15AM +1000, herbert wrote:
> 
> However, printing a warning and then continuing is definitely wrong.
> So expect a follow-up patch to drop the packet when encap_type is
> unknown in esp_input.

Here is the patch to drop the packet if encap_type is unknown.
I've also removed the other two bogus printk's as they cannot
occur (printing a message is the last thing you want to do even
if they did occur :).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/esp4.c 1.45 vs edited =====
--- 1.45/net/ipv4/esp4.c	2004-06-26 15:42:21 +10:00
+++ edited/net/ipv4/esp4.c	2004-06-26 19:57:22 +10:00
@@ -301,28 +301,14 @@
 			switch (decap->decap_type) {
 			case UDP_ENCAP_ESPINUDP:
 			case UDP_ENCAP_ESPINUDP_NON_IKE:
-
-				if ((void*)uh == (void*)esph) {
-					printk(KERN_DEBUG
-					       "esp_input(): Got ESP; expecting ESPinUDP\n");
-					break;
-				}
-
 				encap_data->proto = AF_INET;
 				encap_data->saddr.a4 = iph->saddr;
 				encap_data->sport = uh->source;
 				encap_len = (void*)esph - (void*)uh;
-				if (encap_len != sizeof(*uh))
-				  printk(KERN_DEBUG
-					 "esp_input(): UDP -> ESP: too much room: %d\n",
-					 encap_len);
 				break;
 
 			default:
-				printk(KERN_INFO
-			       "esp_input(): processing unknown encap type: %u\n",
-				       decap->decap_type);
-				break;
+				goto out;
 			}
 		}
 

--W/nzBZO5zC0uMSeA--

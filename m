From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Sat, 14 Aug 2004 10:54:11 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814005411.GA18350@gondor.apana.org.au>
References: <20040812165954.00429e65.davem@redhat.com> <20040813090314.448c971d@dell_ss3.pdx.osdl.net> <20040813093838.6961c0d4.davem@redhat.com> <20040813215602.GA15870@gondor.apana.org.au> <20040813151923.3311b4f0.davem@redhat.com> <20040814003428.GA17760@gondor.apana.org.au> <20040813173924.6d05be15.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040813173924.6d05be15.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Aug 13, 2004 at 05:39:24PM -0700, David S. Miller wrote:
> 
> Yes and I cured the one typo in it two, idev-->in_dev :-)

Two birds with one stone :)

Here is a trivial optimisation for irda to since it doesn't hold
onto the idev.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/irda/irlan/irlan_eth.c 1.12 vs edited =====
--- 1.12/net/irda/irlan/irlan_eth.c	2004-08-14 07:40:24 +10:00
+++ edited/net/irda/irlan/irlan_eth.c	2004-08-14 10:50:29 +10:00
@@ -303,10 +303,10 @@
 	 */
 #ifdef CONFIG_INET
 	IRDA_DEBUG(4, "IrLAN: Sending gratuitous ARP\n");
-	in_dev = in_dev_get(dev);
-	if (in_dev == NULL)
-		return;
 	rcu_read_lock();
+	in_dev = __in_dev_get(dev);
+	if (in_dev == NULL)
+		goto out;
 	if (in_dev->ifa_list)
 		
 	arp_send(ARPOP_REQUEST, ETH_P_ARP, 
@@ -314,8 +314,8 @@
 		 dev, 
 		 in_dev->ifa_list->ifa_address,
 		 NULL, dev->dev_addr, NULL);
+out:
 	rcu_read_unlock();
-	in_dev_put(in_dev);
 #endif /* CONFIG_INET */
 }
 

--DocE+STaALJfprDB--

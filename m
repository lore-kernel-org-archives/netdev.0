From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NETLINK] Check netlink_insert in kernel_create
Date: Thu, 28 Oct 2004 13:07:00 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028030700.GA14181@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AqsLC8rIMeq19msA"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch checks the return value of netlink_insert() in
netlink_kernel_create().  It could fail if someone loads
the same module twice for instance.

Signed-off-by: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au> 

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/netlink/af_netlink.c 1.57 vs edited =====
--- 1.57/net/netlink/af_netlink.c	2004-10-20 15:10:40 +10:00
+++ edited/net/netlink/af_netlink.c	2004-10-28 13:00:33 +10:00
@@ -876,7 +876,10 @@
 	if (input)
 		nlk_sk(sk)->data_ready = input;
 
-	netlink_insert(sk, 0);
+	if (netlink_insert(sk, 0)) {
+		sock_release(sock);
+		return NULL;
+	}
 	return sk;
 }
 

--AqsLC8rIMeq19msA--

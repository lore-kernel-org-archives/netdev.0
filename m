From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NETLINK] Return err in netlink_connect
Date: Wed, 30 Jun 2004 21:41:44 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040630114144.GA31327@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Kj7319i9nmIyA2yE"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch makes netlink_connect() return the value of err instead of 0.
It doesn't actually make any difference since the current implementation
of netlink_autobind() never fails.  But since we went to all this trouble
to check the return status of autobind, might as well return the correct
value :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/netlink/af_netlink.c 1.49 vs edited =====
--- 1.49/net/netlink/af_netlink.c	2004-06-30 21:28:39 +10:00
+++ edited/net/netlink/af_netlink.c	2004-06-30 21:36:36 +10:00
@@ -386,7 +386,7 @@
 		nlk->dst_groups = nladdr->nl_groups;
 	}
 
-	return 0;
+	return err;
 }
 
 static int netlink_getname(struct socket *sock, struct sockaddr *addr, int *addr_len, int peer)

--Kj7319i9nmIyA2yE--

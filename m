From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH] Add nl_open to libnetlink
Date: Sat, 3 Jul 2004 19:46:32 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040703094632.GA14235@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IJpNTDwzlM2Ie8A6"
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Stephen:

I'm in the process of writing two new modules fo ip(8), ippolicy and
ipstate which will be a NETLINK based replacement for setkey.

In order to do so, I need to get libnetlink to speak the XFRM protocol.
Thus I've added a new nl_open function which allows the protocol to
be specified.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: include/libnetlink.h
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/iproute/include/libnetlink.h,v
retrieving revision 1.1.1.1
retrieving revision 1.2
diff -u -r1.1.1.1 -r1.2
--- include/libnetlink.h	2 Jul 2004 17:53:03 -0000	1.1.1.1
+++ include/libnetlink.h	3 Jul 2004 09:34:05 -0000	1.2
@@ -15,6 +15,7 @@
 };
 
 extern int rtnl_open(struct rtnl_handle *rth, unsigned subscriptions);
+extern int nl_open(struct rtnl_handle *rth, unsigned subscriptions, int proto);
 extern void rtnl_close(struct rtnl_handle *rth);
 extern int rtnl_wilddump_request(struct rtnl_handle *rth, int fam, int type);
 extern int rtnl_dump_request(struct rtnl_handle *rth, int type, void *req, int len);
Index: lib/libnetlink.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/iproute/lib/libnetlink.c,v
retrieving revision 1.1.1.1
retrieving revision 1.2
diff -u -r1.1.1.1 -r1.2
--- lib/libnetlink.c	2 Jul 2004 17:53:03 -0000	1.1.1.1
+++ lib/libnetlink.c	3 Jul 2004 09:34:06 -0000	1.2
@@ -32,11 +32,16 @@
 
 int rtnl_open(struct rtnl_handle *rth, unsigned subscriptions)
 {
+	return nl_open(rth, subscriptions, NETLINK_ROUTE);
+}
+
+int nl_open(struct rtnl_handle *rth, unsigned subscriptions, int proto)
+{
 	int addr_len;
 
 	memset(rth, 0, sizeof(rth));
 
-	rth->fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
+	rth->fd = socket(AF_NETLINK, SOCK_RAW, proto);
 	if (rth->fd < 0) {
 		perror("Cannot open netlink socket");
 		return -1;

--IJpNTDwzlM2Ie8A6--

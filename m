From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV4] Make loopback idev stick around
Date: Sat, 5 Feb 2005 16:35:32 +1100
Message-ID: <20050205053532.GA17474@gondor.apana.org.au>
References: <20050205053030.GA17412@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="wRRV7LY7NUeQGEoC"
To: "David S. Miller" <davem@davemloft.net>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050205053030.GA17412@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--wRRV7LY7NUeQGEoC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Feb 05, 2005 at 04:30:30PM +1100, herbert wrote:
> 
> As it is when loopback_dev loses all of its IPv4 addresses its
> corresponding idev will be destroyed.  Unfortunately as of last
> August route.c relies on the loopback idev to kill references
> to other idev objects.

The same problem exists for IPv6.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--wRRV7LY7NUeQGEoC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=idev-2

===== net/ipv6/addrconf.c 1.129 vs edited =====
--- 1.129/net/ipv6/addrconf.c	2005-01-18 08:13:31 +11:00
+++ edited/net/ipv6/addrconf.c	2005-02-05 16:32:34 +11:00
@@ -1914,6 +1914,11 @@
 	struct inet6_dev *idev = __in6_dev_get(dev);
 
 	switch(event) {
+	case NETDEV_REGISTER:
+		if (dev == &loopback_dev && !ipv6_find_idev(dev))
+			panic("addrconf: Failed to create loopback\n");
+		break;
+
 	case NETDEV_UP:
 		switch(dev->type) {
 		case ARPHRD_SIT:
@@ -1998,6 +2003,9 @@
 
 	ASSERT_RTNL();
 
+	if (dev == &loopback_dev)
+		how = 0;
+
 	rt6_ifdown(dev);
 	neigh_ifdown(&nd_tbl, dev);
 
@@ -3445,8 +3453,6 @@
 	 */
 	rtnl_lock();
 	addrconf_notify(&ipv6_dev_notf, NETDEV_REGISTER, &loopback_dev);
-	if (loopback_dev.flags & IFF_UP)
-		addrconf_notify(&ipv6_dev_notf, NETDEV_UP, &loopback_dev);
 	rtnl_unlock();
 
 	register_netdevice_notifier(&ipv6_dev_notf);

--wRRV7LY7NUeQGEoC--

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: oops in ip_rcv
Date: Fri, 6 May 2005 08:02:36 +1000
Message-ID: <20050505220236.GA30068@gondor.apana.org.au>
References: <20050505101542.GB7916@krispykreme> <E1DTeis-0005gu-00@gondolin.me.apana.org.au> <20050505130904.GA16593@krispykreme> <20050505112624.3ffd7f3d.davem@davemloft.net> <20050505213740.GB29526@gondor.apana.org.au> <20050505214453.GA29853@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="SLDf9lqlvOQaIe6s"
Cc: Anton Blanchard <anton@samba.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050505214453.GA29853@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, May 06, 2005 at 07:44:53AM +1000, herbert wrote:
> On Fri, May 06, 2005 at 07:37:40AM +1000, herbert wrote:
> > 
> > Could we delay the call of dev_add_pack(&ip_packet_type) until
> > the very end of inet_init? That way we're guaranteed to not
> > receive anything until it's ready.
> 
> This patch should do the trick.

Here is the version of IPv6.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/af_inet6.c 1.92 vs edited =====
--- 1.92/net/ipv6/af_inet6.c	2005-03-27 09:04:35 +10:00
+++ edited/net/ipv6/af_inet6.c	2005-05-06 08:01:36 +10:00
@@ -774,7 +774,6 @@
 	if (if6_proc_init())
 		goto proc_if6_fail;
 #endif
-	ipv6_packet_init();
 	ip6_route_init();
 	ip6_flowlabel_init();
 	err = addrconf_init();
@@ -791,6 +790,8 @@
 	/* Init v6 transport protocols. */
 	udpv6_init();
 	tcpv6_init();
+
+	ipv6_packet_init();
 	err = 0;
 out:
 	return err;
@@ -798,7 +799,6 @@
 addrconf_fail:
 	ip6_flowlabel_cleanup();
 	ip6_route_cleanup();
-	ipv6_packet_cleanup();
 #ifdef CONFIG_PROC_FS
 	if6_proc_exit();
 proc_if6_fail:

--SLDf9lqlvOQaIe6s--

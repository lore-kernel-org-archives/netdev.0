From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: ip_route_me_harder -> xfrm_lookup
Date: Mon, 8 Mar 2004 22:03:31 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040308110331.GA20719@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="zYM0uCDKw75PZbzx"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

I've received a number of reports that the any packets that are modified
by the PREROUTING mangle table will not be protected by IPsec.

The reason is that ip_route_me_harder which is called upon the exit
of the mangle table does not set the proto field.  This means that
xfrm_lookup is never called.

The following patch sets the proto field so that the packet can be
protected by IPsec.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: kernel-2.5/net/core/netfilter.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/core/netfilter.c,v
retrieving revision 1.1.1.10
diff -u -r1.1.1.10 netfilter.c
--- kernel-2.5/net/core/netfilter.c	8 Oct 2003 19:24:04 -0000	1.1.1.10
+++ kernel-2.5/net/core/netfilter.c	8 Mar 2004 10:52:39 -0000
@@ -639,6 +639,7 @@
 #ifdef CONFIG_IP_ROUTE_FWMARK
 		fl.nl_u.ip4_u.fwmark = (*pskb)->nfmark;
 #endif
+		fl.proto = iph->protocol;
 		if (ip_route_output_key(&rt, &fl) != 0)
 			return -1;
 

--zYM0uCDKw75PZbzx--

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [RTNETLINK] Provide real oif
Date: Tue, 2 Dec 2003 22:02:24 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202110224.GA25957@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ZGiS0Q5IWpPtfppv"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch adds a new attribute RTA_PREFOIF to the RTNETLINK interface
so that we can send the real oif to user space.  Hmm, would RTA_REALOIF
be a better name? It really should be called RTA_OIF but that's already
taken.

Currently if there are two entries in the routing cache that only differ
by the value of oif then they will appear identical to user space.  The
only way to tell them apart would be to export the value of oif from
the kernel.

Of course this patch by itself doesn't do anything.  But once it is in
we can extend ip(8) to display it.

PS IPv6 doesn't seem to have an oif field so it doesn't need this.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: kernel-source-2.5/include/linux/rtnetlink.h
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/include/linux/rtnetlink.h,v
retrieving revision 1.5
diff -u -r1.5 rtnetlink.h
--- kernel-source-2.5/include/linux/rtnetlink.h	18 Oct 2003 07:12:47 -0000	1.5
+++ kernel-source-2.5/include/linux/rtnetlink.h	2 Dec 2003 10:52:34 -0000
@@ -200,6 +200,7 @@
 	RTA_FLOW,
 	RTA_CACHEINFO,
 	RTA_SESSION,
+	RTA_PREFOIF,
 };
 
 #define RTA_MAX RTA_SESSION
Index: kernel-source-2.5/net//ipv4/route.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/ipv4/route.c,v
retrieving revision 1.3
diff -u -r1.3 route.c
--- kernel-source-2.5/net//ipv4/route.c	24 Nov 2003 09:52:04 -0000	1.3
+++ kernel-source-2.5/net//ipv4/route.c	2 Dec 2003 10:57:12 -0000
@@ -2347,6 +2347,8 @@
 #endif
 			RTA_PUT(skb, RTA_IIF, sizeof(int), &rt->fl.iif);
 	}
+	if (rt->fl.oif)
+		RTA_PUT(skb, RTA_PREFOIF, sizeof(int), &rt->fl.oif);
 
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;

--ZGiS0Q5IWpPtfppv--

From: Masahide Nakamura <nakam@linux-ipv6.org>
Subject: [PATCH]Fix adding SA through netlink(xfrm_user)
Date: Thu, 29 Jul 2004 00:10:58 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040729001058.48cd1791@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <davem@redhat.com>, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

When adding IPsec SA with PF_KEY (pfkey_add()),
xfrm_probe_algs() is called to make all algorithms valid.
However, it is missing to call it with netlink (xfrm_user) case and
it causes xfrm_aalg_get_byname() return NULL even if the name of
algorithm seems to be correct.

The patch fixes it and is against 2.6.7. Please apply it.

Index: linux26/net/xfrm/xfrm_user.c
===================================================================
RCS file: /cvsroot/usagi/usagi/kernel/linux26/net/xfrm/xfrm_user.c,v
retrieving revision 1.1.1.13
diff -u -r1.1.1.13 xfrm_user.c
--- linux26/net/xfrm/xfrm_user.c	3 Apr 2004 05:52:43 -0000	1.1.1.13
+++ linux26/net/xfrm/xfrm_user.c	28 Jul 2004 14:26:21 -0000
@@ -258,6 +258,8 @@
 	if (err)
 		return err;
 
+	xfrm_probe_algs();
+
 	x = xfrm_state_construct(p, (struct rtattr **) xfrma, &err);
 	if (!x)
 		return err;



-- 
Masahide NAKAMURA

From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH] fix return value on MCAST_MSFILTER error case
Date: Tue, 20 Apr 2004 18:05:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040420180551.I21045@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Return -EINVAL if (GROUP_FILTER_SIZE(gsf->gf_numsrc) > optlen)

===== net/ipv4/ip_sockglue.c 1.22 vs edited =====
--- 1.22/net/ipv4/ip_sockglue.c	Mon Mar  8 12:15:03 2004
+++ edited/net/ipv4/ip_sockglue.c	Tue Apr 20 18:00:50 2004
@@ -800,7 +800,7 @@
 				goto mc_msf_out;
 			}
 			if (GROUP_FILTER_SIZE(gsf->gf_numsrc) > optlen) {
-				err = EINVAL;
+				err = -EINVAL;
 				goto mc_msf_out;
 			}
 			msize = IP_MSFILTER_SIZE(gsf->gf_numsrc);

From: Jason Lunz <lunz@falooley.org>
Subject: PATCH: sundance #4a
Date: Thu, 19 Sep 2002 16:51:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020919205134.GA17492@orr.falooley.org>
References: <Pine.LNX.4.44.0209190903050.29420-100000@beohost.scyld.com> <3D8A25D1.3060300@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="LZvS9be/3tNcYl/X"
Cc: netdev@oss.sgi.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Donald Becker <becker@scyld.com>, Richard Gooch <rgooch@ras.ucalgary.ca>,
   "Patrick R. McManus" <mcmanus@ducksong.com>, edward_peng@dlink.com.tw
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Content-Disposition: inline
In-Reply-To: <3D8A25D1.3060300@mandrakesoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


If you're going to bail when reading the ASIC fails, you need to
unregister the dev before you return or Bad Things happen.

Jason

--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=sundance-4a

--- sundance-garzik.c	Thu Sep 19 16:45:57 2002
+++ sundance-unreg.c	Thu Sep 19 16:48:22 2002
@@ -599,6 +599,7 @@
 		if (phy_idx == 0) {
 			printk(KERN_INFO "%s: No MII transceiver found, aborting.  ASIC status %x\n",
 				   dev->name, readl(ioaddr + ASICCtrl));
+			unregister_netdev(dev);
 			goto err_out_unmap_rx;
 		}
 

--LZvS9be/3tNcYl/X--

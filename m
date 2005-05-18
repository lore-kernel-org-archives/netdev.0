From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.12-rc4 1/1] tulip: add return to ULI526X clause in tulip_mdio_write
Date: Wed, 18 May 2005 13:41:33 -0400
Message-ID: <20050518174132.GB16148@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, Clear.Zhang@uli.com.tw
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The 'if' clause for ULI526X in tulip_mdio_write allows for
spin_unlock_irqrestore to be called twice for tp->mii_lock.  I believe
this is caused by the unintentional omission of a return at the end
of that clause.  This patch adds that return.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
I'm copying Clear Zhang on this.  As the author of the patch that
added this code, he should know whether or not my intuitive fix is
actually correct... :-)

 drivers/net/tulip/media.c |    1 +
 1 files changed, 1 insertion(+)

--- linux-2.6.12-rc4/drivers/net/tulip/media.c.orig	2005-05-18 09:19:07.392564077 -0400
+++ linux-2.6.12-rc4/drivers/net/tulip/media.c	2005-05-18 09:22:47.107779100 -0400
@@ -174,6 +174,7 @@ void tulip_mdio_write(struct net_device 
 				break;
 		}
 		spin_unlock_irqrestore(&tp->mii_lock, flags);
+		return;
 	}
 		
 	/* Establish sync by sending 32 logic ones. */
-- 
John W. Linville
linville@tuxdriver.com

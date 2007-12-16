From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/5] [IrDA] irlmp_unregister_link needs to free
	lsaps
Date: Mon, 17 Dec 2007 00:46:51 +0100
Message-ID: <20071216234933.289314655@sortiz.org>
References: <20071216234648.774780960@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=irlmp-delete-lsaps-hashbin.diff
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

While testing the mcs7780 based IrDA USB dongle I've stumbled upon
memory leak in irlmp_unregister_link(). Hashbin for lsaps is created in
irlmp_register_link and should probably be freed in irlmp_unregister_link().

Signed-off-by: Hinko Kocevar <hinko.kocevar-oztQky9TsV0CZtS6sZ44uQ@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>

---
 net/irda/irlmp.c |    1 +
 1 file changed, 1 insertion(+)

Index: net-2.6/net/irda/irlmp.c
===================================================================
--- net-2.6.orig/net/irda/irlmp.c	2007-11-25 05:54:02.000000000 +0100
+++ net-2.6/net/irda/irlmp.c	2007-11-25 07:12:13.000000000 +0100
@@ -353,6 +353,7 @@
 		/* Final cleanup */
 		del_timer(&link->idle_timer);
 		link->magic = 0;
+		hashbin_delete(link->lsaps, (FREE_FUNC) __irlmp_close_lsap);
 		kfree(link);
 	}
 }

-- 


-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services
for just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace

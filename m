From: Sascha Silbe <silbe@activitycentral.com>
Subject: [PATCH] Add libertas_disablemesh module parameter to disable mesh
	interface
Date: Wed, 11 May 2011 14:52:34 +0200
Message-ID: <1305118354-17337-1-git-send-email-silbe@activitycentral.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: libertas-dev@lists.infradead.org, Dan Williams <dcbw@redhat.com>,
	netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, devel@lists.laptop.org
To: linux-wireless@vger.kernel.org
Return-path: <devel-bounces@lists.laptop.org>
List-Unsubscribe: <http://lists.laptop.org/listinfo/devel>,
	<mailto:devel-request@lists.laptop.org?subject=unsubscribe>
List-Archive: <http://lists.laptop.org/pipermail/devel>
List-Post: <mailto:devel@lists.laptop.org>
List-Help: <mailto:devel-request@lists.laptop.org?subject=help>
List-Subscribe: <http://lists.laptop.org/listinfo/devel>,
	<mailto:devel-request@lists.laptop.org?subject=subscribe>
Sender: devel-bounces@lists.laptop.org
Errors-To: devel-bounces@lists.laptop.org
List-Id: netdev.vger.kernel.org

This allows individual users and deployments to disable mesh support at
runtime, i.e. without having to build and maintain a custom kernel.

Based on a patch by Paul Fox <pgf@laptop.org>.
Signed-off-by: Sascha Silbe <silbe@activitycentral.com>
---
 drivers/net/wireless/libertas/main.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

The patch is based on the OLPC 2.6.35 kernel tree, but applies cleanly to
wireless-next.

diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 8445473..62069e2 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -41,6 +41,10 @@ unsigned int lbs_debug;
 EXPORT_SYMBOL_GPL(lbs_debug);
 module_param_named(libertas_debug, lbs_debug, int, 0644);

+unsigned int lbs_disablemesh;
+EXPORT_SYMBOL_GPL(lbs_disablemesh);
+module_param_named(libertas_disablemesh, lbs_disablemesh, int, 0644);
+

 /* This global structure is used to send the confirm_sleep command as
  * fast as possible down to the firmware. */
@@ -1086,7 +1090,10 @@ int lbs_start_card(struct lbs_private *priv)

 	lbs_update_channel(priv);

-	lbs_init_mesh(priv);
+	if (!lbs_disablemesh)
+		lbs_init_mesh(priv);
+	else
+		lbs_pr_info("%s: mesh disabled\n", dev->name);

 	/*
 	 * While rtap isn't related to mesh, only mesh-enabled
--
1.7.4.1

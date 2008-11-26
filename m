From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 06/39] genetlink: export genl_unregister_mc_group()
Date: Tue, 25 Nov 2008 23:39:02 -0800
Message-ID: <d89210b560a6c71f5432b7b5ec7409fcd084c30f.1227684996.git.inaky@linux.intel.com>
References: <cover.1227684995.git.inaky@linux.intel.com>
Cc: Thomas Graf <tgraf@suug.ch>, Johannes Berg <johannes@sipsolutions.net>,
	wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1227684995.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

Add an EXPORT_SYMBOL() to genl_unregister_mc_group(), to allow
unregistering groups on the run. EXPORT_SYMBOL_GPL() is not used as
the rest of the functions exported by this module (eg:
genl_register_mc_group) are also not _GPL().

Cleanup is currently done when unregistering a family, but there is
no way to unregister a single multicast group due to that function not
being exported. Seems to be a mistake as it is documented as for
external consumption.

This is needed by the WiMAX stack to be able to cleanup unused mc
groups.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: Thomas Graf <tgraf@suug.ch>
---
 net/netlink/genetlink.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 3e1191c..1d3dd30 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -225,6 +225,7 @@ void genl_unregister_mc_group(struct genl_family *family,
 	__genl_unregister_mc_group(family, grp);
 	genl_unlock();
 }
+EXPORT_SYMBOL(genl_unregister_mc_group);
 
 static void genl_unregister_mc_groups(struct genl_family *family)
 {
-- 
1.5.6.5

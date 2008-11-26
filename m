From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 06/39] genetlink: export genl_unregister_mc_group()
Date: Wed, 26 Nov 2008 14:40:25 -0800
Message-ID: <ffc312e09e5728d546c67dd26aa1f53bacc3b0f1.1227691434.git.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com>
Cc: wimax@linuxwimax.org, Johannes Berg <johannes@sipsolutions.net>,
	Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:43324 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752139AbYKZWlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 17:41:13 -0500
In-Reply-To: <cover.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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


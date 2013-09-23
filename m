From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool] sfc: Stop using bitfields in register definition
 structures
Date: Mon, 23 Sep 2013 19:14:58 +0100
Message-ID: <1379960098.2485.48.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	David Laight <David.Laight@ACULAB.COM>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:27034 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612Ab3IWSPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 14:15:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This doesn't make any difference to the static data size, and
decreases the code size a little.

Reported-by: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 sfc.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/sfc.c b/sfc.c
index 2e15f52..1bb3689 100644
--- a/sfc.c
+++ b/sfc.c
@@ -2562,8 +2562,8 @@
 
 struct efx_nic_reg_field {
 	const char *name;
-	u32 lbn:7, width:8;
-	u32 min_revision:3, max_revision:3;
+	u8 lbn, width;
+	u8 min_revision, max_revision;
 };
 
 #define REGISTER_FIELD_RENAME(name, display_name, arch, min_rev, max_rev) { \
@@ -3545,8 +3545,8 @@ static const struct efx_nic_reg_field efx_nic_reg_fields_BIU_MC_SFT_STATUS[] = {
 struct efx_nic_reg {
 	const char *name;
 	const struct efx_nic_reg_field *fields;
-	u32 field_count:7;
-	u32 min_revision:3, max_revision:3;
+	u8 field_count;
+	u8 min_revision, max_revision;
 };
 
 #define REGISTER(name, arch, min_rev, max_rev) {			\
@@ -3677,9 +3677,10 @@ static const struct efx_nic_reg efx_nic_regs[] = {
 struct efx_nic_reg_table {
 	const char *name;
 	const struct efx_nic_reg_field *fields;
-	u32 field_count:7;
-	u32 min_revision:3, max_revision:3;
-	u32 step:6, rows:21;
+	u8 field_count;
+	u8 min_revision, max_revision;
+	u8 step;
+	u32 rows;
 };
 
 #define REGISTER_TABLE_DIMENSIONS(name, _, arch, min_rev, max_rev, step, rows) { \
-- 
1.8.1.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

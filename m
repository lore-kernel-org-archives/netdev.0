From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH] ethtool: Dump eeprom info for soldered on modules
Date: Sun, 16 Aug 2015 04:05:18 +0200
Message-ID: <1439690718-10040-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Ben Hutchings <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60221 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751749AbbHPCMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Aug 2015 22:12:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modules which are soldered onto the motherboard may also use the sff8079
EEPROM format. Dump these in the same way as SFP modules.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 sfpid.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/sfpid.c b/sfpid.c
index b1a5044..0b5cd62 100644
--- a/sfpid.c
+++ b/sfpid.c
@@ -401,7 +401,7 @@ static void sff8079_show_options(const __u8 *id)
 void sff8079_show_all(const __u8 *id)
 {
 	sff8079_show_identifier(id);
-	if ((id[0] == 0x03) && (id[1] == 0x04)) {
+	if (((id[0] == 0x02) || (id[0] == 0x03)) && (id[1] == 0x04)) {
 		sff8079_show_ext_identifier(id);
 		sff8079_show_connector(id);
 		sff8079_show_transceiver(id);
-- 
2.1.4

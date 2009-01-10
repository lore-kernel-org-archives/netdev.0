From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 1/2] smsc911x: fix smsc911x_reg_read compiler warning
Date: Sat, 10 Jan 2009 13:29:28 +0000
Message-ID: <1231594169-24988-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:60415 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753416AbZAJN24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 08:28:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if this code path is ever hit, the platform_data struct isn't properly
configured with a bus width flag so the device won't work (hence the
BUG()).

This patch adds a dummy return statement to eliminate this compiler
warning:

drivers/net/smsc911x.c: In function 'smsc911x_reg_read':
drivers/net/smsc911x.c:148: warning: control reaches end of non-void function

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index dc3f110..1f443d8 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -144,6 +144,7 @@ static inline u32 smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
 	}
 
 	BUG();
+	return 0;
 }
 
 static inline void smsc911x_reg_write(struct smsc911x_data *pdata, u32 reg,
-- 
1.6.0.6


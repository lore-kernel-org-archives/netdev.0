From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] ServerEngines, benet: Avoid potential null deref in
 be_cmd_get_seeprom_data()
Date: Thu, 3 Feb 2011 22:27:09 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1102032224110.1369@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-drivers@serverengines.com, linux-kernel@vger.kernel.org,
	Ajit Khaparde <ajitk@serverengines.com>,
	Sarveshwar Bandi <sarveshwarb@serverengines.com>,
	Subbu Seetharaman <subbus@serverengines.com>,
	Sathya Perla <sathyap@serverengines.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

wrb_from_mccq() may return null, so we may crash on a null deref in 
be_cmd_get_seeprom_data().
This avoids that potential crash.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 be_cmds.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 0c7811f..ec4a21d 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1786,6 +1786,8 @@ int be_cmd_get_seeprom_data(struct be_adapter *adapter,
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb)
+		return -EBUSY;
 	req = nonemb_cmd->va;
 	sge = nonembedded_sgl(wrb);
 

-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

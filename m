From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] rt2x00: Don't leak mem in error path of
 rt2x00lib_request_firmware()
Date: Tue, 11 Jan 2011 00:47:44 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101110044580.32164@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: users@rt2x00.serialmonkey.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Gertjan van Wingerde <gwingerde@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ivo van Doorn <IvDoorn@gmail.com>
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We need to release_firmware() in order not to leak memory.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 rt2x00firmware.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/rt2x00/rt2x00firmware.c b/drivers/net/wireless/rt2x00/rt2x00firmware.c
index f0e1eb7..be0ff78 100644
--- a/drivers/net/wireless/rt2x00/rt2x00firmware.c
+++ b/drivers/net/wireless/rt2x00/rt2x00firmware.c
@@ -58,6 +58,7 @@ static int rt2x00lib_request_firmware(struct rt2x00_dev *rt2x00dev)
 
 	if (!fw || !fw->size || !fw->data) {
 		ERROR(rt2x00dev, "Failed to read Firmware.\n");
+		release_firmware(fw);
 		return -ENOENT;
 	}
 


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

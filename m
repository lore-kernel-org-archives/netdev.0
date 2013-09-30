From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] isdn: eicon: free pointer after using it in log msg in
 divas_um_idi_delete_entity()
Date: Mon, 30 Sep 2013 21:25:27 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1309302119550.4992@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Armin Schindler <mac@melware.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not really a problem, but nice IMHO; the Coverity static analyzer
complains that we use the pointer 'e' after it has been freed, so move
the freeing below the final use, even if that use is just using the
value of the pointer and not actually dereferencing it.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/isdn/hardware/eicon/um_idi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/um_idi.c b/drivers/isdn/hardware/eicon/um_idi.c
index 7cab5c3..e151971 100644
--- a/drivers/isdn/hardware/eicon/um_idi.c
+++ b/drivers/isdn/hardware/eicon/um_idi.c
@@ -288,9 +288,9 @@ int divas_um_idi_delete_entity(int adapter_nr, void *entity)
 	cleanup_entity(e);
 	diva_os_free(0, e->os_context);
 	memset(e, 0x00, sizeof(*e));
-	diva_os_free(0, e);

 	DBG_LOG(("A(%d) remove E:%08x", adapter_nr, e));
+	diva_os_free(0, e);

 	return (0);
 }
--
1.7.1


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

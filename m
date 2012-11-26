From: Tommi Rantala <tt.rantala@gmail.com>
Subject: [PATCH] irda: irttp: fix memory leak in irttp_open_tsap() error path
Date: Mon, 26 Nov 2012 16:16:44 +0200
Message-ID: <1353939404-19264-1-git-send-email-tt.rantala@gmail.com>
Cc: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Dave Jones <davej@redhat.com>,
	Tommi Rantala <tt.rantala@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:56772 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260Ab2KZOQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 09:16:58 -0500
Received: by mail-wg0-f44.google.com with SMTP id dr13so2168469wgb.1
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2012 06:16:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup the memory we allocated earlier in irttp_open_tsap() when we hit
this error path. The leak goes back to at least 1da177e4
("Linux-2.6.12-rc2").

Discovered with Trinity (the syscall fuzzer).

Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>
---
 net/irda/irttp.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 1002e33..ae43c62 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -441,6 +441,7 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	lsap = irlmp_open_lsap(stsap_sel, &ttp_notify, 0);
 	if (lsap == NULL) {
 		IRDA_DEBUG(0, "%s: unable to allocate LSAP!!\n", __func__);
+		__irttp_close_tsap(self);
 		return NULL;
 	}
 
-- 
1.7.9.5

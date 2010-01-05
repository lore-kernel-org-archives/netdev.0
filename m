From: Greg Kroah-Hartman <gregkh@suse.de>
Subject: [PATCH 39/97] Libertas: fix buffer overflow in lbs_get_essid()
Date: Mon,  4 Jan 2010 16:32:52 -0800
Message-ID: <1262651630-7354-39-git-send-email-gregkh@suse.de>
References: <20100105003133.GA7199@kroah.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, Daniel Mack <daniel@caiaq.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Maithili Hinge <maithili@marvell.com>,
	Kiran Divekar <dkiran@marvell.com>,
	Michael Hirsch <m.hirsch@raumfeld.com>, netdev@vger.kernel.org,
	libertas-dev@lists.infradead.org,
	linux-wireless@lists.infradead.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	stable-review@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:34218 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754309Ab0AEAfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 19:35:13 -0500
In-Reply-To: <20100105003133.GA7199@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <daniel@caiaq.de>

commit 45b241689179a6065384260242637cf21dabfb2d upstream.

The libertas driver copies the SSID buffer back to the wireless core and
appends a trailing NULL character for termination. This is

a) unnecessary because the buffer is allocated with kzalloc and is hence
   already NULLed when this function is called, and

b) for priv->curbssparams.ssid_len == 32, it writes back one byte too
   much which causes memory corruptions.

Fix this by removing the extra write.

Signed-off-by: Daniel Mack <daniel@caiaq.de>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Maithili Hinge <maithili@marvell.com>
Cc: Kiran Divekar <dkiran@marvell.com>
Cc: Michael Hirsch <m.hirsch@raumfeld.com>
Cc: netdev@vger.kernel.org
Cc: libertas-dev@lists.infradead.org
Cc: linux-wireless@lists.infradead.org
Acked-by: Holger Schurig <holgerschurig@gmail.com>
Acked-by: Dan Williams <dcbw@redhat.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
---
 drivers/net/wireless/libertas/wext.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index be837a0..01c738b 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -1953,10 +1953,8 @@ static int lbs_get_essid(struct net_device *dev, struct iw_request_info *info,
 	if (priv->connect_status == LBS_CONNECTED) {
 		memcpy(extra, priv->curbssparams.ssid,
 		       priv->curbssparams.ssid_len);
-		extra[priv->curbssparams.ssid_len] = '\0';
 	} else {
 		memset(extra, 0, 32);
-		extra[priv->curbssparams.ssid_len] = '\0';
 	}
 	/*
 	 * If none, we may want to get the one that was set
-- 
1.6.6


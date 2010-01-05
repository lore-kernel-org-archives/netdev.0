From: Greg KH <gregkh@suse.de>
Subject: [01/10] Libertas: fix buffer overflow in lbs_get_essid()
Date: Tue, 05 Jan 2010 11:47:52 -0800
Message-ID: <20100105194914.321801567@mini.kroah.org>
References: <20100105195007.GA23952@kroah.com>
Cc: Daniel Mack <daniel@caiaq.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Maithili Hinge <maithili@marvell.com>,
	Kiran Divekar <dkiran@marvell.com>,
	Michael Hirsch <m.hirsch@raumfeld.com>, netdev@vger.kernel.org,
	libertas-dev@lists.infradead.org,
	linux-wireless@lists.infradead.org,
	Holger Schurig <holgerschurig@gmail.com>,
	Dan Williams <dcbw@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	stable-review@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755294Ab0AETwy@vger.kernel.org>
In-Reply-To: <20100105195007.GA23952@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2.6.27-stable review patch.  If anyone has any objections, please let us know.

------------------

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
 1 file changed, 2 deletions(-)

--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -1899,10 +1899,8 @@ static int lbs_get_essid(struct net_devi
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

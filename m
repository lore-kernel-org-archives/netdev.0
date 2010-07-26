From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2010-07-26
Date: Mon, 26 Jul 2010 15:49:20 -0400
Message-ID: <20100726194919.GH3903@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here are two more late-bloomers for 2.6.35.  Both are tiny and isolated,
and they fix documented regression BUGs as indicated in their commit logs.

The one from me changes a netif_rx to a netif_rx_ni -- the execution
path is in process context, coming from userland.  The bug reporter
confirmed that it addressed the problem he reported.

The one from Ming Lei has been in net-next-2.6 for a while already.
More recently, someone posted an identical patch indicated it addressed
the BUG as reported in the cited LKML thread.

I think it would be best to get these into 2.6.35 if at all possible.
Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 3b87956ea645fb4de7e59c7d0aa94de04be72615:

  net sched: fix race in mirred device removal (2010-07-24 21:04:20 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

John W. Linville (1):
      wireless: use netif_rx_ni in ieee80211_send_layer2_update

Ming Lei (1):
      ath9k: fix dma direction for map/unmap in ath_rx_tasklet

 drivers/net/wireless/ath/ath9k/recv.c |    4 ++--
 net/mac80211/cfg.c                    |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index ca6065b..e3e5291 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -844,9 +844,9 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 	int dma_type;
 
 	if (edma)
-		dma_type = DMA_FROM_DEVICE;
-	else
 		dma_type = DMA_BIDIRECTIONAL;
+	else
+		dma_type = DMA_FROM_DEVICE;
 
 	qtype = hp ? ATH9K_RX_QUEUE_HP : ATH9K_RX_QUEUE_LP;
 	spin_lock_bh(&sc->rx.rxbuflock);
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index c7000a6..67ee34f 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -632,7 +632,7 @@ static void ieee80211_send_layer2_update(struct sta_info *sta)
 	skb->dev = sta->sdata->dev;
 	skb->protocol = eth_type_trans(skb, sta->sdata->dev);
 	memset(skb->cb, 0, sizeof(skb->cb));
-	netif_rx(skb);
+	netif_rx_ni(skb);
 }
 
 static void sta_apply_parameters(struct ieee80211_local *local,
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Damien Riegel <damien.riegel@savoirfairelinux.com>
Subject: wcn36xx: connection monitoring issue
Date: Fri, 27 Oct 2017 11:55:09 -0400
Message-ID: <20171027155509.bbtcmvxyerlovzsq@workotop.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eugene Krasnikov <k.eugene.e@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
        wcn36xx@lists.infradead.org
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


I'm working on a board derived from the DragonBoard-410c (apq8016 +
wcn3620) and noticed an issue with WiFi connection monitoring. When I
get out of the range of the access point, the device stays associated,
no matter how far I go or how long I wait.

The chip on this board is the WCN3620, and the driver sets
IEEE80211_HW_CONNECTION_MONITOR at drivers/net/wireless/ath/wcn36xx/main.c:1127, 
so the hardware is supposed to do the monitoring, but it looks like it
doesn't. If I comment out this flag (snippet at the end of the email),
the correct behaviour is observed.

Has anyone else noticed that issue?


Thanks,
Damien

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index 35bd50bcbbd5..2aa1643d15bf 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -1124,7 +1124,6 @@ static int wcn36xx_init_ieee80211(struct wcn36xx *wcn)

        ieee80211_hw_set(wcn->hw, TIMING_BEACON_ONLY);
        ieee80211_hw_set(wcn->hw, AMPDU_AGGREGATION);
-       ieee80211_hw_set(wcn->hw, CONNECTION_MONITOR);
        ieee80211_hw_set(wcn->hw, SUPPORTS_PS);
        ieee80211_hw_set(wcn->hw, SIGNAL_DBM);
        ieee80211_hw_set(wcn->hw, HAS_RATE_CONTROL);

From: Fabio Baltieri <fabio.baltieri@gmail.com>
Subject: [PATCH] mac80211: use oneshot blink API for LED triggers
Date: Wed, 24 Jul 2013 02:09:40 +0200
Message-ID: <1374624581-6012-1-git-send-email-fabio.baltieri@gmail.com>
Cc: linux-wireless@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Fabio Baltieri <fabio.baltieri@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Johannes, John,

This patch changes the mac80211 LED driver to use the generic oneshot
LED API.

The current mac80211 blink code seems to lead to very short tx blinks
and toggles the LED on tx.  The oneshot API ensure a complete LED on-off
cycle for each blink event, thus getting a better result for an activity
indicator: one visible blink for sporadic events and a steady on-off
blink sequence on constant traffic.

Would you consider this patch for wireless-next?

Thanks,
Fabio

Fabio Baltieri (1):
  mac80211: use oneshot blink API for LED triggers

 net/mac80211/ieee80211_i.h |  1 -
 net/mac80211/led.c         | 21 +++++++++------------
 net/mac80211/led.h         |  2 +-
 net/mac80211/status.c      |  2 +-
 net/mac80211/tx.c          |  1 -
 5 files changed, 11 insertions(+), 16 deletions(-)

-- 
1.8.2

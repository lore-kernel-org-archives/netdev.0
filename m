From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 6/7] staging: r8712u: Fix Sparse warnings in
 rtl871x_ioctl_linux.c
Date: Fri, 10 Feb 2017 21:30:29 -0600
Message-ID: <20170211033030.28827-7-Larry.Finger@lwfinger.net>
References: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Sparse reports the following:
  CHECK   drivers/staging/rtl8712/rtl871x_ioctl_linux.c
drivers/staging/rtl8712/rtl871x_ioctl_linux.c:1422:46: warning: restricted __le16 degrades to integer
drivers/staging/rtl8712/rtl871x_ioctl_linux.c:1424:46: warning: restricted __le16 degrades to integer

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8712/rtl871x_ioctl_linux.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/rtl8712/rtl871x_ioctl_linux.c b/drivers/staging/rtl8712/rtl871x_ioctl_linux.c
index 0dc18d6..f4167f1 100644
--- a/drivers/staging/rtl8712/rtl871x_ioctl_linux.c
+++ b/drivers/staging/rtl8712/rtl871x_ioctl_linux.c
@@ -1419,9 +1419,9 @@ static int r8711_wx_get_rate(struct net_device *dev,
 			ht_cap = true;
 			pht_capie = (struct ieee80211_ht_cap *)(p + 2);
 			memcpy(&mcs_rate, pht_capie->supp_mcs_set, 2);
-			bw_40MHz = (pht_capie->cap_info &
+			bw_40MHz = (le16_to_cpu(pht_capie->cap_info) &
 				    IEEE80211_HT_CAP_SUP_WIDTH) ? 1 : 0;
-			short_GI = (pht_capie->cap_info &
+			short_GI = (le16_to_cpu(pht_capie->cap_info) &
 				    (IEEE80211_HT_CAP_SGI_20 |
 				    IEEE80211_HT_CAP_SGI_40)) ? 1 : 0;
 		}
-- 
2.10.2

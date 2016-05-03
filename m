From: Kangjie Lu <kangjielu@gmail.com>
Subject: [PATCH] fix infoleak in wireless
Date: Tue,  3 May 2016 16:40:13 -0400
Message-ID: <1462308013-6032-1-git-send-email-kjlu@gatech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Kangjie Lu <kjlu@gatech.edu>
To: johannes@sipsolutions.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 6-bytes array =E2=80=9Cmac_addr=E2=80=9D is not initialized in the =
dump_station
implementations of =E2=80=9Cdrivers/staging/wilc1000/wilc_wfi_cfgoperat=
ions.c=E2=80=9D
and =E2=80=9Cdrivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c=E2=80=9D=
, so all 6
bytes may be leaked.

Signed-off-by: Kangjie Lu <kjlu@gatech.edu>
---
 net/wireless/nl80211.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 056a730..2e92d14 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -3905,6 +3905,7 @@ static int nl80211_dump_station(struct sk_buff *s=
kb,
=20
 	while (1) {
 		memset(&sinfo, 0, sizeof(sinfo));
+		eth_zero_addr(mac_addr);
 		err =3D rdev_dump_station(rdev, wdev->netdev, sta_idx,
 					mac_addr, &sinfo);
 		if (err =3D=3D -ENOENT)
--=20
1.9.1

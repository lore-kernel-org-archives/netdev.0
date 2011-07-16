From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: [PATCH 1/2] Bluetooth: Fix regression in L2CAP connection procedure
Date: Sat, 16 Jul 2011 01:30:20 -0300
Message-ID: <1310790621-28510-2-git-send-email-padovan@profusion.mobi>
References: <1310790621-28510-1-git-send-email-padovan@profusion.mobi>
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1310790621-28510-1-git-send-email-padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>

Caused by the following commit, partially revert it.

commit 9fa7e4f76f3658ba1f44fbdb95c77e7df3f53f95
Author: Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Date:   Thu Jun 30 16:11:30 2011 -0300

    Bluetooth: Fix regression with incoming L2CAP connections

    PTS test A2DP/SRC/SRC_SET/TC_SRC_SET_BV_02_I revealed that
    ( probably after the df3c3931e commit ) the l2cap connection
    could not be established in case when the "Auth Complete" HCI
    event does not arive before the initiator send "Configuration
    request", in which case l2cap replies with "Command rejected"
    since the channel is still in BT_CONNECT2 state.

Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
---
 net/bluetooth/l2cap_core.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index ebff14c..4fbf67e 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -2323,8 +2323,7 @@ static inline int l2cap_config_req(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 
 	sk = chan->sk;
 
-	if ((bt_sk(sk)->defer_setup && sk->sk_state != BT_CONNECT2) ||
-		 (!bt_sk(sk)->defer_setup && sk->sk_state != BT_CONFIG)) {
+	if (sk->sk_state != BT_CONFIG && sk->sk_state != BT_CONNECT2) {
 		struct l2cap_cmd_rej rej;
 
 		rej.reason = cpu_to_le16(0x0002);
-- 
1.7.6

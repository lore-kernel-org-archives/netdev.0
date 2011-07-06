From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the wireless-current
 tree
Date: Wed, 6 Jul 2011 12:53:29 +1000
Message-ID: <20110706125329.6e5bdd1a.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Gustavo F. Padovan" <padovan@profusion.mobi>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/bluetooth/l2cap_core.c between commit 9fa7e4f76f36 ("Bluetooth: Fix
regression with incoming L2CAP connections") from the wireless-current
tree and commit 89bc500e41fc ("Bluetooth: Add state tracking to struct
l2cap_chan") from the net tree.

I fixed it up (I think - see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/bluetooth/l2cap_core.c
index ebff14c,9ec9c8c..0000000
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@@ -2323,8 -2530,7 +2530,8 @@@ static inline int l2cap_config_req(stru
  
  	sk = chan->sk;
  
- 	if ((bt_sk(sk)->defer_setup && sk->sk_state != BT_CONNECT2) ||
- 		 (!bt_sk(sk)->defer_setup && sk->sk_state != BT_CONFIG)) {
 -	if (chan->state != BT_CONFIG) {
++	if ((bt_sk(sk)->defer_setup && chan->state != BT_CONNECT2) ||
++		 (!bt_sk(sk)->defer_setup && chan->state != BT_CONFIG)) {
  		struct l2cap_cmd_rej rej;
  
  		rej.reason = cpu_to_le16(0x0002);

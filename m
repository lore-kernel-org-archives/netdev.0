From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 net-next] Bluetooth: fix shadow warning in hci_disconnect()
Date: Sat, 25 Oct 2014 10:48:58 +0200
Message-ID: <1414226938-7478-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use clkoff_cp for hci_cp_read_clock_offset instead of cp
(already defined above).

Suggested-by: Marcel Holtmann <marcel@holtmann.org>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
V2: use clkoff_cp instead of cpr (suggested by Marcel Holtmann)

 net/bluetooth/hci_conn.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index b9517bd..62f4ac6 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -141,10 +141,11 @@ int hci_disconnect(struct hci_conn *conn, __u8 reason)
 	 */
 	if (conn->type == ACL_LINK && conn->role == HCI_ROLE_MASTER) {
 		struct hci_dev *hdev = conn->hdev;
-		struct hci_cp_read_clock_offset cp;
+		struct hci_cp_read_clock_offset clkoff_cp;
 
-		cp.handle = cpu_to_le16(conn->handle);
-		hci_send_cmd(hdev, HCI_OP_READ_CLOCK_OFFSET, sizeof(cp), &cp);
+		clkoff_cp.handle = cpu_to_le16(conn->handle);
+		hci_send_cmd(hdev, HCI_OP_READ_CLOCK_OFFSET, sizeof(clkoff_cp),
+			     &clkoff_cp);
 	}
 
 	conn->state = BT_DISCONN;
-- 
1.9.3

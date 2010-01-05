From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] drivers/firmware/iscsi_ibft.c: use %pM to show MAC address
Date: Tue, 5 Jan 2010 09:37:43 -0700
Message-ID: <201001050937.43896.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pjones@redhat.com, davem@davemloft.net
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755124Ab0AEQli@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

Also, remove the 'mac' variable and use nic->mac directly.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Acked-by: Peter Jones <pjones@redhat.com>
Cc: David S. Miller <davem@davemloft.net>

---

Repost due to merge issues.

diff --git a/drivers/firmware/iscsi_ibft.c b/drivers/firmware/iscsi_ibft.c
index 051d1eb..5aeb3b5 100644
--- a/drivers/firmware/iscsi_ibft.c
+++ b/drivers/firmware/iscsi_ibft.c
@@ -380,7 +380,6 @@ static ssize_t ibft_attr_show_nic(struct ibft_kobject *entry,
 	struct ibft_nic *nic = entry->nic;
 	void *ibft_loc = entry->header;
 	char *str = buf;
-	char *mac;
 	int val;
 
 	if (!nic)
@@ -421,10 +420,7 @@ static ssize_t ibft_attr_show_nic(struct ibft_kobject *entry,
 		str += sprintf(str, "%d\n", nic->vlan);
 		break;
 	case ibft_eth_mac:
-		mac = nic->mac;
-		str += sprintf(str, "%02x:%02x:%02x:%02x:%02x:%02x\n",
-			       (u8)mac[0], (u8)mac[1], (u8)mac[2],
-			       (u8)mac[3], (u8)mac[4], (u8)mac[5]);
+		str += sprintf(str, "%pM\n", nic->mac);
 		break;
 	case ibft_eth_hostname:
 		str += sprintf_string(str, nic->hostname_len,

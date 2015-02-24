From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH 6/8] NFC: NCI: Add function to get max packet size for conn
Date: Tue, 24 Feb 2015 12:01:50 +0200
Message-ID: <1424772112-27399-7-git-send-email-robert.dolca@intel.com>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

FDP driver needs to send the firmware as regular packets
(not fragmented). That's whay the driver should have a way to
get the max packet size for a given connection.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 include/net/nfc/nci_core.h |  1 +
 net/nfc/nci/data.c         | 12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/include/net/nfc/nci_core.h b/include/net/nfc/nci_core.h
index 42ec342..d79f90e 100644
--- a/include/net/nfc/nci_core.h
+++ b/include/net/nfc/nci_core.h
@@ -321,6 +321,7 @@ void nci_ntf_packet(struct nci_dev *ndev, struct sk_buff *skb);
 void nci_rx_data_packet(struct nci_dev *ndev, struct sk_buff *skb);
 int nci_send_cmd(struct nci_dev *ndev, __u16 opcode, __u8 plen, void *payload);
 int nci_send_data(struct nci_dev *ndev, __u8 conn_id, struct sk_buff *skb);
+__u8 nci_conn_max_data_pkt_payload_size(struct nci_dev *ndev, __u8 conn_id);
 void nci_data_exchange_complete(struct nci_dev *ndev, struct sk_buff *skb,
 				__u8 conn_id, int err);
 void nci_hci_data_received_cb(void *context, struct sk_buff *skb, int err);
diff --git a/net/nfc/nci/data.c b/net/nfc/nci/data.c
index 83acd18..056f841 100644
--- a/net/nfc/nci/data.c
+++ b/net/nfc/nci/data.c
@@ -90,6 +90,18 @@ static inline void nci_push_data_hdr(struct nci_dev *ndev,
 	nci_pbf_set((__u8 *)hdr, pbf);
 }
 
+__u8 nci_conn_max_data_pkt_payload_size(struct nci_dev *ndev, __u8 conn_id)
+{
+	struct nci_conn_info *conn_info;
+
+	conn_info = nci_get_conn_info_by_conn_id(ndev, conn_id);
+	if (!conn_info)
+		return 0;
+
+	return conn_info->max_pkt_payload_len;
+}
+EXPORT_SYMBOL(nci_conn_max_data_pkt_payload_size);
+
 static int nci_queue_tx_data_frags(struct nci_dev *ndev,
 				   __u8 conn_id,
 				   struct sk_buff *skb) {
-- 
1.9.1

From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH v4 02/10] nfc: nci: Add function to get max packet size for conn
Date: Thu, 22 Oct 2015 12:11:34 +0300
Message-ID: <1445505102-16639-3-git-send-email-robert.dolca@intel.com>
References: <1445505102-16639-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org,
	Christophe Ricard <christophe.ricard@gmail.com>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Robert Dolca <robert.dolca@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445505102-16639-1-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

FDP driver needs to send the firmware as regular packets
(not fragmented). The driver should have a way to
get the max packet size for a given connection.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 include/net/nfc/nci_core.h |  1 +
 net/nfc/nci/data.c         | 12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/include/net/nfc/nci_core.h b/include/net/nfc/nci_core.h
index d0d0f1e..aaada20 100644
--- a/include/net/nfc/nci_core.h
+++ b/include/net/nfc/nci_core.h
@@ -351,6 +351,7 @@ int nci_prop_ntf_packet(struct nci_dev *ndev, __u16 opcode,
 void nci_rx_data_packet(struct nci_dev *ndev, struct sk_buff *skb);
 int nci_send_cmd(struct nci_dev *ndev, __u16 opcode, __u8 plen, void *payload);
 int nci_send_data(struct nci_dev *ndev, __u8 conn_id, struct sk_buff *skb);
+int nci_conn_max_data_pkt_payload_size(struct nci_dev *ndev, __u8 conn_id);
 void nci_data_exchange_complete(struct nci_dev *ndev, struct sk_buff *skb,
 				__u8 conn_id, int err);
 void nci_hci_data_received_cb(void *context, struct sk_buff *skb, int err);
diff --git a/net/nfc/nci/data.c b/net/nfc/nci/data.c
index 83acd18..dbd2425 100644
--- a/net/nfc/nci/data.c
+++ b/net/nfc/nci/data.c
@@ -90,6 +90,18 @@ static inline void nci_push_data_hdr(struct nci_dev *ndev,
 	nci_pbf_set((__u8 *)hdr, pbf);
 }
 
+int nci_conn_max_data_pkt_payload_size(struct nci_dev *ndev, __u8 conn_id)
+{
+	struct nci_conn_info *conn_info;
+
+	conn_info = nci_get_conn_info_by_conn_id(ndev, conn_id);
+	if (!conn_info)
+		return -EPROTO;
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

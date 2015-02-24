From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH 3/8] NFC: NCI: Adds NCI init and reset API for drivers
Date: Tue, 24 Feb 2015 12:01:47 +0200
Message-ID: <1424772112-27399-4-git-send-email-robert.dolca@intel.com>
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

In order to communicate with the device during the setup
phase, the driver may need to initialize the device. After
the setup is done the driver should reset the device to leave
it in the same state that it was before the setup function
call.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 include/net/nfc/nci_core.h |  2 ++
 net/nfc/nci/core.c         | 14 ++++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/net/nfc/nci_core.h b/include/net/nfc/nci_core.h
index 34a6e09..4358d0a 100644
--- a/include/net/nfc/nci_core.h
+++ b/include/net/nfc/nci_core.h
@@ -314,6 +314,8 @@ static inline void *nci_get_drvdata(struct nci_dev *ndev)
 	return ndev->driver_data;
 }
 
+int nci_init(struct nci_dev *ndev);
+int nci_reset(struct nci_dev *ndev);
 void nci_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb);
 void nci_ntf_packet(struct nci_dev *ndev, struct sk_buff *skb);
 void nci_rx_data_packet(struct nci_dev *ndev, struct sk_buff *skb);
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 9605b9c..317b94b 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -458,6 +458,20 @@ static int nci_dev_down(struct nfc_dev *nfc_dev)
 	return nci_close_device(ndev);
 }
 
+int nci_init(struct nci_dev *ndev)
+{
+	return __nci_request(ndev, nci_init_req, 0,
+			  msecs_to_jiffies(NCI_INIT_TIMEOUT));
+}
+EXPORT_SYMBOL(nci_init);
+
+int nci_reset(struct nci_dev *ndev)
+{
+	return __nci_request(ndev, nci_reset_req, 0,
+			     msecs_to_jiffies(NCI_RESET_TIMEOUT));
+}
+EXPORT_SYMBOL(nci_reset);
+
 int nci_set_config(struct nci_dev *ndev, __u8 id, size_t len, __u8 *val)
 {
 	struct nci_set_config_param param;
-- 
1.9.1

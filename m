From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 16/16] nfp: advertise support for NFD ABI 0.5
Date: Mon,  5 Jun 2017 17:01:57 -0700
Message-ID: <20170606000157.17556-17-jakub.kicinski@netronome.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34870 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751314AbdFFACj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 20:02:39 -0400
Received: by mail-pf0-f173.google.com with SMTP id l89so15717565pfi.2
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 17:02:34 -0700 (PDT)
In-Reply-To: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NFD ABI 0.5 is equivalent to NFD ABI 3.0 but requires that the
driver checks the APP id symbol and makes sure it can support
given app.  Most advanced apps will likely require control vNIC
(ability to exchange control messages between the driver and
app FW).  Detailed app version checking and capability exchange
is left to app-specific code.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c   | 2 +-
 drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index db12700b5afc..5f27703060c2 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -749,7 +749,7 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 		nfp_warn(pf->cpp, "OBSOLETE Firmware detected - VF isolation not available\n");
 	} else {
 		switch (fw_ver.major) {
-		case 1 ... 4:
+		case 1 ... 5:
 			stride = 4;
 			break;
 		default:
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
index 0bf3b0febd07..c879626e035b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
@@ -161,7 +161,7 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 		dev_warn(&pdev->dev, "OBSOLETE Firmware detected - VF isolation not available\n");
 	} else {
 		switch (fw_ver.major) {
-		case 1 ... 4:
+		case 1 ... 5:
 			stride = 4;
 			tx_bar_no = NFP_NET_Q0_BAR;
 			rx_bar_no = tx_bar_no;
-- 
2.11.0

From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/2] NFC: digital: Improve a size determination in four
 functions
Date: Mon, 22 May 2017 14:58:54 +0200
Message-ID: <d8b16bd5-7acf-6ca4-69cb-6f7b2b43c807@users.sourceforge.net>
References: <7e27a76c-de7a-22ec-cf8a-31aee2000e29@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Samuel Ortiz <sameo@linux.intel.com>,
        Thierry Escande <thierry.escande@collabora.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7e27a76c-de7a-22ec-cf8a-31aee2000e29@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 14:11:01 +0200

Replace the specification of four data structures by pointer dereferences
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/nfc/digital_core.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/nfc/digital_core.c b/net/nfc/digital_core.c
index 0fd5518bf252..3baf91f3ef80 100644
--- a/net/nfc/digital_core.c
+++ b/net/nfc/digital_core.c
@@ -240,5 +240,5 @@ int digital_send_cmd(struct nfc_digital_dev *ddev, u8 cmd_type,
 {
 	struct digital_cmd *cmd;
 
-	cmd = kzalloc(sizeof(struct digital_cmd), GFP_KERNEL);
+	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd)
@@ -287,5 +287,5 @@ static int digital_tg_listen_mdaa(struct nfc_digital_dev *ddev, u8 rf_tech)
 {
 	struct digital_tg_mdaa_params *params;
 
-	params = kzalloc(sizeof(struct digital_tg_mdaa_params), GFP_KERNEL);
+	params = kzalloc(sizeof(*params), GFP_KERNEL);
 	if (!params)
@@ -706,5 +706,5 @@ static int digital_in_send(struct nfc_dev *nfc_dev, struct nfc_target *target,
 	struct digital_data_exch *data_exch;
 	int rc;
 
-	data_exch = kzalloc(sizeof(struct digital_data_exch), GFP_KERNEL);
+	data_exch = kzalloc(sizeof(*data_exch), GFP_KERNEL);
 	if (!data_exch) {
@@ -764,5 +764,5 @@ struct nfc_digital_dev *nfc_digital_allocate_device(struct nfc_digital_ops *ops,
 	    !ops->switch_rf || (ops->tg_listen_md && !ops->tg_get_rf_tech))
 		return NULL;
 
-	ddev = kzalloc(sizeof(struct nfc_digital_dev), GFP_KERNEL);
+	ddev = kzalloc(sizeof(*ddev), GFP_KERNEL);
 	if (!ddev)
-- 
2.13.0

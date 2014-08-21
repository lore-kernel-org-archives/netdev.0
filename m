From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH 5/8 v2] staging: et131x: Remove unnecessary i2c_wack variable
Date: Thu, 21 Aug 2014 16:02:32 +0100
Message-ID: <1408633352-23310-1-git-send-email-mark.einon@gmail.com>
References: <1408572883-9235-6-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Mark Einon <mark.einon@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1408572883-9235-6-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

i2c_wack is only used to implement a while(1) loop, so let's remove it.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---

Modified to remove function parameter indenting changes, which are
largely unrelated.

 drivers/staging/et131x/et131x.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index fc18e8d..245e048 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -573,7 +573,6 @@ static int eeprom_write(struct et131x_adapter *adapter, u32 addr, u8 data)
 	int index = 0;
 	int retries;
 	int err = 0;
-	int i2c_wack = 0;
 	int writeok = 0;
 	u32 status;
 	u32 val = 0;
@@ -599,8 +598,6 @@ static int eeprom_write(struct et131x_adapter *adapter, u32 addr, u8 data)
 			LBCIF_CONTROL_LBCIF_ENABLE | LBCIF_CONTROL_I2C_WRITE))
 		return -EIO;
 
-	i2c_wack = 1;
-
 	/* Prepare EEPROM address for Step 3 */
 
 	for (retries = 0; retries < MAX_NUM_WRITE_RETRIES; retries++) {
@@ -656,7 +653,7 @@ static int eeprom_write(struct et131x_adapter *adapter, u32 addr, u8 data)
 	 */
 	udelay(10);
 
-	while (i2c_wack) {
+	while (1) {
 		if (pci_write_config_byte(pdev, LBCIF_CONTROL_REGISTER,
 			LBCIF_CONTROL_LBCIF_ENABLE))
 			writeok = 0;
-- 
2.1.0

From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 3/3] staging/rtl8192e: avoid comparing unsigned type >= 0
Date: Wed, 20 Jul 2016 17:26:06 +0200
Message-ID: <20160720152606.201775-2-arnd@arndb.de>
References: <20160720151818.4142386-1-arnd@arndb.de>
 <20160720152606.201775-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Arnd Bergmann <arnd@arndb.de>,
 netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, Jes Sorensen <Jes.Sorensen@redhat.com>,
 Kalle Valo <kvalo@codeaurora.org>, Larry Finger <Larry.Finger@lwfinger.net>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160720152606.201775-1-arnd@arndb.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

There is one remaining warning about a type limit check in rtl8192e:

staging/rtl8192e/rtl819x_TSProc.c:326:14: error: comparison is always true due to limited range of data type [-Werror=type-limits]

This changes a macro into a local function to clarify the types and simplify
the check while removing the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/staging/rtl8192e/rtl819x_Qos.h    | 3 ---
 drivers/staging/rtl8192e/rtl819x_TSProc.c | 5 +++++
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/rtl8192e/rtl819x_Qos.h b/drivers/staging/rtl8192e/rtl819x_Qos.h
index 463122db6d29..61da8f7475bb 100644
--- a/drivers/staging/rtl8192e/rtl819x_Qos.h
+++ b/drivers/staging/rtl8192e/rtl819x_Qos.h
@@ -169,9 +169,6 @@ union qos_tclas {
 	} TYPE2_8021Q;
 };
 
-#define IsACValid(ac)		((ac >= 0 && ac <= 7) ? true : false)
-
-
 union aci_aifsn {
 	u8	charData;
 
diff --git a/drivers/staging/rtl8192e/rtl819x_TSProc.c b/drivers/staging/rtl8192e/rtl819x_TSProc.c
index 2c8a526773ed..a966a8e490ab 100644
--- a/drivers/staging/rtl8192e/rtl819x_TSProc.c
+++ b/drivers/staging/rtl8192e/rtl819x_TSProc.c
@@ -306,6 +306,11 @@ static void MakeTSEntry(struct ts_common_info *pTsCommonInfo, u8 *Addr,
 	pTsCommonInfo->TClasNum = TCLAS_Num;
 }
 
+static bool IsACValid(unsigned int tid)
+{
+	return tid < 7;
+}
+
 bool GetTs(struct rtllib_device *ieee, struct ts_common_info **ppTS,
 	   u8 *Addr, u8 TID, enum tr_select TxRxSelect, bool bAddNewTs)
 {
-- 
2.9.0

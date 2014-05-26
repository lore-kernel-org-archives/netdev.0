From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/3] staging: r8192ee: Fix build errors when PCI is not
 available
Date: Mon, 26 May 2014 14:06:05 -0500
Message-ID: <1401131166-6313-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1401131166-6313-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1401131166-6313-1-git-send-email-Larry.Finger@lwfinger.net>
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

A build of this driver fails when PCI is not selected. It would also
fail if MAC80211 is not selected. Kconfig is fixed to handle these
conditions, and to select additional necessary components.

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8192ee/Kconfig | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/staging/rtl8192ee/Kconfig b/drivers/staging/rtl8192ee/Kconfig
index 92c5f44..beb07ac2 100644
--- a/drivers/staging/rtl8192ee/Kconfig
+++ b/drivers/staging/rtl8192ee/Kconfig
@@ -1,6 +1,13 @@
 config R8192EE
 	tristate "Realtek RTL8192EE Wireless Network Adapter"
+	depends on PCI && WLAN && MAC80211
+	depends on m
+	select WIRELESS_EXT
+	select WEXT_PRIV
+	select EEPROM_93CX6
+	select CRYPTO
 	select FW_LOADER
+	default N
 	---help---
 	This is the driver for Realtek RTL8192EE 802.11 PCIe
 	wireless network adapters.
-- 
1.8.4.5

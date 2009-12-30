From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/atm/lanai.c: use %pM to show MAC address
Date: Wed, 30 Dec 2009 13:50:50 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F645@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753241AbZL3Suw@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index cf97c34..7fe7c32 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -998,9 +998,7 @@ static int __devinit eeprom_validate(struct lanai_dev *lanai)
 			    (unsigned int) e[EEPROM_MAC_REV + i]);
 			return -EIO;
 		}
-	DPRINTK("eeprom: MAC address = %02X:%02X:%02X:%02X:%02X:%02X\n",
-		e[EEPROM_MAC + 0], e[EEPROM_MAC + 1], e[EEPROM_MAC + 2],
-		e[EEPROM_MAC + 3], e[EEPROM_MAC + 4], e[EEPROM_MAC + 5]);
+	DPRINTK("eeprom: MAC address = %pM\n", &e[EEPROM_MAC]);
 	/* Verify serial number */
 	lanai->serialno = eeprom_be4(lanai, EEPROM_SERIAL);
 	v = eeprom_be4(lanai, EEPROM_SERIAL_REV);
@@ -2483,14 +2481,8 @@ static int lanai_proc_read(struct atm_dev *atmdev, loff_t *pos, char *page)
 		return sprintf(page, "revision: board=%d, pci_if=%d\n",
 		    lanai->board_rev, (int) lanai->pci->revision);
 	if (left-- == 0)
-		return sprintf(page, "EEPROM ESI: "
-		    "%02X:%02X:%02X:%02X:%02X:%02X\n",
-		    lanai->eeprom[EEPROM_MAC + 0],
-		    lanai->eeprom[EEPROM_MAC + 1],
-		    lanai->eeprom[EEPROM_MAC + 2],
-		    lanai->eeprom[EEPROM_MAC + 3],
-		    lanai->eeprom[EEPROM_MAC + 4],
-		    lanai->eeprom[EEPROM_MAC + 5]);
+		return sprintf(page, "EEPROM ESI: %pM\n",
+		    &lanai->eeprom[EEPROM_MAC]);
 	if (left-- == 0)
 		return sprintf(page, "status: SOOL=%d, LOCD=%d, LED=%d, "
 		    "GPIN=%d\n", (lanai->status & STATUS_SOOL) ? 1 : 0, 

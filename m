From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 12/14] e1000: Applied eeprom fix where it was possible
 to read/write one more word than what should have been possible
Date: Thu, 6 Jan 2005 17:22:05 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061536060.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.6/drivers/net/e1000/e1000_hw.c net-drivers-2.6/drivers/net/e1000.new/e1000_hw.c
--- net-drivers-2.6/drivers/net/e1000/e1000_hw.c	2004-12-03 07:24:37.090623184 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_hw.c	2004-12-03 07:24:38.466414032 -0800
@@ -3504,7 +3504,7 @@ e1000_read_eeprom(struct e1000_hw *hw,
     /* A check for invalid values:  offset too large, too many words, and not
      * enough words.
      */
-    if((offset > eeprom->word_size) || (words > eeprom->word_size - offset) ||
+    if((offset >= eeprom->word_size) || (words > eeprom->word_size - offset) ||
        (words == 0)) {
         DEBUGOUT("\"words\" parameter out of bounds\n");
         return -E1000_ERR_EEPROM;
@@ -3652,7 +3652,7 @@ e1000_write_eeprom(struct e1000_hw *hw,
     /* A check for invalid values:  offset too large, too many words, and not
      * enough words.
      */
-    if((offset > eeprom->word_size) || (words > eeprom->word_size - offset) ||
+    if((offset >= eeprom->word_size) || (words > eeprom->word_size - offset) ||
        (words == 0)) {
         DEBUGOUT("\"words\" parameter out of bounds\n");
         return -E1000_ERR_EEPROM;

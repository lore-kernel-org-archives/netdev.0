From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.4 11/13] e1000:  Applied eeprom fix where it was possible
 to read/write one more word than what should have been possible
Date: Thu, 6 Jan 2005 17:20:24 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061512500.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_hw.c net-drivers-2.4/drivers/net/e1000.new/e1000_hw.c
--- net-drivers-2.4/drivers/net/e1000/e1000_hw.c	2004-12-06 08:43:11.629382832 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_hw.c	2004-12-06 08:43:12.460256520 -0800
@@ -3507,7 +3507,7 @@ e1000_read_eeprom(struct e1000_hw *hw,
     /* A check for invalid values:  offset too large, too many words, and not
      * enough words.
      */
-    if((offset > eeprom->word_size) || (words > eeprom->word_size - offset) ||
+    if((offset >= eeprom->word_size) || (words > eeprom->word_size - offset) ||
        (words == 0)) {
         DEBUGOUT("\"words\" parameter out of bounds\n");
         return -E1000_ERR_EEPROM;
@@ -3653,11 +3653,10 @@ e1000_write_eeprom(struct e1000_hw *hw,
 
     DEBUGFUNC("e1000_write_eeprom");
 
-
     /* A check for invalid values:  offset too large, too many words, and not
      * enough words.
      */
-    if((offset > eeprom->word_size) || (words > eeprom->word_size - offset) ||
+    if((offset >= eeprom->word_size) || (words > eeprom->word_size - offset) ||
        (words == 0)) {
         DEBUGOUT("\"words\" parameter out of bounds\n");
         return -E1000_ERR_EEPROM;

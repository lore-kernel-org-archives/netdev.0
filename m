From: Olaf Hering <olh@suse.de>
Subject: [PATCH] pass unsgined long to udelay in e1000
Date: Fri, 2 Jul 2004 20:17:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040702181744.GA18546@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: cramerj@intel.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I get these warnings on ppc32 due to the check in udelay() macro.
Is it safe to move the struct member?


  CC [M]  drivers/net/e1000/e1000_hw.o
drivers/net/e1000/e1000_hw.c: In function `e1000_raise_ee_clk':
drivers/net/e1000/e1000_hw.c:3122: warning: comparison is always false du=
e to limited range of data type
drivers/net/e1000/e1000_hw.c: In function `e1000_lower_ee_clk':
drivers/net/e1000/e1000_hw.c:3141: warning: comparison is always false du=
e to limited range of data type
drivers/net/e1000/e1000_hw.c: In function `e1000_shift_out_ee_bits':
drivers/net/e1000/e1000_hw.c:3185: warning: comparison is always false du=
e to limited range of data type
drivers/net/e1000/e1000_hw.c: In function `e1000_standby_eeprom':
drivers/net/e1000/e1000_hw.c:3314: warning: comparison is always false du=
e to limited range of data type
drivers/net/e1000/e1000_hw.c:3320: warning: comparison is always false du=
e to limited range of data type
drivers/net/e1000/e1000_hw.c:3326: warning: comparison is always false du=
e to limited range of data type
drivers/net/e1000/e1000_hw.c:3332: warning: comparison is always false du=
e to limited range of data type
drivers/net/e1000/e1000_hw.c:3338: warning: comparison is always false du=
e to limited range of data type
drivers/net/e1000/e1000_hw.c:3342: warning: comparison is always false du=
e to limited range of data type
drivers/net/e1000/e1000_hw.c: In function `e1000_release_eeprom':
drivers/net/e1000/e1000_hw.c:3366: warning: comparison is always false du=
e to limited range of data type
drivers/net/e1000/e1000_hw.c:3379: warning: comparison is always false du=
e to limited range of data type
drivers/net/e1000/e1000_hw.c:3385: warning: comparison is always false du=
e to limited range of data type


patch is against 2.6.7-bk15


--- ./drivers/net/e1000/e1000_hw.h
+++ ./drivers/net/e1000/e1000_hw.h	2004/07/02 18:07:28
@@ -234,8 +234,8 @@ struct e1000_eeprom_info {
     uint16_t word_size;
     uint16_t opcode_bits;
     uint16_t address_bits;
-    uint16_t delay_usec;
     uint16_t page_size;
+    unsigned long delay_usec;
 };
=20
=20

--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=C3=9CRNBERG

From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] tg3: reading eeprom via ethtool: not __init
Date: Tue, 19 Oct 2004 21:28:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4175E955.6070807@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030104020507020302040509"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>, davem@davemloft.net,
        jgarzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030104020507020302040509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


-- 
~Randy

--------------030104020507020302040509
Content-Type: text/x-patch;
 name="tg3_init.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tg3_init.patch"


tg3_get_eeprom calls:  tg3_nvram_read_using_eeprom __init:
but the latter cannot be __init if it can be called (via ethtool)
after driver-init:
Error: ./drivers/net/tg3.o .text refers to 0000000000007220 R_X86_64_PC32     .init.text+0xfffffffffffffffc
Error: ./drivers/net/tg3.o .text refers to 000000000000725d R_X86_64_PC32     .init.text+0xfffffffffffffffc
Error: ./drivers/net/tg3.o .text refers to 00000000000072a7 R_X86_64_PC32     .init.text+0xfffffffffffffffc
Error: ./drivers/net/tg3.o .text refers to 00000000000072e8 R_X86_64_PC32     .init.text+0xfffffffffffffffc

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/net/tg3.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff -Naurp ./drivers/net/tg3.c~tg3_init ./drivers/net/tg3.c
--- ./drivers/net/tg3.c~tg3_init	2004-10-18 14:54:31.000000000 -0700
+++ ./drivers/net/tg3.c	2004-10-19 20:43:44.510473240 -0700
@@ -6319,8 +6319,8 @@ static int tg3_get_eeprom_len(struct net
 	return EEPROM_CHIP_SIZE;
 }
 
-static int __devinit tg3_nvram_read_using_eeprom(struct tg3 *tp,
-						 u32 offset, u32 *val);
+static int tg3_nvram_read_using_eeprom(struct tg3 *tp,
+					u32 offset, u32 *val);
 static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom, u8 *data)
 {
 	struct tg3 *tp = dev->priv;
@@ -6851,8 +6851,8 @@ static void __devinit tg3_nvram_init(str
 	}
 }
 
-static int __devinit tg3_nvram_read_using_eeprom(struct tg3 *tp,
-						 u32 offset, u32 *val)
+static int tg3_nvram_read_using_eeprom(struct tg3 *tp,
+					u32 offset, u32 *val)
 {
 	u32 tmp;
 	int i;

--------------030104020507020302040509--

From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [BK PATCHES] misc tg3 stuff
Date: Tue, 26 Oct 2004 15:15:01 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417EA235.5070700@pobox.com>
References: <20041026165955.GA27136@havoc.gtf.org> <20041026115555.390fcbbb.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070800080703090807010501"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041026115555.390fcbbb.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070800080703090807010501
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

David S. Miller wrote:
> On Tue, 26 Oct 2004 12:59:55 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>Please do a
>>
>>	bk pull bk://kernel.bkbits.net/jgarzik/tg3-2.6
>>
>>This will update the following files:
>>
>> drivers/net/tg3.c |   22 +++++++++++-----------
>> 1 files changed, 11 insertions(+), 11 deletions(-)
> 
> 
> Your attached patch was full of e100 stuff and many
> other totally unrelated changes, there were even crypto
> layer diffs in there as well :-)
> 
> When you do range diffs with bitkeeper you have to
> be really careful.

Looks like I attached the wrong diff, sorry.

The repository itself has the correct stuff in it :)

Attached new one...

	Jeff



--------------070800080703090807010501
Content-Type: text/plain;
 name="linus.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linus.txt"

Please do a

	bk pull bk://kernel.bkbits.net/jgarzik/tg3-2.6

This will update the following files:

 drivers/net/tg3.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

through these ChangeSets:

<shemminger@osdl.org> (04/10/15 1.1988.105.3)
   [PATCH] tg3: make driver only data static
   
   Several data structures should have been marked static because
   the are local to this driver.
   
   Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

<shemminger@osdl.org> (04/10/15 1.1988.105.2)
   [PATCH] tg3: use netdev_priv
   
   use netdev_priv
   
   Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

<shemminger@osdl.org> (04/10/15 1.1988.105.1)
   [PATCH] tg3: use module_param
   
   get rid of deprecated use of MODULE_PARM
   
   Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	2004-10-26 15:14:02 -04:00
+++ b/drivers/net/tg3.c	2004-10-26 15:14:02 -04:00
@@ -12,7 +12,7 @@
 #include <linux/config.h>
 
 #include <linux/module.h>
-
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/compiler.h>
@@ -141,11 +141,11 @@
 MODULE_AUTHOR("David S. Miller (davem@redhat.com) and Jeff Garzik (jgarzik@pobox.com)");
 MODULE_DESCRIPTION("Broadcom Tigon3 ethernet driver");
 MODULE_LICENSE("GPL");
-MODULE_PARM(tg3_debug, "i");
-MODULE_PARM_DESC(tg3_debug, "Tigon3 bitmapped debugging message enable value");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
 static int tg3_debug = -1;	/* -1 == use TG3_DEF_MSG_ENABLE as value */
+module_param(tg3_debug, int, 0);
+MODULE_PARM_DESC(tg3_debug, "Tigon3 bitmapped debugging message enable value");
 
 static struct pci_device_id tg3_pci_tbl[] = {
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5700,
@@ -225,8 +225,8 @@
 
 MODULE_DEVICE_TABLE(pci, tg3_pci_tbl);
 
-struct {
-	char string[ETH_GSTRING_LEN];
+static struct {
+	const char string[ETH_GSTRING_LEN];
 } ethtool_stats_keys[TG3_NUM_STATS] = {
 	{ "rx_octets" },
 	{ "rx_fragments" },
@@ -4505,7 +4505,7 @@
 	0xac470014, 0xac4a0018, 0x03e00008, 0xac4b001c, 0x00000000, 0x00000000,
 };
 
-u32 tg3TsoFwRodata[] = {
+static u32 tg3TsoFwRodata[] = {
 	0x4d61696e, 0x43707542, 0x00000000, 0x4d61696e, 0x43707541, 0x00000000,
 	0x00000000, 0x00000000, 0x73746b6f, 0x66666c64, 0x496e0000, 0x73746b6f,
 	0x66662a2a, 0x00000000, 0x53774576, 0x656e7430, 0x00000000, 0x00000000,
@@ -4513,7 +4513,7 @@
 	0x00000000,
 };
 
-u32 tg3TsoFwData[] = {
+static u32 tg3TsoFwData[] = {
 	0x00000000, 0x73746b6f, 0x66666c64, 0x5f76312e, 0x362e3000, 0x00000000,
 	0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
 	0x00000000,
@@ -4694,14 +4694,14 @@
 	0x00000000, 0x00000000, 0x00000000,
 };
 
-u32 tg3Tso5FwRodata[(TG3_TSO5_FW_RODATA_LEN / 4) + 1] = {
+static u32 tg3Tso5FwRodata[(TG3_TSO5_FW_RODATA_LEN / 4) + 1] = {
 	0x4d61696e, 0x43707542, 0x00000000, 0x4d61696e, 0x43707541, 0x00000000,
 	0x00000000, 0x00000000, 0x73746b6f, 0x66666c64, 0x00000000, 0x00000000,
 	0x73746b6f, 0x66666c64, 0x00000000, 0x00000000, 0x66617461, 0x6c457272,
 	0x00000000, 0x00000000, 0x00000000,
 };
 
-u32 tg3Tso5FwData[(TG3_TSO5_FW_DATA_LEN / 4) + 1] = {
+static u32 tg3Tso5FwData[(TG3_TSO5_FW_DATA_LEN / 4) + 1] = {
 	0x00000000, 0x73746b6f, 0x66666c64, 0x5f76312e, 0x322e3000, 0x00000000,
 	0x00000000, 0x00000000, 0x00000000,
 };
@@ -6324,7 +6324,7 @@
 					u32 offset, u32 *val);
 static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom, u8 *data)
 {
-	struct tg3 *tp = dev->priv;
+	struct tg3 *tp = netdev_priv(dev);
 	int ret;
 	u8  *pd;
 	u32 i, offset, len, val, b_offset, b_count;
@@ -6686,7 +6686,7 @@
 static void tg3_get_ethtool_stats (struct net_device *dev,
 				   struct ethtool_stats *estats, u64 *tmp_stats)
 {
-	struct tg3 *tp = dev->priv;
+	struct tg3 *tp = netdev_priv(dev);
 	memcpy(tmp_stats, tg3_get_estats(tp), sizeof(tp->estats));
 }
 

--------------070800080703090807010501--

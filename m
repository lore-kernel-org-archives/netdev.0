From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] remove unneeded casts in net/wan/
Date: Sun, 29 Feb 2004 14:40:34 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229144034.2a99c7a7.rddunlap@osdl.org>
References: <20040229142516.3d218ed0.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik <jgarzik@pobox.com>
In-Reply-To: <20040229142516.3d218ed0.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Carlo Perassi <carlo@linux.it>


 drivers/net/wan/comx-hw-locomx.c |    6 +++---
 drivers/net/wan/comx-hw-munich.c |    6 +++---
 drivers/net/wan/comx.c           |    2 +-
 drivers/net/wan/cosa.c           |    2 +-
 drivers/net/wan/lapbether.c      |    2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

diff -puN drivers/net/wan/comx.c~net_wan_casts drivers/net/wan/comx.c
--- linux-263-229/drivers/net/wan/comx.c~net_wan_casts	2004-02-29 13:57:19.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/wan/comx.c	2004-02-29 13:57:19.000000000 -0800
@@ -379,7 +379,7 @@ int comx_rx(struct net_device *dev, stru
 
 static struct net_device_stats *comx_stats(struct net_device *dev)
 {
-	struct comx_channel *ch = (struct comx_channel *)dev->priv;
+	struct comx_channel *ch = dev->priv;
 
 	return ch->current_stats;
 }
diff -puN drivers/net/wan/comx-hw-locomx.c~net_wan_casts drivers/net/wan/comx-hw-locomx.c
--- linux-263-229/drivers/net/wan/comx-hw-locomx.c~net_wan_casts	2004-02-29 13:57:19.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/wan/comx-hw-locomx.c	2004-02-29 13:57:19.000000000 -0800
@@ -97,7 +97,7 @@ static void locomx_rx(struct z8530_chann
 
 static int LOCOMX_send_packet(struct net_device *dev, struct sk_buff *skb) 
 {
-	struct comx_channel *ch = (struct comx_channel *)dev->priv;
+	struct comx_channel *ch = dev->priv;
 	struct locomx_data *hw = ch->HW_privdata;
 
 	if (ch->debug_flags & DEBUG_HW_TX) {
@@ -376,7 +376,7 @@ static int locomx_write_proc(struct file
 
 static int LOCOMX_init(struct net_device *dev) 
 {
-	struct comx_channel *ch = (struct comx_channel *)dev->priv;
+	struct comx_channel *ch = dev->priv;
 	struct locomx_data *hw;
 	struct proc_dir_entry *new_file;
 
@@ -449,7 +449,7 @@ cleanup_HW_privdata:
 
 static int LOCOMX_exit(struct net_device *dev)
 {
-	struct comx_channel *ch = (struct comx_channel *)dev->priv;
+	struct comx_channel *ch = dev->priv;
 
 	ch->HW_access_board = NULL;
 	ch->HW_release_board = NULL;
diff -puN drivers/net/wan/comx-hw-munich.c~net_wan_casts drivers/net/wan/comx-hw-munich.c
--- linux-263-229/drivers/net/wan/comx-hw-munich.c~net_wan_casts	2004-02-29 13:57:19.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/wan/comx-hw-munich.c	2004-02-29 13:57:19.000000000 -0800
@@ -933,7 +933,7 @@ static int slicecom_reset(struct net_dev
 
 static int MUNICH_send_packet(struct net_device *dev, struct sk_buff *skb)
 {
-    struct comx_channel *ch = (struct comx_channel *)dev->priv;
+    struct comx_channel *ch = dev->priv;
     struct slicecom_privdata *hw = ch->HW_privdata;
 
     /* Send it to the debug facility too if needed: */
@@ -2656,7 +2656,7 @@ static int init_escape(struct comx_chann
 
 static int BOARD_init(struct net_device *dev)
 {
-    struct comx_channel *ch = (struct comx_channel *)dev->priv;
+    struct comx_channel *ch = dev->priv;
     struct slicecom_privdata *hw;
     struct proc_dir_entry *new_file;
 
@@ -2772,7 +2772,7 @@ static int BOARD_init(struct net_device 
  */
 static int BOARD_exit(struct net_device *dev)
 {
-    struct comx_channel *ch = (struct comx_channel *)dev->priv;
+    struct comx_channel *ch = dev->priv;
 
     /* Free private data area */
 //    board = hw->boardnum + (ch->hardware == &pcicomhw ? pcicom_boards : slicecom_boards);
diff -puN drivers/net/wan/cosa.c~net_wan_casts drivers/net/wan/cosa.c
--- linux-263-229/drivers/net/wan/cosa.c~net_wan_casts	2004-02-29 13:57:19.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/wan/cosa.c	2004-02-29 13:57:19.000000000 -0800
@@ -1205,7 +1205,7 @@ static int cosa_sppp_ioctl(struct net_de
 	int cmd)
 {
 	int rv;
-	struct channel_data *chan = (struct channel_data *)dev->priv;
+	struct channel_data *chan = dev->priv;
 	rv = cosa_ioctl_common(chan->cosa, chan, cmd, (unsigned long)ifr->ifr_data);
 	if (rv == -ENOIOCTLCMD) {
 		return sppp_do_ioctl(dev, ifr, cmd);
diff -puN drivers/net/wan/lapbether.c~net_wan_casts drivers/net/wan/lapbether.c
--- linux-263-229/drivers/net/wan/lapbether.c~net_wan_casts	2004-02-29 13:57:19.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/wan/lapbether.c	2004-02-29 13:57:19.000000000 -0800
@@ -269,7 +269,7 @@ static void lapbeth_disconnected(struct 
  */
 static struct net_device_stats *lapbeth_get_stats(struct net_device *dev)
 {
-	struct lapbethdev *lapbeth = (struct lapbethdev *)dev->priv;
+	struct lapbethdev *lapbeth = dev->priv;
 	return &lapbeth->stats;
 }
 

_


--
~Randy

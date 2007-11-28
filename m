From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] [RFC] New driver "sfc" for Solarstorm SFC4000
 controller
Date: Tue, 27 Nov 2007 22:09:54 -0800
Message-ID: <20071127220954.4f075056@freepuppy.rosehill>
References: <20071123170815.GH31093@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48929 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750898AbXK1GKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 01:10:33 -0500
In-Reply-To: <20071123170815.GH31093@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 23 Nov 2007 17:08:15 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:

> This is a net driver (and MTD driver, sfc_mtd) for our SFC4000 10G
> Ethernet controller, branded "Solarstorm", with various PHYs.  It is
> intended to support our NIC reference designs SFE4001 (10GBASE-T),
> SFE4002 (XFP), SFE4003 (10GBASE-CX4), OEM designs based on them, and
> some development boards.  We have been maintaining drivers out-of-tree
> for some time but are now preparing them to work in-tree.
> 
> There are some issues that might need to be addressed:
> 
> 1. When we enable NAPI polling, we need to set __LINK_STATE_START in
>    the net device used for NAPI.  This bit is commented as private in
>    netdevice.h, but e1000 also does this.  Is this incorrect?

Why are you using it directly?

> 2. We added a lot of definitions and code for 10G MDIO.  This is mostly
>    generic and could be moved into core code.
> 
> We welcome review comments and are ready to address them.
> 
> The patch (against net-2.6.25) is at:
>     https://support.solarflare.com/netdev/net-2.6.25-sfc-2.2.0019.patch
> 
> The new files may also be downloaded as a tarball:
>     https://support.solarflare.com/netdev/net-2.6.25-sfc-2.2.0019.tar.gz
> 
> And for verification there is:
>     https://support.solarflare.com/netdev/MD5SUMS
> 
> Ben.
> 

The driver is pretty big (28K loc), and non trivial to get a good review.

Minor note:
* use u8 not uint8_t (etc.)
* gone overboard with docbook style comments, they are only needed
  on external API's.
* why are you exporting symbol's?
* Please use dev_err() rather than reinventing own message macros.



Trivial warnings from checkpatch.


WARNING: line over 80 characters
#177: FILE: drivers/net/sfc/alaska.c:68:
+	phy_ext = gmii->mdio_read(gmii->dev, gmii->phy_id, ALASKA_EXTENDED_CONTROL);

WARNING: line over 80 characters
#182: FILE: drivers/net/sfc/alaska.c:73:
+	gmii->mdio_write(gmii->dev, gmii->phy_id, ALASKA_EXTENDED_CONTROL, phy_ext);

WARNING: line over 80 characters
#282: FILE: drivers/net/sfc/alaska.c:173:
+	phy_spec = gmii->mdio_read(gmii->dev, gmii->phy_id, ALASKA_PHY_SPECIFIC);

WARNING: line over 80 characters
#284: FILE: drivers/net/sfc/alaska.c:175:
+	gmii->mdio_write(gmii->dev, gmii->phy_id, ALASKA_PHY_SPECIFIC, phy_spec);

WARNING: do not add new typedefs
#477: FILE: drivers/net/sfc/bitfield.h:106:
+typedef union efx_dword {

WARNING: do not add new typedefs
#486: FILE: drivers/net/sfc/bitfield.h:115:
+typedef union efx_qword {

WARNING: do not add new typedefs
#497: FILE: drivers/net/sfc/bitfield.h:126:
+typedef union efx_oword {

ERROR: Macros with complex values should be enclosed in parenthesis
#519: FILE: drivers/net/sfc/bitfield.h:148:
+	((unsigned int) le32_to_cpu((qword).u32[1])),	\

ERROR: Macros with complex values should be enclosed in parenthesis
#524: FILE: drivers/net/sfc/bitfield.h:153:
+	((unsigned int) le32_to_cpu((oword).u32[3])),	\

ERROR: Macros with complex values should be enclosed in parenthesis
#691: FILE: drivers/net/sfc/bitfield.h:320:
+#define EFX_INSERT_FIELDS_NATIVE(min, max,			\
+				 field1, value1,		\
+				 field2, value2,		\
+				 field3, value3,		\
+				 field4, value4,		\
+				 field5, value5,		\
+				 field6, value6,		\
+				 field7, value7,		\
+				 field8, value8,		\
+				 field9, value9,		\
+				 field10, value10)		\

WARNING: line over 80 characters
#1237: FILE: drivers/net/sfc/boards.c:286:
+#define	SFE4005_PORTSEL		(1 << 7) /* Which port to use (for Rx  in BCAST mode) */

WARNING: line over 80 characters
#1242: FILE: drivers/net/sfc/boards.c:291:
+#define SFE4005_CX4uC_nRESET	(1 << 15) /* Reset the microcontroller on CX4 chip */

WARNING: do not add new typedefs
#1440: FILE: drivers/net/sfc/boards.h:35:
+typedef enum {

WARNING: do not add new typedefs
#2467: FILE: drivers/net/sfc/debugfs.h:43:
+typedef int efx_debugfs_reader(struct seq_file *, void *);

WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
#2809: FILE: drivers/net/sfc/driverlink.c:189:
+EXPORT_SYMBOL(efx_dl_unregister_driver);

WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
#2854: FILE: drivers/net/sfc/driverlink.c:234:
+EXPORT_SYMBOL(efx_dl_register_driver);

WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
#3050: FILE: drivers/net/sfc/driverlink.c:430:
+EXPORT_SYMBOL(efx_dl_unregister_callbacks);

WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
#3122: FILE: drivers/net/sfc/driverlink.c:502:
+EXPORT_SYMBOL(efx_dl_register_callbacks);

WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
#3141: FILE: drivers/net/sfc/driverlink.c:521:
+EXPORT_SYMBOL(efx_dl_schedule_reset);

WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
#3234: FILE: drivers/net/sfc/driverlink.c:614:
+EXPORT_SYMBOL(efx_dl_get_nic_port);

ERROR: trailing whitespace
#3399: FILE: drivers/net/sfc/driverlink_api.h:56:
+ * then that client can return failure frmo it's #efx_dl_driver::probe $

ERROR: trailing whitespace
#3413: FILE: drivers/net/sfc/driverlink_api.h:70:
+ * from an error condition.  The client's efx_dl_driver::reset_suspend() $

ERROR: trailing whitespace
#3477: FILE: drivers/net/sfc/driverlink_api.h:134:
+^I * efx_dl_dev->priv (which is not shared between clients). $

WARNING: line over 80 characters
#3909: FILE: drivers/net/sfc/driverlink_api.h:566:
+ *        efx_dl_for_each_device_info_matching(dev_info,  EFX_DL_FALCON_RESOURCES,

ERROR: Macros with complex values should be enclosed in parenthesis
#3920: FILE: drivers/net/sfc/driverlink_api.h:577:
+#define efx_dl_for_each_device_info_matching(_dev_info, _type,		\
+					     _info_type, _field, _p)	\

ERROR: trailing whitespace
#3935: FILE: drivers/net/sfc/driverlink_api.h:592:
+ * $

ERROR: Macros with complex values should be enclosed in parenthesis
#3944: FILE: drivers/net/sfc/driverlink_api.h:601:
+	efx_dl_for_each_device_info_matching(_dev_info, _type,		\
+					     _info_type, _field, _p)	\

ERROR: do not initialise statics to 0 or NULL
#4174: FILE: drivers/net/sfc/efx.c:220:
+static unsigned int allow_bad_hwaddr = 0;

ERROR: do not initialise statics to 0 or NULL
#4207: FILE: drivers/net/sfc/efx.c:253:
+static unsigned int allow_load_on_failure = 0;

ERROR: do not initialise statics to 0 or NULL
#4221: FILE: drivers/net/sfc/efx.c:267:
+static unsigned int interrupt_mode = 0;

ERROR: do not initialise statics to 0 or NULL
#4276: FILE: drivers/net/sfc/efx.c:322:
+static unsigned int rss_cpus = 0;

WARNING: line over 80 characters
#5793: FILE: drivers/net/sfc/efx.c:1839:
+		/* net_dev is not currently created yet, so provide a dummy mtu */

WARNING: line over 80 characters
#7881: FILE: drivers/net/sfc/enum.h:89:
+	RESET_TYPE_ALL = 1,        /* Reset everything but PCI core blocks in Falcon */

WARNING: line over 80 characters
#7882: FILE: drivers/net/sfc/enum.h:90:
+	RESET_TYPE_WORLD = 2,      /* Reset everything, save and restore config space */

WARNING: line over 80 characters
#7889: FILE: drivers/net/sfc/enum.h:97:
+	RESET_TYPE_RX_RECOVERY,    /* Reset to recover from RX datapath errors */

WARNING: do not add new typedefs
#7958: FILE: drivers/net/sfc/ethtool.c:59:
+typedef struct {

ERROR: need consistent spacing around '*' (ctx:WxB)
#7989: FILE: drivers/net/sfc/ethtool.c:90:
+		      &((struct efx_##source_name *) 0)->field) ?	\
 		                                  ^

ERROR: do not initialise statics to 0 or NULL
#9060: FILE: drivers/net/sfc/falcon.c:109:
+static int disable_dma_stats = 0;

WARNING: line over 80 characters
#9087: FILE: drivers/net/sfc/falcon.c:136:
+/** Maximum number of internal errors. After this resets will not be performed */

WARNING: externs should be avoided in .c files
#9573: FILE: drivers/net/sfc/falcon.c:622:
+	extern int __unsupported_tx_descq_size;

WARNING: externs should be avoided in .c files
#9804: FILE: drivers/net/sfc/falcon.c:853:
+	extern int __unsupported_rx_descq_size;

WARNING: braces {} are not necessary for single statement blocks
#10183: FILE: drivers/net/sfc/falcon.c:1232:
+	if (rx_ev_other_err) {
+		EFX_INFO_RL("%s RX queue %d unexpected RX event "
+			    EFX_QWORD_FMT "%s%s%s%s%s%s%s%s%s\n",
+			    efx->name, rx_queue->queue,
+			    EFX_QWORD_VAL(*event),
+			    rx_ev_buf_owner_id_err ? " [OWNER_ID_ERR]" : "",
+			    rx_ev_ip_hdr_chksum_err ?
+			    " [IP_HDR_CHKSUM_ERR]" : "",
+			    rx_ev_tcp_udp_chksum_err ?
+			    " [TCP_UDP_CHKSUM_ERR]" : "",
+			    rx_ev_eth_crc_err ? " [ETH_CRC_ERR]" : "",
+			    rx_ev_frm_trunc ? " [FRM_TRUNC]" : "",
+			    rx_ev_drib_nib ? " [DRIB_NIB]" : "",
+			    rx_ev_tobe_disc ? " [TOBE_DISC]" : "",
+			    rx_ev_pause_frm ? " [PAUSE]" : "",
+			    snap ? " [SNAP/LLC]" : "");
+	}

WARNING: braces {} are not necessary for single statement blocks
#10202: FILE: drivers/net/sfc/falcon.c:1251:
+	if (rx_ev_eth_crc_err && efx->workarounds.bug10750) {
+		efx->bug10750_crcs++;
+	}

WARNING: externs should be avoided in .c files
#10619: FILE: drivers/net/sfc/falcon.c:1668:
+	extern int __unsupported_evq_size;

WARNING: do not add new typedefs
#10807: FILE: drivers/net/sfc/falcon.c:1856:
+typedef efx_oword_t falcon_int_ker_t;

WARNING: Use of volatile is usually wrong: see Documentation/volatile-considered-harmful.txt
#11561: FILE: drivers/net/sfc/falcon.c:2610:
+		if (*(volatile uint32_t *)dma_done == FALCON_STATS_DONE)

WARNING: line over 80 characters
#12113: FILE: drivers/net/sfc/falcon.c:3162:
+				     EXT_PHY_RST_DUR, 0x7 /* datasheet recommended */ ,

WARNING: line over 80 characters
#12140: FILE: drivers/net/sfc/falcon.c:3189:
+					EFX_ERR("%s failed to restore PCI config "

WARNING: line over 80 characters
#12218: FILE: drivers/net/sfc/falcon.c:3267:
+		if (EFX_OWORD_FIELD(srm_cfg_reg_ker, SRAM_OOB_BT_INIT_EN) == 0) {

WARNING: kfree(NULL) is safe this check is probabally not required
#12267: FILE: drivers/net/sfc/falcon.c:3316:
+	if (*spi_device_ret)
+		kfree(*spi_device_ret);

WARNING: kfree(NULL) is safe this check is probabally not required
#12694: FILE: drivers/net/sfc/falcon.c:3743:
+	if (efx->spi_eeprom) {
+		kfree(efx->spi_eeprom);

WARNING: kfree(NULL) is safe this check is probabally not required
#12698: FILE: drivers/net/sfc/falcon.c:3747:
+	if (efx->spi_flash) {
+		kfree(efx->spi_flash);

ERROR: no space before that close parenthesis ')'
#12941: FILE: drivers/net/sfc/falcon.c:3990:
+	EFX_ASSERT(tlp_size <= 3 /* 3=1024 */);

WARNING: kfree(NULL) is safe this check is probabally not required
#13251: FILE: drivers/net/sfc/falcon.c:4300:
+	if (efx->nic_params) {
+		kfree(efx->nic_params);

WARNING: do not add new typedefs
#13491: FILE: drivers/net/sfc/falcon.h:153:
+typedef efx_qword_t falcon_event_t;

WARNING: do not add new typedefs
#13496: FILE: drivers/net/sfc/falcon.h:158:
+typedef efx_qword_t falcon_tx_desc_t;

WARNING: do not add new typedefs
#13499: FILE: drivers/net/sfc/falcon.h:161:
+typedef efx_qword_t falcon_rx_desc_t;

WARNING: line over 80 characters
#16265: FILE: drivers/net/sfc/falcon_xmac.c:402:
+	if (efx_port->efx->revision <= FALCON_REV_A1 && !efx_port->efx->is_asic) {

WARNING: line over 80 characters
#16326: FILE: drivers/net/sfc/falcon_xmac.c:463:
+	if (efx_port->efx->revision == FALCON_REV_B0 && !efx_port->efx->is_asic) {

WARNING: line over 80 characters
#18037: FILE: drivers/net/sfc/mdio_10g.c:133:
+							      efx_port->mii.phy_id,

WARNING: line over 80 characters
#18038: FILE: drivers/net/sfc/mdio_10g.c:134:
+							      mmd, MDIO_MMDREG_CTRL1);

WARNING: line over 80 characters
#18040: FILE: drivers/net/sfc/mdio_10g.c:136:
+					EFX_ERR("%s failed to read status of MMD %s\n",

WARNING: line over 80 characters
#18042: FILE: drivers/net/sfc/mdio_10g.c:138:
+						STRING_TABLE_LOOKUP(mmd, mmd_block));

WARNING: line over 80 characters
#18072: FILE: drivers/net/sfc/mdio_10g.c:168:
+	/* Historically we have probed the PHYXS to find out what devices are present,

WARNING: line over 80 characters
#18073: FILE: drivers/net/sfc/mdio_10g.c:169:
+	 * but that doesn't work so well if the PHYXS isn't expectedt to exist, in

ERROR: no space before that close parenthesis ')'
#19301: FILE: drivers/net/sfc/mentormac.c:606:
+			     GM_PAMBL_LEN, 0x7 /*datasheet recommended */);

ERROR: do not initialise statics to 0 or NULL
#19510: FILE: drivers/net/sfc/mtd.c:84:
+static unsigned int efx_allow_nvconfig_writes = 0;

WARNING: do not add new typedefs
#21296: FILE: drivers/net/sfc/net_driver.h:546:
+typedef enum {

WARNING: do not add new typedefs
#21305: FILE: drivers/net/sfc/net_driver.h:555:
+typedef enum {

WARNING: line over 80 characters
#21561: FILE: drivers/net/sfc/net_driver.h:811:
+	/** Flow control flags - RX/TX are separate so cannot use link_options */

WARNING: Use of volatile is usually wrong: see Documentation/volatile-considered-harmful.txt
#21756: FILE: drivers/net/sfc/net_driver.h:1006:
+	volatile signed int last_irq_cpu;

ERROR: Macros with multiple statements should be enclosed in a do - while loop
#21846: FILE: drivers/net/sfc/net_driver.h:1096:
+	for (_channel = &_efx->channel[0];				\
+	     _channel < &_efx->channel[EFX_MAX_CHANNELS];		\
+	     _channel++)						\

ERROR: Macros with multiple statements should be enclosed in a do - while loop
#21854: FILE: drivers/net/sfc/net_driver.h:1104:
+	for (_channel = &_efx->channel[0];				\
+	     _channel < &_efx->channel[EFX_MAX_CHANNELS];		\
+	     _channel++)						\

ERROR: Macros with multiple statements should be enclosed in a do - while loop
#21863: FILE: drivers/net/sfc/net_driver.h:1113:
+	for (_efx_port = &_efx->port[0];				\
+	     _efx_port < &_efx->port[EFX_MAX_PORTS];			\
+	     _efx_port++)						\

ERROR: Macros with multiple statements should be enclosed in a do - while loop
#21871: FILE: drivers/net/sfc/net_driver.h:1121:
+	for (_tx_queue = &_efx->tx_queue[0];				\
+	     _tx_queue < &_efx->tx_queue[EFX_MAX_TX_QUEUES];		\
+	     _tx_queue++)						\

ERROR: Macros with multiple statements should be enclosed in a do - while loop
#21879: FILE: drivers/net/sfc/net_driver.h:1129:
+	for (_tx_queue = &_channel->efx->tx_queue[0];			\
+	     _tx_queue < &_channel->efx->tx_queue[EFX_MAX_TX_QUEUES];	\
+	     _tx_queue++)						\

ERROR: Macros with multiple statements should be enclosed in a do - while loop
#21888: FILE: drivers/net/sfc/net_driver.h:1138:
+	for (_tx_queue = &_efx_port->efx->tx_queue[0];			\
+	     _tx_queue < &_efx_port->efx->tx_queue[EFX_MAX_TX_QUEUES];	\
+	     _tx_queue++)						\

ERROR: Macros with multiple statements should be enclosed in a do - while loop
#21897: FILE: drivers/net/sfc/net_driver.h:1147:
+	for (_rx_queue = &_efx->rx_queue[0];				\
+	     _rx_queue < &_efx->rx_queue[EFX_MAX_RX_QUEUES];		\
+	     _rx_queue++)						\

ERROR: Macros with multiple statements should be enclosed in a do - while loop
#21905: FILE: drivers/net/sfc/net_driver.h:1155:
+	for (_rx_queue = &_channel->efx->rx_queue[0];			\
+	     _rx_queue < &_channel->efx->rx_queue[EFX_MAX_RX_QUEUES];	\
+	     _rx_queue++)						\

ERROR: no space before that close parenthesis ')'
#21988: FILE: drivers/net/sfc/net_driver.h:1238:
+	((((mtu) + ETH_HLEN + VLAN_HLEN + 4 /* FCS */) + 7) & ~7)

WARNING: line over 80 characters
#22175: FILE: drivers/net/sfc/pm8358_phy.c:59:
+#define PMC_ANALOG_RX_TERM     (1 << 15) /* Bit 15 of RX CFG: 0 for 100 ohms float,

WARNING: braces {} are not necessary for single statement blocks
#22261: FILE: drivers/net/sfc/pm8358_phy.c:145:
+	if (rc < 0) {
+		return rc;
+	}

WARNING: labels should not be indented
#23022: FILE: drivers/net/sfc/rx.c:634:
+	out_unlock_free:

WARNING: labels should not be indented
#23024: FILE: drivers/net/sfc/rx.c:636:
+	out_free:

WARNING: line over 80 characters
#24375: FILE: drivers/net/sfc/selftest.c:743:
+		/* bug6926: Moving into/out of loopback could cut a packet in half.

WARNING: line over 80 characters
#24855: FILE: drivers/net/sfc/sfe4001.c:182:
+			tenxpress_phy_state(&efx->port[0], TENXPRESS_STATUS_OTEMP);

WARNING: line over 80 characters
#24859: FILE: drivers/net/sfc/sfe4001.c:186:
+				EFX_ERR("%s %s: Temperature sensor reports alarm!"

ERROR: trailing whitespace
#24881: FILE: drivers/net/sfc/sfe4001.c:208:
+ * $

WARNING: line over 80 characters
#25630: FILE: drivers/net/sfc/tenxpress.c:361:
+	reg = mdio_clause45_read(efx_port, efx_port->mii.phy_id, MDIO_MMD_PMAPMD,

WARNING: line over 80 characters
#25669: FILE: drivers/net/sfc/tenxpress.c:400:
+	reg = mdio_clause45_read(efx_port, efx_port->mii.phy_id, MDIO_MMD_PMAPMD,

WARNING: line over 80 characters
#25716: FILE: drivers/net/sfc/tenxpress.c:447:
+		 * distinguish between not being plugged in and being plugged into

WARNING: line over 80 characters
#25717: FILE: drivers/net/sfc/tenxpress.c:448:
+		 * a non-AN antique. The FLP bit has the advantage of not clearing

WARNING: line over 80 characters
#25726: FILE: drivers/net/sfc/tenxpress.c:457:
+							      MDIO_AN_10GBT_STATUS);

WARNING: line over 80 characters
#25728: FILE: drivers/net/sfc/tenxpress.c:459:
+					   (1 << MDIO_AN_10GBT_STATUS_LP_10G_LBN));

WARNING: line over 80 characters
#25828: FILE: drivers/net/sfc/tenxpress.c:559:
+	/* Waiting here ensures that the board fini, which can turn off the power

WARNING: line over 80 characters
#26889: FILE: drivers/net/sfc/txc43128_phy.c:257:
+	/* Set PMA to test into loopback using Mt. Diablo reg. as per app note */

WARNING: braces {} are not necessary for single statement blocks
#26916: FILE: drivers/net/sfc/txc43128_phy.c:284:
+	while (bctl & (1 << TXC_BIST_CTRL_STOP_LBN)) {
+		bctl = mdio_clause45_read(port, phy, mmd, TXC_BIST_CTL);
+	}

WARNING: line over 80 characters
#26926: FILE: drivers/net/sfc/txc43128_phy.c:294:
+			EFX_ERR("%s "TXCNAME": BIST error. Lane %d had %d errors\n",

WARNING: line over 80 characters
#26933: FILE: drivers/net/sfc/txc43128_phy.c:301:
+			EFX_ERR("%s "TXCNAME": BIST error. Lane %d got 0 frames\n",

WARNING: do not add new typedefs
#27439: FILE: drivers/net/sfc/workarounds.h:43:
+typedef struct {

WARNING: line over 80 characters
#27446: FILE: drivers/net/sfc/workarounds.h:50:
+	unsigned int bug6926:1; /* Packets stuck in TX moving between loopback modes */

WARNING: line over 80 characters
#27458: FILE: drivers/net/sfc/workarounds.h:62:
+	unsigned int bug8908:1; /* Moving into/out of loopback may cause a packet

WARNING: line over 80 characters
#27459: FILE: drivers/net/sfc/workarounds.h:63:
+				 * to be dropped (caused by the fix for bug 6926) */

WARNING: line over 80 characters
#27460: FILE: drivers/net/sfc/workarounds.h:64:
+	unsigned int bug9096:1; /* Falcon doesn't flush queued ACKs before entering L1 */

WARNING: line over 80 characters
#27461: FILE: drivers/net/sfc/workarounds.h:65:
+	unsigned int bug9141:1; /* TX packet parser problem with <= 16 byte TXes */

WARNING: line over 80 characters
#27463: FILE: drivers/net/sfc/workarounds.h:67:
+	unsigned int bug10750:1;/* Constant low rate CRC errors require XAUI reset */

WARNING: line over 80 characters
#27464: FILE: drivers/net/sfc/workarounds.h:68:
+	unsigned int bug10789:1;/* SFE4001: 10XPress resets 312.5MHz PLL reset */

WARNING: line over 80 characters
#27467: FILE: drivers/net/sfc/workarounds.h:71:
+	unsigned int bug8202:1; /* FPGA/B0 memories need clearing at start-of-day */

WARNING: line over 80 characters
#27470: FILE: drivers/net/sfc/workarounds.h:74:
+				 * erroneously on busy systems. Recent builds OK */

ERROR: need space after that ',' (ctx:VxV)
#27474: FILE: drivers/net/sfc/workarounds.h:78:
+#define FALCON_A1_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1
                                   ^

ERROR: need space after that ',' (ctx:VxV)
#27474: FILE: drivers/net/sfc/workarounds.h:78:
+#define FALCON_A1_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1
                                     ^

ERROR: need space after that ',' (ctx:VxV)
#27474: FILE: drivers/net/sfc/workarounds.h:78:
+#define FALCON_A1_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1
                                       ^

ERROR: need space after that ',' (ctx:VxV)
#27474: FILE: drivers/net/sfc/workarounds.h:78:
+#define FALCON_A1_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1
                                         ^

ERROR: need space after that ',' (ctx:VxV)
#27474: FILE: drivers/net/sfc/workarounds.h:78:
+#define FALCON_A1_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1
                                           ^

ERROR: need space after that ',' (ctx:VxV)
#27474: FILE: drivers/net/sfc/workarounds.h:78:
+#define FALCON_A1_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1
                                             ^

ERROR: need space after that ',' (ctx:VxV)
#27474: FILE: drivers/net/sfc/workarounds.h:78:
+#define FALCON_A1_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1
                                               ^

ERROR: need space after that ',' (ctx:VxV)
#27474: FILE: drivers/net/sfc/workarounds.h:78:
+#define FALCON_A1_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1
                                                 ^

ERROR: need space after that ',' (ctx:VxV)
#27474: FILE: drivers/net/sfc/workarounds.h:78:
+#define FALCON_A1_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1
                                                   ^

ERROR: need space after that ',' (ctx:VxV)
#27475: FILE: drivers/net/sfc/workarounds.h:79:
+#define NO_FALCON_A1_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0
                                   ^

ERROR: need space after that ',' (ctx:VxV)
#27475: FILE: drivers/net/sfc/workarounds.h:79:
+#define NO_FALCON_A1_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0
                                     ^

ERROR: need space after that ',' (ctx:VxV)
#27475: FILE: drivers/net/sfc/workarounds.h:79:
+#define NO_FALCON_A1_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0
                                       ^

ERROR: need space after that ',' (ctx:VxV)
#27475: FILE: drivers/net/sfc/workarounds.h:79:
+#define NO_FALCON_A1_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0
                                         ^

ERROR: need space after that ',' (ctx:VxV)
#27475: FILE: drivers/net/sfc/workarounds.h:79:
+#define NO_FALCON_A1_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0
                                           ^

ERROR: need space after that ',' (ctx:VxV)
#27475: FILE: drivers/net/sfc/workarounds.h:79:
+#define NO_FALCON_A1_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0
                                             ^

ERROR: need space after that ',' (ctx:VxV)
#27475: FILE: drivers/net/sfc/workarounds.h:79:
+#define NO_FALCON_A1_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0
                                               ^

ERROR: need space after that ',' (ctx:VxV)
#27475: FILE: drivers/net/sfc/workarounds.h:79:
+#define NO_FALCON_A1_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0
                                                 ^

ERROR: need space after that ',' (ctx:VxV)
#27475: FILE: drivers/net/sfc/workarounds.h:79:
+#define NO_FALCON_A1_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0
                                                   ^

ERROR: need space after that ',' (ctx:VxV)
#27477: FILE: drivers/net/sfc/workarounds.h:81:
+#define FALCON_B0_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1,1
                                   ^

ERROR: need space after that ',' (ctx:VxV)
#27477: FILE: drivers/net/sfc/workarounds.h:81:
+#define FALCON_B0_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1,1
                                     ^

ERROR: need space after that ',' (ctx:VxV)
#27477: FILE: drivers/net/sfc/workarounds.h:81:
+#define FALCON_B0_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1,1
                                       ^

ERROR: need space after that ',' (ctx:VxV)
#27477: FILE: drivers/net/sfc/workarounds.h:81:
+#define FALCON_B0_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1,1
                                         ^

ERROR: need space after that ',' (ctx:VxV)
#27477: FILE: drivers/net/sfc/workarounds.h:81:
+#define FALCON_B0_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1,1
                                           ^

ERROR: need space after that ',' (ctx:VxV)
#27477: FILE: drivers/net/sfc/workarounds.h:81:
+#define FALCON_B0_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1,1
                                             ^

ERROR: need space after that ',' (ctx:VxV)
#27477: FILE: drivers/net/sfc/workarounds.h:81:
+#define FALCON_B0_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1,1
                                               ^

ERROR: need space after that ',' (ctx:VxV)
#27477: FILE: drivers/net/sfc/workarounds.h:81:
+#define FALCON_B0_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1,1
                                                 ^

ERROR: need space after that ',' (ctx:VxV)
#27477: FILE: drivers/net/sfc/workarounds.h:81:
+#define FALCON_B0_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1,1
                                                   ^

ERROR: need space after that ',' (ctx:VxV)
#27477: FILE: drivers/net/sfc/workarounds.h:81:
+#define FALCON_B0_WORKAROUNDS    1,1,1,1,1,1,1,1,1,1,1
                                                     ^

ERROR: need space after that ',' (ctx:VxV)
#27478: FILE: drivers/net/sfc/workarounds.h:82:
+#define NO_FALCON_B0_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0,0
                                   ^

ERROR: need space after that ',' (ctx:VxV)
#27478: FILE: drivers/net/sfc/workarounds.h:82:
+#define NO_FALCON_B0_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0,0
                                     ^

ERROR: need space after that ',' (ctx:VxV)
#27478: FILE: drivers/net/sfc/workarounds.h:82:
+#define NO_FALCON_B0_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0,0
                                       ^

ERROR: need space after that ',' (ctx:VxV)
#27478: FILE: drivers/net/sfc/workarounds.h:82:
+#define NO_FALCON_B0_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0,0
                                         ^

ERROR: need space after that ',' (ctx:VxV)
#27478: FILE: drivers/net/sfc/workarounds.h:82:
+#define NO_FALCON_B0_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0,0
                                           ^

ERROR: need space after that ',' (ctx:VxV)
#27478: FILE: drivers/net/sfc/workarounds.h:82:
+#define NO_FALCON_B0_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0,0
                                             ^

ERROR: need space after that ',' (ctx:VxV)
#27478: FILE: drivers/net/sfc/workarounds.h:82:
+#define NO_FALCON_B0_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0,0
                                               ^

ERROR: need space after that ',' (ctx:VxV)
#27478: FILE: drivers/net/sfc/workarounds.h:82:
+#define NO_FALCON_B0_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0,0
                                                 ^

ERROR: need space after that ',' (ctx:VxV)
#27478: FILE: drivers/net/sfc/workarounds.h:82:
+#define NO_FALCON_B0_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0,0
                                                   ^

ERROR: need space after that ',' (ctx:VxV)
#27478: FILE: drivers/net/sfc/workarounds.h:82:
+#define NO_FALCON_B0_WORKAROUNDS 0,0,0,0,0,0,0,0,0,0,0
                                                     ^

ERROR: need space after that ',' (ctx:VxV)
#27480: FILE: drivers/net/sfc/workarounds.h:84:
+#define FALCON_B0_FPGA_WORKAROUNDS    1,1,1
                                        ^

ERROR: need space after that ',' (ctx:VxV)
#27480: FILE: drivers/net/sfc/workarounds.h:84:
+#define FALCON_B0_FPGA_WORKAROUNDS    1,1,1
                                          ^

ERROR: need space after that ',' (ctx:VxV)
#27481: FILE: drivers/net/sfc/workarounds.h:85:
+#define NO_FALCON_B0_FPGA_WORKAROUNDS 0,0,0
                                        ^

ERROR: need space after that ',' (ctx:VxV)
#27481: FILE: drivers/net/sfc/workarounds.h:85:
+#define NO_FALCON_B0_FPGA_WORKAROUNDS 0,0,0
                                          ^

total: 70 errors, 81 warnings, 27650 lines checked
Your patch has style problems, please review.  If any of these errors
are false positives report them to the maintainer, see
CHECKPATCH in MAINTAINERS.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>

From: Pradeep Dalvi <pradeep@linsyssoft.com>
Subject: Re: [PATCH 1/9] NetXen 1G/10G ethernet driver patch with
	corrections
Date: Thu, 08 Jun 2006 14:55:02 +0000
Message-ID: <1149778502.12428.3.camel@arya.linsyssoft.com>
References: <Pine.LNX.4.64.0606070237220.10031@unmsrvr>
	 <200606071149.51879.ak@suse.de>
Reply-To: pradeep@linsyssoft.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	UNM Project Staff <unmproj@linsyssoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:65346 "EHLO
	svr68.ehostpros.com") by vger.kernel.org with ESMTP id S964864AbWFHPMH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 11:12:07 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200606071149.51879.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -u linux-2.6.16.20/drivers/net/netxen/netxen_nic_ethtool.c
linux-2.6.16.20/drivers/net/netxen/netxen_nic_ethtool.c
--- linux-2.6.16.20/drivers/net/netxen/netxen_nic_ethtool.c	2006-06-06
06:58:11.000000000 -0700
+++ linux-2.6.16.20/drivers/net/netxen/netxen_nic_ethtool.c	2006-06-08
06:52:09.000000000 -0700
@@ -240,6 +240,95 @@
 	return NETXEN_NIC_REGS_LEN;
 }
 
+struct netxen_niu_regs {
+	netxen_crbword_t	reg[NETXEN_NIC_REGS_COUNT];
+};
+
+static struct netxen_niu_regs niu_registers[] = {
+	{
+	 /* GB Mode */
+	 {
+	  NETXEN_NIU_GB_SERDES_RESET,
+	  NETXEN_NIU_GB0_MII_MODE,
+	  NETXEN_NIU_GB1_MII_MODE,
+	  NETXEN_NIU_GB2_MII_MODE,
+	  NETXEN_NIU_GB3_MII_MODE,
+	  NETXEN_NIU_GB0_GMII_MODE,
+	  NETXEN_NIU_GB1_GMII_MODE,
+	  NETXEN_NIU_GB2_GMII_MODE,
+	  NETXEN_NIU_GB3_GMII_MODE,
+	  NETXEN_NIU_REMOTE_LOOPBACK,
+	  NETXEN_NIU_GB0_HALF_DUPLEX,
+	  NETXEN_NIU_GB1_HALF_DUPLEX,
+	  NETXEN_NIU_RESET_SYS_FIFOS,
+	  NETXEN_NIU_GB_CRC_DROP,
+	  NETXEN_NIU_GB_DROP_WRONGADDR,
+	  NETXEN_NIU_TEST_MUX_CTL,
+	 
+	  NETXEN_NIU_GB_MAC_CONFIG_0(0),
+	  NETXEN_NIU_GB_MAC_CONFIG_1(0),
+	  NETXEN_NIU_GB_HALF_DUPLEX_CTRL(0),
+	  NETXEN_NIU_GB_MAX_FRAME_SIZE(0),
+	  NETXEN_NIU_GB_TEST_REG(0),
+	  NETXEN_NIU_GB_MII_MGMT_CONFIG(0),
+	  NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
+	  NETXEN_NIU_GB_MII_MGMT_ADDR(0),
+	  NETXEN_NIU_GB_MII_MGMT_CTRL(0),
+	  NETXEN_NIU_GB_MII_MGMT_STATUS(0),
+	  NETXEN_NIU_GB_MII_MGMT_INDICATE(0),
+	  NETXEN_NIU_GB_INTERFACE_CTRL(0),
+	  NETXEN_NIU_GB_INTERFACE_STATUS(0),
+	  NETXEN_NIU_GB_STATION_ADDR_0(0),
+	  NETXEN_NIU_GB_STATION_ADDR_1(0),
+	  -1,
+	 }
+	},
+	{
+	 /* XG Mode */
+	 {
+	  NETXEN_NIU_XG_SINGLE_TERM,
+	  NETXEN_NIU_XG_DRIVE_HI,
+	  NETXEN_NIU_XG_DRIVE_LO,
+	  NETXEN_NIU_XG_DTX,
+	  NETXEN_NIU_XG_DEQ,
+	  NETXEN_NIU_XG_WORD_ALIGN,
+	  NETXEN_NIU_XG_RESET,
+	  NETXEN_NIU_XG_POWER_DOWN,
+	  NETXEN_NIU_XG_RESET_PLL,
+	  NETXEN_NIU_XG_SERDES_LOOPBACK,
+	  NETXEN_NIU_XG_DO_BYTE_ALIGN,
+	  NETXEN_NIU_XG_TX_ENABLE,
+	  NETXEN_NIU_XG_RX_ENABLE,
+	  NETXEN_NIU_XG_STATUS,
+	  NETXEN_NIU_XG_PAUSE_THRESHOLD,
+	  NETXEN_NIU_XGE_CONFIG_0,
+	  NETXEN_NIU_XGE_CONFIG_1,
+	  NETXEN_NIU_XGE_IPG,
+	  NETXEN_NIU_XGE_STATION_ADDR_0_HI,
+	  NETXEN_NIU_XGE_STATION_ADDR_0_1,
+	  NETXEN_NIU_XGE_STATION_ADDR_1_LO,
+	  NETXEN_NIU_XGE_STATUS,
+	  NETXEN_NIU_XGE_MAX_FRAME_SIZE,
+	  NETXEN_NIU_XGE_PAUSE_FRAME_VALUE,
+	  NETXEN_NIU_XGE_TX_BYTE_CNT,
+	  NETXEN_NIU_XGE_TX_FRAME_CNT,
+	  NETXEN_NIU_XGE_RX_BYTE_CNT,
+	  NETXEN_NIU_XGE_RX_FRAME_CNT,
+	  NETXEN_NIU_XGE_AGGR_ERROR_CNT,
+	  NETXEN_NIU_XGE_MULTICAST_FRAME_CNT,
+	  NETXEN_NIU_XGE_UNICAST_FRAME_CNT,
+	  NETXEN_NIU_XGE_CRC_ERROR_CNT,
+	  NETXEN_NIU_XGE_OVERSIZE_FRAME_ERR,
+	  NETXEN_NIU_XGE_UNDERSIZE_FRAME_ERR,
+	  NETXEN_NIU_XGE_LOCAL_ERROR_CNT,
+	  NETXEN_NIU_XGE_REMOTE_ERROR_CNT,
+	  NETXEN_NIU_XGE_CONTROL_CHAR_CNT,
+	  NETXEN_NIU_XGE_PAUSE_FRAME_CNT,
+	  -1,
+	 }
+	}
+};
+
 static void
 netxen_nic_get_regs(struct net_device *dev, struct ethtool_regs *regs,
void *p)
 {
@@ -248,6 +337,7 @@
 	netxen_crbword_t mode, *regs_buff = p;
 	unsigned long flags;
 	void *addr;
+	int i, window;
 
 	memset(p, 0, NETXEN_NIC_REGS_LEN);
 	regs->version = (1 << 24) | (adapter->ahw.revision_id << 16) |
@@ -260,176 +350,18 @@
 	/* Common registers to all the modes */
 	NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_STRAP_VALUE_SAVE_HIGHER,
 				   &regs_buff[2]);
-	switch (mode) {
-	case 4:{		/* XGB Mode */
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_SINGLE_TERM,
-						   &regs_buff[3]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_DRIVE_HI,
-						   &regs_buff[4]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_DRIVE_LO,
-						   &regs_buff[5]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_DTX,
-						   &regs_buff[6]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_DEQ,
-						   &regs_buff[7]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_WORD_ALIGN,
-						   &regs_buff[8]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_RESET,
-						   &regs_buff[9]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_POWER_DOWN,
-						   &regs_buff[10]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_RESET_PLL,
-						   &regs_buff[11]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XG_SERDES_LOOPBACK, &regs_buff[12]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_DO_BYTE_ALIGN,
-						   &regs_buff[13]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_TX_ENABLE,
-						   &regs_buff[14]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_RX_ENABLE,
-						   &regs_buff[15]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_STATUS,
-						   &regs_buff[16]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XG_PAUSE_THRESHOLD, &regs_buff[17]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_CONFIG_0,
-						   &regs_buff[18]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_CONFIG_1,
-						   &regs_buff[19]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_IPG,
-						   &regs_buff[20]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XGE_STATION_ADDR_0_HI, &regs_buff[21]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XGE_STATION_ADDR_0_1, &regs_buff[22]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XGE_STATION_ADDR_1_LO, &regs_buff[23]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_STATUS,
-						   &regs_buff[24]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XGE_MAX_FRAME_SIZE, &regs_buff[25]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XGE_PAUSE_FRAME_VALUE, &regs_buff[26]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_TX_BYTE_CNT,
-						   &regs_buff[27]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_TX_FRAME_CNT,
-						   &regs_buff[28]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_RX_BYTE_CNT,
-						   &regs_buff[29]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_RX_FRAME_CNT,
-						   &regs_buff[30]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XGE_AGGR_ERROR_CNT, &regs_buff[31]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XGE_MULTICAST_FRAME_CNT,
-			     &regs_buff[32]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XGE_UNICAST_FRAME_CNT, &regs_buff[33]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_CRC_ERROR_CNT,
-						   &regs_buff[34]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XGE_OVERSIZE_FRAME_ERR, &regs_buff[35]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XGE_UNDERSIZE_FRAME_ERR,
-			     &regs_buff[36]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XGE_LOCAL_ERROR_CNT, &regs_buff[37]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XGE_REMOTE_ERROR_CNT, &regs_buff[38]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XGE_CONTROL_CHAR_CNT, &regs_buff[39]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_XGE_PAUSE_FRAME_CNT, &regs_buff[40]);
-			break;
-		}
+	/* GB/XGB Mode */
+	mode = (mode/2) - 1;
+	window = 0;
+	if(mode <= 1) {
+		for ( i = 3; niu_registers[mode].reg[i - 3] != -1; i++) {
+			/* GB: port specific registers */
+			if(mode == 0 && i >= 19)
+				window = port->portnum * 0x10000;
 
-	case 2:{		/* GB Mode */
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_SERDES_RESET,
-						   &regs_buff[3]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB0_MII_MODE,
-						   &regs_buff[4]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB1_MII_MODE,
-						   &regs_buff[5]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB2_MII_MODE,
-						   &regs_buff[6]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB3_MII_MODE,
-						   &regs_buff[7]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB0_GMII_MODE,
-						   &regs_buff[8]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB1_GMII_MODE,
-						   &regs_buff[9]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB2_GMII_MODE,
-						   &regs_buff[10]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB3_GMII_MODE,
-						   &regs_buff[11]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_REMOTE_LOOPBACK,
-						   &regs_buff[12]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB0_HALF_DUPLEX,
-						   &regs_buff[13]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB1_HALF_DUPLEX,
-						   &regs_buff[14]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_RESET_SYS_FIFOS,
-						   &regs_buff[15]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_CRC_DROP,
-						   &regs_buff[16]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_DROP_WRONGADDR,
-						   &regs_buff[17]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_TEST_MUX_CTL,
-						   &regs_buff[18]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_MAC_CONFIG_0
-						   (port->portnum),
-						   &regs_buff[19]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_MAC_CONFIG_1
-						   (port->portnum),
-						   &regs_buff[20]);
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_GB_HALF_DUPLEX_CTRL(port->portnum),
-			     &regs_buff[21]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_MAX_FRAME_SIZE
-						   (port->portnum),
-						   &regs_buff[22]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_TEST_REG
-						   (port->portnum),
-						   &regs_buff[23]);
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_MII_MGMT_CONFIG
-						   (port->portnum),
-						   &regs_buff[24]);
 			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_GB_MII_MGMT_COMMAND(port->portnum),
-			     &regs_buff[25]);
-
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_MII_MGMT_ADDR
-						   (port->portnum),
-						   &regs_buff[26]);
-
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_MII_MGMT_CTRL
-						   (port->portnum),
-						   &regs_buff[27]);
-
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_MII_MGMT_STATUS
-						   (port->portnum),
-						   &regs_buff[28]);
-
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_GB_MII_MGMT_INDICATE(port->portnum),
-			     &regs_buff[29]);
-
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_INTERFACE_CTRL
-						   (port->portnum),
-						   &regs_buff[30]);
-
-			NETXEN_NIC_LOCKED_READ_REG
-			    (NETXEN_NIU_GB_INTERFACE_STATUS(port->portnum),
-			     &regs_buff[31]);
-
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_STATION_ADDR_0
-						   (port->portnum),
-						   &regs_buff[32]);
-
-			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_STATION_ADDR_1
-						   (port->portnum),
-						   &regs_buff[33]);
-			break;
+			    (niu_registers[mode].reg[i - 3] + window,
+			    &regs_buff[i]);
 		}
 	}
 	write_unlock_irqrestore(&adapter->adapter_lock, flags);

On Wed, 2006-06-07 at 11:49 +0200, Andi Kleen wrote:
> On Wednesday 07 June 2006 11:39, Linsys Contractor Amit S. Kale wrote:
> 
> > +	switch (mode) {
> 
> ... You could save a lot of code by using a table and a loop over the registers.
> 
> 
> > +	case 4:{		/* XGB Mode */
> > +			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_SINGLE_TERM,
> > +						   &regs_buff[3]);
> 
> 
> -Andi
> 
> 
-- 
pradeep


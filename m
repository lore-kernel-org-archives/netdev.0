From: Matthias Winkler <m.winkler@unicon-ka.de>
Subject: Re: 8168, PCI-Express, mac-version 0x3c000000, CFG_METHOD_4
Date: Thu, 11 Oct 2007 10:34:14 +0200
Message-ID: <470DE006.3070005@unicon-ka.de>
References: <470D04FD.30105@unicon-ka.de> <20071010201533.GB10947@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000808010908090302050702"
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.unicon-ka.de ([217.160.115.17]:37617 "EHLO
	mail.unicon-ka.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882AbXJKIqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 04:46:10 -0400
In-Reply-To: <20071010201533.GB10947@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000808010908090302050702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Francois Romieu,

I just tested out your patch for my r8168.
The card is a: r8168, PCI-Express, mac-version 0x3c000000 and the
realtek driver from the manufacutrer uses  CFG_METHOD_4 for it.
The card did NOT work with the current 2.6.23 kernel!

Your patch seems to work but  to strange behaviors still remain:

1) The dropped RX_packet count increases very very fast (see attached 
ifconfig.txt)
2) The card is reported as FIBRE by ethtool (see attached ethtool.txt)

I think (RTL_R8(PHYstatus) & TBI_Enable) should be false for this card. 
If I replace
this expression with "0" in thte code, then the card will be reported as 
Twisted Pair...
but I'am new to all this....

Also attached:
- modprobe r8168 debug=16
- dmesg
- eththool eth0
- lspci -vvx
- ifconfig eth0


greets Matthias


> Matthias Winkler <m.winkler@unicon-ka.de> :
> [...]
>   
>> I try to get the brandnew 2.6.23. r8169 working for my realtek r8168.
>> I already tried the original driver, but I'm not satisfied with it.
>> The original driver want to much DMA-Memory (1024x RxBufferSize)
>> for its Ringbuffer this could fail, if I have filesystem-IO (which needs 
>> DMA)
>> and then try to load the driver. Realteks module fails loading then. I'm not
>> sure if I should just change the RingBufferSize in the Realtek driver....
>>
>> Anyway, I hoped the new kernel driver will fix this up. But my card is 
>> not regonized right from the driver.
>>
>> My mac-version is 0x3c000000 which is not in the list of the kernel 
>> driver. The realtek drivers
>> classifies my card as CFG_METHOD_4:
>>     
>
> Can you try the patch below against 2.6.23 and add netdev@vger.kernel.org
> to the Cc: when you report the result (with a bit of context for the
> newcomers please) ?
>
> I'd welcome a complete lspci -vvx + dmesg + motherboard id ?
>
> commit 4f0e9ba5317c6b1d582ec21542d57c1917c73cb4
> Author: Francois Romieu <romieu@fr.zoreil.com>
> Date:   Fri Aug 17 18:26:35 2007 +0200
>
>     r8169: phy init cleanup
>     
>     Consistent use of hexadecimal. No change of behavior otherwise.
>     
>     Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>     Cc: Edward Hsu <edward_hsu@realtek.com.tw>
>
> commit 8b3e38f65801d3cd3968f43b13cecafd19e04edb
> Author: Francois Romieu <romieu@fr.zoreil.com>
> Date:   Fri Aug 17 18:21:58 2007 +0200
>
>     r8169: phy init for the 8168
>     
>     The values have been extracted from Realtek's r8168 driver
>     version 8.002.00.
>     
>     Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>     Cc: Edward Hsu <edward_hsu@realtek.com.tw>
>
> commit 97da75a842017058d1f6d8fbde3b8bd6c95f847f
> Author: Francois Romieu <romieu@fr.zoreil.com>
> Date:   Fri Aug 17 17:50:46 2007 +0200
>
>     r8169: make room for more phy init changes
>     
>     The code is reworked to easily add phy-dependant init changes.
>     No change of behavior should be noticed.
>     
>     Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>     Cc: Edward Hsu <edward_hsu@realtek.com.tw>
>
> commit b8e80c09fe8d23d1815121a34d7f066a3fa7d75d
> Author: Francois Romieu <romieu@fr.zoreil.com>
> Date:   Fri Aug 17 15:05:21 2007 +0200
>
>     r8169: remove dead wood
>     
>     Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>     Cc: Edward Hsu <edward_hsu@realtek.com.tw>
>
> commit 2faefb1cdec589803a486ce2a9cbf2cbaffe65b7
> Author: Francois Romieu <romieu@fr.zoreil.com>
> Date:   Fri Aug 17 14:55:46 2007 +0200
>
>     r8169: add MAC identifiers
>     
>     The identifiers have been extracted from Realtek's drivers:
>     - version 8.002.00 of the r8168 driver
>     - version 6.002.00 of the r8169 driver
>     - version 1.002.00 of the r8101 driver
>     
>     1. RTL_GIGA_MAC_VER_17 (8168Bf) is isolated from RTL_GIGA_MAC_VER_12 (8168Be)
>        Both are still handled the same in rtl8169_set_speed_xmii and in
>        rtl_set_rx_mode to avoid changes of behavior in this patch.
>     
>     2. RTL_GIGA_MAC_VER_16 (8101Ec) is isolated from RTL_GIGA_MAC_VER_13 (8101Eb)
>        Same thing as above with relation to rtl8169_set_speed_xmii,
>        rtl_set_rx_mode and rtl_hw_start_8101.
>     
>     3. The remaining new identifiers should not hurt.
>     
>     Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>     Cc: Edward Hsu <edward_hsu@realtek.com.tw>
>
> commit ce327077698942617fe9d293736aee95ef85eb6e
> Author: Francois Romieu <romieu@fr.zoreil.com>
> Date:   Thu Oct 4 22:51:38 2007 +0200
>
>     r8169: MSI support
>     
>     It is currently limited to the tested 0x8136 and 0x8168. 8169sb/8110sb ought
>     to handle it as well where they support MSI.
>     
>     Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>     Cc: Edward Hsu <edward_hsu@realtek.com.tw>
>     Tester-Cc: Rolf Eike Beer <eike-kernel@sf-tec.de>
>
> commit e8133c1ffa363c7003b9ce328e6f0186853789fd
> Author: Francois Romieu <romieu@fr.zoreil.com>
> Date:   Thu Oct 4 22:36:14 2007 +0200
>
>     r8169: convert bitfield to plain enum mask
>     
>     Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index c76dd29..5198b3e 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -111,19 +111,15 @@ enum mac_version {
>  	RTL_GIGA_MAC_VER_05 = 0x05, // 8110SCd
>  	RTL_GIGA_MAC_VER_06 = 0x06, // 8110SCe
>  	RTL_GIGA_MAC_VER_11 = 0x0b, // 8168Bb
> -	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be 8168Bf
> -	RTL_GIGA_MAC_VER_13 = 0x0d, // 8101Eb 8101Ec
> -	RTL_GIGA_MAC_VER_14 = 0x0e, // 8101
> -	RTL_GIGA_MAC_VER_15 = 0x0f  // 8101
> -};
> -
> -enum phy_version {
> -	RTL_GIGA_PHY_VER_C = 0x03, /* PHY Reg 0x03 bit0-3 == 0x0000 */
> -	RTL_GIGA_PHY_VER_D = 0x04, /* PHY Reg 0x03 bit0-3 == 0x0000 */
> -	RTL_GIGA_PHY_VER_E = 0x05, /* PHY Reg 0x03 bit0-3 == 0x0000 */
> -	RTL_GIGA_PHY_VER_F = 0x06, /* PHY Reg 0x03 bit0-3 == 0x0001 */
> -	RTL_GIGA_PHY_VER_G = 0x07, /* PHY Reg 0x03 bit0-3 == 0x0002 */
> -	RTL_GIGA_PHY_VER_H = 0x08, /* PHY Reg 0x03 bit0-3 == 0x0003 */
> +	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be
> +	RTL_GIGA_MAC_VER_13 = 0x0d, // 8101Eb
> +	RTL_GIGA_MAC_VER_14 = 0x0e, // 8101 ?
> +	RTL_GIGA_MAC_VER_15 = 0x0f, // 8101 ?
> +	RTL_GIGA_MAC_VER_16 = 0x11, // 8101Ec
> +	RTL_GIGA_MAC_VER_17 = 0x10, // 8168Bf
> +	RTL_GIGA_MAC_VER_18 = 0x12, // 8168CP
> +	RTL_GIGA_MAC_VER_19 = 0x13, // 8168C
> +	RTL_GIGA_MAC_VER_20 = 0x14  // 8168C
>  };
>  
>  #define _R(NAME,MAC,MASK) \
> @@ -144,7 +140,12 @@ static const struct {
>  	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_12, 0xff7e1880), // PCI-E
>  	_R("RTL8101e",		RTL_GIGA_MAC_VER_13, 0xff7e1880), // PCI-E 8139
>  	_R("RTL8100e",		RTL_GIGA_MAC_VER_14, 0xff7e1880), // PCI-E 8139
> -	_R("RTL8100e",		RTL_GIGA_MAC_VER_15, 0xff7e1880)  // PCI-E 8139
> +	_R("RTL8100e",		RTL_GIGA_MAC_VER_15, 0xff7e1880), // PCI-E 8139
> +	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_17, 0xff7e1880), // PCI-E
> +	_R("RTL8101e",		RTL_GIGA_MAC_VER_16, 0xff7e1880), // PCI-E
> +	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_18, 0xff7e1880), // PCI-E
> +	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_19, 0xff7e1880), // PCI-E
> +	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_20, 0xff7e1880)  // PCI-E
>  };
>  #undef _R
>  
> @@ -277,6 +278,7 @@ enum rtl_register_content {
>  	TxDMAShift = 8,	/* DMA burst value (0-7) is shift this many bits */
>  
>  	/* Config1 register p.24 */
> +	MSIEnable	= (1 << 5),	/* Enable Message Signaled Interrupt */
>  	PMEnable	= (1 << 0),	/* Power Management Enable */
>  
>  	/* Config2 register p. 25 */
> @@ -380,6 +382,11 @@ struct ring_info {
>  	u8		__pad[sizeof(void *) - sizeof(u32)];
>  };
>  
> +enum features {
> +	RTL_FEATURE_WOL	= (1 << 0),
> +	RTL_FEATURE_MSI	= (1 << 1),
> +};
> +
>  struct rtl8169_private {
>  	void __iomem *mmio_addr;	/* memory map physical address */
>  	struct pci_dev *pci_dev;	/* Index of PCI device */
> @@ -389,7 +396,6 @@ struct rtl8169_private {
>  	u32 msg_enable;
>  	int chipset;
>  	int mac_version;
> -	int phy_version;
>  	u32 cur_rx; /* Index into the Rx descriptor buffer of next Rx pkt. */
>  	u32 cur_tx; /* Index into the Tx descriptor buffer of next Rx pkt. */
>  	u32 dirty_rx;
> @@ -419,7 +425,7 @@ struct rtl8169_private {
>  	unsigned int (*phy_reset_pending)(void __iomem *);
>  	unsigned int (*link_ok)(void __iomem *);
>  	struct delayed_work task;
> -	unsigned wol_enabled : 1;
> +	unsigned features;
>  };
>  
>  MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
> @@ -625,7 +631,10 @@ static int rtl8169_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
>  
>  	RTL_W8(Cfg9346, Cfg9346_Lock);
>  
> -	tp->wol_enabled = (wol->wolopts) ? 1 : 0;
> +	if (wol->wolopts)
> +		tp->features |= RTL_FEATURE_WOL;
> +	else
> +		tp->features &= ~RTL_FEATURE_WOL;
>  
>  	spin_unlock_irq(&tp->lock);
>  
> @@ -706,7 +715,8 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
>  
>  		/* This tweak comes straight from Realtek's driver. */
>  		if ((speed == SPEED_100) && (duplex == DUPLEX_HALF) &&
> -		    (tp->mac_version == RTL_GIGA_MAC_VER_13)) {
> +		    ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
> +		     (tp->mac_version == RTL_GIGA_MAC_VER_16))) {
>  			auto_nego = ADVERTISE_100HALF | ADVERTISE_CSMA;
>  		}
>  	}
> @@ -714,7 +724,8 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
>  	/* The 8100e/8101e do Fast Ethernet only. */
>  	if ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
>  	    (tp->mac_version == RTL_GIGA_MAC_VER_14) ||
> -	    (tp->mac_version == RTL_GIGA_MAC_VER_15)) {
> +	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
> +	    (tp->mac_version == RTL_GIGA_MAC_VER_16)) {
>  		if ((giga_ctrl & (ADVERTISE_1000FULL | ADVERTISE_1000HALF)) &&
>  		    netif_msg_link(tp)) {
>  			printk(KERN_INFO "%s: PHY does not support 1000Mbps.\n",
> @@ -725,7 +736,8 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
>  
>  	auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
>  
> -	if (tp->mac_version == RTL_GIGA_MAC_VER_12) {
> +	if ((tp->mac_version == RTL_GIGA_MAC_VER_12) ||
> +	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
>  		/* Vendor specific (0x1f) and reserved (0x0e) MII registers. */
>  		mdio_write(ioaddr, 0x1f, 0x0000);
>  		mdio_write(ioaddr, 0x0e, 0x0000);
> @@ -1101,26 +1113,51 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
>  	 */
>  	const struct {
>  		u32 mask;
> +		u32 val;
>  		int mac_version;
>  	} mac_info[] = {
> -		{ 0x38800000,	RTL_GIGA_MAC_VER_15 },
> -		{ 0x38000000,	RTL_GIGA_MAC_VER_12 },
> -		{ 0x34000000,	RTL_GIGA_MAC_VER_13 },
> -		{ 0x30800000,	RTL_GIGA_MAC_VER_14 },
> -		{ 0x30000000,	RTL_GIGA_MAC_VER_11 },
> -		{ 0x98000000,	RTL_GIGA_MAC_VER_06 },
> -		{ 0x18000000,	RTL_GIGA_MAC_VER_05 },
> -		{ 0x10000000,	RTL_GIGA_MAC_VER_04 },
> -		{ 0x04000000,	RTL_GIGA_MAC_VER_03 },
> -		{ 0x00800000,	RTL_GIGA_MAC_VER_02 },
> -		{ 0x00000000,	RTL_GIGA_MAC_VER_01 }	/* Catch-all */
> +		/* 8168B family. */
> +		{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_18 },
> +		{ 0x7cf00000, 0x3c000000,	RTL_GIGA_MAC_VER_19 },
> +		{ 0x7cf00000, 0x3c200000,	RTL_GIGA_MAC_VER_20 },
> +		{ 0x7c800000, 0x3c000000,	RTL_GIGA_MAC_VER_20 },
> +
> +		/* 8168B family. */
> +		{ 0x7cf00000, 0x38000000,	RTL_GIGA_MAC_VER_12 },
> +		{ 0x7cf00000, 0x38500000,	RTL_GIGA_MAC_VER_17 },
> +		{ 0x7c800000, 0x38000000,	RTL_GIGA_MAC_VER_17 },
> +		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
> +
> +		/* 8101 family. */
> +		{ 0x7cf00000, 0x34000000,	RTL_GIGA_MAC_VER_13 },
> +		{ 0x7cf00000, 0x34200000,	RTL_GIGA_MAC_VER_16 },
> +		{ 0x7c800000, 0x34000000,	RTL_GIGA_MAC_VER_16 },
> +		/* FIXME: where did these entries come from ? -- FR */
> +		{ 0xfc800000, 0x38800000,	RTL_GIGA_MAC_VER_15 },
> +		{ 0xfc800000, 0x30800000,	RTL_GIGA_MAC_VER_14 },
> +
> +		/* 8110 family. */
> +		{ 0xfc800000, 0x98000000,	RTL_GIGA_MAC_VER_06 },
> +		{ 0xfc800000, 0x18000000,	RTL_GIGA_MAC_VER_05 },
> +		{ 0xfc800000, 0x10000000,	RTL_GIGA_MAC_VER_04 },
> +		{ 0xfc800000, 0x04000000,	RTL_GIGA_MAC_VER_03 },
> +		{ 0xfc800000, 0x00800000,	RTL_GIGA_MAC_VER_02 },
> +		{ 0xfc800000, 0x00000000,	RTL_GIGA_MAC_VER_01 },
> +
> +		{ 0x00000000, 0x00000000,	RTL_GIGA_MAC_VER_01 }	/* Catch-all */
>  	}, *p = mac_info;
>  	u32 reg;
>  
> -	reg = RTL_R32(TxConfig) & 0xfc800000;
> -	while ((reg & p->mask) != p->mask)
> +	reg = RTL_R32(TxConfig);
> +	while ((reg & p->mask) != p->val)
>  		p++;
>  	tp->mac_version = p->mac_version;
> +
> +	if (p->mask == 0x00000000) {
> +		struct pci_dev *pdev = tp->pci_dev;
> +
> +		dev_info(&pdev->dev, "unknown MAC (%08x)\n", reg);
> +	}
>  }
>  
>  static void rtl8169_print_mac_version(struct rtl8169_private *tp)
> @@ -1128,54 +1165,21 @@ static void rtl8169_print_mac_version(struct rtl8169_private *tp)
>  	dprintk("mac_version = 0x%02x\n", tp->mac_version);
>  }
>  
> -static void rtl8169_get_phy_version(struct rtl8169_private *tp,
> -				    void __iomem *ioaddr)
> -{
> -	const struct {
> -		u16 mask;
> -		u16 set;
> -		int phy_version;
> -	} phy_info[] = {
> -		{ 0x000f, 0x0002, RTL_GIGA_PHY_VER_G },
> -		{ 0x000f, 0x0001, RTL_GIGA_PHY_VER_F },
> -		{ 0x000f, 0x0000, RTL_GIGA_PHY_VER_E },
> -		{ 0x0000, 0x0000, RTL_GIGA_PHY_VER_D } /* Catch-all */
> -	}, *p = phy_info;
> +struct phy_reg {
>  	u16 reg;
> +	u16 val;
> +};
>  
> -	reg = mdio_read(ioaddr, MII_PHYSID2) & 0xffff;
> -	while ((reg & p->mask) != p->set)
> -		p++;
> -	tp->phy_version = p->phy_version;
> -}
> -
> -static void rtl8169_print_phy_version(struct rtl8169_private *tp)
> +static void rtl_phy_write(void __iomem *ioaddr, struct phy_reg *regs, int len)
>  {
> -	struct {
> -		int version;
> -		char *msg;
> -		u32 reg;
> -	} phy_print[] = {
> -		{ RTL_GIGA_PHY_VER_G, "RTL_GIGA_PHY_VER_G", 0x0002 },
> -		{ RTL_GIGA_PHY_VER_F, "RTL_GIGA_PHY_VER_F", 0x0001 },
> -		{ RTL_GIGA_PHY_VER_E, "RTL_GIGA_PHY_VER_E", 0x0000 },
> -		{ RTL_GIGA_PHY_VER_D, "RTL_GIGA_PHY_VER_D", 0x0000 },
> -		{ 0, NULL, 0x0000 }
> -	}, *p;
> -
> -	for (p = phy_print; p->msg; p++) {
> -		if (tp->phy_version == p->version) {
> -			dprintk("phy_version == %s (%04x)\n", p->msg, p->reg);
> -			return;
> -		}
> +	while (len-- > 0) {
> +		mdio_write(ioaddr, regs->reg, regs->val);
> +		regs++;
>  	}
> -	dprintk("phy_version == Unknown\n");
>  }
>  
> -static void rtl8169_hw_phy_config(struct net_device *dev)
> +static void rtl8169s_hw_phy_config(void __iomem *ioaddr)
>  {
> -	struct rtl8169_private *tp = netdev_priv(dev);
> -	void __iomem *ioaddr = tp->mmio_addr;
>  	struct {
>  		u16 regs[5]; /* Beware of bit-sign propagation */
>  	} phy_magic[5] = { {
> @@ -1208,33 +1212,9 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
>  	}, *p = phy_magic;
>  	unsigned int i;
>  
> -	rtl8169_print_mac_version(tp);
> -	rtl8169_print_phy_version(tp);
> -
> -	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
> -		return;
> -	if (tp->phy_version >= RTL_GIGA_PHY_VER_H)
> -		return;
> -
> -	dprintk("MAC version != 0 && PHY version == 0 or 1\n");
> -	dprintk("Do final_reg2.cfg\n");
> -
> -	/* Shazam ! */
> -
> -	if (tp->mac_version == RTL_GIGA_MAC_VER_04) {
> -		mdio_write(ioaddr, 31, 0x0002);
> -		mdio_write(ioaddr,  1, 0x90d0);
> -		mdio_write(ioaddr, 31, 0x0000);
> -		return;
> -	}
> -
> -	if ((tp->mac_version != RTL_GIGA_MAC_VER_02) &&
> -	    (tp->mac_version != RTL_GIGA_MAC_VER_03))
> -		return;
> -
> -	mdio_write(ioaddr, 31, 0x0001);			//w 31 2 0 1
> -	mdio_write(ioaddr, 21, 0x1000);			//w 21 15 0 1000
> -	mdio_write(ioaddr, 24, 0x65c7);			//w 24 15 0 65c7
> +	mdio_write(ioaddr, 0x1f, 0x0001);		//w 31 2 0 1
> +	mdio_write(ioaddr, 0x15, 0x1000);		//w 21 15 0 1000
> +	mdio_write(ioaddr, 0x18, 0x65c7);		//w 24 15 0 65c7
>  	rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 0);	//w 4 11 11 0
>  
>  	for (i = 0; i < ARRAY_SIZE(phy_magic); i++, p++) {
> @@ -1247,7 +1227,79 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
>  		rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 1); //w 4 11 11 1
>  		rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 0); //w 4 11 11 0
>  	}
> -	mdio_write(ioaddr, 31, 0x0000); //w 31 2 0 0
> +	mdio_write(ioaddr, 0x1f, 0x0000); //w 31 2 0 0
> +}
> +
> +static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
> +{
> +	struct phy_reg phy_reg_init[] = {
> +		{ 0x1f, 0x0002 },
> +		{ 0x01, 0x90d0 },
> +		{ 0x1f, 0x0000 }
> +	};
> +
> +	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
> +}
> +
> +static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
> +{
> +	struct phy_reg phy_reg_init[] = {
> +		{ 0x1f, 0x0000 },
> +		{ 0x1d, 0x0f00 },
> +		{ 0x1f, 0x0002 },
> +		{ 0x0c, 0x1ec8 },
> +		{ 0x1f, 0x0000 }
> +	};
> +
> +	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
> +}
> +
> +static void rtl8168c_hw_phy_config(void __iomem *ioaddr)
> +{
> +	struct phy_reg phy_reg_init[] = {
> +		{ 0x1f, 0x0002 },
> +		{ 0x00, 0x88d4 },
> +		{ 0x01, 0x82b1 },
> +		{ 0x03, 0x7002 },
> +		{ 0x08, 0x9e30 },
> +		{ 0x09, 0x01f0 },
> +		{ 0x0a, 0x5500 },
> +		{ 0x0c, 0x00c8 },
> +		{ 0x1f, 0x0003 },
> +		{ 0x12, 0xc096 },
> +		{ 0x16, 0x000a },
> +		{ 0x1f, 0x0000 }
> +	};
> +
> +	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
> +}
> +
> +static void rtl_hw_phy_config(struct net_device *dev)
> +{
> +	struct rtl8169_private *tp = netdev_priv(dev);
> +	void __iomem *ioaddr = tp->mmio_addr;
> +
> +	rtl8169_print_mac_version(tp);
> +
> +	switch (tp->mac_version) {
> +	case RTL_GIGA_MAC_VER_01:
> +		break;
> +	case RTL_GIGA_MAC_VER_02:
> +	case RTL_GIGA_MAC_VER_03:
> +		rtl8169s_hw_phy_config(ioaddr);
> +		break;
> +	case RTL_GIGA_MAC_VER_04:
> +		rtl8169sb_hw_phy_config(ioaddr);
> +		break;
> +	case RTL_GIGA_MAC_VER_18:
> +		rtl8168cp_hw_phy_config(ioaddr);
> +		break;
> +	case RTL_GIGA_MAC_VER_19:
> +		rtl8168c_hw_phy_config(ioaddr);
> +		break;
> +	default:
> +		break;
> +	}
>  }
>  
>  static void rtl8169_phy_timer(unsigned long __opaque)
> @@ -1259,7 +1311,6 @@ static void rtl8169_phy_timer(unsigned long __opaque)
>  	unsigned long timeout = RTL8169_PHY_TIMEOUT;
>  
>  	assert(tp->mac_version > RTL_GIGA_MAC_VER_01);
> -	assert(tp->phy_version < RTL_GIGA_PHY_VER_H);
>  
>  	if (!(tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL))
>  		return;
> @@ -1294,8 +1345,7 @@ static inline void rtl8169_delete_timer(struct net_device *dev)
>  	struct rtl8169_private *tp = netdev_priv(dev);
>  	struct timer_list *timer = &tp->timer;
>  
> -	if ((tp->mac_version <= RTL_GIGA_MAC_VER_01) ||
> -	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
> +	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
>  		return;
>  
>  	del_timer_sync(timer);
> @@ -1306,8 +1356,7 @@ static inline void rtl8169_request_timer(struct net_device *dev)
>  	struct rtl8169_private *tp = netdev_priv(dev);
>  	struct timer_list *timer = &tp->timer;
>  
> -	if ((tp->mac_version <= RTL_GIGA_MAC_VER_01) ||
> -	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
> +	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
>  		return;
>  
>  	mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
> @@ -1359,7 +1408,7 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
>  {
>  	void __iomem *ioaddr = tp->mmio_addr;
>  
> -	rtl8169_hw_phy_config(dev);
> +	rtl_hw_phy_config(dev);
>  
>  	dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
>  	RTL_W8(0x82, 0x01);
> @@ -1454,6 +1503,7 @@ static const struct rtl_cfg_info {
>  	unsigned int align;
>  	u16 intr_event;
>  	u16 napi_event;
> +	unsigned msi;
>  } rtl_cfg_infos [] = {
>  	[RTL_CFG_0] = {
>  		.hw_start	= rtl_hw_start_8169,
> @@ -1461,7 +1511,8 @@ static const struct rtl_cfg_info {
>  		.align		= 0,
>  		.intr_event	= SYSErr | LinkChg | RxOverflow |
>  				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
> -		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
> +		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
> +		.msi		= 0
>  	},
>  	[RTL_CFG_1] = {
>  		.hw_start	= rtl_hw_start_8168,
> @@ -1469,7 +1520,8 @@ static const struct rtl_cfg_info {
>  		.align		= 8,
>  		.intr_event	= SYSErr | LinkChg | RxOverflow |
>  				  TxErr | TxOK | RxOK | RxErr,
> -		.napi_event	= TxErr | TxOK | RxOK | RxOverflow
> +		.napi_event	= TxErr | TxOK | RxOK | RxOverflow,
> +		.msi		= RTL_FEATURE_MSI
>  	},
>  	[RTL_CFG_2] = {
>  		.hw_start	= rtl_hw_start_8101,
> @@ -1477,10 +1529,39 @@ static const struct rtl_cfg_info {
>  		.align		= 8,
>  		.intr_event	= SYSErr | LinkChg | RxOverflow | PCSTimeout |
>  				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
> -		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
> +		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
> +		.msi		= RTL_FEATURE_MSI
>  	}
>  };
>  
> +/* Cfg9346_Unlock assumed. */
> +static unsigned rtl_try_msi(struct pci_dev *pdev, void __iomem *ioaddr,
> +			    const struct rtl_cfg_info *cfg)
> +{
> +	unsigned msi = 0;
> +	u8 cfg2;
> +
> +	cfg2 = RTL_R8(Config2) & ~MSIEnable;
> +	if (cfg->msi) {
> +		if (pci_enable_msi(pdev)) {
> +			dev_info(&pdev->dev, "no MSI. Back to INTx.\n");
> +		} else {
> +			cfg2 |= MSIEnable;
> +			msi = RTL_FEATURE_MSI;
> +		}
> +	}
> +	RTL_W8(Config2, cfg2);
> +	return msi;
> +}
> +
> +static void rtl_disable_msi(struct pci_dev *pdev, struct rtl8169_private *tp)
> +{
> +	if (tp->features & RTL_FEATURE_MSI) {
> +		pci_disable_msi(pdev);
> +		tp->features &= ~RTL_FEATURE_MSI;
> +	}
> +}
> +
>  static int __devinit
>  rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  {
> @@ -1594,10 +1675,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  
>  	/* Identify chip attached to board */
>  	rtl8169_get_mac_version(tp, ioaddr);
> -	rtl8169_get_phy_version(tp, ioaddr);
>  
>  	rtl8169_print_mac_version(tp);
> -	rtl8169_print_phy_version(tp);
>  
>  	for (i = ARRAY_SIZE(rtl_chip_info) - 1; i >= 0; i--) {
>  		if (tp->mac_version == rtl_chip_info[i].mac_version)
> @@ -1617,6 +1696,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	RTL_W8(Cfg9346, Cfg9346_Unlock);
>  	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
>  	RTL_W8(Config5, RTL_R8(Config5) & PMEStatus);
> +	tp->features |= rtl_try_msi(pdev, ioaddr, cfg);
>  	RTL_W8(Cfg9346, Cfg9346_Lock);
>  
>  	if (RTL_R8(PHYstatus) & TBI_Enable) {
> @@ -1685,7 +1765,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  
>  	rc = register_netdev(dev);
>  	if (rc < 0)
> -		goto err_out_unmap_5;
> +		goto err_out_msi_5;
>  
>  	pci_set_drvdata(pdev, dev);
>  
> @@ -1708,7 +1788,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  out:
>  	return rc;
>  
> -err_out_unmap_5:
> +err_out_msi_5:
> +	rtl_disable_msi(pdev, tp);
>  	iounmap(ioaddr);
>  err_out_free_res_4:
>  	pci_release_regions(pdev);
> @@ -1729,6 +1810,7 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
>  	flush_scheduled_work();
>  
>  	unregister_netdev(dev);
> +	rtl_disable_msi(pdev, tp);
>  	rtl8169_release_board(pdev, dev, tp->mmio_addr);
>  	pci_set_drvdata(pdev, NULL);
>  }
> @@ -1772,7 +1854,8 @@ static int rtl8169_open(struct net_device *dev)
>  
>  	smp_mb();
>  
> -	retval = request_irq(dev->irq, rtl8169_interrupt, IRQF_SHARED,
> +	retval = request_irq(dev->irq, rtl8169_interrupt,
> +			     (tp->features & RTL_FEATURE_MSI) ? 0 : IRQF_SHARED,
>  			     dev->name, dev);
>  	if (retval < 0)
>  		goto err_release_ring_2;
> @@ -2024,7 +2107,8 @@ static void rtl_hw_start_8101(struct net_device *dev)
>  	void __iomem *ioaddr = tp->mmio_addr;
>  	struct pci_dev *pdev = tp->pci_dev;
>  
> -	if (tp->mac_version == RTL_GIGA_MAC_VER_13) {
> +	if ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
> +	    (tp->mac_version == RTL_GIGA_MAC_VER_16)) {
>  		pci_write_config_word(pdev, 0x68, 0x00);
>  		pci_write_config_word(pdev, 0x69, 0x08);
>  	}
> @@ -2977,7 +3061,9 @@ static void rtl_set_rx_mode(struct net_device *dev)
>  	    (tp->mac_version == RTL_GIGA_MAC_VER_12) ||
>  	    (tp->mac_version == RTL_GIGA_MAC_VER_13) ||
>  	    (tp->mac_version == RTL_GIGA_MAC_VER_14) ||
> -	    (tp->mac_version == RTL_GIGA_MAC_VER_15)) {
> +	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
> +	    (tp->mac_version == RTL_GIGA_MAC_VER_16) ||
> +	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
>  		mc_filter[0] = 0xffffffff;
>  		mc_filter[1] = 0xffffffff;
>  	}
> @@ -3037,7 +3123,8 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
>  
>  out_pci_suspend:
>  	pci_save_state(pdev);
> -	pci_enable_wake(pdev, pci_choose_state(pdev, state), tp->wol_enabled);
> +	pci_enable_wake(pdev, pci_choose_state(pdev, state),
> +		(tp->features & RTL_FEATURE_WOL) ? 1 : 0);
>  	pci_set_power_state(pdev, pci_choose_state(pdev, state));
>  
>  	return 0;
>   


--------------000808010908090302050702
Content-Type: text/plain;
 name="r8168.modprobe_debug.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="r8168.modprobe_debug.txt"

<6>ACPI: PCI Interrupt 0000:08:00.0[A] -> GSI 19 (level, low) -> IRQ 18
<7>PCI: Setting latency timer of device 0000:08:00.0 to 64
<6>r8169 0000:08:00.0: no MSI. Back to INTx.
<6>eth0: RTL8168c/8111c at 0xdc82a000, 00:19:99:0b:9d:5b, XID 3c0000c0 IRQ 18
<3>eth0: PHY reset failed.
<6>r8169: eth0: TBI auto-negotiating
<5>nfs: server 217.160.115.80 not responding, still trying
<6>r8169: eth0: link up
<5>nfs: server 217.160.115.80 OK

--------------000808010908090302050702
Content-Type: text/plain;
 name="r8168.dmesg.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="r8168.dmesg.txt"

rting at 30000000 (gap: 20000000:c0000000)
Built 1 zonelists.  Total pages: 113491
Kernel command line: ro root=301 vga=791 video=vesafb:ywrap,mtrr,1024x768-32@60 splash=silent,fadein,theme:eluxrl BOOT_MSG=\"\" CONSOLE=/dev/tty4 console=/dev/tty4  ether=0,0,0,eth0 parport=auto idebus=66 ramdisk_size=10240 ip=dhcp irqpoll
ide_setup: idebus=66
Misrouted IRQ fixup and polling support enabled
This may significantly impact system performance
mapped APIC to ffffd000 (fee00000)
mapped IOAPIC to ffffc000 (fec00000)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
PID hash table entries: 2048 (order: 11, 8192 bytes)
Detected 1000.081 MHz processor.
Console: colour dummy device 80x25
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:    8
... MAX_LOCK_DEPTH:          30
... MAX_LOCKDEP_KEYS:        2048
... CLASSHASH_SIZE:           1024
... MAX_LOCKDEP_ENTRIES:     8192
... MAX_LOCKDEP_CHAINS:      16384
... CHAINHASH_SIZE:          8192
 memory used by lock dependency info: 992 kB
 per task-struct memory footprint: 1200 bytes
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Memory: 446632k/457536k available (2665k kernel code, 10356k reserved, 1201k data, 204k init, 0k highmem)
virtual kernel memory layout:
    fixmap  : 0xfffaa000 - 0xfffff000   ( 340 kB)
    pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
    vmalloc : 0xdc800000 - 0xff7fe000   ( 559 MB)
    lowmem  : 0xc0000000 - 0xdbed0000   ( 446 MB)
      .init : 0xc04ca000 - 0xc04fd000   ( 204 kB)
      .data : 0xc039a501 - 0xc04c6aa4   (1201 kB)
      .text : 0xc0100000 - 0xc039a501   (2665 kB)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay using timer specific routine.. 2075.18 BogoMIPS (lpj=3457902)
Mount-cache hash table entries: 512
CPU: After generic identify, caps: 078bfbff ebd3fbff 00000000 00000000 00002001 00000000 00000019
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 256K (64 bytes/line)
CPU: After all inits, caps: 078bfbff ebd3fbff 00000000 00000410 00002001 00000000 00000019
Compat vDSO mapped to ffffe000.
CPU: AMD Sempron(tm) Processor 2100+ stepping 02
Checking 'hlt' instruction... OK.
ACPI: Core revision 20070126
ENABLING IO-APIC IRQs
..TIMER: vector=0x31 apic1=0 pin1=0 apic2=-1 pin2=-1
..MP-BIOS bug: 8254 timer not connected to IO-APIC
...trying to set up timer (IRQ0) through the 8259A ...  failed.
...trying to set up timer as Virtual Wire IRQ... works.
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: Using MMCONFIG
PCI: No mmconfig possible on device 00:18
Setting up standard PCI resources
ACPI: Interpreter enabled
ACPI: (supports S0 S1 S3 S4 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: Device [FDC] status [00000008]: functional but not present; setting present
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: Probing PCI hardware (bus 00)
PCI: Transparent bridge - 0000:00:14.4
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.GRFB._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEXA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.LAN_._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P2P_._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 7 9 10 11 12 14 15) *0, disabled.
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 11 devices
ACPI: ACPI bus type pnp unregistered
SCSI subsystem initialized
libata version 2.21 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
PCI: Cannot allocate resource region 7 of bridge 0000:00:06.0
PCI: Cannot allocate resource region 8 of bridge 0000:00:06.0
PCI: Cannot allocate resource region 3 of device 0000:00:00.0
pnp: 00:01: iomem range 0xe0000000-0xefffffff could not be reserved
pnp: 00:01: iomem range 0xfec00000-0xfecfffff could not be reserved
pnp: 00:01: iomem range 0xfed00000-0xfedfffff has been reserved
pnp: 00:01: iomem range 0xfee00000-0xfeefffff could not be reserved
Time: tsc clocksource has been installed.
PCI: Bridge: 0000:00:01.0
  IO window: 9000-9fff
  MEM window: fc100000-fc2fffff
  PREFETCH window: f8000000-fbffffff
PCI: Bridge: 0000:00:06.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:07.0
  IO window: a000-afff
  MEM window: fc300000-fc3fffff
  PREFETCH window: fc000000-fc0fffff
PCI: Bridge: 0000:00:14.4
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Setting latency timer of device 0000:00:06.0 to 64
PCI: Setting latency timer of device 0000:00:07.0 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 4096 (order: 2, 16384 bytes)
TCP established hash table entries: 16384 (order: 7, 720896 bytes)
TCP bind hash table entries: 16384 (order: 7, 720896 bytes)
TCP: Hash tables configured (established 16384 bind 16384)
TCP reno registered
Initializing RT-Tester: OK
io scheduler noop registered
io scheduler anticipatory registered (default)
io scheduler deadline registered
PCI: MSI quirk detected. MSI deactivated.
Boot video device is 0000:01:05.0
PCI: Setting latency timer of device 0000:00:06.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:06.0:pcie00]
Allocate Port Service[0000:00:06.0:pcie02]
Allocate Port Service[0000:00:06.0:pcie03]
PCI: Setting latency timer of device 0000:00:07.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:07.0:pcie00]
Allocate Port Service[0000:00:07.0:pcie03]
vesafb: framebuffer at 0xf8000000, mapped to 0xdc880000, using 3072k, total 16384k
vesafb: mode is 1024x768x16, linelength=2048, pages=9
vesafb: protected mode interface info at c000:9fba
vesafb: pmi: set display start = c00ca044, set palette = c00ca102
vesafb: scrolling: ywrap using protected mode interface, yres_virtual=1536
vesafb: Truecolor: size=0:5:6:5, shift=0:11:5:0
Console: switching to colour frame buffer device 128x48
fb0: VESA VGA frame buffer device
cs5535_gpio: DIVIL not found
Linux agpgart interface v0.102 (c) Dave Jones
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
00:09: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:0a: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 10240K size 1024 blocksize
loop: module loaded
Intel(R) PRO/1000 Network Driver - version 7.3.20-k2
Copyright (c) 1999-2006 Intel Corporation.
pcnet32.c:v1.33 27.Jun.2006 tsbogend@alpha.franken.de
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 66MHz system bus speed for PIO modes
SB600_PATA: IDE controller at PCI slot 0000:00:14.1
ACPI: PCI Interrupt 0000:00:14.1[A] -> GSI 16 (level, low) -> IRQ 16
SB600_PATA: chipset revision 0
SB600_PATA: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0x8420-0x8427, BIOS settings: hda:DMA, hdb:pio
Probing IDE interface ide0...
Switched to high resolution mode on CPU 0
hda: FCR512, ATA DISK drive
hda: selected mode 0x22
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
hda: max request size: 128KiB
hda: 1025136 sectors (524 MB) w/0KiB Cache, CHS=1017/16/63, DMA
 hda: hda1 hda2 hda3
ahci 0000:00:12.0: version 2.2
ACPI: PCI Interrupt 0000:00:12.0[A] -> GSI 22 (level, low) -> IRQ 17
ahci 0000:00:12.0: controller can't do 64bit DMA, forcing 32bit
ahci 0000:00:12.0: AHCI 0001.0100 32 slots 4 ports 3 Gbps 0xf impl SATA mode
ahci 0000:00:12.0: flags: ncq ilck pm led clo pmp pio slum part 
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
ata1: SATA max UDMA/133 cmd 0xdc80c100 ctl 0x00000000 bmdma 0x00000000 irq 17
ata2: SATA max UDMA/133 cmd 0xdc80c180 ctl 0x00000000 bmdma 0x00000000 irq 17
ata3: SATA max UDMA/133 cmd 0xdc80c200 ctl 0x00000000 bmdma 0x00000000 irq 17
ata4: SATA max UDMA/133 cmd 0xdc80c280 ctl 0x00000000 bmdma 0x00000000 irq 17
ata1: SATA link down (SStatus 0 SControl 300)
ata2: SATA link down (SStatus 0 SControl 300)
ata3: SATA link down (SStatus 0 SControl 300)
ata4: SATA link down (SStatus 0 SControl 300)
ACPI: PCI Interrupt 0000:00:13.5[D] -> GSI 19 (level, low) -> IRQ 18
ehci_hcd 0000:00:13.5: EHCI Host Controller
ehci_hcd 0000:00:13.5: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:13.5: debug port 1
ehci_hcd 0000:00:13.5: irq 18, io mem 0xfc60a400
ehci_hcd 0000:00:13.5: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 10 ports detected
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
ACPI: PCI Interrupt 0000:00:13.0[A] -> GSI 16 (level, low) -> IRQ 16
ohci_hcd 0000:00:13.0: OHCI Host Controller
ohci_hcd 0000:00:13.0: new USB bus registered, assigned bus number 2
ohci_hcd 0000:00:13.0: irq 16, io mem 0xfc604000
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:13.1[B] -> GSI 17 (level, low) -> IRQ 19
ohci_hcd 0000:00:13.1: OHCI Host Controller
ohci_hcd 0000:00:13.1: new USB bus registered, assigned bus number 3
ohci_hcd 0000:00:13.1: irq 19, io mem 0xfc605000
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
usb 1-5: new high speed USB device using ehci_hcd and address 2
ACPI: PCI Interrupt 0000:00:13.2[C] -> GSI 18 (level, low) -> IRQ 20
ohci_hcd 0000:00:13.2: OHCI Host Controller
ohci_hcd 0000:00:13.2: new USB bus registered, assigned bus number 4
ohci_hcd 0000:00:13.2: irq 20, io mem 0xfc606000
usb 1-5: configuration #1 chosen from 1 choice
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:13.3[B] -> GSI 17 (level, low) -> IRQ 19
ohci_hcd 0000:00:13.3: OHCI Host Controller
ohci_hcd 0000:00:13.3: new USB bus registered, assigned bus number 5
ohci_hcd 0000:00:13.3: irq 19, io mem 0xfc607000
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:13.4[C] -> GSI 18 (level, low) -> IRQ 20
ohci_hcd 0000:00:13.4: OHCI Host Controller
ohci_hcd 0000:00:13.4: new USB bus registered, assigned bus number 6
ohci_hcd 0000:00:13.4: irq 20, io mem 0xfc608000
usb usb6: configuration #1 chosen from 1 choice
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
USB Universal Host Controller Interface driver v3.0
Initializing USB Mass Storage driver...
scsi4 : SCSI emulation for USB Mass Storage devices
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
usb-storage: device found at 2
usb-storage: waiting for device to settle before scanning
PNP: PS/2 Controller [PNP0303:KEYB,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
IRQ 0 rejected by it's handlers, but taken by: i8042
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard as /class/input/input0
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
TCP cubic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
Using IPI Shortcut mode
IRQ 0 rejected by it's handlers, but taken by: i8042
IRQ 0 rejected by it's handlers, but taken by: i8042
input: ImPS/2 Generic Wheel Mouse as /class/input/input1
EXT3-fs: INFO: recovery required on readonly filesystem.
EXT3-fs: write access will be enabled during recovery.
IRQ 0 rejected by it's handlers, but taken by: ide0
scsi 4:0:0:0: Direct-Access     SanDisk  Cruzer Micro     0.1  PQ: 0 ANSI: 2
sd 4:0:0:0: [sda] 2001888 512-byte hardware sectors (1025 MB)
IRQ 0 rejected by it's handlers, but taken by: ehci_hcd:usb1
sd 4:0:0:0: [sda] Write Protect is off
sd 4:0:0:0: [sda] Mode Sense: 03 00 00 00
sd 4:0:0:0: [sda] Assuming drive cache: write through
sd 4:0:0:0: [sda] 2001888 512-byte hardware sectors (1025 MB)
IRQ 0 rejected by it's handlers, but taken by: ehci_hcd:usb1
sd 4:0:0:0: [sda] Write Protect is off
sd 4:0:0:0: [sda] Mode Sense: 03 00 00 00
sd 4:0:0:0: [sda] Assuming drive cache: write through
 sda: sda1
sd 4:0:0:0: [sda] Attached SCSI removable disk
sd 4:0:0:0: Attached scsi generic sg0 type 0
usb-storage: device scan complete
kjournald starting.  Commit interval 5 seconds
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 204k freed
Warning: unable to open an initial console.
IRQ 0 rejected by it's handlers, but taken by: ide0
IRQ 0 rejected by it's handlers, but taken by: ide0
IRQ 0 rejected by it's handlers, but taken by: ide0
hda: selected mode 0x22
IRQ 0 rejected by it's handlers, but taken by: ide0
hda: selected mode 0x22
IRQ 0 rejected by it's handlers, but taken by: ide0
kjournald starting.  Commit interval 5 seconds
EXT3-fs warning: maximal mount count reached, running e2fsck is recommended
EXT3 FS on hda3, internal journal
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3-fs warning: maximal mount count reached, running e2fsck is recommended
EXT3 FS on hda3, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
IRQ 0 rejected by it's handlers, but taken by: ide0
Real Time Clock Driver v1.12ac
r8169 Gigabit Ethernet driver 2.2LK loaded
ACPI: PCI Interrupt 0000:08:00.0[A] -> GSI 19 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:08:00.0 to 64
r8169 0000:08:00.0: no MSI. Back to INTx.
eth0: RTL8168c/8111c at 0xdc82a000, 00:19:99:0b:9d:5b, XID 3c0000c0 IRQ 18
IRQ 0 rejected by it's handlers, but taken by: ide0
fuse init (API version 7.8)
IRQ 0 rejected by it's handlers, but taken by: ehci_hcd:usb1
ACPI: PCI Interrupt 0000:00:14.2[A] -> GSI 16 (level, low) -> IRQ 16
hda_codec: Unknown model for ALC262, trying auto-probe from BIOS...
input: Power Button (FF) as /class/input/input2
ACPI: Power Button (FF) [PWRF]
input: Power Button (CM) as /class/input/input3
ACPI: Power Button (CM) [PWRB]
No dock devices found.
r8169: eth0: link up
EXT3 FS on hda1, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3-fs warning: maximal mount count reached, running e2fsck is recommended
EXT3 FS on sda1, internal journal
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with ordered data mode.
EXT3 FS on hda1, internal journal

--------------000808010908090302050702
Content-Type: text/plain;
 name="r8168.ethtool.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="r8168.ethtool.txt"

Settings for eth0:
	Supported ports: [ FIBRE ]
	Supported link modes:   1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  Not reported
	Advertised auto-negotiation: Yes
	Speed: 1000Mb/s
	Duplex: Full
	Port: FIBRE
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Supports Wake-on: pumbg
	Wake-on: g
	Current message level: 0x00000033 (51)
	Link detected: yes

--------------000808010908090302050702
Content-Type: text/plain;
 name="r8168.ifconfig.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="r8168.ifconfig.txt"

eth0      Link encap:Ethernet  HWaddr 00:19:99:0B:9D:5B  
          inet addr:217.160.115.105  Bcast:217.160.115.127  Mask:255.255.255.128
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:5307 errors:0 dropped:141905678 overruns:0 frame:0
          TX packets:849 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:5423841 (5.1 Mb)  TX bytes:186900 (182.5 Kb)
          Interrupt:18 Base address:0xa000 


--------------000808010908090302050702
Content-Type: text/plain;
 name="r8168.lspci.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="r8168.lspci.txt"

00:00.0 Host bridge: ATI Technologies Inc Unknown device 7910
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 111d
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Latency: 64
	Region 3: Memory at <ignored> (64-bit, non-prefetchable) [size=512M]
00: 02 10 10 79 06 00 20 22 00 00 00 06 00 40 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 04 00 00 e0
20: 00 00 00 00 00 00 00 00 00 00 00 00 34 17 1d 11
30: 00 00 00 00 c4 00 00 00 00 00 00 00 00 00 00 00

00:01.0 PCI bridge: ATI Technologies Inc Unknown device 7912 (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
	I/O behind bridge: 00009000-00009fff
	Memory behind bridge: fc100000-fc2fffff
	Prefetchable memory behind bridge: 00000000f8000000-00000000fbf00000
	Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-
	Capabilities: [44] HyperTransport: MSI Mapping
	Capabilities: [b0] #0d [0000]
00: 02 10 12 79 07 00 30 02 00 00 04 06 00 40 01 00
10: 00 00 00 00 00 00 00 00 00 01 01 40 91 91 20 22
20: 10 fc 20 fc 01 f8 f1 fb 00 00 00 00 00 00 00 00
30: 00 00 00 00 44 00 00 00 00 00 00 00 ff 00 0c 00

00:06.0 PCI bridge: ATI Technologies Inc Unknown device 7916 (prog-if 00 [Normal decode])
	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size 08
	Bus: primary=00, secondary=02, subordinate=07, sec-latency=0
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 247
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 6, PowerLimit 25.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Off, PwrInd Off, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0 Enable-
		Address: 00000000  Data: 0000
	Capabilities: [b0] #0d [0000]
	Capabilities: [b8] HyperTransport: MSI Mapping
	Capabilities: [100] Virtual Channel
00: 02 10 16 79 04 00 10 00 00 00 04 06 08 00 01 00
10: 00 00 00 00 00 00 00 00 00 02 07 00 f1 01 00 00
20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 04 00

00:07.0 PCI bridge: ATI Technologies Inc Unknown device 7917 (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size 08
	Bus: primary=00, secondary=08, subordinate=0d, sec-latency=0
	I/O behind bridge: 0000a000-0000afff
	Memory behind bridge: fc300000-fc3fffff
	Prefetchable memory behind bridge: 00000000fc000000-00000000fc000000
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 4
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM L1 Enabled RCB 64 bytes CommClk+ ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
		Slot: Number 6, PowerLimit 25.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Off, PwrInd Off, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0 Enable-
		Address: 00000000  Data: 0000
	Capabilities: [b0] #0d [0000]
	Capabilities: [b8] HyperTransport: MSI Mapping
	Capabilities: [100] Virtual Channel
00: 02 10 17 79 07 00 10 00 00 00 04 06 08 00 01 00
10: 00 00 00 00 00 00 00 00 00 08 0d 00 a1 a1 00 00
20: 30 fc 30 fc 01 fc 01 fc 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 04 00

00:12.0 SATA controller: ATI Technologies Inc SB600 Non-Raid-5 SATA (prog-if 01 [AHCI 1.0])
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 10f5
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64
	Interrupt: pin A routed to IRQ 17
	Region 0: I/O ports at 8440 [size=8]
	Region 1: I/O ports at 8434 [size=4]
	Region 2: I/O ports at 8438 [size=8]
	Region 3: I/O ports at 8430 [size=4]
	Region 4: I/O ports at 8400 [size=16]
	Region 5: Memory at fc60a000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [60] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 02 10 80 43 07 00 30 02 00 01 06 01 00 40 00 00
10: 41 84 00 00 35 84 00 00 39 84 00 00 31 84 00 00
20: 01 84 00 00 00 a0 60 fc 00 00 00 00 34 17 f5 10
30: 00 00 00 00 60 00 00 00 00 00 00 00 0b 01 00 00

00:13.0 USB Controller: ATI Technologies Inc SB600 USB (OHCI0) (prog-if 10 [OHCI])
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 10d1
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 08
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at fc604000 (32-bit, non-prefetchable) [size=4K]
00: 02 10 87 43 17 00 a0 02 00 10 03 0c 08 40 80 00
10: 00 40 60 fc 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 34 17 d1 10
30: 00 00 00 00 00 00 00 00 00 00 00 00 0a 01 00 00

00:13.1 USB Controller: ATI Technologies Inc SB600 USB (OHCI1) (prog-if 10 [OHCI])
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 10d1
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 08
	Interrupt: pin B routed to IRQ 19
	Region 0: Memory at fc605000 (32-bit, non-prefetchable) [size=4K]
00: 02 10 88 43 17 00 a0 02 00 10 03 0c 08 40 00 00
10: 00 50 60 fc 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 34 17 d1 10
30: 00 00 00 00 00 00 00 00 00 00 00 00 05 02 00 00

00:13.2 USB Controller: ATI Technologies Inc SB600 USB (OHCI2) (prog-if 10 [OHCI])
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 10d1
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 08
	Interrupt: pin C routed to IRQ 20
	Region 0: Memory at fc606000 (32-bit, non-prefetchable) [size=4K]
00: 02 10 89 43 17 00 a0 02 00 10 03 0c 08 40 00 00
10: 00 60 60 fc 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 34 17 d1 10
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 03 00 00

00:13.3 USB Controller: ATI Technologies Inc SB600 USB (OHCI3) (prog-if 10 [OHCI])
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 10d1
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 08
	Interrupt: pin B routed to IRQ 19
	Region 0: Memory at fc607000 (32-bit, non-prefetchable) [size=4K]
00: 02 10 8a 43 17 00 a0 02 00 10 03 0c 08 40 00 00
10: 00 70 60 fc 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 34 17 d1 10
30: 00 00 00 00 00 00 00 00 00 00 00 00 05 02 00 00

00:13.4 USB Controller: ATI Technologies Inc SB600 USB (OHCI4) (prog-if 10 [OHCI])
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 10d1
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 08
	Interrupt: pin C routed to IRQ 20
	Region 0: Memory at fc608000 (32-bit, non-prefetchable) [size=4K]
00: 02 10 8b 43 17 00 a0 02 00 10 03 0c 08 40 00 00
10: 00 80 60 fc 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 34 17 d1 10
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 03 00 00

00:13.5 USB Controller: ATI Technologies Inc SB600 USB Controller (EHCI) (prog-if 20 [EHCI])
	Subsystem: ATI Technologies Inc SB600 USB Controller (EHCI)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 10
	Interrupt: pin D routed to IRQ 18
	Region 0: Memory at fc60a400 (32-bit, non-prefetchable) [size=256]
	Capabilities: [c0] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
		Bridge: PM- B3+
	Capabilities: [e4] Debug port
00: 02 10 86 43 17 00 b0 02 00 20 03 0c 10 40 00 00
10: 00 a4 60 fc 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 02 10 86 43
30: 00 00 00 00 c0 00 00 00 00 00 00 00 0b 04 00 00

00:14.0 SMBus: ATI Technologies Inc SB600 SMBus (rev 14)
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 10d1
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Region 0: I/O ports at 8410 [size=16]
	Region 1: Memory at fc609000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [b0] HyperTransport: MSI Mapping
00: 02 10 85 43 03 00 30 02 14 00 05 0c 00 00 80 00
10: 11 84 00 00 00 90 60 fc 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 34 17 d1 10
30: 00 00 00 00 b0 00 00 00 00 00 00 00 00 00 00 00

00:14.1 IDE interface: ATI Technologies Inc SB600 IDE (prog-if 8a [Master SecP PriP])
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 10d1
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 16
	Region 0: I/O ports at 01f0 [size=8]
	Region 1: I/O ports at 03f4
	Region 2: I/O ports at 0170 [size=8]
	Region 3: I/O ports at 0374
	Region 4: I/O ports at 8420 [size=16]
00: 02 10 8c 43 05 00 20 02 00 8a 01 01 00 00 00 00
10: f1 01 00 00 f5 03 00 00 01 00 00 00 01 00 00 00
20: 21 84 00 00 00 00 00 00 00 00 00 00 34 17 d1 10
30: 00 00 00 00 00 00 00 00 00 00 00 00 ff 01 00 00

00:14.2 Audio device: ATI Technologies Inc SB600 Azalia
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 111e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 08
	Interrupt: pin ? routed to IRQ 16
	Region 0: Memory at fc600000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 02 10 83 43 06 00 10 04 00 00 03 04 08 40 00 00
10: 04 00 60 fc 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 34 17 1e 11
30: 00 00 00 00 50 00 00 00 00 00 00 00 0a 00 00 00

00:14.3 ISA bridge: ATI Technologies Inc SB600 PCI to LPC Bridge
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 10d1
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
00: 02 10 8d 43 0f 00 20 02 00 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 34 17 d1 10
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:14.4 PCI bridge: ATI Technologies Inc SB600 PCI to PCI Bridge (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64
	Bus: primary=00, secondary=0e, subordinate=13, sec-latency=64
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
00: 02 10 84 43 07 00 a0 02 00 01 04 06 00 40 81 00
10: 00 00 00 00 00 00 00 00 00 0e 13 40 f0 00 80 22
20: f0 ff 00 00 f0 ff 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00

00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] HyperTransport Technology Configuration
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Capabilities: [80] HyperTransport: Host or Secondary Interface
		!!! Possibly incomplete decoding
		Command: WarmRst+ DblEnd-
		Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=8
		Link Config: MLWI=16bit MLWO=16bit LWI=16bit LWO=16bit
		Revision ID: 1.02
00: 22 10 00 11 00 00 10 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00

00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Address Map
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
00: 22 10 01 11 00 00 00 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM Controller
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
00: 22 10 02 11 00 00 00 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Miscellaneous Control
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
00: 22 10 03 11 00 00 00 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

01:05.0 VGA compatible controller: ATI Technologies Inc Radeon X1200 Series (prog-if 00 [VGA])
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 111d
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 08
	Interrupt: pin A routed to IRQ 10
	Region 0: Memory at f8000000 (64-bit, prefetchable) [size=64M]
	Region 2: Memory at fc200000 (64-bit, non-prefetchable) [size=64K]
	Region 4: I/O ports at 9000 [size=256]
	Region 5: Memory at fc100000 (32-bit, non-prefetchable) [size=1M]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [80] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
00: 02 10 1f 79 07 00 10 00 00 00 00 03 08 40 00 00
10: 0c 00 00 f8 00 00 00 00 04 00 20 fc 00 00 00 00
20: 01 90 00 00 00 00 10 fc 00 00 00 00 34 17 1d 11
30: 00 00 00 00 50 00 00 00 00 00 00 00 0a 01 00 00

08:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 111d
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size 10
	Interrupt: pin A routed to IRQ 18
	Region 0: I/O ports at a000 [size=256]
	Region 2: Memory at fc300000 (64-bit, non-prefetchable) [size=4K]
	Region 4: Memory at fc000000 (64-bit, prefetchable) [size=64K]
	[virtual] Expansion ROM at fc020000 [disabled] [size=128K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [70] Express Endpoint IRQ 1
		Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <512ns, L1 <8us
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 0
		Link: Latency L0s <512ns, L1 <64us
		Link: ASPM L1 Enabled RCB 64 bytes CommClk+ ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
	Capabilities: [b0] MSI-X: Enable- Mask- TabSize=2
		Vector table: BAR=4 offset=00000000
		PBA: BAR=4 offset=00000800
	Capabilities: [d0] Vital Product Data
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Virtual Channel
	Capabilities: [160] Device Serial Number 81-68-10-ec-00-00-00-00
00: ec 10 68 81 07 00 10 00 02 00 00 02 10 00 00 00
10: 01 a0 00 00 00 00 00 00 04 00 30 fc 00 00 00 00
20: 0c 00 00 fc 00 00 00 00 00 00 00 00 34 17 1d 11
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 00 00


--------------000808010908090302050702--

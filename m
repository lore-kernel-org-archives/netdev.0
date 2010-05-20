From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: bnx2x + SFP+ DA/2.6.33.3: Got bad status 0x0 when reading from SFP+
 EEPROM -> SFP+ module is not initialized
Date: Thu, 20 May 2010 19:08:54 +0200
Message-ID: <4BF56CA6.8080306@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:52550 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754286Ab0ETRJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 13:09:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I would like to connect a dual port SFP+ NetXtreme II BCM57711
10-Gigabit NIC to a HP J9309A ProCurve 4-Port 10GbE SFP+ zl Module
using a HP ProCurve 10-GbE SFP+ 7m Direct Attach Cable (J9285B).

Unfortuantely, it does not work. :( After connecting the switch and
the server together and loading the bnx2x module the switch logs:

I 05/20/10 18:32:23 ports: port E4 is Blocked by STP
I 05/20/10 18:32:23 ports: port E4 is now on-line

Here is the dmesg output from the server:

Broadcom NetXtreme II 5771x 10Gigabit Ethernet Driver bnx2x 1.52.1-5 (2=
009/11/09)
bnx2x 0000:04:00.0: PCI INT A -> GSI 38 (level, low) -> IRQ 38
bnx2x 0000:04:00.0: setting latency timer to 64
bnx2x: part number 394D4342-31373735-31314131-473331
bnx2x: Loading bnx2x-e1h-5.2.7.0.fw
bnx2x 0000:04:00.0: firmware: requesting bnx2x-e1h-5.2.7.0.fw
eth4: Broadcom NetXtreme II BCM57711 XGb (A0) PCI-E x8 5GHz (Gen2) foun=
d at mem dc000000, IRQ 38, node addr 00:10:18:5f:e4:b4
bnx2x 0000:04:00.1: PCI INT B -> GSI 45 (level, low) -> IRQ 45
bnx2x 0000:04:00.1: setting latency timer to 64
bnx2x: part number 394D4342-31373735-31314131-473331
bnx2x: Loading bnx2x-e1h-5.2.7.0.fw
bnx2x 0000:04:00.1: firmware: requesting bnx2x-e1h-5.2.7.0.fw
eth5: Broadcom NetXtreme II BCM57711 XGb (A0) PCI-E x8 5GHz (Gen2) foun=
d at mem dd000000, IRQ 45, node addr 00:10:18:5f:e4:b6
bnx2x 0000:04:00.0: irq 97 for MSI/MSI-X
bnx2x 0000:04:00.0: irq 98 for MSI/MSI-X
bnx2x 0000:04:00.0: irq 99 for MSI/MSI-X
bnx2x 0000:04:00.0: irq 100 for MSI/MSI-X
bnx2x 0000:04:00.0: irq 101 for MSI/MSI-X
bnx2x 0000:04:00.0: irq 102 for MSI/MSI-X
bnx2x: eth4: using MSI-X  IRQs: sp 97  fp[0] 99 ... fp[3] 102
ADDRCONF(NETDEV_UP): eth4: link is not ready
bnx2x 0000:04:00.1: irq 103 for MSI/MSI-X
bnx2x 0000:04:00.1: irq 104 for MSI/MSI-X
bnx2x 0000:04:00.1: irq 105 for MSI/MSI-X
bnx2x 0000:04:00.1: irq 106 for MSI/MSI-X
bnx2x 0000:04:00.1: irq 107 for MSI/MSI-X
bnx2x 0000:04:00.1: irq 108 for MSI/MSI-X
bnx2x: eth5: using MSI-X  IRQs: sp 103  fp[0] 105 ... fp[3] 108
ADDRCONF(NETDEV_UP): eth5: link is not ready
bnx2x: eth5 NIC Link is Down
bnx2x: eth5 NIC Link is Down

Loading the driver with debug mode enabled (modprobe bnx2x debug=3D0x20=
004) I got:

bnx2x 0000:04:00.1: irq 103 for MSI/MSI-X
bnx2x 0000:04:00.1: irq 104 for MSI/MSI-X
bnx2x 0000:04:00.1: irq 105 for MSI/MSI-X
bnx2x 0000:04:00.1: irq 106 for MSI/MSI-X
bnx2x 0000:04:00.1: irq 107 for MSI/MSI-X
bnx2x 0000:04:00.1: irq 108 for MSI/MSI-X
bnx2x: eth5: using MSI-X  IRQs: sp 103  fp[0] 105 ... fp[3] 108
[bnx2x_nic_load:7524(eth5)]pmf 1
[bnx2x_link_reset:6171(eth5)]Resetting the link of port 1
[bnx2x_set_led:5804(eth5)]bnx2x_set_led: port 1, mode 0
[bnx2x_set_led:5806(eth5)]speed 0x0, hw_led_mode 0x1
[bnx2x_stats_init:4597(eth5)]port_stx 0xa72f4  func_stx 0x0
[bnx2x_phy_init:5966(eth5)]Phy Initialization started
[bnx2x_phy_init:5968(eth5)]req_speed 10000, req_flowctrl 0
[bnx2x_emac_init:255(eth5)]EMAC reset reg is 1024
[bnx2x_phy_deassert:534(eth5)]bnx2x_phy_deassert:XGXS
[bnx2x_phy_init:6140(eth5)]Phy address =3D 0x1
[bnx2x_ext_phy_reset:2092(eth5)]Port 1: bnx2x_ext_phy_reset
[bnx2x_calc_ieee_aneg_adv:1383(eth5)]ieee_fc =3D 0x1a0
[bnx2x_ext_phy_init:3672(eth5)]control reg 0x2040 (after 0 ms)
[bnx2x_ext_phy_init:4136(eth5)]Initializing BCM8727
[bnx2x_ext_phy_init:4285(eth5)]Setting TX_CTRL1 0xc000,TX_CTRL2 0x40
[bnx2x_link_int_enable:5338(eth5)]enabled XGXS interrupt
[bnx2x_link_int_enable:5345(eth5)]enabled external phy int
[bnx2x_link_int_enable:5366(eth5)]port 1, is_xgxs 1, int_status 0x0
[bnx2x_link_int_enable:5370(eth5)] int_mask 0x3c8001, MI_INT 1, SERDES_=
LINK 0
[bnx2x_link_int_enable:5373(eth5)] 10G 0, XGXS_LINK 0
[bnx2x_stats_handle:4469(eth5)]state 0 -> event 3 -> state 0
[bnx2x_link_update:6375(eth5)]port 1, XGXS?1, int_status 0x0
[bnx2x_link_update:6383(eth5)]int_mask 0x0 MI_INT 1, SERDES_LINK 0
[bnx2x_link_update:6387(eth5)] 10G 0, XGXS_LINK 0
[bnx2x_ext_phy_is_link_up:4809(eth5)]8727 RX_ALARM_STATUS 0x439
ADDRCONF(NETDEV_UP): eth5: link is not ready
[bnx2x_ext_phy_is_link_up:4819(eth5)]8727 LASI status 0x6
[bnx2x_8727_handle_mod_abs:4622(eth5)]MOD_ABS indication show module is=
 present
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_read_sfp_module_eeprom:2818(eth5)]Got bad status 0x0 when r=
eading from SFP+ EEPROM
[bnx2x_8727_handle_mod_abs:4660(eth5)]SFP+ module is not initialized
[bnx2x_8727_handle_mod_abs:4664(eth5)]8727 RX_ALARM_STATUS 0x438
[bnx2x_ext_phy_is_link_up:4916(eth5)]Tx is disabled
[bnx2x_link_settings_status:1958(eth5)]phy link down
[bnx2x_link_settings_status:1976(eth5)]gp_status 0x208  phy_link_up 0 l=
ine_speed 2710
[bnx2x_link_settings_status:1980(eth5)]duplex 1  flow_ctrl 0x400 autone=
g 0x0
[bnx2x_link_settings_status:1981(eth5)]link_status 0x0
[bnx2x_update_link_down:6285(eth5)]Port 1: Link is down
[bnx2x_set_led:5804(eth5)]bnx2x_set_led: port 1, mode 0
[bnx2x_set_led:5806(eth5)]speed 0x0, hw_led_mode 0x1
bnx2x: eth5 NIC Link is Down
[bnx2x_stats_handle:4469(eth5)]state 0 -> event 3 -> state 0
[bnx2x_link_update:6375(eth5)]port 1, XGXS?1, int_status 0x0
[bnx2x_link_update:6383(eth5)]int_mask 0x0 MI_INT 1, SERDES_LINK 0
[bnx2x_link_update:6387(eth5)] 10G 0, XGXS_LINK 0
[bnx2x_ext_phy_is_link_up:4809(eth5)]8727 RX_ALARM_STATUS 0x41c
[bnx2x_ext_phy_is_link_up:4819(eth5)]8727 LASI status 0x2
[bnx2x_ext_phy_is_link_up:4916(eth5)]Tx is disabled
[bnx2x_link_settings_status:1958(eth5)]phy link down
[bnx2x_link_settings_status:1976(eth5)]gp_status 0x208  phy_link_up 0 l=
ine_speed 0
[bnx2x_link_settings_status:1980(eth5)]duplex 1  flow_ctrl 0x400 autone=
g 0x0
[bnx2x_link_settings_status:1981(eth5)]link_status 0x0
[bnx2x_update_link_down:6285(eth5)]Port 1: Link is down
[bnx2x_set_led:5804(eth5)]bnx2x_set_led: port 1, mode 0
[bnx2x_set_led:5806(eth5)]speed 0x0, hw_led_mode 0x1
bnx2x: eth5 NIC Link is Down

# uname -r
2.6.33.3

Is there something I can do to fix this? Like for example kernel/driver=
 or the firmware upgrade?

Best regards,

			Krzysztof Ol=C4=99dzki

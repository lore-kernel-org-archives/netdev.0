From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: bnx2x: link detected up at startup even when it should be down
Date: Thu, 27 Sep 2012 14:51:55 +0200
Message-ID: <CAL8zT=gDipNepDTvL8XEHjvMO8s09pk8yB7PJOCNqp3XSvVD4w@mail.gmail.com>
References: <CAL8zT=hFPQ-NZw8eKQwnktRrcpsOFk3aa_ac5mSWa+TAwyTGBQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F2EB97C@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=i_eV3SjuBgdWrBPaE-CoBBVh5QJD8jg-YMoQHDuA4AOQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F2F1B50@SJEXCHMB06.corp.ad.broadcom.com>
 <504C9EFCA2D0054393414C9CB605C37F3079E4@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=gp5uZ-Q36=vw--j35txrnLRhguoiMHi8a1kzX=VC3nJg@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F3086A3@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=hJ84woFg0KFxztuTxf2NJEBzThPRXDhZ9KnMJnBxmoZA@mail.gmail.com>
 <CAL8zT=j9LC5hKtmkzBA-Epa+NhX1YpC9RodJ-C+UunTH_HRVKQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F30910B@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=h31Prm2dpyKM8wwg_cb1a8_0yP2ziNzhNFC-3J1M0Khg@mail.gmail.com>
 <CAL8zT=i4tdneZVopZGtHVhMArGMH5n=BVrtkaNSVJPX=RtR6OQ@mail.gmail.com>
 <1348734095.7217.46.camel@lb-tlvb-dmitry> <CAL8zT=jFRJt5OT_nJWWocKjWJJ3LajKrA1f7Zy5wMKz9V-DHXA@mail.gmail.com>
 <1348746197.7217.49.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Barak Witkowski <barak@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33286 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134Ab2I0MwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 08:52:16 -0400
Received: by ieak13 with SMTP id k13so4262099iea.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 05:52:15 -0700 (PDT)
In-Reply-To: <1348746197.7217.49.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/9/27 Dmitry Kravkov <dmitry@broadcom.com>:
> On Thu, 2012-09-27 at 12:07 +0200, Jean-Michel Hautbois wrote:
>> 2012/9/27 Dmitry Kravkov <dmitry@broadcom.com>:
>> > On Tue, 2012-09-25 at 16:00 +0200, Jean-Michel Hautbois wrote:
>> >> 2012/9/25 Jean-Michel Hautbois <jhautbois@gmail.com>:
>> >> > 2012/9/25 Dmitry Kravkov <dmitry@broadcom.com>:
>> >> >>> -----Original Message-----
>> >> >>> From: Jean-Michel Hautbois [mailto:jhautbois@gmail.com]
>> >> >>> Sent: Tuesday, September 25, 2012 2:54 PM
>> >> >>> To: Dmitry Kravkov
>> >> >>> Cc: netdev; Barak Witkowski; Eilon Greenstein; davem@davemloft.net
>> >> >>> Subject: Re: bnx2x: link detected up at startup even when it should be down
>> >> >>
>> >> >>
>> >> FYI, eth4 and eth5 are seen UP and they should be down.
>> > It looks driver misses DCC "disable/enable" update
>> >
>> > Can you pls test this simple patch?
>> >
>> > From 1efa0314f4b912f474089f5f8375d37bc265a502 Mon Sep 17 00:00:00 2001
>> > From: Dmitry Kravkov <dmitry@broadcom.com>
>> > Date: Fri, 22 Mar 2013 05:12:02 +0200
>> > Subject: [PATCH] bnx2x: DCC disable/enable update can be missed by driver
>> >
>> > As a result of missed update, OS may be updated with wrong link status.
>> > ---
>> >  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    1 +
>> >  1 files changed, 1 insertions(+), 0 deletions(-)
>> >
>> > diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
>> > index 2f6361e..3962d57 100644
>> > --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
>> > +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
>> > @@ -3445,6 +3445,7 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
>> >                         int func = BP_FUNC(bp);
>> >
>> >                         REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_12 + func*4, 0);
>> > +                       bnx2x_read_mf_cfg(bp);
>> >                         bp->mf_config[BP_VN(bp)] = MF_CFG_RD(bp,
>> >                                         func_mf_config[BP_ABS_FUNC(bp)].config);
>> >                         val = SHMEM_RD(bp,
>> > --
>> > 1.7.1
>> >
>> >
>> >
>> >> JM
>> >>
>>
>> This patch does not work (no change at all).
>>
>
> Since bnx2x.debug didn't work for you, Let's try to force some debug
> messages from inside the driver:
>

OK, nice workaround but maybe could we also try to make bnx2x.debug work ;).
Most importantly, here are the logs for eth4 only (which I know is not
working, and then all the cards (at the end of this e-mail).

Sep 27 12:49:51 debian kernel: [   19.421184] bnx2x 0000:04:00.4:
eth4: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E x8
5GHz (Gen2) found at mem e4000000, IRQ 37, node addr 80:c1:6e:7a:49:4a
Sep 27 12:50:20 debian kernel: [   58.796653] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.068463] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.325567] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.568618] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  107.792132] bnx2x:
[bnx2x_fw_command:2618(eth4)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  107.813780] bnx2x:
[bnx2x_fw_command:2630(eth4)][after 20 ms] read (10120001) seq is (1)
from FW MB
Sep 27 12:51:09 debian kernel: [  107.813961] bnx2x:
[bnx2x_nic_load:1815(eth4)]pmf 0
Sep 27 12:51:09 debian kernel: [  107.817115] bnx2x:
[bnx2x_init_hw_func:6527(eth4)]starting func init  func 4
Sep 27 12:51:09 debian kernel: [  107.938867] bnx2x:
[bnx2x_phy_probe:11586(eth4)]Begin phy probe
Sep 27 12:51:09 debian kernel: [  107.938868] bnx2x:
[bnx2x_phy_probe:11602(eth4)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:09 debian kernel: [  107.938871] bnx2x:
[bnx2x_populate_int_phy:11230(eth4)]:chip_id = 0x168e0000
Sep 27 12:51:09 debian kernel: [  107.938875] bnx2x:
[bnx2x_populate_int_phy:11342(eth4)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:09 debian kernel: [  107.938881] bnx2x:
[bnx2x_phy_def_cfg:11499(eth4)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:51:09 debian kernel: [  107.938883] bnx2x:
[bnx2x_phy_probe:11602(eth4)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:09 debian kernel: [  107.938885] bnx2x:
[bnx2x_phy_probe:11643(eth4)]End phy probe. #phys found 1
Sep 27 12:51:09 debian kernel: [  107.938916] bnx2x 0000:04:00.4:
eth4: using MSI-X  IRQs: sp 98  fp[0] 99 ... fp[0] 99
Sep 27 12:51:09 debian kernel: [  107.938925] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth4)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:09 debian kernel: [  107.941678] bnx2x:
[bnx2x_fw_command:2618(eth4)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  107.952686] bnx2x:
[bnx2x_fw_command:2630(eth4)][after 10 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:51:09 debian kernel: [  107.957898] bnx2x:
[set_phy_vars:3478(eth4)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:09 debian kernel: [  107.958078] bnx2x:
[bnx2x_link_status_update:4481(eth4)]phy link up
Sep 27 12:51:09 debian kernel: [  107.958198] bnx2x:
[bnx2x_link_status_update:4590(eth4)]media_types = 0xf0
Sep 27 12:51:09 debian kernel: [  107.958319] bnx2x:
[bnx2x_link_status_update:4608(eth4)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:09 debian kernel: [  107.958503] bnx2x:
[bnx2x_link_status_update:4610(eth4)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:09 debian kernel: [  107.958696] bnx2x 0000:04:00.4:
eth4: NIC Link is Up, 2500 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:09 debian kernel: [  107.959748] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  107.960223] bonding: bond4:
enslaving eth4 as a backup interface with an up link.
Sep 27 12:51:09 debian kernel: [  107.966818] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  108.140040] bonding: bond4: making
interface eth4 the new active one 100 ms earlier.
Sep 27 12:51:09 debian kernel: [  108.145759] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.405175] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1


Maybe this line can explain more ?
Sep 27 12:51:09 debian kernel: [  107.938925] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth4)]ERROR: Invalid cfg pin 0 for
module detect indication


All the cards :
ep 27 12:49:51 debian kernel: [    0.000000] Command line:
initrd=initrd_Diskless_full.img rw root=/dev/ram0 ip=dhcp bnx2x.poll=1
bnx2x.debug=4 BOOT_IMAGE=vmlinuz BOOTIF=01-80-c1-6e-7a-49-48
Sep 27 12:49:51 debian kernel: [    0.000000] Kernel command line:
initrd=initrd_Diskless_full.img rw root=/dev/ram0 ip=dhcp bnx2x.poll=1
bnx2x.debug=4 BOOT_IMAGE=vmlinuz BOOTIF=01-80-c1-6e-7a-49-48
Sep 27 12:49:51 debian kernel: [   19.411379] bnx2x: Broadcom
NetXtreme II 5771x/578xx 10/20-Gigabit Ethernet Driver bnx2x 1.70.30-1
(2012/08/17)
Sep 27 12:49:51 debian kernel: [   19.411658] bnx2x 0000:04:00.0: PCI
INT A -> GSI 32 (level, low) -> IRQ 32
Sep 27 12:49:51 debian kernel: [   19.412616] bnx2x 0000:04:00.0: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.412618] bnx2x 0000:04:00.0: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.412620] bnx2x 0000:04:00.0:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.412624] bnx2x 0000:04:00.0:
shmem offset 0x3c6c80  shmem2 offset 0x3c3ec4
Sep 27 12:49:51 debian kernel: [   19.412626] bnx2x 0000:04:00.0:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.412628] bnx2x 0000:04:00.0: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.412630] bnx2x 0000:04:00.0: WoL capable
Sep 27 12:49:51 debian kernel: [   19.412634] bnx2x 0000:04:00.0: part
number 394D4342-31383735-31543030-47303030
Sep 27 12:49:51 debian kernel: [   19.412637] bnx2x 0000:04:00.0: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.412724] bnx2x 0000:04:00.0:
igu_dsb_id 0  igu_base_sb 1  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.412727] bnx2x 0000:04:00.0:
shmem2base 0x3c3ec4, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.412731] bnx2x 0000:04:00.0:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.412733] bnx2x 0000:04:00.0: MF
OV for func 0 is 1000 (0x03e8)
Sep 27 12:49:51 debian kernel: [   19.412739] bnx2x 0000:04:00.0:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x01000000
Sep 27 12:49:51 debian kernel: [   19.412741] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.412742] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.412745] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.412748] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.412754] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.412756] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.412758] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.412760] bnx2x 0000:04:00.0: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.412761] bnx2x 0000:04:00.0:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.412762] bnx2x 0000:04:00.0:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.412766] bnx2x 0000:04:00.0: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.413182] bnx2x 0000:04:00.0:
fw_seq 0x00000005
Sep 27 12:49:51 debian kernel: [   19.413184] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.413550] bnx2x 0000:04:00.0:
eth0: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E x8
5GHz (Gen2) found at mem ea000000, IRQ 32, node addr 80:c1:6e:7a:49:48
Sep 27 12:49:51 debian kernel: [   19.413584] bnx2x 0000:04:00.1: PCI
INT B -> GSI 36 (level, low) -> IRQ 36
Sep 27 12:49:51 debian kernel: [   19.414752] bnx2x 0000:04:00.1: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.414753] bnx2x 0000:04:00.1: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.414755] bnx2x 0000:04:00.1:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.414758] bnx2x 0000:04:00.1:
shmem offset 0x3c7640  shmem2 offset 0x3c3fd8
Sep 27 12:49:51 debian kernel: [   19.414760] bnx2x 0000:04:00.1:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.414762] bnx2x 0000:04:00.1: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.414764] bnx2x 0000:04:00.1: WoL capable
Sep 27 12:49:51 debian kernel: [   19.414768] bnx2x 0000:04:00.1: part
number 394D4342-31383735-31543030-47303030
Sep 27 12:49:51 debian kernel: [   19.414771] bnx2x 0000:04:00.1: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.414858] bnx2x 0000:04:00.1:
igu_dsb_id 0  igu_base_sb 1  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.414861] bnx2x 0000:04:00.1:
shmem2base 0x3c3fd8, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.414865] bnx2x 0000:04:00.1:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.414867] bnx2x 0000:04:00.1: MF
OV for func 1 is 1000 (0x03e8)
Sep 27 12:49:51 debian kernel: [   19.414873] bnx2x 0000:04:00.1:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x01000000
Sep 27 12:49:51 debian kernel: [   19.414874] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.414875] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.414878] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.414881] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.414887] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.414889] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.414891] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.414893] bnx2x 0000:04:00.1: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.414894] bnx2x 0000:04:00.1:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.414895] bnx2x 0000:04:00.1:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.414899] bnx2x 0000:04:00.1: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.415314] bnx2x 0000:04:00.1:
fw_seq 0x00000000
Sep 27 12:49:51 debian kernel: [   19.415316] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.415642] bnx2x 0000:04:00.1:
eth1: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E x8
5GHz (Gen2) found at mem e8800000, IRQ 36, node addr 80:c1:6e:7a:49:4c
Sep 27 12:49:51 debian kernel: [   19.415674] bnx2x 0000:04:00.2: PCI
INT B -> GSI 36 (level, low) -> IRQ 36
Sep 27 12:49:51 debian kernel: [   19.416602] bnx2x 0000:04:00.2: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.416603] bnx2x 0000:04:00.2: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.416605] bnx2x 0000:04:00.2:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.416608] bnx2x 0000:04:00.2:
shmem offset 0x3c6c80  shmem2 offset 0x3c3ec4
Sep 27 12:49:51 debian kernel: [   19.416610] bnx2x 0000:04:00.2:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.416613] bnx2x 0000:04:00.2: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.416614] bnx2x 0000:04:00.2: WoL capable
Sep 27 12:49:51 debian kernel: [   19.416618] bnx2x 0000:04:00.2: part
number 394D4342-31383735-31543030-47303030
Sep 27 12:49:51 debian kernel: [   19.416621] bnx2x 0000:04:00.2: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.416709] bnx2x 0000:04:00.2:
igu_dsb_id 17  igu_base_sb 18  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.416711] bnx2x 0000:04:00.2:
shmem2base 0x3c3ec4, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.416716] bnx2x 0000:04:00.2:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.416718] bnx2x 0000:04:00.2: MF
OV for func 2 is 1001 (0x03e9)
Sep 27 12:49:51 debian kernel: [   19.416723] bnx2x 0000:04:00.2:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x01000000
Sep 27 12:49:51 debian kernel: [   19.416725] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.416726] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.416728] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.416732] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.416738] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.416739] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.416741] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.416743] bnx2x 0000:04:00.2: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.416744] bnx2x 0000:04:00.2:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.416745] bnx2x 0000:04:00.2:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.416749] bnx2x 0000:04:00.2: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.417165] bnx2x 0000:04:00.2:
fw_seq 0x00000000
Sep 27 12:49:51 debian kernel: [   19.417167] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.417491] bnx2x 0000:04:00.2:
eth2: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E x8
5GHz (Gen2) found at mem e7000000, IRQ 36, node addr 80:c1:6e:7a:49:49
Sep 27 12:49:51 debian kernel: [   19.417525] bnx2x 0000:04:00.3: PCI
INT C -> GSI 37 (level, low) -> IRQ 37
Sep 27 12:49:51 debian kernel: [   19.418453] bnx2x 0000:04:00.3: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.418454] bnx2x 0000:04:00.3: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.418456] bnx2x 0000:04:00.3:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.418459] bnx2x 0000:04:00.3:
shmem offset 0x3c7640  shmem2 offset 0x3c3fd8
Sep 27 12:49:51 debian kernel: [   19.418461] bnx2x 0000:04:00.3:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.418463] bnx2x 0000:04:00.3: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.418465] bnx2x 0000:04:00.3: WoL capable
Sep 27 12:49:51 debian kernel: [   19.418468] bnx2x 0000:04:00.3: part
number 394D4342-31383735-31543030-47303030
Sep 27 12:49:51 debian kernel: [   19.418471] bnx2x 0000:04:00.3: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.418559] bnx2x 0000:04:00.3:
igu_dsb_id 17  igu_base_sb 18  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.418562] bnx2x 0000:04:00.3:
shmem2base 0x3c3fd8, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.418566] bnx2x 0000:04:00.3:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.418568] bnx2x 0000:04:00.3: MF
OV for func 3 is 1001 (0x03e9)
Sep 27 12:49:51 debian kernel: [   19.418573] bnx2x 0000:04:00.3:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x01000000
Sep 27 12:49:51 debian kernel: [   19.418575] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.418576] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.418579] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.418582] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.418588] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.418590] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.418592] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.418594] bnx2x 0000:04:00.3: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.418595] bnx2x 0000:04:00.3:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.418596] bnx2x 0000:04:00.3:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.418600] bnx2x 0000:04:00.3: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.419015] bnx2x 0000:04:00.3:
fw_seq 0x00000000
Sep 27 12:49:51 debian kernel: [   19.419017] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.419343] bnx2x 0000:04:00.3:
eth3: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E x8
5GHz (Gen2) found at mem e5800000, IRQ 37, node addr 80:c1:6e:7a:49:4d
Sep 27 12:49:51 debian kernel: [   19.419373] bnx2x 0000:04:00.4: PCI
INT C -> GSI 37 (level, low) -> IRQ 37
Sep 27 12:49:51 debian kernel: [   19.420302] bnx2x 0000:04:00.4: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.420303] bnx2x 0000:04:00.4: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.420305] bnx2x 0000:04:00.4:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.420309] bnx2x 0000:04:00.4:
shmem offset 0x3c6c80  shmem2 offset 0x3c3ec4
Sep 27 12:49:51 debian kernel: [   19.420310] bnx2x 0000:04:00.4:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.420313] bnx2x 0000:04:00.4: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.420314] bnx2x 0000:04:00.4: WoL capable
Sep 27 12:49:51 debian kernel: [   19.420318] bnx2x 0000:04:00.4: part
number 394D4342-31383735-31543030-47303030
Sep 27 12:49:51 debian kernel: [   19.420321] bnx2x 0000:04:00.4: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.420409] bnx2x 0000:04:00.4:
igu_dsb_id 34  igu_base_sb 35  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.420411] bnx2x 0000:04:00.4:
shmem2base 0x3c3ec4, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.420415] bnx2x 0000:04:00.4:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.420417] bnx2x 0000:04:00.4: MF
OV for func 4 is 1002 (0x03ea)
Sep 27 12:49:51 debian kernel: [   19.420423] bnx2x 0000:04:00.4:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x01000000
Sep 27 12:49:51 debian kernel: [   19.420424] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.420425] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.420428] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.420431] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.420437] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.420439] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.420441] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.420442] bnx2x 0000:04:00.4: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.420444] bnx2x 0000:04:00.4:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.420445] bnx2x 0000:04:00.4:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.420449] bnx2x 0000:04:00.4: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.420864] bnx2x 0000:04:00.4:
fw_seq 0x00000000
Sep 27 12:49:51 debian kernel: [   19.420866] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.421184] bnx2x 0000:04:00.4:
eth4: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E x8
5GHz (Gen2) found at mem e4000000, IRQ 37, node addr 80:c1:6e:7a:49:4a
Sep 27 12:49:51 debian kernel: [   19.421218] bnx2x 0000:04:00.5: PCI
INT D -> GSI 38 (level, low) -> IRQ 38
Sep 27 12:49:51 debian kernel: [   19.422145] bnx2x 0000:04:00.5: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.422147] bnx2x 0000:04:00.5: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.422149] bnx2x 0000:04:00.5:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.422152] bnx2x 0000:04:00.5:
shmem offset 0x3c7640  shmem2 offset 0x3c3fd8
Sep 27 12:49:51 debian kernel: [   19.422154] bnx2x 0000:04:00.5:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.422156] bnx2x 0000:04:00.5: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.422158] bnx2x 0000:04:00.5: WoL capable
Sep 27 12:49:51 debian kernel: [   19.422162] bnx2x 0000:04:00.5: part
number 394D4342-31383735-31543030-47303030
Sep 27 12:49:51 debian kernel: [   19.422165] bnx2x 0000:04:00.5: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.422252] bnx2x 0000:04:00.5:
igu_dsb_id 34  igu_base_sb 35  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.422255] bnx2x 0000:04:00.5:
shmem2base 0x3c3fd8, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.422259] bnx2x 0000:04:00.5:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.422261] bnx2x 0000:04:00.5: MF
OV for func 5 is 1002 (0x03ea)
Sep 27 12:49:51 debian kernel: [   19.422266] bnx2x 0000:04:00.5:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x01000000
Sep 27 12:49:51 debian kernel: [   19.422268] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.422269] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.422274] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.422277] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.422283] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.422285] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.422287] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.422289] bnx2x 0000:04:00.5: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.422289] bnx2x 0000:04:00.5:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.422291] bnx2x 0000:04:00.5:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.422295] bnx2x 0000:04:00.5: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.422710] bnx2x 0000:04:00.5:
fw_seq 0x00000000
Sep 27 12:49:51 debian kernel: [   19.422711] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.423036] bnx2x 0000:04:00.5:
eth5: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E x8
5GHz (Gen2) found at mem e2800000, IRQ 38, node addr 80:c1:6e:7a:49:4e
Sep 27 12:49:51 debian kernel: [   19.423060] bnx2x 0000:04:00.6: PCI
INT D -> GSI 38 (level, low) -> IRQ 38
Sep 27 12:49:51 debian kernel: [   19.423988] bnx2x 0000:04:00.6: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.423989] bnx2x 0000:04:00.6: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.423991] bnx2x 0000:04:00.6:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.423994] bnx2x 0000:04:00.6:
shmem offset 0x3c6c80  shmem2 offset 0x3c3ec4
Sep 27 12:49:51 debian kernel: [   19.423996] bnx2x 0000:04:00.6:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.423998] bnx2x 0000:04:00.6: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.424000] bnx2x 0000:04:00.6: WoL capable
Sep 27 12:49:51 debian kernel: [   19.424004] bnx2x 0000:04:00.6: part
number 394D4342-31383735-31543030-47303030
Sep 27 12:49:51 debian kernel: [   19.424007] bnx2x 0000:04:00.6: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.424095] bnx2x 0000:04:00.6:
igu_dsb_id 51  igu_base_sb 52  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.424097] bnx2x 0000:04:00.6:
shmem2base 0x3c3ec4, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.424102] bnx2x 0000:04:00.6:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.424103] bnx2x 0000:04:00.6: MF
OV for func 6 is 1003 (0x03eb)
Sep 27 12:49:51 debian kernel: [   19.424109] bnx2x 0000:04:00.6:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x01000000
Sep 27 12:49:51 debian kernel: [   19.424110] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.424112] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.424114] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.424117] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.424124] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.424125] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.424127] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.424129] bnx2x 0000:04:00.6: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.424130] bnx2x 0000:04:00.6:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.424131] bnx2x 0000:04:00.6:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.424135] bnx2x 0000:04:00.6: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.424551] bnx2x 0000:04:00.6:
fw_seq 0x00000000
Sep 27 12:49:51 debian kernel: [   19.424552] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.424899] bnx2x 0000:04:00.6:
eth6: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E x8
5GHz (Gen2) found at mem e1000000, IRQ 38, node addr 80:c1:6e:7a:49:4b
Sep 27 12:49:51 debian kernel: [   19.424927] bnx2x 0000:04:00.7: PCI
INT A -> GSI 32 (level, low) -> IRQ 32
Sep 27 12:49:51 debian kernel: [   19.425856] bnx2x 0000:04:00.7: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.425857] bnx2x 0000:04:00.7: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.425859] bnx2x 0000:04:00.7:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.425863] bnx2x 0000:04:00.7:
shmem offset 0x3c7640  shmem2 offset 0x3c3fd8
Sep 27 12:49:51 debian kernel: [   19.425864] bnx2x 0000:04:00.7:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.425867] bnx2x 0000:04:00.7: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.425868] bnx2x 0000:04:00.7: WoL capable
Sep 27 12:49:51 debian kernel: [   19.425872] bnx2x 0000:04:00.7: part
number 394D4342-31383735-31543030-47303030
Sep 27 12:49:51 debian kernel: [   19.425875] bnx2x 0000:04:00.7: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.425963] bnx2x 0000:04:00.7:
igu_dsb_id 51  igu_base_sb 52  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.425965] bnx2x 0000:04:00.7:
shmem2base 0x3c3fd8, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.425969] bnx2x 0000:04:00.7:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.425971] bnx2x 0000:04:00.7: MF
OV for func 7 is 1003 (0x03eb)
Sep 27 12:49:51 debian kernel: [   19.425977] bnx2x 0000:04:00.7:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x01000000
Sep 27 12:49:51 debian kernel: [   19.425978] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.425980] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.425982] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.425985] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.425992] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.425993] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.425995] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.425997] bnx2x 0000:04:00.7: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.425998] bnx2x 0000:04:00.7:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.425999] bnx2x 0000:04:00.7:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.426003] bnx2x 0000:04:00.7: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.426418] bnx2x 0000:04:00.7:
fw_seq 0x00000000
Sep 27 12:49:51 debian kernel: [   19.426419] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.426745] bnx2x 0000:04:00.7:
eth7: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E x8
5GHz (Gen2) found at mem df800000, IRQ 32, node addr 80:c1:6e:7a:49:4f
Sep 27 12:49:51 debian kernel: [   19.426780] bnx2x 0000:05:00.0: PCI
INT A -> GSI 40 (level, low) -> IRQ 40
Sep 27 12:49:51 debian kernel: [   19.427710] bnx2x 0000:05:00.0: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.427711] bnx2x 0000:05:00.0: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.427713] bnx2x 0000:05:00.0:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.427716] bnx2x 0000:05:00.0:
shmem offset 0x3c6c80  shmem2 offset 0x3c3ec4
Sep 27 12:49:51 debian kernel: [   19.427718] bnx2x 0000:05:00.0:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.427720] bnx2x 0000:05:00.0: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.427722] bnx2x 0000:05:00.0: WoL capable
Sep 27 12:49:51 debian kernel: [   19.427725] bnx2x 0000:05:00.0: part
number 0-0-0-0
Sep 27 12:49:51 debian kernel: [   19.427729] bnx2x 0000:05:00.0: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.427817] bnx2x 0000:05:00.0:
igu_dsb_id 0  igu_base_sb 1  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.427819] bnx2x 0000:05:00.0:
shmem2base 0x3c3ec4, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.427824] bnx2x 0000:05:00.0:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.427825] bnx2x 0000:05:00.0: MF
OV for func 0 is 1000 (0x03e8)
Sep 27 12:49:51 debian kernel: [   19.427831] bnx2x 0000:05:00.0:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x00000000
Sep 27 12:49:51 debian kernel: [   19.427833] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.427834] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.427837] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.427840] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.427846] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.427848] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.427849] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.427851] bnx2x 0000:05:00.0: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.427852] bnx2x 0000:05:00.0:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.427853] bnx2x 0000:05:00.0:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.427857] bnx2x 0000:05:00.0: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.446403] bnx2x 0000:05:00.0:
fw_seq 0x00000000
Sep 27 12:49:51 debian kernel: [   19.446404] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.446726] bnx2x 0000:05:00.0:
eth8: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E x8
5GHz (Gen2) found at mem f6000000, IRQ 40, node addr 2c:76:8a:59:b3:90
Sep 27 12:49:51 debian kernel: [   19.446760] bnx2x 0000:05:00.1: PCI
INT B -> GSI 44 (level, low) -> IRQ 44
Sep 27 12:49:51 debian kernel: [   19.447688] bnx2x 0000:05:00.1: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.447689] bnx2x 0000:05:00.1: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.447692] bnx2x 0000:05:00.1:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.447695] bnx2x 0000:05:00.1:
shmem offset 0x3c7640  shmem2 offset 0x3c3fd8
Sep 27 12:49:51 debian kernel: [   19.447697] bnx2x 0000:05:00.1:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.447699] bnx2x 0000:05:00.1: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.447700] bnx2x 0000:05:00.1: WoL capable
Sep 27 12:49:51 debian kernel: [   19.447704] bnx2x 0000:05:00.1: part
number 0-0-0-0
Sep 27 12:49:51 debian kernel: [   19.447707] bnx2x 0000:05:00.1: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.447795] bnx2x 0000:05:00.1:
igu_dsb_id 0  igu_base_sb 1  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.447798] bnx2x 0000:05:00.1:
shmem2base 0x3c3fd8, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.447802] bnx2x 0000:05:00.1:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.447804] bnx2x 0000:05:00.1: MF
OV for func 1 is 1000 (0x03e8)
Sep 27 12:49:51 debian kernel: [   19.447809] bnx2x 0000:05:00.1:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x00000000
Sep 27 12:49:51 debian kernel: [   19.447811] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.447812] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.447815] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.447818] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.447824] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.447826] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.447828] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.447829] bnx2x 0000:05:00.1: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.447830] bnx2x 0000:05:00.1:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.447831] bnx2x 0000:05:00.1:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.447835] bnx2x 0000:05:00.1: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.448251] bnx2x 0000:05:00.1:
fw_seq 0x00000000
Sep 27 12:49:51 debian kernel: [   19.448252] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.448577] bnx2x 0000:05:00.1:
eth9: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E x8
5GHz (Gen2) found at mem f4800000, IRQ 44, node addr 2c:76:8a:59:b3:94
Sep 27 12:49:51 debian kernel: [   19.448602] bnx2x 0000:05:00.2: PCI
INT B -> GSI 44 (level, low) -> IRQ 44
Sep 27 12:49:51 debian kernel: [   19.449532] bnx2x 0000:05:00.2: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.449533] bnx2x 0000:05:00.2: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.449535] bnx2x 0000:05:00.2:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.449538] bnx2x 0000:05:00.2:
shmem offset 0x3c6c80  shmem2 offset 0x3c3ec4
Sep 27 12:49:51 debian kernel: [   19.449540] bnx2x 0000:05:00.2:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.449542] bnx2x 0000:05:00.2: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.449544] bnx2x 0000:05:00.2: WoL capable
Sep 27 12:49:51 debian kernel: [   19.449547] bnx2x 0000:05:00.2: part
number 0-0-0-0
Sep 27 12:49:51 debian kernel: [   19.449550] bnx2x 0000:05:00.2: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.449639] bnx2x 0000:05:00.2:
igu_dsb_id 17  igu_base_sb 18  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.449641] bnx2x 0000:05:00.2:
shmem2base 0x3c3ec4, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.449646] bnx2x 0000:05:00.2:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.449648] bnx2x 0000:05:00.2: MF
OV for func 2 is 1001 (0x03e9)
Sep 27 12:49:51 debian kernel: [   19.449654] bnx2x 0000:05:00.2:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x00000000
Sep 27 12:49:51 debian kernel: [   19.449655] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.449656] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.449659] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.449662] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.449669] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.449670] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.449672] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.449674] bnx2x 0000:05:00.2: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.449675] bnx2x 0000:05:00.2:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.449676] bnx2x 0000:05:00.2:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.449680] bnx2x 0000:05:00.2: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.450096] bnx2x 0000:05:00.2:
fw_seq 0x00000000
Sep 27 12:49:51 debian kernel: [   19.450097] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.450427] bnx2x 0000:05:00.2:
eth10: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E
x8 5GHz (Gen2) found at mem f3000000, IRQ 44, node addr
2c:76:8a:59:b3:91
Sep 27 12:49:51 debian kernel: [   19.450452] bnx2x 0000:05:00.3: PCI
INT C -> GSI 45 (level, low) -> IRQ 45
Sep 27 12:49:51 debian kernel: [   19.451381] bnx2x 0000:05:00.3: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.451382] bnx2x 0000:05:00.3: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.451384] bnx2x 0000:05:00.3:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.451387] bnx2x 0000:05:00.3:
shmem offset 0x3c7640  shmem2 offset 0x3c3fd8
Sep 27 12:49:51 debian kernel: [   19.451389] bnx2x 0000:05:00.3:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.451391] bnx2x 0000:05:00.3: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.451393] bnx2x 0000:05:00.3: WoL capable
Sep 27 12:49:51 debian kernel: [   19.451396] bnx2x 0000:05:00.3: part
number 0-0-0-0
Sep 27 12:49:51 debian kernel: [   19.451399] bnx2x 0000:05:00.3: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.451487] bnx2x 0000:05:00.3:
igu_dsb_id 17  igu_base_sb 18  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.451489] bnx2x 0000:05:00.3:
shmem2base 0x3c3fd8, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.451494] bnx2x 0000:05:00.3:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.451495] bnx2x 0000:05:00.3: MF
OV for func 3 is 1001 (0x03e9)
Sep 27 12:49:51 debian kernel: [   19.451501] bnx2x 0000:05:00.3:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x00000000
Sep 27 12:49:51 debian kernel: [   19.451502] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.451504] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.451507] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.451510] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.451516] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.451518] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.451520] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.451521] bnx2x 0000:05:00.3: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.451522] bnx2x 0000:05:00.3:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.451524] bnx2x 0000:05:00.3:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.451528] bnx2x 0000:05:00.3: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.451943] bnx2x 0000:05:00.3:
fw_seq 0x00000000
Sep 27 12:49:51 debian kernel: [   19.451945] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.452277] bnx2x 0000:05:00.3:
eth11: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E
x8 5GHz (Gen2) found at mem f1800000, IRQ 45, node addr
2c:76:8a:59:b3:95
Sep 27 12:49:51 debian kernel: [   19.452303] bnx2x 0000:05:00.4: PCI
INT C -> GSI 45 (level, low) -> IRQ 45
Sep 27 12:49:51 debian kernel: [   19.453228] bnx2x 0000:05:00.4: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.453229] bnx2x 0000:05:00.4: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.453232] bnx2x 0000:05:00.4:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.453235] bnx2x 0000:05:00.4:
shmem offset 0x3c6c80  shmem2 offset 0x3c3ec4
Sep 27 12:49:51 debian kernel: [   19.453237] bnx2x 0000:05:00.4:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.453239] bnx2x 0000:05:00.4: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.453241] bnx2x 0000:05:00.4: WoL capable
Sep 27 12:49:51 debian kernel: [   19.453244] bnx2x 0000:05:00.4: part
number 0-0-0-0
Sep 27 12:49:51 debian kernel: [   19.453247] bnx2x 0000:05:00.4: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.453338] bnx2x 0000:05:00.4:
igu_dsb_id 34  igu_base_sb 35  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.453341] bnx2x 0000:05:00.4:
shmem2base 0x3c3ec4, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.453345] bnx2x 0000:05:00.4:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.453347] bnx2x 0000:05:00.4: MF
OV for func 4 is 1002 (0x03ea)
Sep 27 12:49:51 debian kernel: [   19.453353] bnx2x 0000:05:00.4:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x00000000
Sep 27 12:49:51 debian kernel: [   19.453354] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.453356] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.453358] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.453362] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.453368] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.453369] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.453371] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.453373] bnx2x 0000:05:00.4: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.453374] bnx2x 0000:05:00.4:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.453375] bnx2x 0000:05:00.4:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.453379] bnx2x 0000:05:00.4: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.453794] bnx2x 0000:05:00.4:
fw_seq 0x00000000
Sep 27 12:49:51 debian kernel: [   19.453796] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.454121] bnx2x 0000:05:00.4:
eth12: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E
x8 5GHz (Gen2) found at mem f0000000, IRQ 45, node addr
2c:76:8a:59:b3:92
Sep 27 12:49:51 debian kernel: [   19.454155] bnx2x 0000:05:00.5: PCI
INT D -> GSI 46 (level, low) -> IRQ 46
Sep 27 12:49:51 debian kernel: [   19.455084] bnx2x 0000:05:00.5: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.455086] bnx2x 0000:05:00.5: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.455088] bnx2x 0000:05:00.5:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.455091] bnx2x 0000:05:00.5:
shmem offset 0x3c7640  shmem2 offset 0x3c3fd8
Sep 27 12:49:51 debian kernel: [   19.455093] bnx2x 0000:05:00.5:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.455095] bnx2x 0000:05:00.5: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.455097] bnx2x 0000:05:00.5: WoL capable
Sep 27 12:49:51 debian kernel: [   19.455100] bnx2x 0000:05:00.5: part
number 0-0-0-0
Sep 27 12:49:51 debian kernel: [   19.455103] bnx2x 0000:05:00.5: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.455191] bnx2x 0000:05:00.5:
igu_dsb_id 34  igu_base_sb 35  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.455194] bnx2x 0000:05:00.5:
shmem2base 0x3c3fd8, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.455198] bnx2x 0000:05:00.5:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.455200] bnx2x 0000:05:00.5: MF
OV for func 5 is 1002 (0x03ea)
Sep 27 12:49:51 debian kernel: [   19.455206] bnx2x 0000:05:00.5:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x00000000
Sep 27 12:49:51 debian kernel: [   19.455207] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.455208] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.455211] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.455214] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.455220] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.455222] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.455224] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.455225] bnx2x 0000:05:00.5: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.455226] bnx2x 0000:05:00.5:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.455228] bnx2x 0000:05:00.5:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.455232] bnx2x 0000:05:00.5: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.455650] bnx2x 0000:05:00.5:
fw_seq 0x00000000
Sep 27 12:49:51 debian kernel: [   19.455651] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.455982] bnx2x 0000:05:00.5:
eth13: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E
x8 5GHz (Gen2) found at mem ee800000, IRQ 46, node addr
2c:76:8a:59:b3:96
Sep 27 12:49:51 debian kernel: [   19.456006] bnx2x 0000:05:00.6: PCI
INT D -> GSI 46 (level, low) -> IRQ 46
Sep 27 12:49:51 debian kernel: [   19.456936] bnx2x 0000:05:00.6: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.456937] bnx2x 0000:05:00.6: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.456940] bnx2x 0000:05:00.6:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.456943] bnx2x 0000:05:00.6:
shmem offset 0x3c6c80  shmem2 offset 0x3c3ec4
Sep 27 12:49:51 debian kernel: [   19.456944] bnx2x 0000:05:00.6:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.456947] bnx2x 0000:05:00.6: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.456948] bnx2x 0000:05:00.6: WoL capable
Sep 27 12:49:51 debian kernel: [   19.456952] bnx2x 0000:05:00.6: part
number 0-0-0-0
Sep 27 12:49:51 debian kernel: [   19.456955] bnx2x 0000:05:00.6: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.457043] bnx2x 0000:05:00.6:
igu_dsb_id 51  igu_base_sb 52  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.457045] bnx2x 0000:05:00.6:
shmem2base 0x3c3ec4, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.457049] bnx2x 0000:05:00.6:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.457051] bnx2x 0000:05:00.6: MF
OV for func 6 is 1003 (0x03eb)
Sep 27 12:49:51 debian kernel: [   19.457057] bnx2x 0000:05:00.6:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x00000000
Sep 27 12:49:51 debian kernel: [   19.457058] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.457059] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.457062] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.457065] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.457071] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.457073] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.457075] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.457076] bnx2x 0000:05:00.6: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.457078] bnx2x 0000:05:00.6:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.457079] bnx2x 0000:05:00.6:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.457083] bnx2x 0000:05:00.6: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.457499] bnx2x 0000:05:00.6:
fw_seq 0x00000000
Sep 27 12:49:51 debian kernel: [   19.457501] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.457822] bnx2x 0000:05:00.6:
eth14: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E
x8 5GHz (Gen2) found at mem ed000000, IRQ 46, node addr
2c:76:8a:59:b3:93
Sep 27 12:49:51 debian kernel: [   19.457848] bnx2x 0000:05:00.7: PCI
INT A -> GSI 40 (level, low) -> IRQ 40
Sep 27 12:49:51 debian kernel: [   19.458778] bnx2x 0000:05:00.7: chip
is in 2_PORT_MODE
Sep 27 12:49:51 debian kernel: [   19.458779] bnx2x 0000:05:00.7: chip
ID is 0x168e1000
Sep 27 12:49:51 debian kernel: [   19.458781] bnx2x 0000:05:00.7:
flash_size 0x200000 (2097152)
Sep 27 12:49:51 debian kernel: [   19.458785] bnx2x 0000:05:00.7:
shmem offset 0x3c7640  shmem2 offset 0x3c3fd8
Sep 27 12:49:51 debian kernel: [   19.458786] bnx2x 0000:05:00.7:
hw_config 0x00010001
Sep 27 12:49:51 debian kernel: [   19.458789] bnx2x 0000:05:00.7: bc_ver 70031
Sep 27 12:49:51 debian kernel: [   19.458790] bnx2x 0000:05:00.7: WoL capable
Sep 27 12:49:51 debian kernel: [   19.458794] bnx2x 0000:05:00.7: part
number 0-0-0-0
Sep 27 12:49:51 debian kernel: [   19.458797] bnx2x 0000:05:00.7: IGU
Normal Mode
Sep 27 12:49:51 debian kernel: [   19.458885] bnx2x 0000:05:00.7:
igu_dsb_id 51  igu_base_sb 52  igu_sb_cnt 16
Sep 27 12:49:51 debian kernel: [   19.458887] bnx2x 0000:05:00.7:
shmem2base 0x3c3fd8, size 244, mfcfg offset 16
Sep 27 12:49:51 debian kernel: [   19.458891] bnx2x 0000:05:00.7:
multi function mode
Sep 27 12:49:51 debian kernel: [   19.458893] bnx2x 0000:05:00.7: MF
OV for func 7 is 1003 (0x03eb)
Sep 27 12:49:51 debian kernel: [   19.458899] bnx2x 0000:05:00.7:
lane_config 0x00000000  speed_cap_mask0 0x00500050  link_config0
0x00000000
Sep 27 12:49:51 debian kernel: [   19.458900] bnx2x:
[bnx2x_phy_probe:11586(eth%d)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   19.458902] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   19.458904] bnx2x:
[bnx2x_populate_int_phy:11230(eth%d)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   19.458907] bnx2x:
[bnx2x_populate_int_phy:11342(eth%d)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   19.458913] bnx2x:
[bnx2x_phy_def_cfg:11499(eth%d)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   19.458915] bnx2x:
[bnx2x_phy_probe:11602(eth%d)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   19.458917] bnx2x:
[bnx2x_phy_probe:11643(eth%d)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   19.458918] bnx2x 0000:05:00.7: phy_addr 0x1
Sep 27 12:49:51 debian kernel: [   19.458919] bnx2x 0000:05:00.7:
supported 0x7460 0x0
Sep 27 12:49:51 debian kernel: [   19.458921] bnx2x 0000:05:00.7:
req_line_speed 0  req_duplex 1 req_flow_ctrl 0x0 advertising 0x7460
Sep 27 12:49:51 debian kernel: [   19.458925] bnx2x 0000:05:00.7: drv_pulse 0x0
Sep 27 12:49:51 debian kernel: [   19.459342] bnx2x 0000:05:00.7:
fw_seq 0x00000000
Sep 27 12:49:51 debian kernel: [   19.459343] bnx2x:
[bnx2x_dcbx_set_state:938(eth%d)]DCB state [ON:on-chip with
negotiation]
Sep 27 12:49:51 debian kernel: [   19.459673] bnx2x 0000:05:00.7:
eth15: Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet (B0) PCI-E
x8 5GHz (Gen2) found at mem eb800000, IRQ 40, node addr
2c:76:8a:59:b3:97
Sep 27 12:49:51 debian kernel: [   26.700212] bnx2x:
[bnx2x_fw_command:2618(eth0)]wrote command (10000006) to FW MB param
0x00000000
Sep 27 12:49:51 debian kernel: [   26.722283] bnx2x:
[bnx2x_fw_command:2630(eth0)][after 20 ms] read (10130006) seq is (6)
from FW MB
Sep 27 12:49:51 debian kernel: [   26.722286] bnx2x:
[bnx2x_nic_load:1815(eth0)]pmf 1
Sep 27 12:49:51 debian kernel: [   26.722297] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:49:51 debian kernel: [   26.722308] bnx2x 0000:04:00.0:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:49:51 debian kernel: [   26.809341] bnx2x:
[bnx2x_init_hw_common:5849(eth0)]starting common init  func 0
Sep 27 12:49:51 debian kernel: [   27.166645] bnx2x:
[bnx2x_common_init_phy:12320(eth0)]Begin common phy init
Sep 27 12:49:51 debian kernel: [   27.166766] bnx2x:
[bnx2x_ext_phy_common_init:12300(eth0)]ext_phy 0x0 common init not
required
Sep 27 12:49:51 debian kernel: [   27.166942] bnx2x:
[bnx2x_ext_phy_common_init:12300(eth0)]ext_phy 0xff00 common init not
required
Sep 27 12:49:51 debian kernel: [   27.167122] bnx2x:
[bnx2x_link_reset:11850(eth0)]Resetting the link of port 0
Sep 27 12:49:51 debian kernel: [   27.167241] bnx2x:
[bnx2x_xmac_disable:1696(eth0)]Disable XMAC on port 0
Sep 27 12:49:51 debian kernel: [   27.177969] bnx2x:
[bnx2x_set_led:5986(eth0)]bnx2x_set_led: port 0, mode 0
Sep 27 12:49:51 debian kernel: [   27.178091] bnx2x:
[bnx2x_set_led:5988(eth0)]speed 0x0, hw_led_mode 0x1
Sep 27 12:49:51 debian kernel: [   27.178254] bnx2x:
[bnx2x_sfp_e3_set_transmitter:4356(eth0)]Setting WC TX to 0
Sep 27 12:49:51 debian kernel: [   27.178477] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:49:51 debian kernel: [   27.179541] bnx2x:
[bnx2x_init_hw_port:6304(eth0)]starting port init  port 0
Sep 27 12:49:51 debian kernel: [   27.179878] bnx2x:
[bnx2x_init_hw_func:6527(eth0)]starting func init  func 0
Sep 27 12:49:51 debian kernel: [   27.302002] bnx2x:
[bnx2x_phy_probe:11586(eth0)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   27.302123] bnx2x:
[bnx2x_phy_probe:11602(eth0)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   27.302306] bnx2x:
[bnx2x_populate_int_phy:11230(eth0)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   27.302427] bnx2x:
[bnx2x_populate_int_phy:11342(eth0)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   27.302615] bnx2x:
[bnx2x_phy_def_cfg:11499(eth0)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   27.302800] bnx2x:
[bnx2x_phy_probe:11602(eth0)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   27.302987] bnx2x:
[bnx2x_phy_probe:11643(eth0)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   27.303138] bnx2x 0000:04:00.0:
eth0: using MSI-X  IRQs: sp 90  fp[0] 91 ... fp[0] 91
Sep 27 12:49:51 debian kernel: [   27.303327] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth0)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:49:51 debian kernel: [   27.306438] bnx2x:
[bnx2x_fw_command:2618(eth0)]wrote command (11000007) to FW MB param
0x00000000
Sep 27 12:49:51 debian kernel: [   27.316873] bnx2x:
[bnx2x_fw_command:2630(eth0)][after 10 ms] read (11100007) seq is (7)
from FW MB
Sep 27 12:49:51 debian kernel: [   27.322084] bnx2x:
[bnx2x_phy_init:11783(eth0)]Phy Initialization started
Sep 27 12:49:51 debian kernel: [   27.322200] bnx2x:
[bnx2x_phy_init:11785(eth0)](1) req_speed 0, req_flowctrl 0
Sep 27 12:49:51 debian kernel: [   27.322373] bnx2x:
[bnx2x_phy_init:11787(eth0)](2) req_speed 0, req_flowctrl 0
Sep 27 12:49:51 debian kernel: [   27.322554] bnx2x:
[bnx2x_emac_init:1463(eth0)]EMAC reset reg is 1024
Sep 27 12:49:51 debian kernel: [   27.322711] bnx2x:
[set_phy_vars:3478(eth0)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:49:51 debian kernel: [   27.322887] bnx2x:
[bnx2x_phy_init:11812(eth0)]Num of phys on board: 1
Sep 27 12:49:51 debian kernel: [   27.323006] bnx2x:
[bnx2x_warpcore_config_init:4250(eth0)]Begin Warpcore init, link_speed
0, serdes_net_if = 0x3000000
Sep 27 12:49:51 debian kernel: [   27.323185] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:49:51 debian kernel: [   27.323375] bnx2x:
[bnx2x_warpcore_enable_AN_KR:3591(eth0)]Enable Auto Negotiation for KR
Sep 27 12:49:51 debian kernel: [   27.323771] bnx2x:
[bnx2x_warpcore_enable_AN_KR:3611(eth0)]Advertize 1G
Sep 27 12:49:51 debian kernel: [   27.323967] bnx2x:
[bnx2x_warpcore_enable_AN_KR:3622(eth0)]Advertize 10G
Sep 27 12:49:51 debian kernel: [   27.324535] bnx2x:
[bnx2x_calc_ieee_aneg_adv:3438(eth0)]ieee_fc = 0x1a0
Sep 27 12:49:51 debian kernel: [   27.324655] bnx2x:
[bnx2x_ext_phy_set_pause:3505(eth0)]Ext phy AN advertize 0xc01
Sep 27 12:49:51 debian kernel: [   27.325491] bnx2x:
[bnx2x_warpcore_config_init:4340(eth0)]Exit config init
Sep 27 12:49:51 debian kernel: [   27.355850] bnx2x:
[bnx2x_link_int_enable:5748(eth0)]port 0, is_xgxs 1, int_status 0x0
Sep 27 12:49:51 debian kernel: [   27.356033] bnx2x:
[bnx2x_link_int_enable:5752(eth0)] int_mask 0x3c0000, MI_INT 1,
SERDES_LINK 0
Sep 27 12:49:51 debian kernel: [   27.356215] bnx2x:
[bnx2x_link_int_enable:5755(eth0)] 10G 0, XGXS_LINK 0
Sep 27 12:49:51 debian kernel: [   27.358222] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:49:51 debian kernel: [   27.364722] bnx2x:
[bnx2x_fw_command:2618(eth8)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:49:51 debian kernel: [   27.376832] bnx2x:
[bnx2x_fw_command:2630(eth8)][after 10 ms] read (10130001) seq is (1)
from FW MB
Sep 27 12:49:51 debian kernel: [   27.376835] bnx2x:
[bnx2x_nic_load:1815(eth8)]pmf 1
Sep 27 12:49:51 debian kernel: [   27.376843] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:49:51 debian kernel: [   27.376852] bnx2x 0000:05:00.0:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:49:51 debian kernel: [   27.404204] bnx2x:
[bnx2x_init_hw_common:5849(eth8)]starting common init  func 0
Sep 27 12:49:51 debian kernel: [   27.724617] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:49:51 debian kernel: [   27.734347] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:49:51 debian kernel: [   27.734539] bnx2x:
[bnx2x_link_update:6470(eth0)]port 0, XGXS?1, int_status 0x0
Sep 27 12:49:51 debian kernel: [   27.734717] bnx2x:
[bnx2x_link_update:6477(eth0)]int_mask 0x0 MI_INT 1, SERDES_LINK 0
Sep 27 12:49:51 debian kernel: [   27.734893] bnx2x:
[bnx2x_link_update:6481(eth0)] 10G 0, XGXS_LINK f
Sep 27 12:49:51 debian kernel: [   27.735082] bnx2x:
[bnx2x_warpcore_read_status:5436(eth0)]0x81d1 = 0x5005
Sep 27 12:49:51 debian kernel: [   27.735480] bnx2x:
[bnx2x_ext_phy_resolve_fc:3573(eth0)]Ext PHY pause result 0xd
Sep 27 12:49:51 debian kernel: [   27.735729] bnx2x:
[bnx2x_warpcore_read_status:5471(eth0)]lane 0 gp_speed 0x20f
Sep 27 12:49:51 debian kernel: [   27.735908] bnx2x:
[bnx2x_get_link_speed_duplex:5284(eth0)]phy link up
Sep 27 12:49:51 debian kernel: [   27.736027] bnx2x:
[bnx2x_get_link_speed_duplex:5359(eth0)] phy_link_up 1 line_speed
10000
Sep 27 12:49:51 debian kernel: [   27.736210] bnx2x:
[bnx2x_warpcore_read_status:5482(eth0)]duplex 1  flow_ctrl 0x300
link_status 0x140075
Sep 27 12:49:51 debian kernel: [   27.736394] bnx2x:
[bnx2x_link_update:6616(eth0)]vars->flow_ctrl = 0x300,
vars->link_status = 0x140075, ext_phy_line_speed = 0
Sep 27 12:49:51 debian kernel: [   27.738582] bnx2x:
[bnx2x_link_int_ack:5828(eth0)]Ack link up interrupt with mask
0x3c0000
Sep 27 12:49:51 debian kernel: [   27.738764] bnx2x:
[bnx2x_xmac_enable:1706(eth0)]enabling XMAC
Sep 27 12:49:51 debian kernel: [   27.739884] bnx2x:
[bnx2x_xmac_init:1658(eth0)]Init XMAC to 10G x 1 port per path
Sep 27 12:49:51 debian kernel: [   27.741098] bnx2x:
[bnx2x_set_led:5986(eth0)]bnx2x_set_led: port 0, mode 2
Sep 27 12:49:51 debian kernel: [   27.741217] bnx2x:
[bnx2x_set_led:5988(eth0)]speed 0x2710, hw_led_mode 0x1
Sep 27 12:49:51 debian kernel: [   27.761582] bnx2x 0000:04:00.0:
eth0: NIC Link is Up, 2500 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:49:51 debian kernel: [   27.762171] bnx2x:
[bnx2x_common_init_phy:12320(eth8)]Begin common phy init
Sep 27 12:49:51 debian kernel: [   27.762298] bnx2x:
[bnx2x_ext_phy_common_init:12300(eth8)]ext_phy 0x0 common init not
required
Sep 27 12:49:51 debian kernel: [   27.762483] bnx2x:
[bnx2x_ext_phy_common_init:12300(eth8)]ext_phy 0xff00 common init not
required
Sep 27 12:49:51 debian kernel: [   27.762671] bnx2x:
[bnx2x_link_reset:11850(eth8)]Resetting the link of port 0
Sep 27 12:49:51 debian kernel: [   27.762797] bnx2x:
[bnx2x_xmac_disable:1696(eth8)]Disable XMAC on port 0
Sep 27 12:49:51 debian kernel: [   27.773564] bnx2x:
[bnx2x_set_led:5986(eth8)]bnx2x_set_led: port 0, mode 0
Sep 27 12:49:51 debian kernel: [   27.773690] bnx2x:
[bnx2x_set_led:5988(eth8)]speed 0x0, hw_led_mode 0x1
Sep 27 12:49:51 debian kernel: [   27.773859] bnx2x:
[bnx2x_sfp_e3_set_transmitter:4356(eth8)]Setting WC TX to 0
Sep 27 12:49:51 debian kernel: [   27.774093] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:49:51 debian kernel: [   27.775171] bnx2x:
[bnx2x_init_hw_port:6304(eth8)]starting port init  port 0
Sep 27 12:49:51 debian kernel: [   27.775521] bnx2x:
[bnx2x_init_hw_func:6527(eth8)]starting func init  func 0
Sep 27 12:49:51 debian kernel: [   27.897653] bnx2x:
[bnx2x_phy_probe:11586(eth8)]Begin phy probe
Sep 27 12:49:51 debian kernel: [   27.897777] bnx2x:
[bnx2x_phy_probe:11602(eth8)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:49:51 debian kernel: [   27.897969] bnx2x:
[bnx2x_populate_int_phy:11230(eth8)]:chip_id = 0x168e0000
Sep 27 12:49:51 debian kernel: [   27.898099] bnx2x:
[bnx2x_populate_int_phy:11342(eth8)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:49:51 debian kernel: [   27.898295] bnx2x:
[bnx2x_phy_def_cfg:11499(eth8)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:49:51 debian kernel: [   27.898490] bnx2x:
[bnx2x_phy_probe:11602(eth8)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:49:51 debian kernel: [   27.898683] bnx2x:
[bnx2x_phy_probe:11643(eth8)]End phy probe. #phys found 1
Sep 27 12:49:51 debian kernel: [   27.898837] bnx2x 0000:05:00.0:
eth8: using MSI-X  IRQs: sp 106  fp[0] 107 ... fp[0] 107
Sep 27 12:49:51 debian kernel: [   27.899036] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth8)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:49:51 debian kernel: [   27.902220] bnx2x:
[bnx2x_fw_command:2618(eth8)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:49:51 debian kernel: [   27.923458] bnx2x:
[bnx2x_fw_command:2630(eth8)][after 20 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:49:51 debian kernel: [   27.928676] bnx2x:
[bnx2x_phy_init:11783(eth8)]Phy Initialization started
Sep 27 12:49:51 debian kernel: [   27.928802] bnx2x:
[bnx2x_phy_init:11785(eth8)](1) req_speed 0, req_flowctrl 0
Sep 27 12:49:51 debian kernel: [   27.928987] bnx2x:
[bnx2x_phy_init:11787(eth8)](2) req_speed 0, req_flowctrl 0
Sep 27 12:49:51 debian kernel: [   27.929181] bnx2x:
[bnx2x_emac_init:1463(eth8)]EMAC reset reg is 1024
Sep 27 12:49:51 debian kernel: [   27.929346] bnx2x:
[set_phy_vars:3478(eth8)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:49:51 debian kernel: [   27.929542] bnx2x:
[bnx2x_phy_init:11812(eth8)]Num of phys on board: 1
Sep 27 12:49:51 debian kernel: [   27.929671] bnx2x:
[bnx2x_warpcore_config_init:4250(eth8)]Begin Warpcore init, link_speed
0, serdes_net_if = 0x3000000
Sep 27 12:49:51 debian kernel: [   27.929866] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:49:51 debian kernel: [   27.930066] bnx2x:
[bnx2x_warpcore_enable_AN_KR:3591(eth8)]Enable Auto Negotiation for KR
Sep 27 12:49:51 debian kernel: [   27.930476] bnx2x:
[bnx2x_warpcore_enable_AN_KR:3611(eth8)]Advertize 1G
Sep 27 12:49:51 debian kernel: [   27.930676] bnx2x:
[bnx2x_warpcore_enable_AN_KR:3622(eth8)]Advertize 10G
Sep 27 12:49:51 debian kernel: [   27.931249] bnx2x:
[bnx2x_calc_ieee_aneg_adv:3438(eth8)]ieee_fc = 0x1a0
Sep 27 12:49:51 debian kernel: [   27.931374] bnx2x:
[bnx2x_ext_phy_set_pause:3505(eth8)]Ext phy AN advertize 0xc01
Sep 27 12:49:51 debian kernel: [   27.932226] bnx2x:
[bnx2x_warpcore_config_init:4340(eth8)]Exit config init
Sep 27 12:49:51 debian kernel: [   27.962434] bnx2x:
[bnx2x_link_int_enable:5748(eth8)]port 0, is_xgxs 0, int_status 0x0
Sep 27 12:49:51 debian kernel: [   27.962624] bnx2x:
[bnx2x_link_int_enable:5752(eth8)] int_mask 0x3c0000, MI_INT 0,
SERDES_LINK 0
Sep 27 12:49:51 debian kernel: [   27.962813] bnx2x:
[bnx2x_link_int_enable:5755(eth8)] 10G 0, XGXS_LINK 0
Sep 27 12:49:51 debian kernel: [   27.964797] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:49:51 debian kernel: [   27.966523] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:49:51 debian kernel: [   27.967754] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:49:51 debian kernel: [   28.191469] bnx2x:
[bnx2x_dcc_event:2965(eth0)]dcc_event 0x300
Sep 27 12:49:51 debian kernel: [   28.191597] bnx2x:
[bnx2x_fw_command:2618(eth0)]wrote command (30000008) to FW MB param
0x00000000
Sep 27 12:49:51 debian kernel: [   28.202267] bnx2x:
[bnx2x_fw_command:2630(eth0)][after 10 ms] read (30100008) seq is (8)
from FW MB
Sep 27 12:49:51 debian kernel: [   28.202443] bnx2x:
[set_phy_vars:3478(eth0)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:49:51 debian kernel: [   28.202620] bnx2x:
[bnx2x_link_status_update:4481(eth0)]phy link up
Sep 27 12:49:51 debian kernel: [   28.202737] bnx2x:
[bnx2x_link_status_update:4590(eth0)]media_types = 0xf0
Sep 27 12:49:51 debian kernel: [   28.202853] bnx2x:
[bnx2x_link_status_update:4608(eth0)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:49:51 debian kernel: [   28.203033] bnx2x:
[bnx2x_link_status_update:4610(eth0)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:49:51 debian kernel: [   28.233983] bnx2x:
[bnx2x_dcc_event:2965(eth0)]dcc_event 0x200
Sep 27 12:49:51 debian kernel: [   28.234109] bnx2x:
[bnx2x_fw_command:2618(eth0)]wrote command (30000009) to FW MB param
0x00000000
Sep 27 12:49:51 debian kernel: [   28.245236] bnx2x:
[bnx2x_fw_command:2630(eth0)][after 10 ms] read (30100009) seq is (9)
from FW MB
Sep 27 12:49:51 debian kernel: [   28.245411] bnx2x:
[set_phy_vars:3478(eth0)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:49:51 debian kernel: [   28.245592] bnx2x:
[bnx2x_link_status_update:4481(eth0)]phy link up
Sep 27 12:49:51 debian kernel: [   28.245711] bnx2x:
[bnx2x_link_status_update:4590(eth0)]media_types = 0xf0
Sep 27 12:49:51 debian kernel: [   28.245833] bnx2x:
[bnx2x_link_status_update:4608(eth0)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:49:51 debian kernel: [   28.246018] bnx2x:
[bnx2x_link_status_update:4610(eth0)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:49:51 debian kernel: [   28.280196] bnx2x:
[bnx2x_dcc_event:2965(eth0)]dcc_event 0x200
Sep 27 12:49:51 debian kernel: [   28.280322] bnx2x:
[bnx2x_fw_command:2618(eth0)]wrote command (3000000a) to FW MB param
0x00000000
Sep 27 12:49:51 debian kernel: [   28.291205] bnx2x:
[bnx2x_fw_command:2630(eth0)][after 10 ms] read (3010000a) seq is (a)
from FW MB
Sep 27 12:49:51 debian kernel: [   28.291391] bnx2x:
[set_phy_vars:3478(eth0)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:49:51 debian kernel: [   28.291575] bnx2x:
[bnx2x_link_status_update:4481(eth0)]phy link up
Sep 27 12:49:51 debian kernel: [   28.291696] bnx2x:
[bnx2x_link_status_update:4590(eth0)]media_types = 0xf0
Sep 27 12:49:51 debian kernel: [   28.291816] bnx2x:
[bnx2x_link_status_update:4608(eth0)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:49:51 debian kernel: [   28.291999] bnx2x:
[bnx2x_link_status_update:4610(eth0)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:49:51 debian kernel: [   28.311376] bnx2x:
[bnx2x_dcc_event:2965(eth0)]dcc_event 0x200
Sep 27 12:49:51 debian kernel: [   28.311501] bnx2x:
[bnx2x_fw_command:2618(eth0)]wrote command (3000000b) to FW MB param
0x00000000
Sep 27 12:49:51 debian kernel: [   28.322184] bnx2x:
[bnx2x_fw_command:2630(eth0)][after 10 ms] read (3010000b) seq is (b)
from FW MB
Sep 27 12:49:51 debian kernel: [   28.322370] bnx2x:
[set_phy_vars:3478(eth0)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:49:51 debian kernel: [   28.322552] bnx2x:
[bnx2x_link_status_update:4481(eth0)]phy link up
Sep 27 12:49:51 debian kernel: [   28.322674] bnx2x:
[bnx2x_link_status_update:4590(eth0)]media_types = 0xf0
Sep 27 12:49:51 debian kernel: [   28.322795] bnx2x:
[bnx2x_link_status_update:4608(eth0)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:49:51 debian kernel: [   28.322981] bnx2x:
[bnx2x_link_status_update:4610(eth0)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:49:51 debian kernel: [   28.341169] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:49:51 debian kernel: [   28.341362] bnx2x:
[bnx2x_link_update:6470(eth8)]port 0, XGXS?1, int_status 0x0
Sep 27 12:49:51 debian kernel: [   28.341543] bnx2x:
[bnx2x_link_update:6477(eth8)]int_mask 0x0 MI_INT 0, SERDES_LINK 0
Sep 27 12:49:51 debian kernel: [   28.342991] bnx2x:
[bnx2x_link_update:6481(eth8)] 10G 0, XGXS_LINK f
Sep 27 12:49:51 debian kernel: [   28.343182] bnx2x:
[bnx2x_warpcore_read_status:5436(eth8)]0x81d1 = 0x5005
Sep 27 12:49:51 debian kernel: [   28.343580] bnx2x:
[bnx2x_ext_phy_resolve_fc:3573(eth8)]Ext PHY pause result 0xd
Sep 27 12:49:51 debian kernel: [   28.343826] bnx2x:
[bnx2x_warpcore_read_status:5471(eth8)]lane 0 gp_speed 0x20f
Sep 27 12:49:51 debian kernel: [   28.344001] bnx2x:
[bnx2x_get_link_speed_duplex:5284(eth8)]phy link up
Sep 27 12:49:51 debian kernel: [   28.344117] bnx2x:
[bnx2x_get_link_speed_duplex:5359(eth8)] phy_link_up 1 line_speed
10000
Sep 27 12:49:51 debian kernel: [   28.344292] bnx2x:
[bnx2x_warpcore_read_status:5482(eth8)]duplex 1  flow_ctrl 0x300
link_status 0x140075
Sep 27 12:49:51 debian kernel: [   28.344467] bnx2x:
[bnx2x_link_update:6616(eth8)]vars->flow_ctrl = 0x300,
vars->link_status = 0x140075, ext_phy_line_speed = 0
Sep 27 12:49:51 debian kernel: [   28.346166] bnx2x:
[bnx2x_link_int_ack:5828(eth8)]Ack link up interrupt with mask
0x3c0000
Sep 27 12:49:51 debian kernel: [   28.346351] bnx2x:
[bnx2x_xmac_enable:1706(eth8)]enabling XMAC
Sep 27 12:49:51 debian kernel: [   28.347471] bnx2x:
[bnx2x_xmac_init:1658(eth8)]Init XMAC to 10G x 1 port per path
Sep 27 12:49:51 debian kernel: [   28.348681] bnx2x:
[bnx2x_set_led:5986(eth8)]bnx2x_set_led: port 0, mode 2
Sep 27 12:49:51 debian kernel: [   28.348801] bnx2x:
[bnx2x_set_led:5988(eth8)]speed 0x2710, hw_led_mode 0x1
Sep 27 12:49:51 debian kernel: [   28.369162] bnx2x 0000:05:00.0:
eth8: NIC Link is Up, 2500 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:49:51 debian kernel: [   28.370039] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:49:51 debian kernel: [   28.378148] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:49:51 debian kernel: [   28.665970] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:49:51 debian kernel: [   28.725917] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:49:51 debian kernel: [   28.866638] bnx2x:
[bnx2x_dcc_event:2965(eth8)]dcc_event 0x300
Sep 27 12:49:51 debian kernel: [   28.866763] bnx2x:
[bnx2x_fw_command:2618(eth8)]wrote command (30000003) to FW MB param
0x00000000
Sep 27 12:49:51 debian kernel: [   28.877805] bnx2x:
[bnx2x_fw_command:2630(eth8)][after 10 ms] read (30100003) seq is (3)
from FW MB
Sep 27 12:49:51 debian kernel: [   28.877992] bnx2x:
[set_phy_vars:3478(eth8)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:49:51 debian kernel: [   28.878177] bnx2x:
[bnx2x_link_status_update:4481(eth8)]phy link up
Sep 27 12:49:51 debian kernel: [   28.878298] bnx2x:
[bnx2x_link_status_update:4590(eth8)]media_types = 0xf0
Sep 27 12:49:51 debian kernel: [   28.878422] bnx2x:
[bnx2x_link_status_update:4608(eth8)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:49:51 debian kernel: [   28.878605] bnx2x:
[bnx2x_link_status_update:4610(eth8)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:49:51 debian kernel: [   28.897199] bnx2x:
[bnx2x_dcc_event:2965(eth8)]dcc_event 0x200
Sep 27 12:49:51 debian kernel: [   28.897320] bnx2x:
[bnx2x_fw_command:2618(eth8)]wrote command (30000004) to FW MB param
0x00000000
Sep 27 12:49:51 debian kernel: [   28.907784] bnx2x:
[bnx2x_fw_command:2630(eth8)][after 10 ms] read (30100004) seq is (4)
from FW MB
Sep 27 12:49:51 debian kernel: [   28.907970] bnx2x:
[set_phy_vars:3478(eth8)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:49:51 debian kernel: [   28.908149] bnx2x:
[bnx2x_link_status_update:4481(eth8)]phy link up
Sep 27 12:49:51 debian kernel: [   28.908266] bnx2x:
[bnx2x_link_status_update:4590(eth8)]media_types = 0xf0
Sep 27 12:49:51 debian kernel: [   28.908386] bnx2x:
[bnx2x_link_status_update:4608(eth8)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:49:51 debian kernel: [   28.908568] bnx2x:
[bnx2x_link_status_update:4610(eth8)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:49:51 debian kernel: [   28.941258] bnx2x:
[bnx2x_dcc_event:2965(eth8)]dcc_event 0x200
Sep 27 12:49:51 debian kernel: [   28.941383] bnx2x:
[bnx2x_fw_command:2618(eth8)]wrote command (30000005) to FW MB param
0x00000000
Sep 27 12:49:51 debian kernel: [   28.951754] bnx2x:
[bnx2x_fw_command:2630(eth8)][after 10 ms] read (30100005) seq is (5)
from FW MB
Sep 27 12:49:51 debian kernel: [   28.951940] bnx2x:
[set_phy_vars:3478(eth8)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:49:51 debian kernel: [   28.952122] bnx2x:
[bnx2x_link_status_update:4481(eth8)]phy link up
Sep 27 12:49:51 debian kernel: [   28.952240] bnx2x:
[bnx2x_link_status_update:4590(eth8)]media_types = 0xf0
Sep 27 12:49:51 debian kernel: [   28.952359] bnx2x:
[bnx2x_link_status_update:4608(eth8)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:49:51 debian kernel: [   28.952538] bnx2x:
[bnx2x_link_status_update:4610(eth8)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:49:51 debian kernel: [   29.008603] bnx2x:
[bnx2x_dcc_event:2965(eth8)]dcc_event 0x200
Sep 27 12:49:51 debian kernel: [   29.008733] bnx2x:
[bnx2x_fw_command:2618(eth8)]wrote command (30000006) to FW MB param
0x00000000
Sep 27 12:49:51 debian kernel: [   29.019707] bnx2x:
[bnx2x_fw_command:2630(eth8)][after 10 ms] read (30100006) seq is (6)
from FW MB
Sep 27 12:49:51 debian kernel: [   29.019894] bnx2x:
[set_phy_vars:3478(eth8)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:49:51 debian kernel: [   29.020075] bnx2x:
[bnx2x_link_status_update:4481(eth8)]phy link up
Sep 27 12:49:51 debian kernel: [   29.020192] bnx2x:
[bnx2x_link_status_update:4590(eth8)]media_types = 0xf0
Sep 27 12:49:51 debian kernel: [   29.020312] bnx2x:
[bnx2x_link_status_update:4608(eth8)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:49:51 debian kernel: [   29.020494] bnx2x:
[bnx2x_link_status_update:4610(eth8)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:49:51 debian kernel: [   29.379463] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:49:51 debian kernel: [   29.727229] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:49:51 debian kernel: [   30.380780] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:49:52 debian kernel: [   30.728544] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:49:52 debian kernel: [   31.382098] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:49:53 debian kernel: [   31.729861] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:49:53 debian kernel: [   32.383413] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:49:54 debian kernel: [   32.731196] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:49:54 debian kernel: [   33.384748] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:49:55 debian kernel: [   33.732489] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:49:55 debian kernel: [   34.386040] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:49:56 debian kernel: [   34.733805] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:49:56 debian kernel: [   35.387356] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:49:57 debian kernel: [   35.735121] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:49:57 debian kernel: [   36.388672] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:49:58 debian kernel: [   36.736433] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:49:58 debian kernel: [   37.389984] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:49:59 debian kernel: [   37.737749] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:49:59 debian kernel: [   38.391319] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:00 debian kernel: [   38.739061] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:00 debian kernel: [   39.392615] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:01 debian kernel: [   39.740388] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:01 debian kernel: [   40.393927] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:02 debian kernel: [   40.741695] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:02 debian kernel: [   41.395241] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:03 debian kernel: [   41.743022] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:03 debian kernel: [   42.396557] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:04 debian kernel: [   42.744316] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:04 debian kernel: [   43.398058] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:05 debian kernel: [   43.745632] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:05 debian kernel: [   44.399185] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:06 debian kernel: [   44.746947] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:06 debian kernel: [   45.401499] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:07 debian kernel: [   45.748264] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:07 debian kernel: [   46.403815] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:08 debian kernel: [   46.749576] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:08 debian kernel: [   47.405131] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:09 debian kernel: [   47.750912] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:09 debian kernel: [   48.406448] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:10 debian kernel: [   48.752367] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:10 debian kernel: [   49.407775] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:11 debian kernel: [   49.753550] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:11 debian kernel: [   50.409089] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:12 debian kernel: [   50.754862] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:12 debian kernel: [   51.410408] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:13 debian kernel: [   51.756303] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:13 debian kernel: [   52.411706] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:14 debian kernel: [   52.757485] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:14 debian kernel: [   53.413021] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:15 debian kernel: [   53.758795] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:15 debian kernel: [   54.414336] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:16 debian kernel: [   54.760115] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:16 debian kernel: [   55.415664] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:17 debian kernel: [   55.761439] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:17 debian kernel: [   56.416978] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:18 debian kernel: [   56.762767] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:18 debian kernel: [   57.418295] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:19 debian kernel: [   57.764061] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:19 debian kernel: [   58.419607] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:20 debian kernel: [   58.765500] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:20 debian kernel: [   58.786013] bnx2x:
[bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   58.786773] bnx2x:
[bnx2x_extract_max_cfg:1490(eth7)]Max BW configured to 0 - using 100
instead
Sep 27 12:50:20 debian kernel: [   58.786957] bnx2x:
[bnx2x_get_settings:251(eth7)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   58.787721] bnx2x:
[bnx2x_get_settings:251(eth12)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   58.788645] bnx2x:
[bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   58.789394] bnx2x:
[bnx2x_get_settings:251(eth6)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   58.790148] bnx2x:
[bnx2x_get_settings:251(eth11)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   58.790940] bnx2x:
[bnx2x_extract_max_cfg:1490(eth15)]Max BW configured to 0 - using 100
instead
Sep 27 12:50:20 debian kernel: [   58.791127] bnx2x:
[bnx2x_get_settings:251(eth15)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   58.791933] bnx2x:
[bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   58.792788] bnx2x:
[bnx2x_get_settings:251(eth5)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   58.793544] bnx2x:
[bnx2x_get_settings:251(eth10)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   58.794333] bnx2x:
[bnx2x_get_settings:251(eth9)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   58.795119] bnx2x:
[bnx2x_get_settings:251(eth14)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   58.795923] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   58.796653] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   58.797402] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   58.798188] bnx2x:
[bnx2x_get_settings:251(eth13)]ethtool_cmd: cmd 1
Sep 27 12:50:20 debian kernel: [   59.420909] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:21 debian kernel: [   59.766687] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:21 debian kernel: [   60.422223] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:22 debian kernel: [   60.768133] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:22 debian kernel: [   61.423553] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:23 debian kernel: [   61.769319] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:23 debian kernel: [   62.424853] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:24 debian kernel: [   62.770634] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:24 debian kernel: [   63.426181] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:25 debian kernel: [   63.771955] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:25 debian kernel: [   64.427498] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:26 debian kernel: [   64.773274] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:26 debian kernel: [   65.428814] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:27 debian kernel: [   65.774592] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:27 debian kernel: [   66.430112] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:28 debian kernel: [   66.775903] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:28 debian kernel: [   67.431427] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:29 debian kernel: [   67.777220] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:29 debian kernel: [   68.432741] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:30 debian kernel: [   68.778539] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:30 debian kernel: [   69.434069] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:31 debian kernel: [   69.779974] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:31 debian kernel: [   70.057859] bnx2x:
[bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.058621] bnx2x:
[bnx2x_extract_max_cfg:1490(eth7)]Max BW configured to 0 - using 100
instead
Sep 27 12:50:31 debian kernel: [   70.058809] bnx2x:
[bnx2x_get_settings:251(eth7)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.059579] bnx2x:
[bnx2x_get_settings:251(eth12)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.060497] bnx2x:
[bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.061242] bnx2x:
[bnx2x_get_settings:251(eth6)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.061992] bnx2x:
[bnx2x_get_settings:251(eth11)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.062775] bnx2x:
[bnx2x_extract_max_cfg:1490(eth15)]Max BW configured to 0 - using 100
instead
Sep 27 12:50:31 debian kernel: [   70.062963] bnx2x:
[bnx2x_get_settings:251(eth15)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.063760] bnx2x:
[bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.064601] bnx2x:
[bnx2x_get_settings:251(eth5)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.065353] bnx2x:
[bnx2x_get_settings:251(eth10)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.066139] bnx2x:
[bnx2x_get_settings:251(eth9)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.066921] bnx2x:
[bnx2x_get_settings:251(eth14)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.067727] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.068463] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.069211] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.069997] bnx2x:
[bnx2x_get_settings:251(eth13)]ethtool_cmd: cmd 1
Sep 27 12:50:31 debian kernel: [   70.435370] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:32 debian kernel: [   70.781157] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:32 debian kernel: [   71.436685] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:32 debian kernel: [   71.453788] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:50:32 debian kernel: [   71.473051] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:50:33 debian kernel: [   71.782463] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:33 debian kernel: [   72.437996] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:33 debian kernel: [   72.495052] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:50:33 debian kernel: [   72.512829] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:50:34 debian kernel: [   72.783778] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:34 debian kernel: [   73.439312] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:35 debian kernel: [   73.785136] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:35 debian kernel: [   74.440625] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:36 debian kernel: [   74.786406] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:36 debian kernel: [   75.441940] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:37 debian kernel: [   75.787846] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:37 debian kernel: [   76.443254] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:38 debian kernel: [   76.789035] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:38 debian kernel: [   77.444570] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:39 debian kernel: [   77.790351] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:39 debian kernel: [   78.445884] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:40 debian kernel: [   78.791789] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:40 debian kernel: [   79.447199] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:41 debian kernel: [   79.792981] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:41 debian kernel: [   80.448513] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:42 debian kernel: [   80.794295] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:42 debian kernel: [   81.449828] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:43 debian kernel: [   81.795732] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:43 debian kernel: [   82.451142] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:44 debian kernel: [   82.796926] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:44 debian kernel: [   83.452457] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:45 debian kernel: [   83.798241] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:45 debian kernel: [   84.453770] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:46 debian kernel: [   84.799677] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:46 debian kernel: [   85.455086] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:47 debian kernel: [   85.800871] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:47 debian kernel: [   86.456400] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:48 debian kernel: [   86.802186] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:48 debian kernel: [   87.457715] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:49 debian kernel: [   87.803576] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:49 debian kernel: [   88.314942] bnx2x:
[bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.315702] bnx2x:
[bnx2x_extract_max_cfg:1490(eth7)]Max BW configured to 0 - using 100
instead
Sep 27 12:50:49 debian kernel: [   88.315886] bnx2x:
[bnx2x_get_settings:251(eth7)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.316649] bnx2x:
[bnx2x_get_settings:251(eth12)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.317596] bnx2x:
[bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.318338] bnx2x:
[bnx2x_get_settings:251(eth6)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.319092] bnx2x:
[bnx2x_get_settings:251(eth11)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.319880] bnx2x:
[bnx2x_extract_max_cfg:1490(eth15)]Max BW configured to 0 - using 100
instead
Sep 27 12:50:49 debian kernel: [   88.320064] bnx2x:
[bnx2x_get_settings:251(eth15)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.320861] bnx2x:
[bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.321723] bnx2x:
[bnx2x_get_settings:251(eth5)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.322480] bnx2x:
[bnx2x_get_settings:251(eth10)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.323263] bnx2x:
[bnx2x_get_settings:251(eth9)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.324034] bnx2x:
[bnx2x_get_settings:251(eth14)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.324828] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.325567] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.326296] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.327077] bnx2x:
[bnx2x_get_settings:251(eth13)]ethtool_cmd: cmd 1
Sep 27 12:50:49 debian kernel: [   88.459032] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:50 debian kernel: [   88.804817] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:50 debian kernel: [   89.460349] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:51 debian kernel: [   89.806118] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:51 debian kernel: [   90.461683] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:52 debian kernel: [   90.807455] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:52 debian kernel: [   91.462979] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:53 debian kernel: [   91.808778] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:53 debian kernel: [   92.464306] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:54 debian kernel: [   92.810113] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:54 debian kernel: [   93.465608] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:55 debian kernel: [   93.811396] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:55 debian kernel: [   94.466938] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:56 debian kernel: [   94.812723] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:56 debian kernel: [   95.468238] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:57 debian kernel: [   95.814032] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:57 debian kernel: [   96.469566] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:58 debian kernel: [   96.815473] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:58 debian kernel: [   97.470882] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:50:59 debian kernel: [   97.816647] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:50:59 debian kernel: [   98.472182] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:51:00 debian kernel: [   98.817983] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:51:00 debian kernel: [   99.473495] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:51:01 debian kernel: [   99.556631] bnx2x:
[bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.557396] bnx2x:
[bnx2x_extract_max_cfg:1490(eth7)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:01 debian kernel: [   99.557582] bnx2x:
[bnx2x_get_settings:251(eth7)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.558334] bnx2x:
[bnx2x_get_settings:251(eth12)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.559247] bnx2x:
[bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.559992] bnx2x:
[bnx2x_get_settings:251(eth6)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.560757] bnx2x:
[bnx2x_get_settings:251(eth11)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.561548] bnx2x:
[bnx2x_extract_max_cfg:1490(eth15)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:01 debian kernel: [   99.561733] bnx2x:
[bnx2x_get_settings:251(eth15)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.562546] bnx2x:
[bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.564718] bnx2x:
[bnx2x_get_settings:251(eth5)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.565476] bnx2x:
[bnx2x_get_settings:251(eth10)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.566262] bnx2x:
[bnx2x_get_settings:251(eth9)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.567054] bnx2x:
[bnx2x_get_settings:251(eth14)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.567876] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.568618] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.569364] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.570163] bnx2x:
[bnx2x_get_settings:251(eth13)]ethtool_cmd: cmd 1
Sep 27 12:51:01 debian kernel: [   99.819270] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:51:01 debian kernel: [  100.474808] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:51:02 debian kernel: [  100.820577] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:51:02 debian kernel: [  100.928422] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:51:02 debian kernel: [  100.945988] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:51:02 debian kernel: [  101.476124] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:51:03 debian kernel: [  101.821910] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:51:03 debian kernel: [  101.967984] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:51:03 debian kernel: [  101.985631] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:51:03 debian kernel: [  102.477436] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:51:04 debian kernel: [  102.823251] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:51:04 debian kernel: [  103.007539] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:51:04 debian kernel: [  103.025076] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:51:04 debian kernel: [  103.478750] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:51:05 debian kernel: [  103.824512] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:51:05 debian kernel: [  104.046716] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:51:05 debian kernel: [  104.063991] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:51:05 debian kernel: [  104.480067] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:51:06 debian kernel: [  104.825825] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:51:06 debian kernel: [  105.085875] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:51:06 debian kernel: [  105.104260] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:51:06 debian kernel: [  105.481618] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:51:07 debian kernel: [  105.696911] bnx2x:
[bnx2x_fw_command:2618(eth1)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:51:07 debian kernel: [  105.718212] bnx2x:
[bnx2x_fw_command:2630(eth1)][after 20 ms] read (10100001) seq is (1)
from FW MB
Sep 27 12:51:07 debian kernel: [  105.718406] bnx2x:
[bnx2x_nic_load:1815(eth1)]pmf 1
Sep 27 12:51:07 debian kernel: [  105.718414] bnx2x:
[bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
Sep 27 12:51:07 debian kernel: [  105.718673] bnx2x 0000:04:00.1:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:51:07 debian kernel: [  105.721754] bnx2x:
[bnx2x_init_hw_common:5849(eth1)]starting common init  func 1
Sep 27 12:51:07 debian kernel: [  105.827144] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:51:07 debian kernel: [  106.079388] bnx2x:
[bnx2x_link_reset:11850(eth1)]Resetting the link of port 0
Sep 27 12:51:07 debian kernel: [  106.079519] bnx2x:
[bnx2x_xmac_disable:1696(eth1)]Disable XMAC on port 0
Sep 27 12:51:07 debian kernel: [  106.089959] bnx2x:
[bnx2x_set_led:5986(eth1)]bnx2x_set_led: port 0, mode 0
Sep 27 12:51:07 debian kernel: [  106.090087] bnx2x:
[bnx2x_set_led:5988(eth1)]speed 0x0, hw_led_mode 0x1
Sep 27 12:51:07 debian kernel: [  106.090255] bnx2x:
[bnx2x_sfp_e3_set_transmitter:4356(eth1)]Setting WC TX to 0
Sep 27 12:51:07 debian kernel: [  106.090487] bnx2x:
[bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
Sep 27 12:51:07 debian kernel: [  106.091566] bnx2x:
[bnx2x_init_hw_port:6304(eth1)]starting port init  port 0
Sep 27 12:51:07 debian kernel: [  106.091916] bnx2x:
[bnx2x_init_hw_func:6527(eth1)]starting func init  func 0
Sep 27 12:51:07 debian kernel: [  106.214051] bnx2x:
[bnx2x_phy_probe:11586(eth1)]Begin phy probe
Sep 27 12:51:07 debian kernel: [  106.214176] bnx2x:
[bnx2x_phy_probe:11602(eth1)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:07 debian kernel: [  106.214370] bnx2x:
[bnx2x_populate_int_phy:11230(eth1)]:chip_id = 0x168e0000
Sep 27 12:51:07 debian kernel: [  106.214497] bnx2x:
[bnx2x_populate_int_phy:11342(eth1)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:07 debian kernel: [  106.214694] bnx2x:
[bnx2x_phy_def_cfg:11499(eth1)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:51:07 debian kernel: [  106.214889] bnx2x:
[bnx2x_phy_probe:11602(eth1)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:07 debian kernel: [  106.215083] bnx2x:
[bnx2x_phy_probe:11643(eth1)]End phy probe. #phys found 1
Sep 27 12:51:07 debian kernel: [  106.215236] bnx2x 0000:04:00.1:
eth1: using MSI-X  IRQs: sp 92  fp[0] 93 ... fp[0] 93
Sep 27 12:51:07 debian kernel: [  106.215434] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth1)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:07 debian kernel: [  106.216600] bnx2x:
[bnx2x_extract_max_cfg:1490(eth1)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:07 debian kernel: [  106.218812] bnx2x:
[bnx2x_fw_command:2618(eth1)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:51:07 debian kernel: [  106.229861] bnx2x:
[bnx2x_fw_command:2630(eth1)][after 10 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:51:07 debian kernel: [  106.235129] bnx2x:
[bnx2x_phy_init:11783(eth1)]Phy Initialization started
Sep 27 12:51:07 debian kernel: [  106.235256] bnx2x:
[bnx2x_phy_init:11785(eth1)](1) req_speed 0, req_flowctrl 0
Sep 27 12:51:07 debian kernel: [  106.235445] bnx2x:
[bnx2x_phy_init:11787(eth1)](2) req_speed 0, req_flowctrl 0
Sep 27 12:51:07 debian kernel: [  106.235641] bnx2x:
[bnx2x_emac_init:1463(eth1)]EMAC reset reg is 1024
Sep 27 12:51:07 debian kernel: [  106.235807] bnx2x:
[set_phy_vars:3478(eth1)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:07 debian kernel: [  106.236001] bnx2x:
[bnx2x_phy_init:11812(eth1)]Num of phys on board: 1
Sep 27 12:51:07 debian kernel: [  106.236128] bnx2x:
[bnx2x_warpcore_config_init:4250(eth1)]Begin Warpcore init, link_speed
0, serdes_net_if = 0x3000000
Sep 27 12:51:07 debian kernel: [  106.236319] bnx2x:
[bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
Sep 27 12:51:07 debian kernel: [  106.236516] bnx2x:
[bnx2x_warpcore_enable_AN_KR:3591(eth1)]Enable Auto Negotiation for KR
Sep 27 12:51:07 debian kernel: [  106.236931] bnx2x:
[bnx2x_warpcore_enable_AN_KR:3611(eth1)]Advertize 1G
Sep 27 12:51:07 debian kernel: [  106.237132] bnx2x:
[bnx2x_warpcore_enable_AN_KR:3622(eth1)]Advertize 10G
Sep 27 12:51:07 debian kernel: [  106.237705] bnx2x:
[bnx2x_calc_ieee_aneg_adv:3438(eth1)]ieee_fc = 0x1a0
Sep 27 12:51:07 debian kernel: [  106.237831] bnx2x:
[bnx2x_ext_phy_set_pause:3505(eth1)]Ext phy AN advertize 0xc01
Sep 27 12:51:07 debian kernel: [  106.238677] bnx2x:
[bnx2x_warpcore_config_init:4340(eth1)]Exit config init
Sep 27 12:51:07 debian kernel: [  106.268841] bnx2x:
[bnx2x_link_int_enable:5748(eth1)]port 0, is_xgxs 1, int_status 0x0
Sep 27 12:51:07 debian kernel: [  106.269032] bnx2x:
[bnx2x_link_int_enable:5752(eth1)] int_mask 0x3c0000, MI_INT 1,
SERDES_LINK 0
Sep 27 12:51:07 debian kernel: [  106.269223] bnx2x:
[bnx2x_link_int_enable:5755(eth1)] 10G 0, XGXS_LINK 0
Sep 27 12:51:07 debian kernel: [  106.271241] bnx2x:
[bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
Sep 27 12:51:07 debian kernel: [  106.277878] bnx2x:
[bnx2x_fw_command:2618(eth9)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:51:07 debian kernel: [  106.299816] bnx2x:
[bnx2x_fw_command:2630(eth9)][after 20 ms] read (10100001) seq is (1)
from FW MB
Sep 27 12:51:07 debian kernel: [  106.300001] bnx2x:
[bnx2x_nic_load:1815(eth9)]pmf 1
Sep 27 12:51:07 debian kernel: [  106.300007] bnx2x:
[bnx2x_set_aer_mmd:3342(eth9)]Set AER to 0x2
Sep 27 12:51:07 debian kernel: [  106.300256] bnx2x 0000:05:00.1:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:51:07 debian kernel: [  106.303289] bnx2x:
[bnx2x_init_hw_common:5849(eth9)]starting common init  func 1
Sep 27 12:51:07 debian kernel: [  106.482699] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:51:08 debian kernel: [  106.647696] bnx2x:
[bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
Sep 27 12:51:08 debian kernel: [  106.647891] bnx2x:
[bnx2x_link_update:6470(eth1)]port 0, XGXS?1, int_status 0x0
Sep 27 12:51:08 debian kernel: [  106.649338] bnx2x:
[bnx2x_link_update:6477(eth1)]int_mask 0x0 MI_INT 1, SERDES_LINK 0
Sep 27 12:51:08 debian kernel: [  106.649513] bnx2x:
[bnx2x_link_update:6481(eth1)] 10G 0, XGXS_LINK f
Sep 27 12:51:08 debian kernel: [  106.649703] bnx2x:
[bnx2x_warpcore_read_status:5436(eth1)]0x81d1 = 0x5005
Sep 27 12:51:08 debian kernel: [  106.650100] bnx2x:
[bnx2x_ext_phy_resolve_fc:3573(eth1)]Ext PHY pause result 0xd
Sep 27 12:51:08 debian kernel: [  106.650344] bnx2x:
[bnx2x_warpcore_read_status:5471(eth1)]lane 2 gp_speed 0x20f
Sep 27 12:51:08 debian kernel: [  106.650518] bnx2x:
[bnx2x_get_link_speed_duplex:5284(eth1)]phy link up
Sep 27 12:51:08 debian kernel: [  106.650636] bnx2x:
[bnx2x_get_link_speed_duplex:5359(eth1)] phy_link_up 1 line_speed
10000
Sep 27 12:51:08 debian kernel: [  106.650811] bnx2x:
[bnx2x_warpcore_read_status:5482(eth1)]duplex 1  flow_ctrl 0x300
link_status 0x140075
Sep 27 12:51:08 debian kernel: [  106.650994] bnx2x:
[bnx2x_link_update:6616(eth1)]vars->flow_ctrl = 0x300,
vars->link_status = 0x140075, ext_phy_line_speed = 0
Sep 27 12:51:08 debian kernel: [  106.652572] bnx2x:
[bnx2x_link_int_ack:5828(eth1)]Ack link up interrupt with mask
0x3c0000
Sep 27 12:51:08 debian kernel: [  106.652754] bnx2x:
[bnx2x_xmac_enable:1706(eth1)]enabling XMAC
Sep 27 12:51:08 debian kernel: [  106.653878] bnx2x:
[bnx2x_xmac_init:1658(eth1)]Init XMAC to 10G x 1 port per path
Sep 27 12:51:08 debian kernel: [  106.655098] bnx2x:
[bnx2x_set_led:5986(eth1)]bnx2x_set_led: port 0, mode 2
Sep 27 12:51:08 debian kernel: [  106.655219] bnx2x:
[bnx2x_set_led:5988(eth1)]speed 0x2710, hw_led_mode 0x1
Sep 27 12:51:08 debian kernel: [  106.659857] bnx2x:
[bnx2x_link_reset:11850(eth9)]Resetting the link of port 0
Sep 27 12:51:08 debian kernel: [  106.659980] bnx2x:
[bnx2x_xmac_disable:1696(eth9)]Disable XMAC on port 0
Sep 27 12:51:08 debian kernel: [  106.670562] bnx2x:
[bnx2x_set_led:5986(eth9)]bnx2x_set_led: port 0, mode 0
Sep 27 12:51:08 debian kernel: [  106.670684] bnx2x:
[bnx2x_set_led:5988(eth9)]speed 0x0, hw_led_mode 0x1
Sep 27 12:51:08 debian kernel: [  106.670849] bnx2x:
[bnx2x_sfp_e3_set_transmitter:4356(eth9)]Setting WC TX to 0
Sep 27 12:51:08 debian kernel: [  106.671072] bnx2x:
[bnx2x_set_aer_mmd:3342(eth9)]Set AER to 0x2
Sep 27 12:51:08 debian kernel: [  106.672137] bnx2x:
[bnx2x_init_hw_port:6304(eth9)]starting port init  port 0
Sep 27 12:51:08 debian kernel: [  106.672526] bnx2x:
[bnx2x_init_hw_func:6527(eth9)]starting func init  func 0
Sep 27 12:51:08 debian kernel: [  106.675564] bnx2x:
[bnx2x_extract_max_cfg:1490(eth1)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:08 debian kernel: [  106.675758] bnx2x 0000:04:00.1:
eth1: NIC Link is Up, 8000 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:08 debian kernel: [  106.718537] bnx2x:
[bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
Sep 27 12:51:08 debian kernel: [  106.794594] bnx2x:
[bnx2x_phy_probe:11586(eth9)]Begin phy probe
Sep 27 12:51:08 debian kernel: [  106.794715] bnx2x:
[bnx2x_phy_probe:11602(eth9)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:08 debian kernel: [  106.794901] bnx2x:
[bnx2x_populate_int_phy:11230(eth9)]:chip_id = 0x168e0000
Sep 27 12:51:08 debian kernel: [  106.795025] bnx2x:
[bnx2x_populate_int_phy:11342(eth9)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:08 debian kernel: [  106.795211] bnx2x:
[bnx2x_phy_def_cfg:11499(eth9)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:51:08 debian kernel: [  106.795392] bnx2x:
[bnx2x_phy_probe:11602(eth9)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:08 debian kernel: [  106.795575] bnx2x:
[bnx2x_phy_probe:11643(eth9)]End phy probe. #phys found 1
Sep 27 12:51:08 debian kernel: [  106.795724] bnx2x 0000:05:00.1:
eth9: using MSI-X  IRQs: sp 108  fp[0] 109 ... fp[0] 109
Sep 27 12:51:08 debian kernel: [  106.795914] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth9)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:08 debian kernel: [  106.797000] bnx2x:
[bnx2x_extract_max_cfg:1490(eth9)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:08 debian kernel: [  106.799200] bnx2x:
[bnx2x_fw_command:2618(eth9)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:51:08 debian kernel: [  106.820458] bnx2x:
[bnx2x_fw_command:2630(eth9)][after 20 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:51:08 debian kernel: [  106.825654] bnx2x:
[bnx2x_phy_init:11783(eth9)]Phy Initialization started
Sep 27 12:51:08 debian kernel: [  106.825775] bnx2x:
[bnx2x_phy_init:11785(eth9)](1) req_speed 0, req_flowctrl 0
Sep 27 12:51:08 debian kernel: [  106.825958] bnx2x:
[bnx2x_phy_init:11787(eth9)](2) req_speed 0, req_flowctrl 0
Sep 27 12:51:08 debian kernel: [  106.826148] bnx2x:
[bnx2x_emac_init:1463(eth9)]EMAC reset reg is 1024
Sep 27 12:51:08 debian kernel: [  106.826310] bnx2x:
[set_phy_vars:3478(eth9)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:08 debian kernel: [  106.826498] bnx2x:
[bnx2x_phy_init:11812(eth9)]Num of phys on board: 1
Sep 27 12:51:08 debian kernel: [  106.826622] bnx2x:
[bnx2x_warpcore_config_init:4250(eth9)]Begin Warpcore init, link_speed
0, serdes_net_if = 0x3000000
Sep 27 12:51:08 debian kernel: [  106.826810] bnx2x:
[bnx2x_set_aer_mmd:3342(eth9)]Set AER to 0x2
Sep 27 12:51:08 debian kernel: [  106.827005] bnx2x:
[bnx2x_warpcore_enable_AN_KR:3591(eth9)]Enable Auto Negotiation for KR
Sep 27 12:51:08 debian kernel: [  106.827405] bnx2x:
[bnx2x_warpcore_enable_AN_KR:3611(eth9)]Advertize 1G
Sep 27 12:51:08 debian kernel: [  106.827603] bnx2x:
[bnx2x_warpcore_enable_AN_KR:3622(eth9)]Advertize 10G
Sep 27 12:51:08 debian kernel: [  106.828171] bnx2x:
[bnx2x_calc_ieee_aneg_adv:3438(eth9)]ieee_fc = 0x1a0
Sep 27 12:51:08 debian kernel: [  106.828293] bnx2x:
[bnx2x_ext_phy_set_pause:3505(eth9)]Ext phy AN advertize 0xc01
Sep 27 12:51:08 debian kernel: [  106.828456] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:51:08 debian kernel: [  106.829250] bnx2x:
[bnx2x_warpcore_config_init:4340(eth9)]Exit config init
Sep 27 12:51:08 debian kernel: [  106.859436] bnx2x:
[bnx2x_link_int_enable:5748(eth9)]port 0, is_xgxs 0, int_status 0x0
Sep 27 12:51:08 debian kernel: [  106.859619] bnx2x:
[bnx2x_link_int_enable:5752(eth9)] int_mask 0x3c0000, MI_INT 0,
SERDES_LINK 0
Sep 27 12:51:08 debian kernel: [  106.859800] bnx2x:
[bnx2x_link_int_enable:5755(eth9)] 10G 0, XGXS_LINK 0
Sep 27 12:51:08 debian kernel: [  106.861778] bnx2x:
[bnx2x_get_settings:251(eth9)]ethtool_cmd: cmd 1
Sep 27 12:51:08 debian kernel: [  106.864243] bnx2x:
[bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
Sep 27 12:51:08 debian kernel: [  106.865523] bnx2x:
[bnx2x_get_settings:251(eth9)]ethtool_cmd: cmd 1
Sep 27 12:51:08 debian kernel: [  106.866950] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:51:08 debian kernel: [  106.867437] bnx2x:
[bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
Sep 27 12:51:08 debian kernel: [  106.883485] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:51:08 debian kernel: [  106.943867] bnx2x:
[bnx2x_fw_command:2618(eth2)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:51:08 debian kernel: [  106.965361] bnx2x:
[bnx2x_fw_command:2630(eth2)][after 20 ms] read (10120001) seq is (1)
from FW MB
Sep 27 12:51:08 debian kernel: [  106.965551] bnx2x:
[bnx2x_nic_load:1815(eth2)]pmf 0
Sep 27 12:51:08 debian kernel: [  106.965693] bnx2x 0000:04:00.2:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:51:08 debian kernel: [  106.968723] bnx2x:
[bnx2x_init_hw_func:6527(eth2)]starting func init  func 2
Sep 27 12:51:08 debian kernel: [  107.086466] bnx2x:
[bnx2x_dcc_event:2965(eth1)]dcc_event 0x300
Sep 27 12:51:08 debian kernel: [  107.086592] bnx2x:
[bnx2x_extract_max_cfg:1490(eth1)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:08 debian kernel: [  107.086775] bnx2x:
[bnx2x_fw_command:2618(eth1)]wrote command (30000003) to FW MB param
0x00000000
Sep 27 12:51:08 debian kernel: [  107.090395] bnx2x:
[bnx2x_phy_probe:11586(eth2)]Begin phy probe
Sep 27 12:51:08 debian kernel: [  107.090512] bnx2x:
[bnx2x_phy_probe:11602(eth2)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:08 debian kernel: [  107.090694] bnx2x:
[bnx2x_populate_int_phy:11230(eth2)]:chip_id = 0x168e0000
Sep 27 12:51:08 debian kernel: [  107.090816] bnx2x:
[bnx2x_populate_int_phy:11342(eth2)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:08 debian kernel: [  107.091001] bnx2x:
[bnx2x_phy_def_cfg:11499(eth2)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:51:08 debian kernel: [  107.091189] bnx2x:
[bnx2x_phy_probe:11602(eth2)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:08 debian kernel: [  107.091379] bnx2x:
[bnx2x_phy_probe:11643(eth2)]End phy probe. #phys found 1
Sep 27 12:51:08 debian kernel: [  107.091527] bnx2x 0000:04:00.2:
eth2: using MSI-X  IRQs: sp 94  fp[0] 95 ... fp[0] 95
Sep 27 12:51:08 debian kernel: [  107.091715] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth2)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:08 debian kernel: [  107.097268] bnx2x:
[bnx2x_fw_command:2630(eth1)][after 10 ms] read (30100003) seq is (3)
from FW MB
Sep 27 12:51:08 debian kernel: [  107.097455] bnx2x:
[set_phy_vars:3478(eth1)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:08 debian kernel: [  107.097644] bnx2x:
[bnx2x_link_status_update:4481(eth1)]phy link up
Sep 27 12:51:08 debian kernel: [  107.097765] bnx2x:
[bnx2x_link_status_update:4590(eth1)]media_types = 0xf0
Sep 27 12:51:08 debian kernel: [  107.097886] bnx2x:
[bnx2x_link_status_update:4608(eth1)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:08 debian kernel: [  107.098070] bnx2x:
[bnx2x_link_status_update:4610(eth1)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:08 debian kernel: [  107.098658] bnx2x:
[bnx2x_fw_command:2618(eth2)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:51:08 debian kernel: [  107.109261] bnx2x:
[bnx2x_fw_command:2630(eth2)][after 10 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:51:08 debian kernel: [  107.114477] bnx2x:
[set_phy_vars:3478(eth2)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:08 debian kernel: [  107.114659] bnx2x:
[bnx2x_link_status_update:4481(eth2)]phy link up
Sep 27 12:51:08 debian kernel: [  107.114779] bnx2x:
[bnx2x_link_status_update:4590(eth2)]media_types = 0xf0
Sep 27 12:51:08 debian kernel: [  107.114900] bnx2x:
[bnx2x_link_status_update:4608(eth2)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:08 debian kernel: [  107.115084] bnx2x:
[bnx2x_link_status_update:4610(eth2)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:08 debian kernel: [  107.115277] bnx2x 0000:04:00.2:
eth2: NIC Link is Up, 2500 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:08 debian kernel: [  107.116299] bnx2x:
[bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
Sep 27 12:51:08 debian kernel: [  107.122744] bnx2x:
[bnx2x_fw_command:2618(eth10)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:51:08 debian kernel: [  107.140078] bnx2x:
[bnx2x_dcc_event:2965(eth1)]dcc_event 0x200
Sep 27 12:51:08 debian kernel: [  107.140203] bnx2x:
[bnx2x_extract_max_cfg:1490(eth1)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:08 debian kernel: [  107.140395] bnx2x:
[bnx2x_fw_command:2618(eth1)]wrote command (30000004) to FW MB param
0x00000000
Sep 27 12:51:08 debian kernel: [  107.146236] bnx2x:
[bnx2x_fw_command:2630(eth10)][after 20 ms] read (10120001) seq is (1)
from FW MB
Sep 27 12:51:08 debian kernel: [  107.146426] bnx2x:
[bnx2x_nic_load:1815(eth10)]pmf 0
Sep 27 12:51:08 debian kernel: [  107.146567] bnx2x 0000:05:00.2:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:51:08 debian kernel: [  107.149588] bnx2x:
[bnx2x_init_hw_func:6527(eth10)]starting func init  func 2
Sep 27 12:51:08 debian kernel: [  107.151233] bnx2x:
[bnx2x_fw_command:2630(eth1)][after 10 ms] read (30100004) seq is (4)
from FW MB
Sep 27 12:51:08 debian kernel: [  107.151419] bnx2x:
[set_phy_vars:3478(eth1)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:08 debian kernel: [  107.151606] bnx2x:
[bnx2x_link_status_update:4481(eth1)]phy link up
Sep 27 12:51:08 debian kernel: [  107.151727] bnx2x:
[bnx2x_link_status_update:4590(eth1)]media_types = 0xf0
Sep 27 12:51:08 debian kernel: [  107.151853] bnx2x:
[bnx2x_link_status_update:4608(eth1)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:08 debian kernel: [  107.152040] bnx2x:
[bnx2x_link_status_update:4610(eth1)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:08 debian kernel: [  107.174276] bnx2x:
[bnx2x_dcc_event:2965(eth1)]dcc_event 0x200
Sep 27 12:51:08 debian kernel: [  107.174397] bnx2x:
[bnx2x_extract_max_cfg:1490(eth1)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:08 debian kernel: [  107.174575] bnx2x:
[bnx2x_fw_command:2618(eth1)]wrote command (30000005) to FW MB param
0x00000000
Sep 27 12:51:08 debian kernel: [  107.185209] bnx2x:
[bnx2x_fw_command:2630(eth1)][after 10 ms] read (30100005) seq is (5)
from FW MB
Sep 27 12:51:08 debian kernel: [  107.185393] bnx2x:
[set_phy_vars:3478(eth1)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:08 debian kernel: [  107.185577] bnx2x:
[bnx2x_link_status_update:4481(eth1)]phy link up
Sep 27 12:51:08 debian kernel: [  107.185697] bnx2x:
[bnx2x_link_status_update:4590(eth1)]media_types = 0xf0
Sep 27 12:51:08 debian kernel: [  107.185821] bnx2x:
[bnx2x_link_status_update:4608(eth1)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:08 debian kernel: [  107.186008] bnx2x:
[bnx2x_link_status_update:4610(eth1)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:08 debian kernel: [  107.271378] bnx2x:
[bnx2x_phy_probe:11586(eth10)]Begin phy probe
Sep 27 12:51:08 debian kernel: [  107.271506] bnx2x:
[bnx2x_phy_probe:11602(eth10)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:08 debian kernel: [  107.271701] bnx2x:
[bnx2x_populate_int_phy:11230(eth10)]:chip_id = 0x168e0000
Sep 27 12:51:08 debian kernel: [  107.271831] bnx2x:
[bnx2x_populate_int_phy:11342(eth10)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:08 debian kernel: [  107.272031] bnx2x:
[bnx2x_phy_def_cfg:11499(eth10)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:51:08 debian kernel: [  107.272227] bnx2x:
[bnx2x_phy_probe:11602(eth10)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:08 debian kernel: [  107.272419] bnx2x:
[bnx2x_phy_probe:11643(eth10)]End phy probe. #phys found 1
Sep 27 12:51:08 debian kernel: [  107.272570] bnx2x 0000:05:00.2:
eth10: using MSI-X  IRQs: sp 110  fp[0] 111 ... fp[0] 111
Sep 27 12:51:08 debian kernel: [  107.272768] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth10)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:08 debian kernel: [  107.274696] bnx2x:
[bnx2x_fw_command:2618(eth10)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:51:08 debian kernel: [  107.285141] bnx2x:
[bnx2x_fw_command:2630(eth10)][after 10 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:51:08 debian kernel: [  107.290363] bnx2x:
[set_phy_vars:3478(eth10)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:08 debian kernel: [  107.290555] bnx2x:
[bnx2x_link_status_update:4481(eth10)]phy link up
Sep 27 12:51:08 debian kernel: [  107.290682] bnx2x:
[bnx2x_link_status_update:4590(eth10)]media_types = 0xf0
Sep 27 12:51:08 debian kernel: [  107.290811] bnx2x:
[bnx2x_link_status_update:4608(eth10)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:08 debian kernel: [  107.291007] bnx2x:
[bnx2x_link_status_update:4610(eth10)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:08 debian kernel: [  107.291205] bnx2x 0000:05:00.2:
eth10: NIC Link is Up, 2500 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:08 debian kernel: [  107.292249] bnx2x:
[bnx2x_get_settings:251(eth10)]ethtool_cmd: cmd 1
Sep 27 12:51:08 debian kernel: [  107.303132] bnx2x:
[bnx2x_set_aer_mmd:3342(eth9)]Set AER to 0x2
Sep 27 12:51:08 debian kernel: [  107.365745] bnx2x:
[bnx2x_set_aer_mmd:3342(eth9)]Set AER to 0x2
Sep 27 12:51:08 debian kernel: [  107.365943] bnx2x:
[bnx2x_link_update:6470(eth9)]port 0, XGXS?1, int_status 0x0
Sep 27 12:51:08 debian kernel: [  107.366128] bnx2x:
[bnx2x_link_update:6477(eth9)]int_mask 0x0 MI_INT 0, SERDES_LINK 0
Sep 27 12:51:08 debian kernel: [  107.366309] bnx2x:
[bnx2x_link_update:6481(eth9)] 10G 0, XGXS_LINK f
Sep 27 12:51:08 debian kernel: [  107.366498] bnx2x:
[bnx2x_warpcore_read_status:5436(eth9)]0x81d1 = 0x5005
Sep 27 12:51:08 debian kernel: [  107.366897] bnx2x:
[bnx2x_ext_phy_resolve_fc:3573(eth9)]Ext PHY pause result 0xd
Sep 27 12:51:08 debian kernel: [  107.367146] bnx2x:
[bnx2x_warpcore_read_status:5471(eth9)]lane 2 gp_speed 0x20f
Sep 27 12:51:08 debian kernel: [  107.367326] bnx2x:
[bnx2x_get_link_speed_duplex:5284(eth9)]phy link up
Sep 27 12:51:08 debian kernel: [  107.367446] bnx2x:
[bnx2x_get_link_speed_duplex:5359(eth9)] phy_link_up 1 line_speed
10000
Sep 27 12:51:08 debian kernel: [  107.367628] bnx2x:
[bnx2x_warpcore_read_status:5482(eth9)]duplex 1  flow_ctrl 0x300
link_status 0x140075
Sep 27 12:51:08 debian kernel: [  107.367810] bnx2x:
[bnx2x_link_update:6616(eth9)]vars->flow_ctrl = 0x300,
vars->link_status = 0x140075, ext_phy_line_speed = 0
Sep 27 12:51:08 debian kernel: [  107.369083] bnx2x:
[bnx2x_link_int_ack:5828(eth9)]Ack link up interrupt with mask
0x3c0000
Sep 27 12:51:08 debian kernel: [  107.369263] bnx2x:
[bnx2x_xmac_enable:1706(eth9)]enabling XMAC
Sep 27 12:51:08 debian kernel: [  107.370383] bnx2x:
[bnx2x_xmac_init:1658(eth9)]Init XMAC to 10G x 1 port per path
Sep 27 12:51:08 debian kernel: [  107.371599] bnx2x:
[bnx2x_set_led:5986(eth9)]bnx2x_set_led: port 0, mode 2
Sep 27 12:51:08 debian kernel: [  107.371720] bnx2x:
[bnx2x_set_led:5988(eth9)]speed 0x2710, hw_led_mode 0x1
Sep 27 12:51:08 debian kernel: [  107.371748] bnx2x:
[bnx2x_fw_command:2618(eth3)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:51:08 debian kernel: [  107.392076] bnx2x:
[bnx2x_extract_max_cfg:1490(eth9)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:08 debian kernel: [  107.392264] bnx2x 0000:05:00.1:
eth9: NIC Link is Up, 8000 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:08 debian kernel: [  107.393065] bnx2x:
[bnx2x_fw_command:2630(eth3)][after 20 ms] read (10120001) seq is (1)
from FW MB
Sep 27 12:51:08 debian kernel: [  107.393252] bnx2x:
[bnx2x_nic_load:1815(eth3)]pmf 0
Sep 27 12:51:08 debian kernel: [  107.393389] bnx2x 0000:04:00.3:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:51:08 debian kernel: [  107.396437] bnx2x:
[bnx2x_init_hw_func:6527(eth3)]starting func init  func 2
Sep 27 12:51:08 debian kernel: [  107.484011] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:51:09 debian kernel: [  107.518100] bnx2x:
[bnx2x_phy_probe:11586(eth3)]Begin phy probe
Sep 27 12:51:09 debian kernel: [  107.518219] bnx2x:
[bnx2x_phy_probe:11602(eth3)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:09 debian kernel: [  107.518402] bnx2x:
[bnx2x_populate_int_phy:11230(eth3)]:chip_id = 0x168e0000
Sep 27 12:51:09 debian kernel: [  107.518524] bnx2x:
[bnx2x_populate_int_phy:11342(eth3)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:09 debian kernel: [  107.518708] bnx2x:
[bnx2x_phy_def_cfg:11499(eth3)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:51:09 debian kernel: [  107.518892] bnx2x:
[bnx2x_phy_probe:11602(eth3)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:09 debian kernel: [  107.519080] bnx2x:
[bnx2x_phy_probe:11643(eth3)]End phy probe. #phys found 1
Sep 27 12:51:09 debian kernel: [  107.519224] bnx2x 0000:04:00.3:
eth3: using MSI-X  IRQs: sp 96  fp[0] 97 ... fp[0] 97
Sep 27 12:51:09 debian kernel: [  107.519413] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth3)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:09 debian kernel: [  107.521354] bnx2x:
[bnx2x_fw_command:2618(eth3)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  107.531970] bnx2x:
[bnx2x_fw_command:2630(eth3)][after 10 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:51:09 debian kernel: [  107.537183] bnx2x:
[set_phy_vars:3478(eth3)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:09 debian kernel: [  107.537369] bnx2x:
[bnx2x_link_status_update:4481(eth3)]phy link up
Sep 27 12:51:09 debian kernel: [  107.537491] bnx2x:
[bnx2x_link_status_update:4590(eth3)]media_types = 0xf0
Sep 27 12:51:09 debian kernel: [  107.537614] bnx2x:
[bnx2x_link_status_update:4608(eth3)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:09 debian kernel: [  107.537800] bnx2x:
[bnx2x_link_status_update:4610(eth3)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:09 debian kernel: [  107.537994] bnx2x 0000:04:00.3:
eth3: NIC Link is Up, 1000 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:09 debian kernel: [  107.539023] bnx2x:
[bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  107.540398] bnx2x:
[bnx2x_get_settings:251(eth9)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  107.540967] bnx2x:
[bnx2x_get_settings:251(eth9)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  107.546244] bnx2x:
[bnx2x_fw_command:2618(eth11)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  107.567947] bnx2x:
[bnx2x_fw_command:2630(eth11)][after 20 ms] read (10120001) seq is (1)
from FW MB
Sep 27 12:51:09 debian kernel: [  107.568141] bnx2x:
[bnx2x_nic_load:1815(eth11)]pmf 0
Sep 27 12:51:09 debian kernel: [  107.568284] bnx2x 0000:05:00.3:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:51:09 debian kernel: [  107.571256] bnx2x:
[bnx2x_init_hw_func:6527(eth11)]starting func init  func 2
Sep 27 12:51:09 debian kernel: [  107.693090] bnx2x:
[bnx2x_phy_probe:11586(eth11)]Begin phy probe
Sep 27 12:51:09 debian kernel: [  107.693215] bnx2x:
[bnx2x_phy_probe:11602(eth11)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:09 debian kernel: [  107.693408] bnx2x:
[bnx2x_populate_int_phy:11230(eth11)]:chip_id = 0x168e0000
Sep 27 12:51:09 debian kernel: [  107.693536] bnx2x:
[bnx2x_populate_int_phy:11342(eth11)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:09 debian kernel: [  107.695042] bnx2x:
[bnx2x_phy_def_cfg:11499(eth11)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:51:09 debian kernel: [  107.695234] bnx2x:
[bnx2x_phy_probe:11602(eth11)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:09 debian kernel: [  107.695423] bnx2x:
[bnx2x_phy_probe:11643(eth11)]End phy probe. #phys found 1
Sep 27 12:51:09 debian kernel: [  107.695575] bnx2x 0000:05:00.3:
eth11: using MSI-X  IRQs: sp 112  fp[0] 113 ... fp[0] 113
Sep 27 12:51:09 debian kernel: [  107.695771] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth11)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:09 debian kernel: [  107.697695] bnx2x:
[bnx2x_fw_command:2618(eth11)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  107.708850] bnx2x:
[bnx2x_fw_command:2630(eth11)][after 10 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:51:09 debian kernel: [  107.714072] bnx2x:
[set_phy_vars:3478(eth11)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:09 debian kernel: [  107.714260] bnx2x:
[bnx2x_link_status_update:4481(eth11)]phy link up
Sep 27 12:51:09 debian kernel: [  107.714385] bnx2x:
[bnx2x_link_status_update:4590(eth11)]media_types = 0xf0
Sep 27 12:51:09 debian kernel: [  107.714509] bnx2x:
[bnx2x_link_status_update:4608(eth11)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:09 debian kernel: [  107.714704] bnx2x:
[bnx2x_link_status_update:4610(eth11)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:09 debian kernel: [  107.714907] bnx2x 0000:05:00.3:
eth11: NIC Link is Up, 1000 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:09 debian kernel: [  107.715938] bnx2x:
[bnx2x_get_settings:251(eth11)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  107.718845] bnx2x:
[bnx2x_get_settings:251(eth10)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  107.719860] bnx2x:
[bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
Sep 27 12:51:09 debian kernel: [  107.792132] bnx2x:
[bnx2x_fw_command:2618(eth4)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  107.813780] bnx2x:
[bnx2x_fw_command:2630(eth4)][after 20 ms] read (10120001) seq is (1)
from FW MB
Sep 27 12:51:09 debian kernel: [  107.813961] bnx2x:
[bnx2x_nic_load:1815(eth4)]pmf 0
Sep 27 12:51:09 debian kernel: [  107.814097] bnx2x 0000:04:00.4:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:51:09 debian kernel: [  107.817115] bnx2x:
[bnx2x_init_hw_func:6527(eth4)]starting func init  func 4
Sep 27 12:51:09 debian kernel: [  107.829775] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:51:09 debian kernel: [  107.927018] bnx2x:
[bnx2x_dcc_event:2965(eth9)]dcc_event 0x300
Sep 27 12:51:09 debian kernel: [  107.927141] bnx2x:
[bnx2x_extract_max_cfg:1490(eth9)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:09 debian kernel: [  107.927319] bnx2x:
[bnx2x_fw_command:2618(eth9)]wrote command (30000003) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  107.937694] bnx2x:
[bnx2x_fw_command:2630(eth9)][after 10 ms] read (30100003) seq is (3)
from FW MB
Sep 27 12:51:09 debian kernel: [  107.937882] bnx2x:
[set_phy_vars:3478(eth9)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:09 debian kernel: [  107.938069] bnx2x:
[bnx2x_link_status_update:4481(eth9)]phy link up
Sep 27 12:51:09 debian kernel: [  107.938190] bnx2x:
[bnx2x_link_status_update:4590(eth9)]media_types = 0xf0
Sep 27 12:51:09 debian kernel: [  107.938313] bnx2x:
[bnx2x_link_status_update:4608(eth9)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:09 debian kernel: [  107.938496] bnx2x:
[bnx2x_link_status_update:4610(eth9)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:09 debian kernel: [  107.938720] bnx2x:
[set_phy_vars:3478(eth11)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:09 debian kernel: [  107.938867] bnx2x:
[bnx2x_phy_probe:11586(eth4)]Begin phy probe
Sep 27 12:51:09 debian kernel: [  107.938868] bnx2x:
[bnx2x_phy_probe:11602(eth4)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:09 debian kernel: [  107.938871] bnx2x:
[bnx2x_populate_int_phy:11230(eth4)]:chip_id = 0x168e0000
Sep 27 12:51:09 debian kernel: [  107.938875] bnx2x:
[bnx2x_populate_int_phy:11342(eth4)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:09 debian kernel: [  107.938881] bnx2x:
[bnx2x_phy_def_cfg:11499(eth4)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:51:09 debian kernel: [  107.938883] bnx2x:
[bnx2x_phy_probe:11602(eth4)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:09 debian kernel: [  107.938885] bnx2x:
[bnx2x_phy_probe:11643(eth4)]End phy probe. #phys found 1
Sep 27 12:51:09 debian kernel: [  107.938916] bnx2x 0000:04:00.4:
eth4: using MSI-X  IRQs: sp 98  fp[0] 99 ... fp[0] 99
Sep 27 12:51:09 debian kernel: [  107.938925] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth4)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:09 debian kernel: [  107.940353] bnx2x:
[bnx2x_link_status_update:4481(eth11)]phy link up
Sep 27 12:51:09 debian kernel: [  107.940471] bnx2x:
[bnx2x_link_status_update:4590(eth11)]media_types = 0xf0
Sep 27 12:51:09 debian kernel: [  107.940587] bnx2x:
[bnx2x_link_status_update:4608(eth11)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:09 debian kernel: [  107.940767] bnx2x:
[bnx2x_link_status_update:4610(eth11)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:09 debian kernel: [  107.941678] bnx2x:
[bnx2x_fw_command:2618(eth4)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  107.952686] bnx2x:
[bnx2x_fw_command:2630(eth4)][after 10 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:51:09 debian kernel: [  107.957898] bnx2x:
[set_phy_vars:3478(eth4)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:09 debian kernel: [  107.958078] bnx2x:
[bnx2x_link_status_update:4481(eth4)]phy link up
Sep 27 12:51:09 debian kernel: [  107.958198] bnx2x:
[bnx2x_link_status_update:4590(eth4)]media_types = 0xf0
Sep 27 12:51:09 debian kernel: [  107.958319] bnx2x:
[bnx2x_link_status_update:4608(eth4)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:09 debian kernel: [  107.958503] bnx2x:
[bnx2x_link_status_update:4610(eth4)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:09 debian kernel: [  107.958696] bnx2x 0000:04:00.4:
eth4: NIC Link is Up, 2500 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:09 debian kernel: [  107.959748] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  107.961176] bnx2x:
[bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  107.962400] bnx2x:
[bnx2x_get_settings:251(eth10)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  107.963617] bnx2x:
[bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  107.964833] bnx2x:
[bnx2x_get_settings:251(eth11)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  107.966818] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  107.972446] bnx2x:
[bnx2x_fw_command:2618(eth12)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  107.993654] bnx2x:
[bnx2x_fw_command:2630(eth12)][after 20 ms] read (10120001) seq is (1)
from FW MB
Sep 27 12:51:09 debian kernel: [  107.993840] bnx2x:
[bnx2x_nic_load:1815(eth12)]pmf 0
Sep 27 12:51:09 debian kernel: [  107.993977] bnx2x 0000:05:00.4:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:51:09 debian kernel: [  107.997046] bnx2x:
[bnx2x_init_hw_func:6527(eth12)]starting func init  func 4
Sep 27 12:51:09 debian kernel: [  107.999973] bnx2x:
[bnx2x_dcc_event:2965(eth11)]dcc_event 0x100
Sep 27 12:51:09 debian kernel: [  108.000096] bnx2x:
[bnx2x_fw_command:2618(eth11)]wrote command (30000003) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  108.010643] bnx2x:
[bnx2x_fw_command:2630(eth11)][after 10 ms] read (30100003) seq is (3)
from FW MB
Sep 27 12:51:09 debian kernel: [  108.010826] bnx2x:
[set_phy_vars:3478(eth11)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:09 debian kernel: [  108.011007] bnx2x:
[bnx2x_link_status_update:4481(eth11)]phy link up
Sep 27 12:51:09 debian kernel: [  108.011125] bnx2x:
[bnx2x_link_status_update:4590(eth11)]media_types = 0xf0
Sep 27 12:51:09 debian kernel: [  108.011243] bnx2x:
[bnx2x_link_status_update:4608(eth11)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:09 debian kernel: [  108.011423] bnx2x:
[bnx2x_link_status_update:4610(eth11)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:09 debian kernel: [  108.011736] bnx2x:
[bnx2x_dcc_event:2965(eth9)]dcc_event 0x200
Sep 27 12:51:09 debian kernel: [  108.011856] bnx2x:
[bnx2x_extract_max_cfg:1490(eth9)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:09 debian kernel: [  108.012034] bnx2x:
[bnx2x_fw_command:2618(eth9)]wrote command (30000004) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  108.022636] bnx2x:
[bnx2x_fw_command:2630(eth9)][after 10 ms] read (30100004) seq is (4)
from FW MB
Sep 27 12:51:09 debian kernel: [  108.022823] bnx2x:
[set_phy_vars:3478(eth9)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:09 debian kernel: [  108.023007] bnx2x:
[bnx2x_link_status_update:4481(eth9)]phy link up
Sep 27 12:51:09 debian kernel: [  108.023128] bnx2x:
[bnx2x_link_status_update:4590(eth9)]media_types = 0xf0
Sep 27 12:51:09 debian kernel: [  108.023252] bnx2x:
[bnx2x_link_status_update:4608(eth9)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:09 debian kernel: [  108.023437] bnx2x:
[bnx2x_link_status_update:4610(eth9)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:09 debian kernel: [  108.023651] bnx2x:
[set_phy_vars:3478(eth11)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:09 debian kernel: [  108.023836] bnx2x:
[bnx2x_link_status_update:4481(eth11)]phy link up
Sep 27 12:51:09 debian kernel: [  108.023955] bnx2x:
[bnx2x_link_status_update:4590(eth11)]media_types = 0xf0
Sep 27 12:51:09 debian kernel: [  108.024076] bnx2x:
[bnx2x_link_status_update:4608(eth11)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:09 debian kernel: [  108.024262] bnx2x:
[bnx2x_link_status_update:4610(eth11)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:09 debian kernel: [  108.037602] bnx2x:
[bnx2x_dcc_event:2965(eth9)]dcc_event 0x200
Sep 27 12:51:09 debian kernel: [  108.039030] bnx2x:
[bnx2x_extract_max_cfg:1490(eth9)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:09 debian kernel: [  108.039213] bnx2x:
[bnx2x_fw_command:2618(eth9)]wrote command (30000005) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  108.049616] bnx2x:
[bnx2x_fw_command:2630(eth9)][after 10 ms] read (30100005) seq is (5)
from FW MB
Sep 27 12:51:09 debian kernel: [  108.049799] bnx2x:
[set_phy_vars:3478(eth9)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:09 debian kernel: [  108.049980] bnx2x:
[bnx2x_link_status_update:4481(eth9)]phy link up
Sep 27 12:51:09 debian kernel: [  108.050099] bnx2x:
[bnx2x_link_status_update:4590(eth9)]media_types = 0xf0
Sep 27 12:51:09 debian kernel: [  108.050220] bnx2x:
[bnx2x_link_status_update:4608(eth9)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:09 debian kernel: [  108.050404] bnx2x:
[bnx2x_link_status_update:4610(eth9)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:09 debian kernel: [  108.050613] bnx2x:
[set_phy_vars:3478(eth11)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:09 debian kernel: [  108.050797] bnx2x:
[bnx2x_link_status_update:4481(eth11)]phy link up
Sep 27 12:51:09 debian kernel: [  108.050917] bnx2x:
[bnx2x_link_status_update:4590(eth11)]media_types = 0xf0
Sep 27 12:51:09 debian kernel: [  108.051038] bnx2x:
[bnx2x_link_status_update:4608(eth11)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:09 debian kernel: [  108.051223] bnx2x:
[bnx2x_link_status_update:4610(eth11)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:09 debian kernel: [  108.118689] bnx2x:
[bnx2x_phy_probe:11586(eth12)]Begin phy probe
Sep 27 12:51:09 debian kernel: [  108.118808] bnx2x:
[bnx2x_phy_probe:11602(eth12)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:09 debian kernel: [  108.118995] bnx2x:
[bnx2x_populate_int_phy:11230(eth12)]:chip_id = 0x168e0000
Sep 27 12:51:09 debian kernel: [  108.119119] bnx2x:
[bnx2x_populate_int_phy:11342(eth12)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:09 debian kernel: [  108.119308] bnx2x:
[bnx2x_phy_def_cfg:11499(eth12)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:51:09 debian kernel: [  108.119491] bnx2x:
[bnx2x_phy_probe:11602(eth12)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:09 debian kernel: [  108.119676] bnx2x:
[bnx2x_phy_probe:11643(eth12)]End phy probe. #phys found 1
Sep 27 12:51:09 debian kernel: [  108.119819] bnx2x 0000:05:00.4:
eth12: using MSI-X  IRQs: sp 114  fp[0] 115 ... fp[0] 115
Sep 27 12:51:09 debian kernel: [  108.120010] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth12)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:09 debian kernel: [  108.121928] bnx2x:
[bnx2x_fw_command:2618(eth12)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  108.132560] bnx2x:
[bnx2x_fw_command:2630(eth12)][after 10 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:51:09 debian kernel: [  108.137768] bnx2x:
[set_phy_vars:3478(eth12)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:09 debian kernel: [  108.137951] bnx2x:
[bnx2x_link_status_update:4481(eth12)]phy link up
Sep 27 12:51:09 debian kernel: [  108.138072] bnx2x:
[bnx2x_link_status_update:4590(eth12)]media_types = 0xf0
Sep 27 12:51:09 debian kernel: [  108.138192] bnx2x:
[bnx2x_link_status_update:4608(eth12)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:09 debian kernel: [  108.138376] bnx2x:
[bnx2x_link_status_update:4610(eth12)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:09 debian kernel: [  108.138567] bnx2x 0000:05:00.4:
eth12: NIC Link is Up, 2500 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:09 debian kernel: [  108.139582] bnx2x:
[bnx2x_get_settings:251(eth12)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  108.143803] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  108.144285] bnx2x:
[bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  108.144797] bnx2x:
[bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  108.145277] bnx2x:
[bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  108.145759] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  108.153990] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  108.154463] bnx2x:
[bnx2x_get_settings:251(eth9)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  108.154954] bnx2x:
[bnx2x_get_settings:251(eth10)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  108.160706] bnx2x:
[bnx2x_get_settings:251(eth12)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  108.217830] bnx2x:
[bnx2x_fw_command:2618(eth5)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  108.239489] bnx2x:
[bnx2x_fw_command:2630(eth5)][after 20 ms] read (10120001) seq is (1)
from FW MB
Sep 27 12:51:09 debian kernel: [  108.239672] bnx2x:
[bnx2x_nic_load:1815(eth5)]pmf 0
Sep 27 12:51:09 debian kernel: [  108.239811] bnx2x 0000:04:00.5:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:51:09 debian kernel: [  108.242828] bnx2x:
[bnx2x_init_hw_func:6527(eth5)]starting func init  func 4
Sep 27 12:51:09 debian kernel: [  108.305447] bnx2x:
[bnx2x_set_aer_mmd:3342(eth9)]Set AER to 0x2
Sep 27 12:51:09 debian kernel: [  108.364573] bnx2x:
[bnx2x_phy_probe:11586(eth5)]Begin phy probe
Sep 27 12:51:09 debian kernel: [  108.364693] bnx2x:
[bnx2x_phy_probe:11602(eth5)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:09 debian kernel: [  108.364878] bnx2x:
[bnx2x_populate_int_phy:11230(eth5)]:chip_id = 0x168e0000
Sep 27 12:51:09 debian kernel: [  108.364999] bnx2x:
[bnx2x_populate_int_phy:11342(eth5)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:09 debian kernel: [  108.365187] bnx2x:
[bnx2x_phy_def_cfg:11499(eth5)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:51:09 debian kernel: [  108.365370] bnx2x:
[bnx2x_phy_probe:11602(eth5)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:09 debian kernel: [  108.365551] bnx2x:
[bnx2x_phy_probe:11643(eth5)]End phy probe. #phys found 1
Sep 27 12:51:09 debian kernel: [  108.365698] bnx2x 0000:04:00.5:
eth5: using MSI-X  IRQs: sp 100  fp[0] 101 ... fp[0] 101
Sep 27 12:51:09 debian kernel: [  108.365880] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth5)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:09 debian kernel: [  108.367796] bnx2x:
[bnx2x_fw_command:2618(eth5)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  108.378391] bnx2x:
[bnx2x_fw_command:2630(eth5)][after 10 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:51:09 debian kernel: [  108.383603] bnx2x:
[set_phy_vars:3478(eth5)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:09 debian kernel: [  108.383786] bnx2x:
[bnx2x_link_status_update:4481(eth5)]phy link up
Sep 27 12:51:09 debian kernel: [  108.383906] bnx2x:
[bnx2x_link_status_update:4590(eth5)]media_types = 0xf0
Sep 27 12:51:09 debian kernel: [  108.384027] bnx2x:
[bnx2x_link_status_update:4608(eth5)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:09 debian kernel: [  108.384209] bnx2x:
[bnx2x_link_status_update:4610(eth5)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:09 debian kernel: [  108.384399] bnx2x 0000:04:00.5:
eth5: NIC Link is Up, 1000 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:09 debian kernel: [  108.385415] bnx2x:
[bnx2x_get_settings:251(eth5)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  108.386387] bnx2x:
[bnx2x_get_settings:251(eth12)]ethtool_cmd: cmd 1
Sep 27 12:51:09 debian kernel: [  108.391952] bnx2x:
[bnx2x_fw_command:2618(eth13)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:51:09 debian kernel: [  108.413368] bnx2x:
[bnx2x_fw_command:2630(eth13)][after 20 ms] read (10120001) seq is (1)
from FW MB
Sep 27 12:51:09 debian kernel: [  108.413558] bnx2x:
[bnx2x_nic_load:1815(eth13)]pmf 0
Sep 27 12:51:09 debian kernel: [  108.413702] bnx2x 0000:05:00.5:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:51:09 debian kernel: [  108.416692] bnx2x:
[bnx2x_init_hw_func:6527(eth13)]starting func init  func 4
Sep 27 12:51:09 debian kernel: [  108.485327] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:51:10 debian kernel: [  108.538514] bnx2x:
[bnx2x_phy_probe:11586(eth13)]Begin phy probe
Sep 27 12:51:10 debian kernel: [  108.538643] bnx2x:
[bnx2x_phy_probe:11602(eth13)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:10 debian kernel: [  108.538841] bnx2x:
[bnx2x_populate_int_phy:11230(eth13)]:chip_id = 0x168e0000
Sep 27 12:51:10 debian kernel: [  108.538968] bnx2x:
[bnx2x_populate_int_phy:11342(eth13)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:10 debian kernel: [  108.539163] bnx2x:
[bnx2x_phy_def_cfg:11499(eth13)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:51:10 debian kernel: [  108.539360] bnx2x:
[bnx2x_phy_probe:11602(eth13)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:10 debian kernel: [  108.539553] bnx2x:
[bnx2x_phy_probe:11643(eth13)]End phy probe. #phys found 1
Sep 27 12:51:10 debian kernel: [  108.539712] bnx2x 0000:05:00.5:
eth13: using MSI-X  IRQs: sp 116  fp[0] 117 ... fp[0] 117
Sep 27 12:51:10 debian kernel: [  108.539913] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth13)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:10 debian kernel: [  108.541846] bnx2x:
[bnx2x_fw_command:2618(eth13)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:51:10 debian kernel: [  108.552274] bnx2x:
[bnx2x_fw_command:2630(eth13)][after 10 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:51:10 debian kernel: [  108.558850] bnx2x:
[set_phy_vars:3478(eth13)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:10 debian kernel: [  108.559049] bnx2x:
[bnx2x_link_status_update:4481(eth13)]phy link up
Sep 27 12:51:10 debian kernel: [  108.559176] bnx2x:
[bnx2x_link_status_update:4590(eth13)]media_types = 0xf0
Sep 27 12:51:10 debian kernel: [  108.559306] bnx2x:
[bnx2x_link_status_update:4608(eth13)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:10 debian kernel: [  108.559500] bnx2x:
[bnx2x_link_status_update:4610(eth13)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:10 debian kernel: [  108.559698] bnx2x 0000:05:00.5:
eth13: NIC Link is Up, 1000 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:10 debian kernel: [  108.560717] bnx2x:
[bnx2x_get_settings:251(eth13)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  108.612237] bnx2x:
[bnx2x_get_settings:251(eth13)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  108.636035] bnx2x:
[bnx2x_fw_command:2618(eth6)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:51:10 debian kernel: [  108.658202] bnx2x:
[bnx2x_fw_command:2630(eth6)][after 20 ms] read (10120001) seq is (1)
from FW MB
Sep 27 12:51:10 debian kernel: [  108.658394] bnx2x:
[bnx2x_nic_load:1815(eth6)]pmf 0
Sep 27 12:51:10 debian kernel: [  108.658539] bnx2x 0000:04:00.6:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:51:10 debian kernel: [  108.661595] bnx2x:
[bnx2x_init_hw_func:6527(eth6)]starting func init  func 6
Sep 27 12:51:10 debian kernel: [  108.721172] bnx2x:
[bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
Sep 27 12:51:10 debian kernel: [  108.783345] bnx2x:
[bnx2x_phy_probe:11586(eth6)]Begin phy probe
Sep 27 12:51:10 debian kernel: [  108.783470] bnx2x:
[bnx2x_phy_probe:11602(eth6)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:10 debian kernel: [  108.783666] bnx2x:
[bnx2x_populate_int_phy:11230(eth6)]:chip_id = 0x168e0000
Sep 27 12:51:10 debian kernel: [  108.783794] bnx2x:
[bnx2x_populate_int_phy:11342(eth6)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:10 debian kernel: [  108.783990] bnx2x:
[bnx2x_phy_def_cfg:11499(eth6)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:51:10 debian kernel: [  108.784185] bnx2x:
[bnx2x_phy_probe:11602(eth6)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:10 debian kernel: [  108.784375] bnx2x:
[bnx2x_phy_probe:11643(eth6)]End phy probe. #phys found 1
Sep 27 12:51:10 debian kernel: [  108.784533] bnx2x 0000:04:00.6:
eth6: using MSI-X  IRQs: sp 102  fp[0] 103 ... fp[0] 103
Sep 27 12:51:10 debian kernel: [  108.784730] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth6)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:10 debian kernel: [  108.786673] bnx2x:
[bnx2x_fw_command:2618(eth6)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:51:10 debian kernel: [  108.797105] bnx2x:
[bnx2x_fw_command:2630(eth6)][after 10 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:51:10 debian kernel: [  108.802333] bnx2x:
[set_phy_vars:3478(eth6)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:10 debian kernel: [  108.802526] bnx2x:
[bnx2x_link_status_update:4481(eth6)]phy link up
Sep 27 12:51:10 debian kernel: [  108.802653] bnx2x:
[bnx2x_link_status_update:4590(eth6)]media_types = 0xf0
Sep 27 12:51:10 debian kernel: [  108.802781] bnx2x:
[bnx2x_link_status_update:4608(eth6)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:10 debian kernel: [  108.802972] bnx2x:
[bnx2x_link_status_update:4610(eth6)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:10 debian kernel: [  108.803175] bnx2x 0000:04:00.6:
eth6: NIC Link is Up, 2500 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:10 debian kernel: [  108.804226] bnx2x:
[bnx2x_get_settings:251(eth6)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  108.810688] bnx2x:
[bnx2x_fw_command:2618(eth14)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:51:10 debian kernel: [  108.831085] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:51:10 debian kernel: [  108.832082] bnx2x:
[bnx2x_fw_command:2630(eth14)][after 20 ms] read (10120001) seq is (1)
from FW MB
Sep 27 12:51:10 debian kernel: [  108.832267] bnx2x:
[bnx2x_nic_load:1815(eth14)]pmf 0
Sep 27 12:51:10 debian kernel: [  108.832407] bnx2x 0000:05:00.6:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:51:10 debian kernel: [  108.835357] bnx2x:
[bnx2x_init_hw_func:6527(eth14)]starting func init  func 6
Sep 27 12:51:10 debian kernel: [  108.957114] bnx2x:
[bnx2x_phy_probe:11586(eth14)]Begin phy probe
Sep 27 12:51:10 debian kernel: [  108.957233] bnx2x:
[bnx2x_phy_probe:11602(eth14)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:10 debian kernel: [  108.957415] bnx2x:
[bnx2x_populate_int_phy:11230(eth14)]:chip_id = 0x168e0000
Sep 27 12:51:10 debian kernel: [  108.957535] bnx2x:
[bnx2x_populate_int_phy:11342(eth14)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:10 debian kernel: [  108.957722] bnx2x:
[bnx2x_phy_def_cfg:11499(eth14)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:51:10 debian kernel: [  108.957907] bnx2x:
[bnx2x_phy_probe:11602(eth14)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:10 debian kernel: [  108.958095] bnx2x:
[bnx2x_phy_probe:11643(eth14)]End phy probe. #phys found 1
Sep 27 12:51:10 debian kernel: [  108.958245] bnx2x 0000:05:00.6:
eth14: using MSI-X  IRQs: sp 118  fp[0] 119 ... fp[0] 119
Sep 27 12:51:10 debian kernel: [  108.958433] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth14)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:10 debian kernel: [  108.960362] bnx2x:
[bnx2x_fw_command:2618(eth14)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:51:10 debian kernel: [  108.970986] bnx2x:
[bnx2x_fw_command:2630(eth14)][after 10 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:51:10 debian kernel: [  108.976194] bnx2x:
[set_phy_vars:3478(eth14)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:10 debian kernel: [  108.976375] bnx2x:
[bnx2x_link_status_update:4481(eth14)]phy link up
Sep 27 12:51:10 debian kernel: [  108.976493] bnx2x:
[bnx2x_link_status_update:4590(eth14)]media_types = 0xf0
Sep 27 12:51:10 debian kernel: [  108.976612] bnx2x:
[bnx2x_link_status_update:4608(eth14)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:10 debian kernel: [  108.976791] bnx2x:
[bnx2x_link_status_update:4610(eth14)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:10 debian kernel: [  108.976983] bnx2x 0000:05:00.6:
eth14: NIC Link is Up, 2500 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:10 debian kernel: [  108.978016] bnx2x:
[bnx2x_get_settings:251(eth14)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  108.979964] bnx2x:
[bnx2x_get_settings:251(eth12)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  108.981268] bnx2x:
[bnx2x_get_settings:251(eth11)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  108.982486] bnx2x:
[bnx2x_get_settings:251(eth5)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  108.983699] bnx2x:
[bnx2x_get_settings:251(eth13)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  108.985785] bnx2x:
[bnx2x_get_settings:251(eth6)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  108.987009] bnx2x:
[bnx2x_get_settings:251(eth14)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.056036] bnx2x:
[bnx2x_fw_command:2618(eth7)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:51:10 debian kernel: [  109.077913] bnx2x:
[bnx2x_fw_command:2630(eth7)][after 20 ms] read (10120001) seq is (1)
from FW MB
Sep 27 12:51:10 debian kernel: [  109.078108] bnx2x:
[bnx2x_nic_load:1815(eth7)]pmf 0
Sep 27 12:51:10 debian kernel: [  109.078250] bnx2x 0000:04:00.7:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:51:10 debian kernel: [  109.081302] bnx2x:
[bnx2x_init_hw_func:6527(eth7)]starting func init  func 6
Sep 27 12:51:10 debian kernel: [  109.203055] bnx2x:
[bnx2x_phy_probe:11586(eth7)]Begin phy probe
Sep 27 12:51:10 debian kernel: [  109.203176] bnx2x:
[bnx2x_phy_probe:11602(eth7)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:10 debian kernel: [  109.203362] bnx2x:
[bnx2x_populate_int_phy:11230(eth7)]:chip_id = 0x168e0000
Sep 27 12:51:10 debian kernel: [  109.203487] bnx2x:
[bnx2x_populate_int_phy:11342(eth7)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:10 debian kernel: [  109.203676] bnx2x:
[bnx2x_phy_def_cfg:11499(eth7)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:51:10 debian kernel: [  109.203866] bnx2x:
[bnx2x_phy_probe:11602(eth7)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:10 debian kernel: [  109.204057] bnx2x:
[bnx2x_phy_probe:11643(eth7)]End phy probe. #phys found 1
Sep 27 12:51:10 debian kernel: [  109.204212] bnx2x 0000:04:00.7:
eth7: using MSI-X  IRQs: sp 104  fp[0] 105 ... fp[0] 105
Sep 27 12:51:10 debian kernel: [  109.204411] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth7)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:10 debian kernel: [  109.206351] bnx2x:
[bnx2x_fw_command:2618(eth7)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:51:10 debian kernel: [  109.216818] bnx2x:
[bnx2x_fw_command:2630(eth7)][after 10 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:51:10 debian kernel: [  109.223310] bnx2x:
[set_phy_vars:3478(eth7)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:10 debian kernel: [  109.223506] bnx2x:
[bnx2x_link_status_update:4481(eth7)]phy link up
Sep 27 12:51:10 debian kernel: [  109.223636] bnx2x:
[bnx2x_link_status_update:4590(eth7)]media_types = 0xf0
Sep 27 12:51:10 debian kernel: [  109.223762] bnx2x:
[bnx2x_link_status_update:4608(eth7)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:10 debian kernel: [  109.223957] bnx2x:
[bnx2x_link_status_update:4610(eth7)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:10 debian kernel: [  109.224154] bnx2x:
[bnx2x_extract_max_cfg:1490(eth7)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:10 debian kernel: [  109.224350] bnx2x 0000:04:00.7:
eth7: NIC Link is Up, 10000 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:10 debian kernel: [  109.225386] bnx2x:
[bnx2x_extract_max_cfg:1490(eth7)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:10 debian kernel: [  109.225582] bnx2x:
[bnx2x_get_settings:251(eth7)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.232281] bnx2x:
[bnx2x_fw_command:2618(eth15)]wrote command (10000001) to FW MB param
0x00000000
Sep 27 12:51:10 debian kernel: [  109.253792] bnx2x:
[bnx2x_fw_command:2630(eth15)][after 20 ms] read (10120001) seq is (1)
from FW MB
Sep 27 12:51:10 debian kernel: [  109.253985] bnx2x:
[bnx2x_nic_load:1815(eth15)]pmf 0
Sep 27 12:51:10 debian kernel: [  109.254126] bnx2x 0000:05:00.7:
Loading bnx2x/bnx2x-e2-7.0.29.0.fw
Sep 27 12:51:10 debian kernel: [  109.257151] bnx2x:
[bnx2x_init_hw_func:6527(eth15)]starting func init  func 6
Sep 27 12:51:10 debian kernel: [  109.306766] bnx2x:
[bnx2x_set_aer_mmd:3342(eth9)]Set AER to 0x2
Sep 27 12:51:10 debian kernel: [  109.378936] bnx2x:
[bnx2x_phy_probe:11586(eth15)]Begin phy probe
Sep 27 12:51:10 debian kernel: [  109.379062] bnx2x:
[bnx2x_phy_probe:11602(eth15)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:10 debian kernel: [  109.379256] bnx2x:
[bnx2x_populate_int_phy:11230(eth15)]:chip_id = 0x168e0000
Sep 27 12:51:10 debian kernel: [  109.379385] bnx2x:
[bnx2x_populate_int_phy:11342(eth15)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:10 debian kernel: [  109.379582] bnx2x:
[bnx2x_phy_def_cfg:11499(eth15)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:51:10 debian kernel: [  109.379777] bnx2x:
[bnx2x_phy_probe:11602(eth15)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:10 debian kernel: [  109.379971] bnx2x:
[bnx2x_phy_probe:11643(eth15)]End phy probe. #phys found 1
Sep 27 12:51:10 debian kernel: [  109.380120] bnx2x 0000:05:00.7:
eth15: using MSI-X  IRQs: sp 120  fp[0] 121 ... fp[0] 121
Sep 27 12:51:10 debian kernel: [  109.380318] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth15)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:10 debian kernel: [  109.382245] bnx2x:
[bnx2x_fw_command:2618(eth15)]wrote command (11000002) to FW MB param
0x00000000
Sep 27 12:51:10 debian kernel: [  109.392698] bnx2x:
[bnx2x_fw_command:2630(eth15)][after 10 ms] read (11100002) seq is (2)
from FW MB
Sep 27 12:51:10 debian kernel: [  109.397917] bnx2x:
[set_phy_vars:3478(eth15)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:10 debian kernel: [  109.398113] bnx2x:
[bnx2x_link_status_update:4481(eth15)]phy link up
Sep 27 12:51:10 debian kernel: [  109.398240] bnx2x:
[bnx2x_link_status_update:4590(eth15)]media_types = 0xf0
Sep 27 12:51:10 debian kernel: [  109.398369] bnx2x:
[bnx2x_link_status_update:4608(eth15)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:10 debian kernel: [  109.398561] bnx2x:
[bnx2x_link_status_update:4610(eth15)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:10 debian kernel: [  109.398762] bnx2x:
[bnx2x_extract_max_cfg:1490(eth15)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:10 debian kernel: [  109.398951] bnx2x 0000:05:00.7:
eth15: NIC Link is Up, 10000 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:10 debian kernel: [  109.399980] bnx2x:
[bnx2x_extract_max_cfg:1490(eth15)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:10 debian kernel: [  109.400171] bnx2x:
[bnx2x_get_settings:251(eth15)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.403232] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.403721] bnx2x:
[bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.404207] bnx2x:
[bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.404696] bnx2x:
[bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.405175] bnx2x:
[bnx2x_get_settings:251(eth4)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.405655] bnx2x:
[bnx2x_get_settings:251(eth5)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.406143] bnx2x:
[bnx2x_get_settings:251(eth6)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.406628] bnx2x:
[bnx2x_extract_max_cfg:1490(eth7)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:10 debian kernel: [  109.406819] bnx2x:
[bnx2x_get_settings:251(eth7)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.407297] bnx2x:
[bnx2x_get_settings:251(eth8)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.407780] bnx2x:
[bnx2x_get_settings:251(eth9)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.408256] bnx2x:
[bnx2x_get_settings:251(eth10)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.408743] bnx2x:
[bnx2x_get_settings:251(eth12)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.409219] bnx2x:
[bnx2x_get_settings:251(eth13)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.409752] bnx2x:
[bnx2x_get_settings:251(eth14)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.410233] bnx2x:
[bnx2x_extract_max_cfg:1490(eth15)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:10 debian kernel: [  109.410420] bnx2x:
[bnx2x_get_settings:251(eth15)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.411687] bnx2x:
[bnx2x_get_settings:251(eth14)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.451659] bnx2x:
[bnx2x_extract_max_cfg:1490(eth15)]Max BW configured to 0 - using 100
instead
Sep 27 12:51:10 debian kernel: [  109.451840] bnx2x:
[bnx2x_get_settings:251(eth15)]ethtool_cmd: cmd 1
Sep 27 12:51:10 debian kernel: [  109.486641] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:51:11 debian kernel: [  109.722478] bnx2x:
[bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
Sep 27 12:51:11 debian kernel: [  109.832402] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:51:11 debian kernel: [  109.920493] bnx2x:
[bnx2x_fw_command:2618(eth7)]wrote command (20000003) to FW MB param
0x00000000
Sep 27 12:51:11 debian kernel: [  109.931330] bnx2x:
[bnx2x_fw_command:2630(eth7)][after 10 ms] read (20120003) seq is (3)
from FW MB
Sep 27 12:51:11 debian kernel: [  109.941504] bnx2x:
[bnx2x_fw_command:2618(eth7)]wrote command (21000004) to FW MB param
0x00000000
Sep 27 12:51:11 debian kernel: [  109.963311] bnx2x:
[bnx2x_fw_command:2630(eth7)][after 20 ms] read (21100004) seq is (4)
from FW MB
Sep 27 12:51:11 debian kernel: [  109.973102] bnx2x:
[bnx2x_fw_command:2618(eth15)]wrote command (20010003) to FW MB param
0x00000000
Sep 27 12:51:11 debian kernel: [  109.983292] bnx2x:
[bnx2x_fw_command:2630(eth15)][after 10 ms] read (20120003) seq is (3)
from FW MB
Sep 27 12:51:11 debian kernel: [  109.993509] bnx2x:
[bnx2x_fw_command:2618(eth15)]wrote command (21000004) to FW MB param
0x00000000
Sep 27 12:51:11 debian kernel: [  110.015273] bnx2x:
[bnx2x_fw_command:2630(eth15)][after 20 ms] read (21100004) seq is (4)
from FW MB
Sep 27 12:51:11 debian kernel: [  110.038164] bnx2x:
[bnx2x_fw_command:2618(eth1)]wrote command (20010006) to FW MB param
0x00000000
Sep 27 12:51:11 debian kernel: [  110.049248] bnx2x:
[bnx2x_fw_command:2630(eth1)][after 10 ms] read (20120006) seq is (6)
from FW MB
Sep 27 12:51:11 debian kernel: [  110.059409] bnx2x:
[bnx2x_fw_command:2618(eth1)]wrote command (21000007) to FW MB param
0x00000000
Sep 27 12:51:11 debian kernel: [  110.059441] bnx2x:
[bnx2x_pmf_update:2569(eth3)]pmf 1
Sep 27 12:51:11 debian kernel: [  110.060451] bnx2x:
[set_phy_vars:3478(eth3)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:11 debian kernel: [  110.060634] bnx2x:
[bnx2x_link_status_update:4481(eth3)]phy link up
Sep 27 12:51:11 debian kernel: [  110.060755] bnx2x:
[bnx2x_link_status_update:4590(eth3)]media_types = 0xf0
Sep 27 12:51:11 debian kernel: [  110.060876] bnx2x:
[bnx2x_link_status_update:4608(eth3)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:11 debian kernel: [  110.061064] bnx2x:
[bnx2x_link_status_update:4610(eth3)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:11 debian kernel: [  110.061267] bnx2x:
[bnx2x_set_aer_mmd:3342(eth3)]Set AER to 0x2
Sep 27 12:51:11 debian kernel: [  110.082225] bnx2x:
[bnx2x_fw_command:2630(eth1)][after 20 ms] read (21100007) seq is (7)
from FW MB
Sep 27 12:51:11 debian kernel: [  110.090241] bnx2x:
[bnx2x_fw_command:2618(eth1)]wrote command (10000008) to FW MB param
0x00000000
Sep 27 12:51:11 debian kernel: [  110.112205] bnx2x:
[bnx2x_fw_command:2630(eth1)][after 20 ms] read (10120008) seq is (8)
from FW MB
Sep 27 12:51:11 debian kernel: [  110.112385] bnx2x:
[bnx2x_nic_load:1815(eth1)]pmf 0
Sep 27 12:51:11 debian kernel: [  110.112534] bnx2x:
[bnx2x_init_hw_func:6527(eth1)]starting func init  func 0
Sep 27 12:51:11 debian kernel: [  110.234245] bnx2x:
[bnx2x_phy_probe:11586(eth1)]Begin phy probe
Sep 27 12:51:11 debian kernel: [  110.234365] bnx2x:
[bnx2x_phy_probe:11602(eth1)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:11 debian kernel: [  110.234552] bnx2x:
[bnx2x_populate_int_phy:11230(eth1)]:chip_id = 0x168e0000
Sep 27 12:51:11 debian kernel: [  110.234672] bnx2x:
[bnx2x_populate_int_phy:11342(eth1)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:11 debian kernel: [  110.234857] bnx2x:
[bnx2x_phy_def_cfg:11499(eth1)]Default config phy idx 0 cfg 0x1000000
speed_cap_mask 0x500050
Sep 27 12:51:11 debian kernel: [  110.235040] bnx2x:
[bnx2x_phy_probe:11602(eth1)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:11 debian kernel: [  110.235226] bnx2x:
[bnx2x_phy_probe:11643(eth1)]End phy probe. #phys found 1
Sep 27 12:51:11 debian kernel: [  110.235375] bnx2x 0000:04:00.1:
eth1: using MSI-X  IRQs: sp 92  fp[0] 93 ... fp[0] 93
Sep 27 12:51:11 debian kernel: [  110.235565] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth1)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:11 debian kernel: [  110.237567] bnx2x:
[bnx2x_fw_command:2618(eth1)]wrote command (11000009) to FW MB param
0x00000000
Sep 27 12:51:11 debian kernel: [  110.248111] bnx2x:
[bnx2x_fw_command:2630(eth1)][after 10 ms] read (11100009) seq is (9)
from FW MB
Sep 27 12:51:11 debian kernel: [  110.253328] bnx2x:
[set_phy_vars:3478(eth1)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:11 debian kernel: [  110.253510] bnx2x:
[bnx2x_link_status_update:4481(eth1)]phy link up
Sep 27 12:51:11 debian kernel: [  110.253630] bnx2x:
[bnx2x_link_status_update:4590(eth1)]media_types = 0xf0
Sep 27 12:51:11 debian kernel: [  110.253752] bnx2x:
[bnx2x_link_status_update:4608(eth1)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:11 debian kernel: [  110.253936] bnx2x:
[bnx2x_link_status_update:4610(eth1)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:11 debian kernel: [  110.254136] bnx2x 0000:04:00.1:
eth1: NIC Link is Up, 8000 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:11 debian kernel: [  110.258133] bnx2x:
[bnx2x_fw_command:2618(eth9)]wrote command (20010006) to FW MB param
0x00000000
Sep 27 12:51:11 debian kernel: [  110.269099] bnx2x:
[bnx2x_fw_command:2630(eth9)][after 10 ms] read (20120006) seq is (6)
from FW MB
Sep 27 12:51:11 debian kernel: [  110.279262] bnx2x:
[bnx2x_fw_command:2618(eth9)]wrote command (21000007) to FW MB param
0x00000000
Sep 27 12:51:11 debian kernel: [  110.290970] bnx2x:
[bnx2x_pmf_update:2569(eth11)]pmf 1
Sep 27 12:51:11 debian kernel: [  110.292099] bnx2x:
[set_phy_vars:3478(eth11)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:11 debian kernel: [  110.292287] bnx2x:
[bnx2x_link_status_update:4481(eth11)]phy link up
Sep 27 12:51:11 debian kernel: [  110.292407] bnx2x:
[bnx2x_link_status_update:4590(eth11)]media_types = 0xf0
Sep 27 12:51:11 debian kernel: [  110.292527] bnx2x:
[bnx2x_link_status_update:4608(eth11)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:11 debian kernel: [  110.292708] bnx2x:
[bnx2x_link_status_update:4610(eth11)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:11 debian kernel: [  110.292900] bnx2x:
[bnx2x_set_aer_mmd:3342(eth11)]Set AER to 0x2
Sep 27 12:51:11 debian kernel: [  110.323061] bnx2x:
[bnx2x_fw_command:2630(eth9)][after 40 ms] read (21100007) seq is (7)
from FW MB
Sep 27 12:51:11 debian kernel: [  110.331137] bnx2x:
[bnx2x_fw_command:2618(eth9)]wrote command (10000008) to FW MB param
0x00000000
Sep 27 12:51:11 debian kernel: [  110.353040] bnx2x:
[bnx2x_fw_command:2630(eth9)][after 20 ms] read (10120008) seq is (8)
from FW MB
Sep 27 12:51:11 debian kernel: [  110.353459] bnx2x:
[bnx2x_nic_load:1815(eth9)]pmf 0
Sep 27 12:51:11 debian kernel: [  110.353600] bnx2x:
[bnx2x_init_hw_func:6527(eth9)]starting func init  func 0
Sep 27 12:51:11 debian kernel: [  110.475078] bnx2x:
[bnx2x_phy_probe:11586(eth9)]Begin phy probe
Sep 27 12:51:11 debian kernel: [  110.475197] bnx2x:
[bnx2x_phy_probe:11602(eth9)]phy_config_swapped 0, phy_index 0,
actual_phy_idx 0
Sep 27 12:51:11 debian kernel: [  110.475384] bnx2x:
[bnx2x_populate_int_phy:11230(eth9)]:chip_id = 0x168e0000
Sep 27 12:51:11 debian kernel: [  110.475507] bnx2x:
[bnx2x_populate_int_phy:11342(eth9)]Internal phy port=0, addr=0x1,
mdio_ctl=0x8000
Sep 27 12:51:11 debian kernel: [  110.475696] bnx2x:
[bnx2x_phy_def_cfg:11499(eth9)]Default config phy idx 0 cfg 0x0
speed_cap_mask 0x500050
Sep 27 12:51:11 debian kernel: [  110.475880] bnx2x:
[bnx2x_phy_probe:11602(eth9)]phy_config_swapped 0, phy_index 1,
actual_phy_idx 1
Sep 27 12:51:11 debian kernel: [  110.476067] bnx2x:
[bnx2x_phy_probe:11643(eth9)]End phy probe. #phys found 1
Sep 27 12:51:11 debian kernel: [  110.476210] bnx2x 0000:05:00.1:
eth9: using MSI-X  IRQs: sp 108  fp[0] 109 ... fp[0] 109
Sep 27 12:51:11 debian kernel: [  110.476399] bnx2x:
[bnx2x_get_mod_abs_int_cfg:4124(eth9)]ERROR: Invalid cfg pin 0 for
module detect indication
Sep 27 12:51:11 debian kernel: [  110.478383] bnx2x:
[bnx2x_fw_command:2618(eth9)]wrote command (11000009) to FW MB param
0x00000000
Sep 27 12:51:11 debian kernel: [  110.487954] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:51:11 debian kernel: [  110.488947] bnx2x:
[bnx2x_fw_command:2630(eth9)][after 10 ms] read (11100009) seq is (9)
from FW MB
Sep 27 12:51:11 debian kernel: [  110.494159] bnx2x:
[set_phy_vars:3478(eth9)]req_flow_ctrl 0, req_line_speed 0,
speed_cap_mask 500050
Sep 27 12:51:11 debian kernel: [  110.494338] bnx2x:
[bnx2x_link_status_update:4481(eth9)]phy link up
Sep 27 12:51:11 debian kernel: [  110.494454] bnx2x:
[bnx2x_link_status_update:4590(eth9)]media_types = 0xf0
Sep 27 12:51:11 debian kernel: [  110.494575] bnx2x:
[bnx2x_link_status_update:4608(eth9)]link_status 0x40170075
phy_link_up 1 int_mask 0x0
Sep 27 12:51:11 debian kernel: [  110.494757] bnx2x:
[bnx2x_link_status_update:4610(eth9)]line_speed 2710  duplex 1
flow_ctrl 0x300
Sep 27 12:51:11 debian kernel: [  110.494958] bnx2x 0000:05:00.1:
eth9: NIC Link is Up, 8000 Mbps full duplex, Flow control: ON -
receive & transmit
Sep 27 12:51:12 debian kernel: [  110.833720] bnx2x:
[bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
Sep 27 12:51:12 debian kernel: [  111.024452] bnx2x:
[bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
Sep 27 12:51:12 debian kernel: [  111.025673] bnx2x:
[bnx2x_get_settings:251(eth9)]ethtool_cmd: cmd 1
Sep 27 12:51:12 debian kernel: [  111.063562] bnx2x:
[bnx2x_set_aer_mmd:3342(eth3)]Set AER to 0x2
Sep 27 12:51:12 debian kernel: [  111.295402] bnx2x:
[bnx2x_set_aer_mmd:3342(eth11)]Set AER to 0x2
Sep 27 12:51:13 debian kernel: [  111.489269] bnx2x:
[bnx2x_set_aer_mmd:3342(eth8)]Set AER to 0x0
Sep 27 12:51:13 debian kernel: [  111.499591] bnx2x:
[bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1

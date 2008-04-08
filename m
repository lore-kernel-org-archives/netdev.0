From: Patrick McHardy <kaber@trash.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Tue, 08 Apr 2008 22:18:18 +0200
Message-ID: <47FBD30A.1010003@trash.net>
References: <1203589042.17534.145.camel@johannes.berg>	 <1203616486.7181.269.camel@localhost>	<47BDBC23.5080007@trash.net>	 <20080223.200202.255773165.davem@davemloft.net>	 <47C2AAC8.8020202@trash.net> <1203969502.19319.279.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000001040502040703030306"
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	harvey.harrison@gmail.com, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50908 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbYDHUSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 16:18:25 -0400
In-Reply-To: <1203969502.19319.279.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000001040502040703030306
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Joe Perches wrote:
> On Mon, 2008-02-25 at 12:47 +0100, Patrick McHardy wrote: 
>> It would be good if Joe could go through the remaining print_mac users
>> and convert the remaining unintended function calls in fastpaths back
>> to MAC_FMT. Grepping for "start_xmit" in commit 0795af5729b shows that
>> at least 10 hard_start_xmit functions are affected and I expect that
>> some of the changes in the wireless code affect fastpaths as well.
> 
> I don't mind doing that, as calling print_mac in these fastpaths in
> unintentional and undesirable.


Unfortunately the current tree still includes all the fallout,
are you planning on cleaning this up again any time soon?

I've attached a codiff of a tree with and without this change
(might not include all drivers, but I think I enabled all that
build on x86_64). The _probe and _init_one functions should
be harmless, but there are lots of functions that look like
they would prefer to avoid useless overhead. A small sample:

drivers/net/starfire.c:
   netdev_poll       |  +50

drivers/net/tokenring/olympic.c:
   olympic_interrupt |  +10

drivers/net/wan/pc300_drv.c:
   cpc_net_rx |  +11

drivers/net/wireless/ipw2200.c:
   ipw_net_hard_start_xmit |  +32

drivers/net/wireless/hostap/hostap_80211_rx.c:
   hostap_rx_frame_decrypt |  +27
   hostap_80211_rx         |  +96

drivers/net/wireless/hostap/hostap_80211_tx.c:
   hostap_master_start_xmit |  +18

drivers/net/wireless/hostap/hostap_ap.c:
   hostap_handle_sta_tx_exc |  +13
   hostap_ap_tx_cb_poll     |   +9
   hostap_rx                | +254
   hostap_ap_tx_cb_auth     |  +62
   hostap_ap_tx_cb_assoc    |  +26
   hostap_handle_sta_tx     |  +90
   hostap_handle_sta_rx     |  +63

<lots more wireless>

drivers/net/virtio_net.c:
   start_xmit |  +19

net/atm/lec.c:
   lec_start_xmit | +118
   lec_atm_send   |   +2

net/ieee80211/ieee80211_rx.c:
   ieee80211_rx |  +32



--------------000001040502040703030306
Content-Type: text/plain;
 name="diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="diff"

drivers/net/e1000/e1000_main.c:
  e1000_probe |  +32
 1 function changed, 32 bytes added

drivers/net/bonding/bond_main.c:
  bond_info_seq_show |  +14
  bond_release       |  +12
 2 functions changed, 26 bytes added

drivers/net/bonding/bond_sysfs.c:
  bonding_show_ad_partner_mac |  +29
 1 function changed, 29 bytes added

drivers/net/rrunner.c:
  rr_init_one |  +30
 1 function changed, 30 bytes added

drivers/net/sunhme.c:
  happy_meal_pci_probe |  +16
 1 function changed, 16 bytes added

drivers/net/sungem.c:
  gem_init_one |  +16
 1 function changed, 16 bytes added

drivers/net/cassini.c:
  cas_init_one |   +3
 1 function changed, 3 bytes added

drivers/net/3c59x.c:
  vortex_probe1 |  +16
 1 function changed, 16 bytes added

drivers/net/typhoon.c:
  typhoon_init_one |  +51
 1 function changed, 51 bytes added

drivers/net/ne2k-pci.c:
  ne2k_pci_init_one |  +42
 1 function changed, 42 bytes added

drivers/net/pcnet32.c:
  pcnet32_probe1 |  +32
 1 function changed, 32 bytes added

drivers/net/eepro100.c:
  eepro100_init_one |  +21
 1 function changed, 21 bytes added

drivers/net/e100.c:
  e100_probe |  +12
 1 function changed, 12 bytes added

drivers/net/epic100.c:
  epic_init_one |  +16
 1 function changed, 16 bytes added

drivers/net/sis190.c:
  sis190_init_one |  +31
 1 function changed, 31 bytes added

drivers/net/sis900.c:
  sis900_probe |  +44
 1 function changed, 44 bytes added

drivers/net/yellowfin.c:
  yellowfin_init_one |  +76
 1 function changed, 76 bytes added

drivers/net/acenic.c:
  acenic_probe_one |  +17
 1 function changed, 17 bytes added

drivers/net/natsemi.c:
  natsemi_probe1 |  +31
 1 function changed, 31 bytes added

drivers/net/ns83820.c:
  ns83820_init_one |  +30
 1 function changed, 30 bytes added

drivers/net/fealnx.c:
  fealnx_init_one |  +45
 1 function changed, 45 bytes added

drivers/net/tg3.c:
  tg3_init_one | +112
 1 function changed, 112 bytes added

drivers/net/bnx2.c:
  bnx2_init_one |  +81
 1 function changed, 81 bytes added

drivers/net/bnx2x.c:
  bnx2x_init_one |  +16
 1 function changed, 16 bytes added

drivers/net/skge.c:
  skge_show_addr |  +22
 1 function changed, 22 bytes added

drivers/net/sky2.c:
  sky2_show_addr |  +22
 1 function changed, 22 bytes added

drivers/net/via-rhine.c:
  rhine_init_one |  +23
 1 function changed, 23 bytes added

drivers/net/starfire.c:
  netdev_poll       |  +50
  starfire_init_one |  +16
 2 functions changed, 66 bytes added

drivers/net/sundance.c:
  sundance_probe1 |  +34
 1 function changed, 34 bytes added

drivers/net/hamachi.c:
  hamachi_init_one |  +13
 1 function changed, 13 bytes added

drivers/net/b44.c:
  b44_init_one |  +18
 1 function changed, 18 bytes added

drivers/net/forcedeth.c:
  nv_probe |  +48
 1 function changed, 48 bytes added

drivers/net/qla3xxx.c:
  ql3xxx_probe |   +4
 1 function changed, 4 bytes added

drivers/net/pppoe.c:
  pppoe_seq_show |  +39
 1 function changed, 39 bytes added

drivers/net/de600.c:
  de600_init |  +26
 1 function changed, 26 bytes added

drivers/net/de620.c:
  de620_probe |  +16
 1 function changed, 16 bytes added

drivers/net/8139cp.c:
  cp_init_one |  +32
 1 function changed, 32 bytes added

drivers/net/8139too.c:
  rtl8139_init_one |  +74
 1 function changed, 74 bytes added

drivers/net/atp.c:
  atp_probe1 |   +8
 1 function changed, 8 bytes added

drivers/net/dl2k.c:
  rio_probe1 |  +16
 1 function changed, 16 bytes added

drivers/net/amd8111e.c:
  amd8111e_probe_one |  +16
 1 function changed, 16 bytes added

drivers/net/s2io.c:
  s2io_init_nic |   +3
 1 function changed, 3 bytes added

drivers/net/myri10ge/myri10ge.c:
  myri10ge_set_multicast_list |  +16
 1 function changed, 16 bytes added

drivers/net/tokenring/olympic.c:
  olympic_proc_info | +310
  olympic_open      |  +76
  olympic_interrupt |  +10
 3 functions changed, 396 bytes added

drivers/net/tokenring/abyss.c:
  abyss_attach |  +15
 1 function changed, 15 bytes added

drivers/net/tokenring/tmspci.c:
  tms_pci_attach |  +16
 1 function changed, 16 bytes added

drivers/net/wan/pc300_drv.c:
  cpc_net_rx |  +11
 1 function changed, 11 bytes added

drivers/net/wan/wanxl.c:
  wanxl_pci_init_one |   -3
 1 function changed, 3 bytes removed

drivers/net/usb/pegasus.c:
  pegasus_probe |  +69
 1 function changed, 69 bytes added

drivers/net/usb/usbnet.c:
  usbnet_probe |  +13
 1 function changed, 13 bytes added

drivers/net/wireless/ipw2100.c:
  show_bssinfo |  +21
 1 function changed, 21 bytes added

drivers/net/wireless/ipw2200.c:
  ipw_send_disassociate   |  +46
  ipw_associate_network   |  +18
  ipw_debug_config        |  +32
  ipw_best_network        | +241
  ipw_up                  |   +9
  ipw_add_station         |  +15
  ipw_rx_notification     | +139
  ipw_wx_set_wap          |   +8
  ipw_wx_get_wap          |  +20
  ipw_net_hard_start_xmit |  +32
  ipw_net_set_mac_address |   +9
  ipw_irq_tasklet         |  +29
 12 functions changed, 598 bytes added

drivers/net/wireless/orinoco.c:
  orinoco_init |  +80
 1 function changed, 80 bytes added

drivers/net/wireless/airo.c:
  reset_airo_card   |  +14
  _init_airo_card   |  +17
  proc_APList_open  |  +14
  proc_BSSList_open |  +46
 4 functions changed, 91 bytes added

drivers/net/wireless/atmel.c:
  init_atmel_card |   +5
 1 function changed, 5 bytes added

drivers/net/wireless/prism54/isl_ioctl.c:
  send_formatted_event |  +25
  prism54_process_trap |  +41
 2 functions changed, 66 bytes added

drivers/net/wireless/hostap/hostap_80211_rx.c:
  hostap_dump_rx_80211    |  +34
  hostap_rx_frame_decrypt |  +27
  hostap_80211_rx         |  +96
 3 functions changed, 157 bytes added

drivers/net/wireless/hostap/hostap_80211_tx.c:
  hostap_dump_tx_80211     |  +29
  hostap_master_start_xmit |  +18
 2 functions changed, 47 bytes added

drivers/net/wireless/hostap/hostap_ap.c:
  ap_sta_hash_del          |  +29
  hostap_handle_sta_tx_exc |  +13
  ap_free_sta              |   -5
  prism2_ap_proc_read      |  +28
  ap_control_proc_read     |  +26
  handle_assoc             |  +48
  hostap_ap_tx_cb_poll     |   +9
  hostap_rx                | +254
  handle_wds_oper_queue    |  +28
  hostap_ap_tx_cb_auth     |  +62
  hostap_ap_tx_cb_assoc    |  +26
  handle_add_proc_queue    |  -11
  hostap_handle_sta_tx     |  +90
  hostap_handle_sta_rx     |  +63
  prism2_sta_proc_read     | +150
  ap_handle_timer          |  +36
 16 functions changed, 862 bytes added, 16 bytes removed, diff: +846

drivers/net/wireless/hostap/hostap_info.c:
  prism2_host_roaming |  +37
  handle_info_queue   |  -16
 2 functions changed, 37 bytes added, 16 bytes removed, diff: +21

drivers/net/wireless/hostap/hostap_ioctl.c:
  hostap_ioctl       |  +17
  prism2_ioctl_siwap |  +29
 2 functions changed, 46 bytes added

drivers/net/wireless/hostap/hostap_main.c:
  hostap_dump_tx_header | +201
  hostap_dump_rx_header | +125
 2 functions changed, 326 bytes added

drivers/net/wireless/hostap/hostap_proc.c:
  prism2_scan_results_proc_read |   -9
  prism2_bss_list_proc_read     |  +36
  prism2_wds_proc_read          |  +12
 3 functions changed, 48 bytes added, 9 bytes removed, diff: +39

drivers/net/wireless/hostap/hostap_plx.c:
  hostap_bap_tasklet |  +19
 1 function changed, 19 bytes added

drivers/net/wireless/hostap/hostap_pci.c:
  hostap_bap_tasklet |  +32
 1 function changed, 32 bytes added

drivers/net/wireless/libertas/cmd.c:
  lbs_update_hw_spec |  +81
 1 function changed, 81 bytes added

drivers/net/wireless/libertas/debugfs.c:
  lbs_getscantable |   +9
 1 function changed, 9 bytes added

drivers/net/wireless/rtl8180_dev.c:
  rtl8180_probe |  +13
 1 function changed, 13 bytes added

drivers/net/wireless/rtl8187_dev.c:
  rtl8187_probe |   +7
 1 function changed, 7 bytes added

drivers/net/wireless/adm8211.c:
  adm8211_probe |  +28
 1 function changed, 28 bytes added

drivers/net/wireless/iwlwifi/iwl3945-base.c:
  iwl3945_add_station          |   +7
  iwl3945_commit_rxon          |  +33
  iwl3945_mac_tx               |  +69
  iwl3945_mac_set_key          |  +22
  iwl3945_pci_probe            |  +17
  iwl3945_bg_post_associate    |  -24
  iwl3945_mac_add_interface    |   +4
  iwl3945_mac_config_interface |  +31
 8 functions changed, 183 bytes added, 24 bytes removed, diff: +159

drivers/net/wireless/iwlwifi/iwl-3945.c:
  iwl3945_rx_reply_rx     | +161
  iwl3945_hw_find_station |  +24
 2 functions changed, 185 bytes added

drivers/net/wireless/iwlwifi/iwl-3945-rs.c:
  rs_get_rate |  -16
 1 function changed, 16 bytes removed

drivers/net/wireless/iwlwifi/iwl4965-base.c:
  iwl4965_add_station_flags    |  +12
  iwl4965_commit_rxon          |  +16
  iwl4965_mac_tx               |  +31
  iwl4965_mac_set_key          |  +22
  iwl4965_pci_probe            |  +16
  iwl4965_bg_post_associate    |  -19
  iwl4965_mac_add_interface    |   +4
  iwl4965_mac_config_interface |  +31
 8 functions changed, 132 bytes added, 19 bytes removed, diff: +113

drivers/net/wireless/iwlwifi/iwl-4965.c:
  iwl4965_hw_find_station |  +17
  iwl4965_rx_reply_rx     | +167
 2 functions changed, 184 bytes added

drivers/net/wireless/iwlwifi/iwl-4965-rs.c:
  rs_rate_init |  +30
  rs_get_rate  |  +10
 2 functions changed, 40 bytes added

drivers/net/wireless/p54usb.c:
  p54u_probe |  +41
 1 function changed, 41 bytes added

drivers/net/wireless/p54pci.c:
  p54p_probe |  +44
 1 function changed, 44 bytes added

drivers/net/tulip/dmfe.c:
  dmfe_init_one |  +25
 1 function changed, 25 bytes added

drivers/net/tulip/winbond-840.c:
  w840_probe1  |  +16
  intr_handler | +112
 2 functions changed, 128 bytes added

drivers/net/tulip/de2104x.c:
  de_init_one |  +23
 1 function changed, 23 bytes added

drivers/net/tulip/tulip_core.c:
  set_rx_mode    |  +16
  tulip_init_one |  +60
 2 functions changed, 76 bytes added

drivers/net/tulip/de4x5.c:
  DevicePresent   |  +11
  de4x5_interrupt |   -2
  de4x5_pci_probe |  +32
 3 functions changed, 43 bytes added, 2 bytes removed, diff: +41

drivers/net/tulip/uli526x.c:
  uli526x_init_one |   +9
 1 function changed, 9 bytes added

drivers/net/netconsole.c:
  show_remote_mac |  +16
  show_local_mac  |  +13
 2 functions changed, 29 bytes added

drivers/net/netxen/netxen_nic_main.c:
  netxen_nic_probe |  +45
 1 function changed, 45 bytes added

drivers/net/netxen/netxen_nic_init.c:
  netxen_rom_se |   +3
 1 function changed, 3 bytes added

drivers/net/netxen/netxen_nic_niu.c:
  netxen_niu_macaddr_set |  +21
 1 function changed, 21 bytes added

drivers/net/niu.c:
  niu_pci_init_one |  +35
 1 function changed, 35 bytes added

drivers/net/virtio_net.c:
  start_xmit |  +19
 1 function changed, 19 bytes added

net/core/pktgen.c:
  pktgen_if_show |  +88
 1 function changed, 88 bytes added

net/core/netpoll.c:
  netpoll_print_options |  +17
 1 function changed, 17 bytes added

net/llc/llc_proc.c:
  llc_ui_format_mac |  +21
 1 function changed, 21 bytes added

net/ethernet/eth.c:
  sysfs_format_mac | -115
 1 function changed, 115 bytes removed

net/802/tr.c:
  rif_seq_show |   +6
 1 function changed, 6 bytes added

net/appletalk/aarp.c:
  aarp_seq_show |  +15
 1 function changed, 15 bytes added

net/atm/br2684.c:
  br2684_seq_show |  +17
 1 function changed, 17 bytes added

net/atm/lec.c:
  lec_start_xmit | +118
  lec_atm_send   |   +2
 2 functions changed, 120 bytes added

net/mac80211/ieee80211.c:
  ieee80211_if_update_wds |  +14
 1 function changed, 14 bytes added

net/mac80211/sta_info.c:
  sta_info_cleanup |  +24
 1 function changed, 24 bytes added

net/mac80211/wpa.c:
  ieee80211_rx_h_michael_mic_verify |  +11
 1 function changed, 11 bytes added

net/mac80211/ieee80211_sta.c:
  ieee80211_handle_erp_ie      |  +28
  ieee80211_associate          |  +15
  ieee80211_sta_find_ibss      |  +20
  ieee80211_rx_bss_info        |  +16
  ieee80211_associated         |  +16
  ieee80211_rx_mgmt_assoc_resp |  +96
  ieee80211_ibss_add_sta       |  +23
  ieee80211_sta_work           | -3608
  ieee80211_sta_scan_results   |   -4
 9 functions changed, 214 bytes added, 3612 bytes removed, diff: -3398

net/mac80211/rx.c:
  ieee80211_data_to_8023       | +262
  __ieee80211_rx_handle_packet |  +48
  ieee80211_rx_h_defragment    |  +82
 3 functions changed, 392 bytes added

net/mac80211/tx.c:
  ieee80211_tx_h_ps_buf |   +8
 1 function changed, 8 bytes added

net/mac80211/key.c:
  ieee80211_key_disable_hw_accel |  +24
  ieee80211_key_enable_hw_accel  |  +15
 2 functions changed, 39 bytes added

net/mac80211/event.c:
  mac80211_ev_michael_mic_failure |  +14
 1 function changed, 14 bytes added

net/ieee80211/ieee80211_rx.c:
  ieee80211_rx |  +32
 1 function changed, 32 bytes added

net/ieee80211/ieee80211_crypt_ccmp.c:
  ieee80211_ccmp_decrypt | +114
 1 function changed, 114 bytes added

net/ieee80211/ieee80211_crypt_tkip.c:
  ieee80211_michael_mic_verify |  +37
  ieee80211_tkip_decrypt       |  +95
  ieee80211_tkip_encrypt       |  +43
 3 functions changed, 175 bytes added

net/ieee80211/softmac/ieee80211softmac_auth.c:
  ieee80211softmac_auth_queue |  -53
  ieee80211softmac_auth_resp  | +111
 2 functions changed, 111 bytes added, 53 bytes removed, diff: +58

net/ethernet/eth.c:
  print_mac |  +27
 1 function changed, 27 bytes added

vmlinux.with:
 190 functions changed, 7138 bytes added, 3885 bytes removed, diff: +3253

--------------000001040502040703030306--

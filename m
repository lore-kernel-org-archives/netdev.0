From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: Re: [PATCH V3.18] rtlwifi: Add check for get_btc_status callback
Date: Thu, 23 Oct 2014 20:08:51 +0200
Message-ID: <1414087731.5231.19.camel@marge.simpson.net>
References: <1414081629-23002-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	troy_tan@realsil.com.cn, netdev@vger.kernel.org,
	Murilo Opsfelder Araujo <mopsfelder@gmail.com>,
	Thadeu Cascardo <cascardo@cascardo.eti.br>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:44680 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293AbaJWSI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 14:08:59 -0400
In-Reply-To: <1414081629-23002-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-23 at 11:27 -0500, Larry Finger wrote:=20
> Drivers that do not use the get_btc_status() callback may not define =
a
> dummy routine. The caller needs to check before making the call.

Ok, seems this has little to do with my lappy explosion.  Reverting the
bisected commit will kill the initial spew, terminal wq illness remains
w/wo this patchlet.  (joy, multiple troubles, with a thermonuclear i915
thingy somewhere in between.. woohoo:)

v3.18-rc1-221-gc3351dfabf5c + only this patch

[   20.177519] rtl8192se 0000:08:00.0: enabling device (0000 -> 0003)
[   20.219507] rtl8192se: FW Power Save off (module option)
[   20.221726] rtl8192se: Driver for Realtek RTL8192SE/RTL8191SE
[   20.221726] Loading firmware rtlwifi/rtl8192sefw.bin
[   20.264163] ieee80211 phy0: Selected rate control algorithm 'rtl_rc'
[   20.267819] ------------[ cut here ]------------
[   20.269885] WARNING: CPU: 0 PID: 53 at fs/sysfs/dir.c:31 sysfs_warn_=
dup+0x68/0x80()
[   20.271953] sysfs: cannot create duplicate filename '/devices/pci000=
0:00/0000:00:1c.5/0000:08:00.0/ieee80211/phy0'
[   20.274093] Modules linked in: arc4 rtl8192se rtl_pci rtlwifi mac802=
11 snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_codec_generic snd_=
hda_intel snd_hda_controller snd_hda_codec uvcvideo cfg80211 snd_hwdep =
snd_pcm iTCO_wdt iTCO_vendor_support coretemp videobuf2_core v4l2_commo=
n videodev btusb snd_seq snd_timer snd_seq_device microcode snd bluetoo=
th lpc_ich mfd_core serio_raw i2c_i801 videobuf2_vmalloc videobuf2_memo=
ps joydev toshiba_acpi toshiba_haps toshiba_bluetooth sparse_keymap bat=
tery soundcore rfkill wmi ac acpi_cpufreq sg autofs4 i915 drm_kms_helpe=
r drm i2c_algo_bit thermal video processor thermal_sys button scsi_dh_r=
dac scsi_dh_alua scsi_dh_emc scsi_dh_hp_sw scsi_dh netconsole atl1c
[   20.286147] CPU: 0 PID: 53 Comm: kworker/0:3 Not tainted 3.18.0-mast=
er #52
[   20.288549] Hardware name: TOSHIBA =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD/=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD, BIOS V1.70    09/29/2009
[   20.291160] Workqueue: events request_firmware_work_func
[   20.293784]  0000000000000009 ffff8801360e7a98 ffffffff815878e0 0000=
000000000001
[   20.296463]  ffff8801360e7ae8 ffff8801360e7ad8 ffffffff8104c801 0000=
0000000035e0
[   20.299109]  ffff8800aff78000 ffff8800370dcce0 ffff880037080cd0 ffff=
88013b027098
[   20.301755] Call Trace:
[   20.304390]  [<ffffffff815878e0>] dump_stack+0x46/0x58
[   20.307010]  [<ffffffff8104c801>] warn_slowpath_common+0x81/0xa0
[   20.309570]  [<ffffffff8104c866>] warn_slowpath_fmt+0x46/0x50
[   20.312052]  [<ffffffff811d06c8>] ? kernfs_path+0x48/0x60
[   20.314502]  [<ffffffff811d3b48>] sysfs_warn_dup+0x68/0x80
[   20.316929]  [<ffffffff811d3bee>] sysfs_create_dir_ns+0x8e/0xa0
[   20.319368]  [<ffffffff81286879>] kobject_add_internal+0xc9/0x400
[   20.321809]  [<ffffffff81286fe0>] kobject_add+0x60/0xb0
[   20.324220]  [<ffffffff8158c226>] ? mutex_lock+0x16/0x37
[   20.326580]  [<ffffffff81380d54>] device_add+0x104/0x600
[   20.328963]  [<ffffffff8114b98e>] ? lazy_max_pages+0x1e/0x30
[   20.331391]  [<ffffffffa035ad0d>] wiphy_register+0x3fd/0x710 [cfg802=
11]
[   20.333816]  [<ffffffff8114d352>] ? __vunmap+0xc2/0x110
[   20.336289]  [<ffffffffa048fcfc>] ? ieee80211_register_hw+0x1ec/0x9a=
0 [mac80211]
[   20.338758]  [<ffffffffa048fe78>] ieee80211_register_hw+0x368/0x9a0 =
[mac80211]
[   20.341239]  [<ffffffffa045826b>] rtl92se_fw_cb+0xab/0x1d0 [rtl8192s=
e]
[   20.343651]  [<ffffffff81393d80>] request_firmware_work_func+0x30/0x=
60
[   20.346048]  [<ffffffff8106270d>] process_one_work+0x14d/0x3d0
[   20.348423]  [<ffffffff81062ab1>] worker_thread+0x121/0x480
[   20.350790]  [<ffffffff81062990>] ? process_one_work+0x3d0/0x3d0
[   20.353119]  [<ffffffff81067319>] kthread+0xc9/0xe0
[   20.355442]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   20.357790]  [<ffffffff8158e26c>] ret_from_fork+0x7c/0xb0
[   20.360083]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   20.362342] ---[ end trace 637e034763f6c493 ]---
[   20.364597] ------------[ cut here ]------------
[   20.366837] WARNING: CPU: 0 PID: 53 at lib/kobject.c:240 kobject_add=
_internal+0x294/0x400()
[   20.369111] kobject_add_internal failed for phy0 with -EEXIST, don't=
 try to register things with the same name in the same directory.
[   20.371446] Modules linked in: arc4 rtl8192se rtl_pci rtlwifi mac802=
11 snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_codec_generic snd_=
hda_intel snd_hda_controller snd_hda_codec uvcvideo cfg80211 snd_hwdep =
snd_pcm iTCO_wdt iTCO_vendor_support coretemp videobuf2_core v4l2_commo=
n videodev btusb snd_seq snd_timer snd_seq_device microcode snd bluetoo=
th lpc_ich mfd_core serio_raw i2c_i801 videobuf2_vmalloc videobuf2_memo=
ps joydev toshiba_acpi toshiba_haps toshiba_bluetooth sparse_keymap bat=
tery soundcore rfkill wmi ac acpi_cpufreq sg autofs4 i915 drm_kms_helpe=
r drm i2c_algo_bit thermal video processor thermal_sys button scsi_dh_r=
dac scsi_dh_alua scsi_dh_emc scsi_dh_hp_sw scsi_dh netconsole atl1c
[   20.384614] CPU: 0 PID: 53 Comm: kworker/0:3 Tainted: G        W    =
  3.18.0-master #52
[   20.387260] Hardware name: TOSHIBA =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD/=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD, BIOS V1.70    09/29/2009
[   20.389952] Workqueue: events request_firmware_work_func
[   20.392570]  0000000000000009 ffff8801360e7af8 ffffffff815878e0 0000=
000000000001
[   20.395169]  ffff8801360e7b48 ffff8801360e7b38 ffffffff8104c801 ffff=
8801360e7b38
[   20.397690]  ffff8800afe60350 00000000ffffffef ffff8800af8d2240 ffff=
88013b027098
[   20.400148] Call Trace:
[   20.402493]  [<ffffffff815878e0>] dump_stack+0x46/0x58
[   20.404838]  [<ffffffff8104c801>] warn_slowpath_common+0x81/0xa0
[   20.407153]  [<ffffffff8104c866>] warn_slowpath_fmt+0x46/0x50
[   20.409412]  [<ffffffff81286a44>] kobject_add_internal+0x294/0x400
[   20.411635]  [<ffffffff81286fe0>] kobject_add+0x60/0xb0
[   20.413849]  [<ffffffff8158c226>] ? mutex_lock+0x16/0x37
[   20.416054]  [<ffffffff81380d54>] device_add+0x104/0x600
[   20.418216]  [<ffffffff8114b98e>] ? lazy_max_pages+0x1e/0x30
[   20.420403]  [<ffffffffa035ad0d>] wiphy_register+0x3fd/0x710 [cfg802=
11]
[   20.422571]  [<ffffffff8114d352>] ? __vunmap+0xc2/0x110
[   20.424785]  [<ffffffffa048fcfc>] ? ieee80211_register_hw+0x1ec/0x9a=
0 [mac80211]
[   20.427006]  [<ffffffffa048fe78>] ieee80211_register_hw+0x368/0x9a0 =
[mac80211]
[   20.429259]  [<ffffffffa045826b>] rtl92se_fw_cb+0xab/0x1d0 [rtl8192s=
e]
[   20.431502]  [<ffffffff81393d80>] request_firmware_work_func+0x30/0x=
60
[   20.433750]  [<ffffffff8106270d>] process_one_work+0x14d/0x3d0
[   20.435988]  [<ffffffff81062ab1>] worker_thread+0x121/0x480
[   20.438264]  [<ffffffff81062990>] ? process_one_work+0x3d0/0x3d0
[   20.440533]  [<ffffffff81067319>] kthread+0xc9/0xe0
[   20.442772]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   20.445056]  [<ffffffff8158e26c>] ret_from_fork+0x7c/0xb0
[   20.447328]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   20.449599] ---[ end trace 637e034763f6c494 ]---
[   20.451838] rtl8192se:rtl92se_fw_cb():<0-0> Can't register mac80211 =
hw
[   21.235493] EXT4-fs (sda1): mounted filesystem with ordered data mod=
e. Opts: acl
[   25.962837] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.964418] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.965914] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.967374] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.968842] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.970252] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.971618] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.972974] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.974297] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.975598] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.976878] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.978133] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.979362] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.980560] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.981742] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.982878] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.983985] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.985091] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.986211] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.987274] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.988320] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.989354] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.990357] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.991309] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.992243] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.993119] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.993991] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.994826] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.995648] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.996471] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.997308] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.998139] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.998944] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   25.999745] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.000501] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.001254] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.001997] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.002731] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.003427] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.004084] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.004715] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.005324] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.005873] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.006408] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.006900] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.007390] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.007874] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.008343] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.008743] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.009151] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.009535] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.009917] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.010306] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.010717] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.011108] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.011498] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.011910] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.012335] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.012721] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.013107] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.013493] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.013895] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.014279] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.014657] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.015041] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.015441] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.015838] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.016220] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.016608] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.016983] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.017365] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.017764] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.018143] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.018545] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.018963] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.019367] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.019744] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.020120] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.020504] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.020898] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.021264] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.021644] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.022014] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.022410] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.022776] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.023135] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.023496] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.023850] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.024248] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.024608] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.024980] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.025334] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.025706] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.026061] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.026450] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.026839] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.027231] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.027630] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.028015] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.028379] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.028777] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.029148] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.029515] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.029872] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.030239] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.030599] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.030953] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.031309] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.031665] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.032035] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.032394] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.032765] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.033146] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.033534] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.033889] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.034246] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.034614] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.034981] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.035336] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.035701] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.036064] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.036428] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.036832] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.037214] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.037570] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.037929] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.038288] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.038676] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.039032] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.039402] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.039760] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.040130] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.040507] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.040902] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.041259] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.041617] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.042000] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.042388] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.042760] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.043116] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.043489] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.043865] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.044263] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.044628] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.044994] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.045382] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.045739] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.046098] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.046459] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.046819] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.047174] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.047534] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.047890] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.048257] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.048621] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.049021] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.049390] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.049743] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.050126] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.050483] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.050865] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.051229] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.051588] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.051943] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.052337] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.052701] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.053062] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.053430] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.053786] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.054142] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.054508] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.054862] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.055246] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.055631] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.055988] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.056354] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.056722] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.057108] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.057487] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.057873] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.058232] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.058622] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.058979] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.059365] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.059738] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.060108] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.060473] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.060857] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.061212] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.061612] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.061996] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.062377] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.062750] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.063106] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.063463] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.063845] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.064219] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.064596] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.064984] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.065347] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.065744] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.066119] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.066478] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.066840] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.067199] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.067577] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.067964] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.068357] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.068750] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.069122] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.069501] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.069892] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.070267] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.070632] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.071019] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.071381] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.071747] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.072143] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.072514] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.072884] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.073241] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.073635] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.073995] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.074361] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.074726] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.075109] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.075475] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.075835] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.076199] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.076565] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.076950] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.077307] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.077687] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.078040] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.078400] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.078762] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.079116] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.079475] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.079832] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.080205] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.080567] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.080952] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.081310] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.081676] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.082046] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.082408] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.082764] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.083123] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.083491] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.083852] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.084240] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.084625] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.084979] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.085334] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.085689] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.086064] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.086430] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.086784] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.087142] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.087499] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.087882] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.088249] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.088609] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.088977] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.089357] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.089723] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.090075] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.090430] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.090800] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.091148] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.091527] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.091881] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.092253] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.092642] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.093008] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.093373] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.093754] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.094138] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.094502] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.094886] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.095272] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.095661] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.096051] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.096427] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.096814] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.097173] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.097533] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.097889] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.098246] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.098602] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.098958] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.099315] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.099671] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.100048] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.100418] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.100803] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.101191] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.101550] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.101907] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.102282] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.102654] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.103012] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.103383] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.103740] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.104116] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.104488] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.104847] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.105212] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.105596] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.105980] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.106338] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.106722] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.107081] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.107468] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.107827] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.108206] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.108586] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.108945] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.109301] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.109691] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.110062] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.110449] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.110818] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.111177] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.111539] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.111906] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.112283] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.112684] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.113049] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.113407] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.113764] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.114121] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.114483] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.114842] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.115211] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.115580] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.115974] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.116370] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.116754] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.117116] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.117493] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.117853] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.118210] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.118582] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.118964] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.119391] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.119752] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.120123] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.120487] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.120857] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.121214] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.121599] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.121970] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.122393] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.122797] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.123195] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.123553] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.123946] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.124350] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.124777] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.125140] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.125500] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.125855] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.126242] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.126602] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.126998] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.127383] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.127801] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.128205] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.128604] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.129014] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.129417] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.129786] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.130172] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.130526] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.130888] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.131252] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.131606] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.131965] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.132330] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.132703] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.133076] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.133443] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.133798] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.134154] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.134522] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.134875] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.135266] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.135624] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.135984] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.136351] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.136740] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.137105] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.137463] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.137818] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.138170] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.138535] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.138896] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.139279] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.139649] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.140014] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.140373] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.140734] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.141087] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.141454] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.141812] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.142192] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.142548] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.142912] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.143283] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.143682] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.144055] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.144428] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.144819] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.145201] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.145569] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.145929] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.146298] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.146681] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.147040] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.147425] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.147791] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.148158] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.148547] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.148938] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.149297] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.149671] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.150054] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.150415] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.150771] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.151134] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.151526] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.151913] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.152289] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.152678] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.153062] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.153422] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.153807] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.154167] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.154550] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.154908] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.155267] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.155664] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.156045] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.156438] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.156795] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.157158] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.157528] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.157906] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.158277] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.158660] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.159042] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.159398] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.159756] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.160149] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.160514] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.160904] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.161286] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.161655] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.162012] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.162372] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.162727] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.163087] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.163439] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.163803] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.164198] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.164582] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.164939] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.165296] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.165669] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.166064] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.166419] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.166802] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.167156] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.167539] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.167895] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.168260] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.168623] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.168990] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.169372] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.169754] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.170128] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.170485] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.170844] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.171210] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.171570] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.171950] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.172313] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.172699] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.173057] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.173423] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.173777] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.174142] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.174527] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.174882] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.175263] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.175648] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.176021] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.176384] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.176769] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.177134] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.177492] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.177862] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.178217] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.178576] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.178933] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.179297] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.179652] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.180042] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.180413] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.180772] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.181130] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.181489] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.181856] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.182238] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.182596] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.182956] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.183311] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.183664] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.184043] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.184426] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.184799] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.185181] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.185552] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.185909] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.186265] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.186629] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.186985] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.187365] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.187717] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.188090] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.188491] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.188857] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.189214] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.189574] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.189929] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.190285] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.190669] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.191026] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.191389] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.191742] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.192134] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.192517] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.192876] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.193235] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.193616] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.193973] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.194352] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.194733] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.195086] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.195455] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.195814] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.196179] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.196555] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.196912] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.197270] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.197627] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.198012] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.198399] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.198761] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.199148] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.199508] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.199878] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.200261] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.200639] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.201006] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.201377] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.201736] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.202119] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.202492] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.202852] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.203212] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.203596] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.203960] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.204325] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.204720] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.205077] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.205436] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.205801] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.206171] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.206553] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.206909] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.207267] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.207639] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.208019] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.208409] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.208786] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.209141] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.209520] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.209873] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.210226] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.210583] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.210937] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.211317] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.211681] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.212049] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.212433] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.212794] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.213188] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.213571] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.213926] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.214281] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.214638] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.215016] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.215395] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.215747] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.216110] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.216497] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.216864] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.217260] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.217625] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.218007] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.218364] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.218721] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.219105] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.219489] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.219872] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.220252] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.220621] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.221015] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.221385] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.221756] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.222113] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.222481] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.222836] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.223204] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.223561] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.223919] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.224287] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.224654] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.225019] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.225403] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.225763] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.226135] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.226503] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.226887] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.227271] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.227641] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.227999] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.228395] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.228757] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.229116] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.229509] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.229883] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.230249] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.230607] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.230990] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.231349] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.231705] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.232071] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.232462] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.232822] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.233177] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.233572] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.233933] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.234289] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.234654] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.235009] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.235369] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.235748] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.236120] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.236479] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.236859] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.237210] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.237581] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.237935] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.238298] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.238651] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.239004] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.239360] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.239727] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.240094] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.240457] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.240815] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.241169] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.241549] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.241931] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.242315] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.242672] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.243051] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.243416] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.243782] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.244175] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.244533] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.244917] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.245318] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.245689] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.246089] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.246510] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.246872] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.247285] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.247679] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.248083] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.248510] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.248871] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.249230] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.249615] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.249983] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.250372] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.250732] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.251117] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.251475] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.251864] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.252259] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.252679] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.253099] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.253494] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.253854] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.254207] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.254563] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.254949] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.255329] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.255691] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.256093] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.256463] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.256816] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.257166] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.257523] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.257882] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.258251] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.258601] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.258948] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.259293] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.259653] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.260043] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.260396] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.260754] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.261123] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.261468] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.261812] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.262192] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.262545] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.262902] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.263246] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.263615] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.263986] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.264350] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.264733] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.265108] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.265456] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.265801] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.266148] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.266495] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.266873] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.267250] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.267601] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.267949] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.268314] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.268667] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.269041] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.269417] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.269784] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.270140] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.270493] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.270857] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.271212] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.271564] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.271921] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.272296] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.272656] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.273012] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.273394] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.273751] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.274108] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.274476] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.274832] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.275214] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.275597] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.275957] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.276334] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.276722] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.277078] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.277463] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.277853] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.278238] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.278607] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.278990] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.279356] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.279713] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.280084] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.280486] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.280856] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.281212] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.281572] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.281957] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.282311] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.282695] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.283079] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.283445] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.283799] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.284191] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.284568] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.284925] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.285283] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.285665] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.286019] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.286378] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.286735] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.287092] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.287452] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.287808] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.288196] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.288559] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.288924] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.289277] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.289657] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.290008] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.290360] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.290725] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.291089] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.291473] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.291855] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.292221] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.292582] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.292946] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.293325] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.293696] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.294080] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.294446] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.294829] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.295183] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.295543] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.295897] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.296290] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.296659] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.297031] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.297405] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.297768] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.298119] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.298492] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.298857] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.299227] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.299608] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.299965] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.300341] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.300731] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.301112] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.301498] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.301855] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.302239] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.302598] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.302954] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.303312] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.303682] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.304075] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.304453] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.304808] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.305187] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.305544] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.305903] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.306257] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.306640] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.306997] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.307357] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.307713] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.308082] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.308448] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.308818] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.309214] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.309573] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.309953] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.310330] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.310685] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.311066] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.311437] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.311792] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.312154] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.312520] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.312882] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.313246] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.313613] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.313997] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.314353] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.314726] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.315105] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.315479] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.315861] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.316224] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.316592] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.316949] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.317325] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.317711] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.318095] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.318484] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.318843] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.319209] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.319570] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.319938] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.320306] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.320689] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.321047] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.321434] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.321798] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.322168] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.322528] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.322885] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.323241] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.323611] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.323966] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.324330] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.324699] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.325057] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.325426] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.325817] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.326172] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.326531] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.326897] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.327262] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.327650] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.328056] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.328425] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.328787] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.329180] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.329552] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.329937] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.330300] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.330661] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.331021] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.331408] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.331797] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.332164] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.332556] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.332953] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.333319] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.333709] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.334066] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.334425] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.334808] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.335163] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.335545] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.335925] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.336289] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.336653] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.337018] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.337374] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.337731] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.338101] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.338464] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.338814] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.339168] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.339548] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.339897] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.340260] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.340647] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.341001] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.341381] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.341747] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.342110] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.342482] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.342864] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.343217] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.343577] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.343937] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.344293] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.344652] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.345012] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.345368] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.345717] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.346107] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.346462] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.346808] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.347159] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.347538] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.347885] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.348275] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.348654] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.349003] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.349351] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.349696] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.350072] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.350422] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.350766] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.351115] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.351490] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.351863] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.352232] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.352591] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.352947] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.353297] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.353672] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.354016] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.354371] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.354717] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.355091] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.355441] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.355815] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.356179] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.356544] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.356895] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.357254] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.357614] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.357990] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.358338] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.358698] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.359046] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.359395] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.359760] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.360118] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.360514] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.360877] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.361258] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.361610] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.361961] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.362316] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.362681] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.363036] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.363396] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.363750] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.364114] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.364499] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.364854] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.365209] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.365563] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.365918] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.366295] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.366668] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.367023] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.367378] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.367732] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.368136] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.368547] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.368937] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.369295] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.369684] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   26.518068] BUG: unable to handle kernel NULL pointer dereference at=
           (null)
[   26.518556] IP: [<          (null)>]           (null)
[   26.518993] PGD af929067 PUD aff44067 PMD 0=20
[   26.519470] Oops: 0010 [#1] SMP=20
[   26.519965] Modules linked in: arc4 rtl8192se rtl_pci rtlwifi mac802=
11 snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_codec_generic snd_=
hda_intel snd_hda_controller snd_hda_codec uvcvideo cfg80211 snd_hwdep =
snd_pcm iTCO_wdt iTCO_vendor_support coretemp videobuf2_core v4l2_commo=
n videodev btusb snd_seq snd_timer snd_seq_device microcode snd bluetoo=
th lpc_ich mfd_core serio_raw i2c_i801 videobuf2_vmalloc videobuf2_memo=
ps joydev toshiba_acpi toshiba_haps toshiba_bluetooth sparse_keymap bat=
tery soundcore rfkill wmi ac acpi_cpufreq sg autofs4 i915 drm_kms_helpe=
r drm i2c_algo_bit thermal video processor thermal_sys button scsi_dh_r=
dac scsi_dh_alua scsi_dh_emc scsi_dh_hp_sw scsi_dh netconsole atl1c
[   26.520182] CPU: 1 PID: 139 Comm: kworker/1:2 Tainted: G        W   =
   3.18.0-master #52
[   26.520182] Hardware name: TOSHIBA =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD/=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD, BIOS V1.70    09/29/2009
[   26.520182] Workqueue: rtl92s_pci rtl_watchdog_wq_callback [rtlwifi]
[   26.520182] task: ffff8801361d6850 ti: ffff8801363a8000 task.ti: fff=
f8801363a8000
[   26.528483] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   26.528502] RIP: 0010:[<0000000000000000>]  [<          (null)>]    =
       (null)
[   26.528502] RSP: 0018:ffff8801363abd80  EFLAGS: 00010293
[   26.528502] RAX: ffffffffa045e3c0 RBX: ffff8800afe619c0 RCX: 0000000=
000000000
[   26.528502] RDX: 0000000000000001 RSI: 000000000000005d RDI: ffff880=
0afe60620
[   26.528502] RBP: ffff8801363abdf8 R08: ffffffff81658a00 R09: ffffc90=
022306aa0
[   26.528502] R10: 00000000000007c1 R11: 0000000000aaaaaa R12: ffff880=
0afe60620
[   26.528502] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000=
000000000
[   26.528502] FS:  0000000000000000(0000) GS:ffff88013fd00000(0000) kn=
lGS:0000000000000000
[   26.528502] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   26.528502] CR2: 0000000000000000 CR3: 00000000af116000 CR4: 0000000=
0000407e0
[   26.528502] Stack:
[   26.528502]  ffffffffa052a51e ffff880037c58800 0000000000000002 ffff=
880136196400
[   26.528502]  0000000037c58a10 0000000000000000 0000000000000000 0000=
000000000000
[   26.528502]  0000000000000000 ffff8801363abde8 ffff8800afe61be0 ffff=
8800365f9dc0
[   26.528502] Call Trace:
[   26.528502]  [<ffffffffa052a51e>] ? rtl_watchdog_wq_callback+0xfe/0x=
420 [rtlwifi]
[   26.528502]  [<ffffffff8106270d>] process_one_work+0x14d/0x3d0
[   26.528502]  [<ffffffff81062ab1>] worker_thread+0x121/0x480
[   26.528502]  [<ffffffff81062990>] ? process_one_work+0x3d0/0x3d0
[   26.528502]  [<ffffffff81067319>] kthread+0xc9/0xe0
[   26.528502]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   26.528502]  [<ffffffff8158e26c>] ret_from_fork+0x7c/0xb0
[   26.528502]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   26.528502] Code:  Bad RIP value.
[   26.528502] RIP  [<          (null)>]           (null)
[   26.528502]  RSP <ffff8801363abd80>
[   26.528502] CR2: 0000000000000000
[   26.528502] ---[ end trace 637e034763f6c495 ]---
[   26.582384] BUG: unable to handle kernel paging request at fffffffff=
fffffd8
[   26.584012] IP: [<ffffffff810678f1>] kthread_data+0x11/0x20
[   26.584012] PGD 1a16067 PUD 1a18067 PMD 0=20
[   26.584012] Oops: 0000 [#2] SMP=20
[   26.584012] Modules linked in: arc4 rtl8192se rtl_pci rtlwifi mac802=
11 snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_codec_generic snd_=
hda_intel snd_hda_controller snd_hda_codec uvcvideo cfg80211 snd_hwdep =
snd_pcm iTCO_wdt iTCO_vendor_support coretemp videobuf2_core v4l2_commo=
n videodev btusb snd_seq snd_timer snd_seq_device microcode snd bluetoo=
th lpc_ich mfd_core serio_raw i2c_i801 videobuf2_vmalloc videobuf2_memo=
ps joydev toshiba_acpi toshiba_haps toshiba_bluetooth sparse_keymap bat=
tery soundcore rfkill wmi ac acpi_cpufreq sg autofs4 i915 drm_kms_helpe=
r drm i2c_algo_bit thermal video processor thermal_sys button scsi_dh_r=
dac scsi_dh_alua scsi_dh_emc scsi_dh_hp_sw scsi_dh netconsole atl1c
[   26.584012] CPU: 1 PID: 139 Comm: kworker/1:2 Tainted: G      D W   =
   3.18.0-master #52
[   26.584012] Hardware name: TOSHIBA =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD/=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD, BIOS V1.70    09/29/2009
[   26.584012] task: ffff8801361d6850 ti: ffff8801363a8000 task.ti: fff=
f8801363a8000
[   26.584012] RIP: 0010:[<ffffffff810678f1>]  [<ffffffff810678f1>] kth=
read_data+0x11/0x20
[   26.584012] RSP: 0018:ffff8801363ab990  EFLAGS: 00010092
[   26.584012] RAX: 0000000000000000 RBX: 0000000000000001 RCX: 0000000=
178adfd47
[   26.584012] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff880=
1361d6850
[   26.584012] RBP: ffff8801363ab9a8 R08: 0000000000007a17 R09: 0000000=
0000003ff
[   26.584012] R10: 0000000000003c7e R11: 0000000000005b4b R12: ffff880=
13fd12b00
[   26.584012] R13: 0000000000000001 R14: 0000000000000000 R15: ffff880=
1361d6850
[   26.584012] FS:  0000000000000000(0000) GS:ffff88013fd00000(0000) kn=
lGS:0000000000000000
[   26.584012] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   26.584012] CR2: 0000000000000028 CR3: 0000000136b17000 CR4: 0000000=
0000407e0
[   26.584012] Stack:
[   26.584012]  ffffffff81063145 ffff8801363ab9a8 ffff8801361d6850 ffff=
8801363aba18
[   26.584012]  ffffffff8158a1ae ffff8801361d6850 0000000000012b00 ffff=
8801363abfd8
[   26.584012]  0000000000012b00 ffff8801363aba08 ffff8801361d6850 ffff=
8801361d6850
[   26.584012] Call Trace:
[   26.584012]  [<ffffffff81063145>] ? wq_worker_sleeping+0x15/0xa0
[   26.584012]  [<ffffffff8158a1ae>] __schedule+0x53e/0x810
[   26.584012]  [<ffffffff8158a4a9>] schedule+0x29/0x70
[   26.584012]  [<ffffffff8104dfa2>] do_exit+0x6a2/0x9e0
[   26.584012]  [<ffffffff8100645e>] oops_end+0x8e/0xd0
[   26.584012]  [<ffffffff815829aa>] no_context+0x248/0x298
[   26.584012]  [<ffffffff81582a67>] __bad_area_nosemaphore+0x6d/0x1c6
[   26.584012]  [<ffffffff81582bd3>] bad_area_nosemaphore+0x13/0x15
[   26.584012]  [<ffffffff8103d67c>] __do_page_fault+0x9c/0x530
[   26.584012]  [<ffffffff8103db1c>] do_page_fault+0xc/0x10
[   26.584012]  [<ffffffff8158fe22>] page_fault+0x22/0x30
[   26.584012]  [<ffffffffa052a51e>] ? rtl_watchdog_wq_callback+0xfe/0x=
420 [rtlwifi]
[   26.584012]  [<ffffffff8106270d>] process_one_work+0x14d/0x3d0
[   26.584012]  [<ffffffff81062ab1>] worker_thread+0x121/0x480
[   26.584012]  [<ffffffff81062990>] ? process_one_work+0x3d0/0x3d0
[   26.584012]  [<ffffffff81067319>] kthread+0xc9/0xe0
[   26.584012]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   26.584012]  [<ffffffff8158e26c>] ret_from_fork+0x7c/0xb0
[   26.584012]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   26.584012] Code: 48 89 e5 5d 48 8b 40 c8 48 c1 e8 02 83 e0 01 c3 66=
 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 48 8b 87 60 04 00 00 55 48 8=
9 e5 5d <48> 8b 40 d8 c3 66 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 5=
5=20
[   26.584012] RIP  [<ffffffff810678f1>] kthread_data+0x11/0x20
[   26.584012]  RSP <ffff8801363ab990>
[   26.584012] CR2: ffffffffffffffd8
[   26.584012] ---[ end trace 637e034763f6c496 ]---
[   26.584012] Fixing recursive fault but reboot is needed!
[   26.584012] Kernel panic - not syncing: Watchdog detected hard LOCKU=
P on cpu 1
[   26.584012] Shutting down cpus with NMI
[   26.584012] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation r=
ange: 0xffffffff80000000-0xffffffff9fffffff)
[   26.584012] drm_kms_helper: panic occurred, switching back to text c=
onsole
[   26.584012] Rebooting in 60 seconds..

From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: Re: Possible wireless issue introduced in next-20140930
Date: Thu, 23 Oct 2014 07:23:35 +0200
Message-ID: <1414041815.5228.37.camel@marge.simpson.net>
References: <54487346.4080604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54487346.4080604@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-10-23 at 01:17 -0200, Murilo Opsfelder Araujo wrote:=20
> Hello, everyone.
>=20
> With next-20140930 my laptop does not work, i.e. after I enter my log=
in=20
> and password in KDM, the entire system becomes unresponsive and I nee=
d=20
> to reset it in order to reboot (it does not even show the KDE splash=20
> screen).
>=20
> It was working pretty fine with next-20140926.
>=20
> I've also tested with next-20141022 and v3.18-rc1 and no luck.
>=20
> git bisect pointed me to the commit below [1].  My wireless card is a=
=20
> RTL8191SEvA [2].

Mine is RTL8191SEvB.

I was going to bisect RTL8191SE regression when I got a chance, but you
beat me to it.

> commit 38506ecefab911785d5e1aa5889f6eeb462e0954
> Author: Larry Finger <Larry.Finger@lwfinger.net>
> Date:   Mon Sep 22 09:39:19 2014 -0500
>=20
>      rtlwifi: rtl_pci: Start modification for new drivers

Did you confirm that bisection result, ie revert it at HEAD of whicheve=
r
tree you bisected?

The revert (master) removed some warnings on the way to kaboom here, bu=
t
the drivers is still toxic.  My log follows in case it's the same thing=
=2E
I can't go hunting atm, maybe during the weekend if the problem hasn't
evaporate by then.

Master:
[   28.028817] cfg80211: Calling CRDA to update world regulatory domain
[   28.102230] cfg80211: World regulatory domain updated:
[   28.103799] cfg80211:  DFS Master region: unset
[   28.103838] cfg80211:   (start_freq - end_freq @ bandwidth), (max_an=
tenna_gain, max_eirp), (dfs_cac_time)
[   28.107012] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (30=
0 mBi, 2000 mBm), (N/A)
[   28.108663] cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz), (30=
0 mBi, 2000 mBm), (N/A)
[   28.110251] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (30=
0 mBi, 2000 mBm), (N/A)
[   28.111837] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (30=
0 mBi, 2000 mBm), (N/A)
[   28.113422] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (30=
0 mBi, 2000 mBm), (N/A)
[   29.577727] rtl8192se 0000:08:00.0: enabling device (0000 -> 0003)
[   29.618681] rtl8192se: FW Power Save off (module option)
[   29.620355] rtl8192se: Driver for Realtek RTL8192SE/RTL8191SE
[   29.620355] Loading firmware rtlwifi/rtl8192sefw.bin
[   29.648444] ------------[ cut here ]------------
[   29.650012] WARNING: CPU: 1 PID: 59 at fs/sysfs/dir.c:31 sysfs_warn_=
dup+0x68/0x80()
[   29.651602] sysfs: cannot create duplicate filename '/devices/pci000=
0:00/0000:00:1c.5/0000:08:00.0/ieee80211/phy0'
[   29.653278] Modules linked in: rtl8192se(+) rtl_pci rtlwifi mac80211=
 cfg80211 btusb bluetooth coretemp iTCO_wdt iTCO_vendor_support serio_r=
aw microcode toshiba_acpi sparse_keymap snd_hda_codec_hdmi snd_hda_code=
c_conexant rfkill snd_hda_codec_generic pcspkr uvcvideo videobuf2_core =
v4l2_common videodev videobuf2_vmalloc videobuf2_memops joydev i2c_i801=
 wmi lpc_ich mfd_core acpi_cpufreq toshiba_haps snd_hda_intel snd_hda_c=
ontroller snd_hda_codec snd_hwdep toshiba_bluetooth snd_pcm snd_seq snd=
_timer snd_seq_device snd battery ac soundcore sg autofs4 i915 drm_kms_=
helper drm i2c_algo_bit thermal video processor thermal_sys button scsi=
_dh_rdac scsi_dh_alua scsi_dh_emc scsi_dh_hp_sw scsi_dh netconsole atl1=
c
[   29.655223] CPU: 1 PID: 59 Comm: kworker/1:4 Not tainted 3.18.0-mast=
er #48
[   29.655225] Hardware name: TOSHIBA =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD/=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD, BIOS V1.70    09/29/2009
[   29.655231] Workqueue: events request_firmware_work_func
[   29.655235]  0000000000000009 ffff8800379bba98 ffffffff8158f1d4 0000=
00000000c5c5
[   29.655238]  ffff8800379bbae8 ffff8800379bbad8 ffffffff8104c801 0000=
000000003664
[   29.655241]  ffff880037b0c000 ffff880136392dc0 ffff8800371feeb0 ffff=
88013b027098
[   29.655242] Call Trace:
[   29.655248]  [<ffffffff8158f1d4>] dump_stack+0x46/0x58
[   29.655253]  [<ffffffff8104c801>] warn_slowpath_common+0x81/0xa0
[   29.655256]  [<ffffffff8104c866>] warn_slowpath_fmt+0x46/0x50
[   29.655261]  [<ffffffff811d1108>] ? kernfs_path+0x48/0x60
[   29.655263]  [<ffffffff811d4588>] sysfs_warn_dup+0x68/0x80
[   29.655266]  [<ffffffff811d462e>] sysfs_create_dir_ns+0x8e/0xa0
[   29.655270]  [<ffffffff8128e149>] kobject_add_internal+0xc9/0x400
[   29.655273]  [<ffffffff8128e8b0>] kobject_add+0x60/0xb0
[   29.655276]  [<ffffffff81593b16>] ? mutex_lock+0x16/0x37
[   29.655281]  [<ffffffff81388624>] device_add+0x104/0x600
[   29.655285]  [<ffffffff8114c3ce>] ? lazy_max_pages+0x1e/0x30
[   29.655312]  [<ffffffffa0401d0d>] wiphy_register+0x3fd/0x710 [cfg802=
11]
[   29.655315]  [<ffffffff8114dd92>] ? __vunmap+0xc2/0x110
[   29.655346]  [<ffffffffa04a5cfc>] ? ieee80211_register_hw+0x1ec/0x9a=
0 [mac80211]
[   29.655361]  [<ffffffffa04a5e78>] ieee80211_register_hw+0x368/0x9a0 =
[mac80211]
[   29.655369]  [<ffffffffa049126b>] rtl92se_fw_cb+0xab/0x1d0 [rtl8192s=
e]
[   29.655373]  [<ffffffff8139b650>] request_firmware_work_func+0x30/0x=
60
[   29.655378]  [<ffffffff810627ed>] process_one_work+0x14d/0x3d0
[   29.655381]  [<ffffffff81062b91>] worker_thread+0x121/0x480
[   29.655384]  [<ffffffff81062a70>] ? process_one_work+0x3d0/0x3d0
[   29.655387]  [<ffffffff810672c9>] kthread+0xc9/0xe0
[   29.655390]  [<ffffffff81067200>] ? __kthread_parkme+0x80/0x80
[   29.655394]  [<ffffffff81595b6c>] ret_from_fork+0x7c/0xb0
[   29.655397]  [<ffffffff81067200>] ? __kthread_parkme+0x80/0x80
[   29.655399] ---[ end trace 3935ea42665e29bc ]---
[   29.655401] ------------[ cut here ]------------
[   29.655404] WARNING: CPU: 1 PID: 59 at lib/kobject.c:240 kobject_add=
_internal+0x294/0x400()
[   29.655406] kobject_add_internal failed for phy0 with -EEXIST, don't=
 try to register things with the same name in the same directory.
[   29.655442] Modules linked in: rtl8192se(+) rtl_pci rtlwifi mac80211=
 cfg80211 btusb bluetooth coretemp iTCO_wdt iTCO_vendor_support serio_r=
aw microcode toshiba_acpi sparse_keymap snd_hda_codec_hdmi snd_hda_code=
c_conexant rfkill snd_hda_codec_generic pcspkr uvcvideo videobuf2_core =
v4l2_common videodev videobuf2_vmalloc videobuf2_memops joydev i2c_i801=
 wmi lpc_ich mfd_core acpi_cpufreq toshiba_haps snd_hda_intel snd_hda_c=
ontroller snd_hda_codec snd_hwdep toshiba_bluetooth snd_pcm snd_seq snd=
_timer snd_seq_device snd battery ac soundcore sg autofs4 i915 drm_kms_=
helper drm i2c_algo_bit thermal video processor thermal_sys button scsi=
_dh_rdac scsi_dh_alua scsi_dh_emc scsi_dh_hp_sw scsi_dh netconsole atl1=
c
[   29.655444] CPU: 1 PID: 59 Comm: kworker/1:4 Tainted: G        W    =
  3.18.0-master #48
[   29.655446] Hardware name: TOSHIBA =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD/=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD, BIOS V1.70    09/29/2009
[   29.655449] Workqueue: events request_firmware_work_func
[   29.655452]  0000000000000009 ffff8800379bbaf8 ffffffff8158f1d4 0000=
000000004e4e
[   29.655455]  ffff8800379bbb48 ffff8800379bbb38 ffffffff8104c801 ffff=
8800379bbb38
[   29.655458]  ffff880036470350 00000000ffffffef ffff8800367d72c0 ffff=
88013b027098
[   29.655459] Call Trace:
[   29.655462]  [<ffffffff8158f1d4>] dump_stack+0x46/0x58
[   29.655465]  [<ffffffff8104c801>] warn_slowpath_common+0x81/0xa0
[   29.655468]  [<ffffffff8104c866>] warn_slowpath_fmt+0x46/0x50
[   29.655471]  [<ffffffff8128e314>] kobject_add_internal+0x294/0x400
[   29.655474]  [<ffffffff8128e8b0>] kobject_add+0x60/0xb0
[   29.655477]  [<ffffffff81593b16>] ? mutex_lock+0x16/0x37
[   29.655480]  [<ffffffff81388624>] device_add+0x104/0x600
[   29.655483]  [<ffffffff8114c3ce>] ? lazy_max_pages+0x1e/0x30
[   29.655496]  [<ffffffffa0401d0d>] wiphy_register+0x3fd/0x710 [cfg802=
11]
[   29.655498]  [<ffffffff8114dd92>] ? __vunmap+0xc2/0x110
[   29.655512]  [<ffffffffa04a5cfc>] ? ieee80211_register_hw+0x1ec/0x9a=
0 [mac80211]
[   29.655526]  [<ffffffffa04a5e78>] ieee80211_register_hw+0x368/0x9a0 =
[mac80211]
[   29.655533]  [<ffffffffa049126b>] rtl92se_fw_cb+0xab/0x1d0 [rtl8192s=
e]
[   29.655536]  [<ffffffff8139b650>] request_firmware_work_func+0x30/0x=
60
[   29.655540]  [<ffffffff810627ed>] process_one_work+0x14d/0x3d0
[   29.655543]  [<ffffffff81062b91>] worker_thread+0x121/0x480
[   29.655546]  [<ffffffff81062a70>] ? process_one_work+0x3d0/0x3d0
[   29.655548]  [<ffffffff810672c9>] kthread+0xc9/0xe0
[   29.655551]  [<ffffffff81067200>] ? __kthread_parkme+0x80/0x80
[   29.655555]  [<ffffffff81595b6c>] ret_from_fork+0x7c/0xb0
[   29.655557]  [<ffffffff81067200>] ? __kthread_parkme+0x80/0x80
[   29.655559] ---[ end trace 3935ea42665e29bd ]---
[   29.655563] rtl8192se:rtl92se_fw_cb():<0-0> Can't register mac80211 =
hw
[   29.818806] ieee80211 phy0: Selected rate control algorithm 'rtl_rc'
[   30.265418] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   30.267617] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   30.269767] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   30.271919] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   30.274034] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   30.276117] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process

=2E.. more

[   30.684030] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   30.684408] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   30.684776] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   30.685139] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   30.685535] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   30.685901] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   30.686290] rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process
[   30.686710] BUG: unable to handle kernel NULL pointer dereference at=
           (null)
[   30.687145] IP: [<          (null)>]           (null)
[   30.687592] PGD 137165067 PUD 135e2e067 PMD 0=20
[   30.688094] Oops: 0010 [#1] SMP=20
[   30.688601] Modules linked in: arc4 rtl8192se rtl_pci rtlwifi mac802=
11 cfg80211 btusb bluetooth[    0.000000] Initializing cgroup subsys cp=
uset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
(kdump tried to do its thing, but fscking systemd busted it, so, no oop=
s/crash)

Master with 38506ece reverted, kdump disabled:
[   19.383131] rtl8192se 0000:08:00.0: enabling device (0000 -> 0003)
[   19.424672] rtl8192se: FW Power Save off (module option)
[   19.427269] rtl8192se: Driver for Realtek RTL8192SE/RTL8191SE
[   19.427269] Loading firmware rtlwifi/rtl8192sefw.bin
[   19.525633] EXT4-fs (sda1): mounted filesystem with ordered data mod=
e. Opts: acl
[   19.528188] ieee80211 phy0: Selected rate control algorithm 'rtl_rc'
[   25.515995] BUG: unable to handle kernel NULL pointer dereference at=
           (null)
[   25.516020] IP: [<          (null)>]           (null)
[   25.516020] PGD 362a6067 PUD 36d39067 PMD 0=20
[   25.516020] Oops: 0010 [#1] SMP=20
[   25.516020] Modules linked in: arc4 rtl8192se rtl_pci rtlwifi uvcvid=
eo coretemp videobuf2_core mac80211 iTCO_wdt iTCO_vendor_support cfg802=
11 v4l2_common btusb videodev lpc_ich bluetooth mfd_core microcode tosh=
iba_acpi sparse_keymap rfkill videobuf2_vmalloc videobuf2_memops serio_=
raw i2c_i801 joydev snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_c=
odec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_hwdep t=
oshiba_haps wmi snd_pcm toshiba_bluetooth snd_seq snd_timer snd_seq_dev=
ice snd battery[   25.526648] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is=
 not ready

[   25.526604]  soundcore ac acpi_cpufreq sg autofs4 i915 drm_kms_helpe=
r drm i2c_algo_bit thermal video processor thermal_sys button scsi_dh_r=
dac scsi_dh_alua scsi_dh_emc scsi_dh_hp_sw scsi_dh netconsole atl1c
[   25.526604] CPU: 1 PID: 21 Comm: kworker/1:1 Not tainted 3.18.0-mast=
er #49
[   25.526604] Hardware name: TOSHIBA =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD/=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD, BIOS V1.70    09/29/2009
[   25.526604] Workqueue: rtl92s_pci rtl_watchdog_wq_callback [rtlwifi]
[   25.526604] task: ffff88013f2e2550 ti: ffff88013f2e4000 task.ti: fff=
f88013f2e4000
[   25.526604] RIP: 0010:[<0000000000000000>]  [<          (null)>]    =
       (null)
[   25.526604] RSP: 0018:ffff88013f2e7d80  EFLAGS: 00010293
[   25.526604] RAX: ffffffffa05363c0 RBX: ffff8800364019c0 RCX: 0000000=
000000000
[   25.526604] RDX: 0000000000000001 RSI: 000000000000005d RDI: ffff880=
036400620
[   25.526604] RBP: ffff88013f2e7df8 R08: ffffffff81658a40 R09: ffffc90=
022306aa0
[   25.526604] R10: 000000000000037e R11: 0000000000aaaaaa R12: ffff880=
036400620
[   25.526604] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000=
000000000
[   25.526604] FS:  0000000000000000(0000) GS:ffff88013fd00000(0000) kn=
lGS:0000000000000000
[   25.526604] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   25.526604] CR2: 0000000000000000 CR3: 00000000365e2000 CR4: 0000000=
0000407e0
[   25.526604] Stack:
[   25.526604]  ffffffffa04ff51e ffff880037bdbc00 0000000000000002 ffff=
880037b8e400
[   25.526604]  0000000037bdbe10 0000000000000000 0000000000000000 0000=
000000000000
[   25.526604]  0000000000000000 ffff88013f2e7e38 ffff880036401be0 ffff=
88013f239700
[   25.526604] Call Trace:
[   25.526604]  [<ffffffffa04ff51e>] ? rtl_watchdog_wq_callback+0xfe/0x=
420 [rtlwifi]
[   25.526604]  [<ffffffff810627ed>] process_one_work+0x14d/0x3d0
[   25.526604]  [<ffffffff81062b91>] worker_thread+0x121/0x480
[   25.526604]  [<ffffffff81062a70>] ? process_one_work+0x3d0/0x3d0
[   25.526604]  [<ffffffff810672c9>] kthread+0xc9/0xe0
[   25.526604]  [<ffffffff81067200>] ? __kthread_parkme+0x80/0x80
[   25.526604]  [<ffffffff81595b6c>] ret_from_fork+0x7c/0xb0
[   25.526604]  [<ffffffff81067200>] ? __kthread_parkme+0x80/0x80
[   25.526604] Code:  Bad RIP value.
[   25.526604] RIP  [<          (null)>]           (null)
[   25.526604]  RSP <ffff88013f2e7d80>
[   25.526604] CR2: 0000000000000000
[   25.526604] ---[ end trace fc110bb3836ecc51 ]---
[   25.607061] BUG: unable to handle kernel paging request at fffffffff=
fffffd8
[   25.609239] IP: [<ffffffff81067a71>] kthread_data+0x11/0x20
[   25.609239] PGD 1a16067 PUD 1a18067 PMD 0=20
[   25.609239] Oops: 0000 [#2] SMP=20
[   25.609239] Modules linked in: arc4 rtl8192se rtl_pci rtlwifi uvcvid=
eo coretemp videobuf2_core mac80211 iTCO_wdt iTCO_vendor_support cfg802=
11 v4l2_common btusb videodev lpc_ich bluetooth mfd_core microcode tosh=
iba_acpi sparse_keymap rfkill videobuf2_vmalloc videobuf2_memops serio_=
raw i2c_i801 joydev snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_c=
odec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_hwdep t=
oshiba_haps wmi snd_pcm toshiba_bluetooth snd_seq snd_timer snd_seq_dev=
ice snd battery soundcore ac acpi_cpufreq sg autofs4 i915 drm_kms_helpe=
r drm i2c_algo_bit thermal video processor thermal_sys button scsi_dh_r=
dac scsi_dh_alua scsi_dh_emc scsi_dh_hp_sw scsi_dh netconsole atl1c
[   25.609239] CPU: 1 PID: 21 Comm: kworker/1:1 Tainted: G      D      =
  3.18.0-master #49
[   25.609239] Hardware name: TOSHIBA =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD/=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD, BIOS V1.70    09/29/2009
[   25.609239] task: ffff88013f2e2550 ti: ffff88013f2e4000 task.ti: fff=
f88013f2e4000
[   25.609239] RIP: 0010:[<ffffffff81067a71>]  [<ffffffff81067a71>] kth=
read_data+0x11/0x20
[   25.609239] RSP: 0018:ffff88013f2e7990  EFLAGS: 00010092
[   25.609239] RAX: 0000000000000000 RBX: 0000000000000001 RCX: 0000000=
19c731d81
[   25.609239] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff880=
13f2e2550
[   25.609239] RBP: ffff88013f2e79a8 R08: ffff88013f1f8990 R09: 0000000=
0000003ac
[   25.609239] R10: 000000000000bc00 R11: 000000000000b407 R12: ffff880=
13fd12b00
[   25.609239] R13: 0000000000000001 R14: 0000000000000000 R15: ffff880=
13f2e2550
[   25.609239] FS:  0000000000000000(0000) GS:ffff88013fd00000(0000) kn=
lGS:0000000000000000
[   25.609239] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   25.609239] CR2: 0000000000000028 CR3: 0000000037075000 CR4: 0000000=
0000407e0
[   25.609239] Stack:
[   25.609239]  ffffffff81063225 ffff88013f2e79a8 ffff88013f2e2550 ffff=
88013f2e7a18
[   25.609239]  ffffffff81591aa9 ffff88013f2e2550 0000000000012b00 ffff=
88013f2e7fd8
[   25.609239]  0000000000012b00 ffff88013f2e7a08 ffff88013f2e2550 ffff=
88013f2e2550
[   25.609239] Call Trace:
[   25.609239]  [<ffffffff81063225>] ? wq_worker_sleeping+0x15/0xa0
[   25.609239]  [<ffffffff81591aa9>] __schedule+0x549/0x810
[   25.609239]  [<ffffffff81591d99>] schedule+0x29/0x70
[   25.609239]  [<ffffffff8104dfa2>] do_exit+0x6a2/0x9e0
[   25.609239]  [<ffffffff8100645e>] oops_end+0x8e/0xd0
[   25.609239]  [<ffffffff8158a27a>] no_context+0x248/0x298
[   25.609239]  [<ffffffff8158a337>] __bad_area_nosemaphore+0x6d/0x1c6
[   25.609239]  [<ffffffff8158a4a3>] bad_area_nosemaphore+0x13/0x15
[   25.609239]  [<ffffffff8103d67c>] __do_page_fault+0x9c/0x530
[   25.609239]  [<ffffffff812ef124>] ? soft_cursor+0x1b4/0x250
[   25.609239]  [<ffffffff8103db1c>] do_page_fault+0xc/0x10
[   25.609239]  [<ffffffff81597722>] page_fault+0x22/0x30
[   25.609239]  [<ffffffffa04ff51e>] ? rtl_watchdog_wq_callback+0xfe/0x=
420 [rtlwifi]
[   25.609239]  [<ffffffff810627ed>] process_one_work+0x14d/0x3d0
[   25.609239]  [<ffffffff81062b91>] worker_thread+0x121/0x480
[   25.609239]  [<ffffffff81062a70>] ? process_one_work+0x3d0/0x3d0
[   25.609239]  [<ffffffff810672c9>] kthread+0xc9/0xe0
[   25.609239]  [<ffffffff81067200>] ? __kthread_parkme+0x80/0x80
[   25.609239]  [<ffffffff81595b6c>] ret_from_fork+0x7c/0xb0
[   25.609239]  [<ffffffff81067200>] ? __kthread_parkme+0x80/0x80
[   25.609239] Code: 48 89 e5 5d 48 8b 40 c8 48 c1 e8 02 83 e0 01 c3 66=
 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 48 8b 87 60 04 00 00 55 48 8=
9 e5 5d <48> 8b 40 d8 c3 66 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 5=
5=20
[   25.609239] RIP  [<ffffffff81067a71>] kthread_data+0x11/0x20
[   25.609239]  RSP <ffff88013f2e7990>
[   25.609239] CR2: ffffffffffffffd8
[   25.609239] ---[ end trace fc110bb3836ecc52 ]---
[   25.609239] Fixing recursive fault but reboot is needed!
[   25.609239] Kernel panic - not syncing: Watchdog detected hard LOCKU=
P on cpu 1
[   25.609239] Shutting down cpus with NMI
[   25.609239] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation r=
ange: 0xffffffff80000000-0xffffffff9fffffff)
[   25.609239] drm_kms_helper: panic occurred, switching back to text c=
onsole
[   25.609239] Rebooting in 60 seconds..

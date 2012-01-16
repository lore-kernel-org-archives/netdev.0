From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Mon, 16 Jan 2012 18:33:06 +0100
Message-ID: <4F145F52.9010200@broadcom.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com>
 <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
 <4F101047.4090902@broadcom.com>
 <CA+55aFxtaw+FF8wRf9td1rU0A_vhM8XwgSznzE-ph_4j=t5gWg@mail.gmail.com>
 <4F142D84.4060405@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary=------------030704090203090400040109
Cc: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	"Larry Finger" <Larry.Finger@lwfinger.net>,
	"Alwin Beukers" <alwin@broadcom.com>,
	"Roland Vossen" <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Network Development" <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: "Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1358 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754152Ab2APRdX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jan 2012 12:33:23 -0500
In-Reply-To: <4F142D84.4060405@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--------------030704090203090400040109
Content-Type: text/plain;
 charset=iso-8859-2
Content-Transfer-Encoding: 7bit

On 01/16/2012 03:00 PM, Arend van Spriel wrote:
> On 01/14/2012 04:50 AM, Linus Torvalds wrote:
>> 2012/1/13 Arend van Spriel <arend@broadcom.com>:
>>>
>>> Upon suspend my laptop hangs (see trace below pulled from serial
>>> console). I do not see the pr_debug in the suspend function (compiled
>>> with -DDEBUG). Unfortunately the same happens when I don't insert bcma
>>> and brcmsmac. I attached the kernel configuration.
>>
>> Ok, I note that you do have MCE enabled.
>>
>> The MCE problems should be fixed in current -git, and so it might be
>> worth re-testing with that.
>>
>>                    Linus
>>
> 
> Hi Linus,
> 
> I build a kernel with MCE disabled and tested that. It still hung. I
> decided run the kernel with nomodeset parameter to avoid framebuffer
> issues. Now the suspend worked, but resume failed. Just heard a beep and
> that was it. I will refresh the tree and build another kernel with MCE
> enabled.
> 

I build a new kernel with MCE enabled. Same issue. I did not load bcma
or brcmsmac yet. Attached is trace I could pull from the kernel log
(str-test-*).

I also tried the pm_test and attached the trace for that
(str-devices-*). No bcma/brcmsmac test done with it yet.

Gr. AvS

-----------------------------------
version: 3.2.0-08699-ga93ce74

a93ce74 bcma: invalidate the mapped window over suspend/resume
d205a29 brcmsmac: remove PCI suspend/resume from bcma driver
310c9f8 bcma: connect the bcma bus suspend/resume to the bcma driver
suspend/res
6f55bd0 bcma: add stub for bcma_bus suspend()
83d836c bcma: convert suspend/resume to pm_ops
53999bf error: implicit declaration of function 'module_flags_taint'
122804e Merge branch 'v4l_for_linus' of
git://git.kernel.org/pub/scm/linux/kerne


--------------030704090203090400040109
Content-Type: text/plain;
 name=str-test-3.2.0-08699-ga93ce74.log
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=str-test-3.2.0-08699-ga93ce74.log

Jan 16 16:12:18 arend-lp-dev kernel: [   18.677791] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Jan 16 16:12:18 arend-lp-dev kernel: [   18.750899] hda-intel: IRQ timing workaround is activated for card #1. Suggest a bigger bdl_pos_adj.
Jan 16 16:12:18 arend-lp-dev kernel: [   19.527827] EXT4-fs (sda5): re-mounted. Opts: errors=remount-ro,commit=0
Jan 16 16:12:19 arend-lp-dev kernel: [   19.536249] EXT4-fs (sda7): re-mounted. Opts: commit=0
Jan 16 16:12:25 arend-lp-dev kernel: [   26.004187] EXT4-fs (sda5): re-mounted. Opts: errors=remount-ro,commit=0
Jan 16 16:12:25 arend-lp-dev kernel: [   26.012413] EXT4-fs (sda7): re-mounted. Opts: commit=0
Jan 16 16:12:26 arend-lp-dev kernel: [   27.277853] PM: Syncing filesystems ... done.
Jan 16 16:12:26 arend-lp-dev kernel: [   27.282818] PM: Preparing system for mem sleep
Jan 16 16:12:51 arend-lp-dev kernel: [   27.287317] Freezing user space processes ... (elapsed 0.01 seconds) done.
Jan 16 16:12:51 arend-lp-dev kernel: [   27.307802] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
Jan 16 16:12:51 arend-lp-dev kernel: [   27.327823] PM: Entering mem sleep
Jan 16 16:12:51 arend-lp-dev kernel: [   27.331518] sd 0:0:0:0: [sda] Synchronizing SCSI cache
Jan 16 16:12:51 arend-lp-dev kernel: [   27.401472] sd 0:0:0:0: [sda] Stopping disk
Jan 16 16:12:51 arend-lp-dev kernel: [   28.419112] serial 00:08: disabled
Jan 16 16:12:51 arend-lp-dev kernel: [   28.419347] serial 00:08: wake-up capability disabled by ACPI
Jan 16 16:12:51 arend-lp-dev kernel: [   28.427126] ACPI handle has no context!
Jan 16 16:12:51 arend-lp-dev kernel: [   28.485022] e1000e 0000:00:19.0: wake-up capability enabled by ACPI
Jan 16 16:12:51 arend-lp-dev kernel: [   28.866326] ACPI handle has no context!
Jan 16 16:12:51 arend-lp-dev kernel: [   28.882283] PM: suspend of devices complete after 1553.559 msecs
Jan 16 16:12:51 arend-lp-dev kernel: [   28.882655] PM: suspend devices took 1.556 seconds
Jan 16 16:12:51 arend-lp-dev kernel: [   28.883343] ehci_hcd 0000:00:1d.0: wake-up capability enabled by ACPI
Jan 16 16:12:51 arend-lp-dev kernel: [   28.898388] ehci_hcd 0000:00:1a.0: wake-up capability enabled by ACPI
Jan 16 16:12:51 arend-lp-dev kernel: [   28.914277] PM: late suspend of devices complete after 31.374 msecs
Jan 16 16:12:51 arend-lp-dev kernel: [   28.914834] ACPI: Preparing to enter system sleep state S3
Jan 16 16:12:51 arend-lp-dev kernel: [   28.934410] PM: Saving platform NVS memory
Jan 16 16:12:51 arend-lp-dev kernel: [   28.935334] Disabling non-boot CPUs ...
Jan 16 16:12:51 arend-lp-dev kernel: [   29.038021] CPU 1 is now offline
Jan 16 16:12:51 arend-lp-dev kernel: [   29.038513] ------------[ cut here ]------------
Jan 16 16:12:51 arend-lp-dev kernel: [   29.038813] WARNING: at drivers/base/core.c:194 device_release+0x76/0x80()
Jan 16 16:12:51 arend-lp-dev kernel: [   29.039225] Hardware name: Latitude E6410
Jan 16 16:12:51 arend-lp-dev kernel: [   29.039499] Device 'machinecheck1' does not have a release() function, it is broken and must be fixed.
Jan 16 16:12:51 arend-lp-dev kernel: [   29.040054] Modules linked in: binfmt_misc snd_hda_codec_hdmi snd_hda_codec_idt nouveau snd_hda_intel snd_hda_codec ttm snd_hwdep snd_pcm snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd drm_kms_helper psmouse serio_raw dell_laptop drm intel_agp intel_gtt dcdbas mxm_wmi dell_wmi video sparse_keymap soundcore snd_page_alloc intel_ips agpgart firewire_ohci firewire_core crc_itu_t ahci libahci sdhci_pci sdhci mmc_core e1000e
Jan 16 16:12:51 arend-lp-dev kernel: [   29.044752] Pid: 1272, comm: pm-suspend Not tainted 3.2.0-08699-ga93ce74 #1
Jan 16 16:12:51 arend-lp-dev kernel: [   29.045169] Call Trace:
Jan 16 16:12:51 arend-lp-dev kernel: [   29.045367]  [<c10305e2>] warn_slowpath_common+0x72/0xa0
Jan 16 16:12:51 arend-lp-dev kernel: [   29.045702]  [<c131dfa6>] ? device_release+0x76/0x80
Jan 16 16:12:51 arend-lp-dev kernel: [   29.046022]  [<c131dfa6>] ? device_release+0x76/0x80
Jan 16 16:12:51 arend-lp-dev kernel: [   29.046341]  [<c10306b3>] warn_slowpath_fmt+0x33/0x40
Jan 16 16:12:51 arend-lp-dev kernel: [   29.046663]  [<c131dfa6>] device_release+0x76/0x80
Jan 16 16:12:51 arend-lp-dev kernel: [   29.046975]  [<c1273e2a>] kobject_release+0x3a/0x80
Jan 16 16:12:51 arend-lp-dev kernel: [   29.047289]  [<c1273d17>] kobject_put+0x27/0x60
Jan 16 16:12:51 arend-lp-dev kernel: [   29.047586]  [<c1273de2>] ? kobject_del+0x22/0x30
Jan 16 16:12:51 arend-lp-dev kernel: [   29.047894]  [<c131e975>] ? device_del+0x125/0x150
Jan 16 16:12:51 arend-lp-dev kernel: [   29.048207]  [<c131ddf4>] put_device+0x14/0x20
Jan 16 16:12:51 arend-lp-dev kernel: [   29.048502]  [<c131e9b7>] device_unregister+0x17/0x20
Jan 16 16:12:51 arend-lp-dev kernel: [   29.048830]  [<c14a5256>] mce_cpu_callback+0xc3/0x155
Jan 16 16:12:51 arend-lp-dev kernel: [   29.049156]  [<c14b64a5>] notifier_call_chain+0x45/0x60
Jan 16 16:12:51 arend-lp-dev kernel: [   29.049493]  [<c1053e1e>] __raw_notifier_call_chain+0x1e/0x30
Jan 16 16:12:51 arend-lp-dev kernel: [   29.049853]  [<c1031fa4>] __cpu_notify+0x24/0x40
Jan 16 16:12:51 arend-lp-dev kernel: [   29.050158]  [<c10320cc>] cpu_notify_nofail+0x1c/0x30
Jan 16 16:12:51 arend-lp-dev kernel: [   29.050485]  [<c149929d>] _cpu_down+0xdd/0x250
Jan 16 16:12:51 arend-lp-dev kernel: [   29.050780]  [<c10321b4>] disable_nonboot_cpus+0x74/0x110
Jan 16 16:12:51 arend-lp-dev kernel: [   29.051124]  [<c1083183>] suspend_devices_and_enter+0x173/0x2e0
Jan 16 16:12:51 arend-lp-dev kernel: [   29.051494]  [<c108342c>] enter_state+0x13c/0x160
Jan 16 16:12:51 arend-lp-dev kernel: [   29.051802]  [<c10820aa>] state_store+0x8a/0x110
Jan 16 16:12:51 arend-lp-dev kernel: [   29.052106]  [<c1082020>] ? pm_trace_dev_match_show+0x20/0x20
Jan 16 16:12:51 arend-lp-dev kernel: [   29.052468]  [<c1273c2b>] kobj_attr_store+0x1b/0x30
Jan 16 16:12:51 arend-lp-dev kernel: [   29.052786]  [<c1177bb6>] sysfs_write_file+0xa6/0x100
Jan 16 16:12:51 arend-lp-dev kernel: [   29.053112]  [<c112047f>] vfs_write+0x8f/0x160
Jan 16 16:12:51 arend-lp-dev kernel: [   29.053407]  [<c1177b10>] ? sysfs_poll+0x80/0x80
Jan 16 16:12:51 arend-lp-dev kernel: [   29.053710]  [<c112075d>] sys_write+0x3d/0x70
Jan 16 16:12:51 arend-lp-dev kernel: [   29.054002]  [<c14b99df>] sysenter_do_call+0x12/0x28
Jan 16 16:12:51 arend-lp-dev kernel: [   29.054320] ---[ end trace 2172e4a3414a456b ]---
Jan 16 16:12:51 arend-lp-dev kernel: [   29.157826] CPU 2 is now offline
Jan 16 16:12:51 arend-lp-dev kernel: [   29.158290] ------------[ cut here ]------------
Jan 16 16:12:51 arend-lp-dev kernel: [   29.158598] WARNING: at drivers/base/core.c:194 device_release+0x76/0x80()
Jan 16 16:12:51 arend-lp-dev kernel: [   29.159015] Hardware name: Latitude E6410
Jan 16 16:12:51 arend-lp-dev kernel: [   29.159286] Device 'machinecheck2' does not have a release() function, it is broken and must be fixed.
Jan 16 16:12:51 arend-lp-dev kernel: [   29.159836] Modules linked in: binfmt_misc snd_hda_codec_hdmi snd_hda_codec_idt nouveau snd_hda_intel snd_hda_codec ttm snd_hwdep snd_pcm snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd drm_kms_helper psmouse serio_raw dell_laptop drm intel_agp intel_gtt dcdbas mxm_wmi dell_wmi video sparse_keymap soundcore snd_page_alloc intel_ips agpgart firewire_ohci firewire_core crc_itu_t ahci libahci sdhci_pci sdhci mmc_core e1000e
Jan 16 16:12:51 arend-lp-dev kernel: [   29.164520] Pid: 1272, comm: pm-suspend Tainted: G        W    3.2.0-08699-ga93ce74 #1
Jan 16 16:12:51 arend-lp-dev kernel: [   29.165000] Call Trace:
Jan 16 16:12:51 arend-lp-dev kernel: [   29.165198]  [<c10305e2>] warn_slowpath_common+0x72/0xa0
Jan 16 16:12:51 arend-lp-dev kernel: [   29.165536]  [<c131dfa6>] ? device_release+0x76/0x80
Jan 16 16:12:51 arend-lp-dev kernel: [   29.165860]  [<c131dfa6>] ? device_release+0x76/0x80
Jan 16 16:12:51 arend-lp-dev kernel: [   29.166182]  [<c10306b3>] warn_slowpath_fmt+0x33/0x40
Jan 16 16:12:51 arend-lp-dev kernel: [   29.166507]  [<c131dfa6>] device_release+0x76/0x80
Jan 16 16:12:51 arend-lp-dev kernel: [   29.166822]  [<c1273e2a>] kobject_release+0x3a/0x80
Jan 16 16:12:51 arend-lp-dev kernel: [   29.167139]  [<c1273d17>] kobject_put+0x27/0x60
Jan 16 16:12:51 arend-lp-dev kernel: [   29.167440]  [<c1273de2>] ? kobject_del+0x22/0x30
Jan 16 16:12:51 arend-lp-dev kernel: [   29.167749]  [<c131e975>] ? device_del+0x125/0x150
Jan 16 16:12:51 arend-lp-dev kernel: [   29.168064]  [<c131ddf4>] put_device+0x14/0x20
Jan 16 16:12:51 arend-lp-dev kernel: [   29.168360]  [<c131e9b7>] device_unregister+0x17/0x20
Jan 16 16:12:51 arend-lp-dev kernel: [   29.168687]  [<c14a5256>] mce_cpu_callback+0xc3/0x155
Jan 16 16:12:51 arend-lp-dev kernel: [   29.169015]  [<c14b64a5>] notifier_call_chain+0x45/0x60
Jan 16 16:12:51 arend-lp-dev kernel: [   29.169351]  [<c1053e1e>] __raw_notifier_call_chain+0x1e/0x30
Jan 16 16:12:51 arend-lp-dev kernel: [   29.169712]  [<c1031fa4>] __cpu_notify+0x24/0x40
Jan 16 16:12:51 arend-lp-dev kernel: [   29.170017]  [<c10320cc>] cpu_notify_nofail+0x1c/0x30
Jan 16 16:12:51 arend-lp-dev kernel: [   29.170344]  [<c149929d>] _cpu_down+0xdd/0x250
Jan 16 16:12:51 arend-lp-dev kernel: [   29.170639]  [<c10321b4>] disable_nonboot_cpus+0x74/0x110
Jan 16 16:12:51 arend-lp-dev kernel: [   29.170984]  [<c1083183>] suspend_devices_and_enter+0x173/0x2e0
Jan 16 16:12:51 arend-lp-dev kernel: [   29.171353]  [<c108342c>] enter_state+0x13c/0x160
Jan 16 16:12:51 arend-lp-dev kernel: [   29.171661]  [<c10820aa>] state_store+0x8a/0x110
Jan 16 16:12:51 arend-lp-dev kernel: [   29.171965]  [<c1082020>] ? pm_trace_dev_match_show+0x20/0x20
Jan 16 16:12:51 arend-lp-dev kernel: [   29.172326]  [<c1273c2b>] kobj_attr_store+0x1b/0x30
Jan 16 16:12:51 arend-lp-dev kernel: [   29.172646]  [<c1177bb6>] sysfs_write_file+0xa6/0x100
Jan 16 16:12:51 arend-lp-dev kernel: [   29.172974]  [<c112047f>] vfs_write+0x8f/0x160
Jan 16 16:12:51 arend-lp-dev kernel: [   29.173268]  [<c1177b10>] ? sysfs_poll+0x80/0x80
Jan 16 16:12:51 arend-lp-dev kernel: [   29.173571]  [<c112075d>] sys_write+0x3d/0x70
Jan 16 16:12:51 arend-lp-dev kernel: [   29.173864]  [<c14b99df>] sysenter_do_call+0x12/0x28
Jan 16 16:12:51 arend-lp-dev kernel: [   29.174183] ---[ end trace 2172e4a3414a456c ]---
Jan 16 16:12:51 arend-lp-dev kernel: [   29.277612] CPU 3 is now offline
Jan 16 16:12:51 arend-lp-dev kernel: [   29.278082] ------------[ cut here ]------------
Jan 16 16:12:51 arend-lp-dev kernel: [   29.278392] WARNING: at drivers/base/core.c:194 device_release+0x76/0x80()
Jan 16 16:12:51 arend-lp-dev kernel: [   29.278810] Hardware name: Latitude E6410
Jan 16 16:12:51 arend-lp-dev kernel: [   29.279082] Device 'machinecheck3' does not have a release() function, it is broken and must be fixed.
Jan 16 16:12:51 arend-lp-dev kernel: [   29.279631] Modules linked in: binfmt_misc snd_hda_codec_hdmi snd_hda_codec_idt nouveau snd_hda_intel snd_hda_codec ttm snd_hwdep snd_pcm snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd drm_kms_helper psmouse serio_raw dell_laptop drm intel_agp intel_gtt dcdbas mxm_wmi dell_wmi video sparse_keymap soundcore snd_page_alloc intel_ips agpgart firewire_ohci firewire_core crc_itu_t ahci libahci sdhci_pci sdhci mmc_core e1000e
Jan 16 16:12:51 arend-lp-dev kernel: [   29.284313] Pid: 1272, comm: pm-suspend Tainted: G        W    3.2.0-08699-ga93ce74 #1
Jan 16 16:12:51 arend-lp-dev kernel: [   29.284791] Call Trace:
Jan 16 16:12:51 arend-lp-dev kernel: [   29.284989]  [<c10305e2>] warn_slowpath_common+0x72/0xa0
Jan 16 16:12:51 arend-lp-dev kernel: [   29.285327]  [<c131dfa6>] ? device_release+0x76/0x80
Jan 16 16:12:51 arend-lp-dev kernel: [   29.285649]  [<c131dfa6>] ? device_release+0x76/0x80
Jan 16 16:12:51 arend-lp-dev kernel: [   29.285969]  [<c10306b3>] warn_slowpath_fmt+0x33/0x40
Jan 16 16:12:51 arend-lp-dev kernel: [   29.286294]  [<c131dfa6>] device_release+0x76/0x80
Jan 16 16:12:51 arend-lp-dev kernel: [   29.286608]  [<c1273e2a>] kobject_release+0x3a/0x80
Jan 16 16:12:51 arend-lp-dev kernel: [   29.286923]  [<c1273d17>] kobject_put+0x27/0x60
Jan 16 16:12:51 arend-lp-dev kernel: [   29.287222]  [<c1273de2>] ? kobject_del+0x22/0x30
Jan 16 16:12:51 arend-lp-dev kernel: [   29.287529]  [<c131e975>] ? device_del+0x125/0x150
Jan 16 16:12:51 arend-lp-dev kernel: [   29.287843]  [<c131ddf4>] put_device+0x14/0x20
Jan 16 16:12:51 arend-lp-dev kernel: [   29.288139]  [<c131e9b7>] device_unregister+0x17/0x20
Jan 16 16:12:51 arend-lp-dev kernel: [   29.288466]  [<c14a5256>] mce_cpu_callback+0xc3/0x155
Jan 16 16:12:51 arend-lp-dev kernel: [   29.288793]  [<c14b64a5>] notifier_call_chain+0x45/0x60
Jan 16 16:12:51 arend-lp-dev kernel: [   29.289130]  [<c1053e1e>] __raw_notifier_call_chain+0x1e/0x30
Jan 16 16:12:51 arend-lp-dev kernel: [   29.289492]  [<c1031fa4>] __cpu_notify+0x24/0x40
Jan 16 16:12:51 arend-lp-dev kernel: [   29.289797]  [<c10320cc>] cpu_notify_nofail+0x1c/0x30
Jan 16 16:12:51 arend-lp-dev kernel: [   29.290123]  [<c149929d>] _cpu_down+0xdd/0x250
Jan 16 16:12:51 arend-lp-dev kernel: [   29.290418]  [<c10321b4>] disable_nonboot_cpus+0x74/0x110
Jan 16 16:12:51 arend-lp-dev kernel: [   29.290763]  [<c1083183>] suspend_devices_and_enter+0x173/0x2e0
Jan 16 16:12:51 arend-lp-dev kernel: [   29.291133]  [<c108342c>] enter_state+0x13c/0x160
Jan 16 16:12:51 arend-lp-dev kernel: [   29.291440]  [<c10820aa>] state_store+0x8a/0x110
Jan 16 16:12:51 arend-lp-dev kernel: [   29.291744]  [<c1082020>] ? pm_trace_dev_match_show+0x20/0x20
Jan 16 16:12:51 arend-lp-dev kernel: [   29.292106]  [<c1273c2b>] kobj_attr_store+0x1b/0x30
Jan 16 16:12:51 arend-lp-dev kernel: [   29.292425]  [<c1177bb6>] sysfs_write_file+0xa6/0x100
Jan 16 16:12:51 arend-lp-dev kernel: [   29.292753]  [<c112047f>] vfs_write+0x8f/0x160
Jan 16 16:12:51 arend-lp-dev kernel: [   29.293048]  [<c1177b10>] ? sysfs_poll+0x80/0x80
Jan 16 16:12:51 arend-lp-dev kernel: [   29.293353]  [<c112075d>] sys_write+0x3d/0x70
Jan 16 16:12:51 arend-lp-dev kernel: [   29.293647]  [<c14b99df>] sysenter_do_call+0x12/0x28
Jan 16 16:12:51 arend-lp-dev kernel: [   29.293969] ---[ end trace 2172e4a3414a456d ]---
Jan 16 16:12:51 arend-lp-dev kernel: [   29.294358] Extended CMOS year: 2000
Jan 16 16:12:51 arend-lp-dev kernel: [   29.294850] ACPI: Low-level resume complete
Jan 16 16:12:51 arend-lp-dev kernel: [   29.303805] PM: Restoring platform NVS memory
Jan 16 16:12:51 arend-lp-dev kernel: [   29.313487] CPU0: Thermal monitoring handled by SMI
Jan 16 16:12:51 arend-lp-dev kernel: [   29.323835] Extended CMOS year: 2000
Jan 16 16:12:51 arend-lp-dev kernel: [   29.331436] Enabling non-boot CPUs ...
Jan 16 16:12:51 arend-lp-dev kernel: [   29.339449] Booting Node 0 Processor 1 APIC 0x4
Jan 16 16:12:51 arend-lp-dev kernel: [   29.349018] smpboot cpu 1: start_ip = 96000
Jan 16 16:12:51 arend-lp-dev kernel: [   29.368076] Initializing CPU#1
Jan 16 16:12:51 arend-lp-dev kernel: [   29.374474] CPU1: Thermal monitoring handled by SMI
Jan 16 16:12:51 arend-lp-dev kernel: [   29.384668] Calibrating delay loop (skipped) already calibrated this CPU
Jan 16 16:12:51 arend-lp-dev kernel: [   29.418661] CPU1 is up
Jan 16 16:12:51 arend-lp-dev kernel: [   29.424231] Booting Node 0 Processor 2 APIC 0x1
Jan 16 16:12:51 arend-lp-dev kernel: [   29.433796] smpboot cpu 2: start_ip = 96000
Jan 16 16:12:51 arend-lp-dev kernel: [   29.452775] Initializing CPU#2
Jan 16 16:12:51 arend-lp-dev kernel: [   29.459175] CPU2: Thermal monitoring handled by SMI
Jan 16 16:12:51 arend-lp-dev kernel: [   29.469367] Calibrating delay loop (skipped) already calibrated this CPU
Jan 16 16:12:51 arend-lp-dev kernel: [   29.503620] CPU2 is up
Jan 16 16:12:51 arend-lp-dev kernel: [   29.509235] Booting Node 0 Processor 3 APIC 0x5
Jan 16 16:12:51 arend-lp-dev kernel: [   29.518804] smpboot cpu 3: start_ip = 96000
Jan 16 16:12:51 arend-lp-dev kernel: [   29.537782] Initializing CPU#3
Jan 16 16:12:51 arend-lp-dev kernel: [   29.544180] CPU3: Thermal monitoring handled by SMI
Jan 16 16:12:51 arend-lp-dev kernel: [   29.554374] Calibrating delay loop (skipped) already calibrated this CPU
Jan 16 16:12:51 arend-lp-dev kernel: [   29.588799] CPU3 is up
Jan 16 16:12:51 arend-lp-dev kernel: [   29.596812] ACPI: Waking up from system sleep state S3
Jan 16 16:12:51 arend-lp-dev kernel: [   29.674203] ehci_hcd 0000:00:1a.0: wake-up capability disabled by ACPI
Jan 16 16:12:51 arend-lp-dev kernel: [   29.688278] ehci_hcd 0000:00:1d.0: wake-up capability disabled by ACPI
Jan 16 16:12:51 arend-lp-dev kernel: [   29.702906] PM: early resume of devices complete after 28.947 msecs
Jan 16 16:12:51 arend-lp-dev kernel: [   29.716520] ehci_hcd 0000:00:1a.0: setting latency timer to 64
Jan 16 16:12:51 arend-lp-dev kernel: [   29.716533] pci 0000:00:1e.0: setting latency timer to 64
Jan 16 16:12:51 arend-lp-dev kernel: [   29.740208] ehci_hcd 0000:00:1d.0: setting latency timer to 64
Jan 16 16:12:51 arend-lp-dev kernel: [   29.740236] e1000e 0000:00:19.0: wake-up capability disabled by ACPI
Jan 16 16:12:51 arend-lp-dev kernel: [   29.740269] ahci 0000:00:1f.2: setting latency timer to 64
Jan 16 16:12:51 arend-lp-dev kernel: [   29.740372] snd_hda_intel 0000:00:1b.0: irq 42 for MSI/MSI-X
Jan 16 16:12:51 arend-lp-dev kernel: [   29.740599] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
Jan 16 16:12:51 arend-lp-dev kernel: [   29.769722] firewire_ohci 0000:04:00.4: irq 44 for MSI/MSI-X
Jan 16 16:12:51 arend-lp-dev kernel: [   29.769958] firewire_core: skipped bus generations, destroying all nodes
Jan 16 16:12:51 arend-lp-dev kernel: [   29.863455] serial 00:08: activated
Jan 16 16:12:51 arend-lp-dev kernel: [   29.871831] Extended CMOS year: 2000
Jan 16 16:12:51 arend-lp-dev kernel: [   30.021390] usb 1-1.4: reset high-speed USB device number 5 using ehci_hcd
Jan 16 16:12:51 arend-lp-dev kernel: [   30.245011] usb 1-1.2: reset high-speed USB device number 4 using ehci_hcd
Jan 16 16:12:51 arend-lp-dev kernel: [   30.268745] firewire_core: rediscovered device fw0
Jan 16 16:12:51 arend-lp-dev kernel: [   30.383564] dell_wmi: Received unknown WMI event (0x11)
Jan 16 16:12:51 arend-lp-dev kernel: [   30.516494] usb 1-1.1: reset high-speed USB device number 3 using ehci_hcd
Jan 16 16:12:51 arend-lp-dev kernel: [   30.574062] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
Jan 16 16:12:51 arend-lp-dev kernel: [   30.627212] ata1.00: ACPI cmd ef/5a:00:00:00:00:a0 (SET FEATURES) succeeded
Jan 16 16:12:51 arend-lp-dev kernel: [   30.728834] ata1.00: ACPI cmd 00/00:00:00:00:00:a0 (NOP) rejected by device (Stat=0x51 Err=0x04)
Jan 16 16:12:51 arend-lp-dev kernel: [   30.803763] ata1.00: configured for UDMA/133
Jan 16 16:12:51 arend-lp-dev kernel: [   30.855809] sd 0:0:0:0: [sda] Starting disk
Jan 16 16:12:51 arend-lp-dev kernel: [   30.923815] usb 2-1.7: reset full-speed USB device number 3 using ehci_hcd
Jan 16 16:12:51 arend-lp-dev kernel: [   31.175196] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
Jan 16 16:12:51 arend-lp-dev kernel: [   31.232457] ata2.00: configured for UDMA/133
Jan 16 16:12:51 arend-lp-dev kernel: [   31.602454] ata5: SATA link down (SStatus 0 SControl 300)
Jan 16 16:12:51 arend-lp-dev kernel: [   31.981797] ata6: SATA link down (SStatus 0 SControl 300)
Jan 16 16:12:51 arend-lp-dev kernel: [   32.043966] PM: resume of devices complete after 2331.835 msecs
Jan 16 16:12:51 arend-lp-dev kernel: [   32.093540] PM: resume devices took 2.384 seconds
Jan 16 16:12:51 arend-lp-dev kernel: [   32.132899] PM: Finishing wakeup.
Jan 16 16:12:51 arend-lp-dev kernel: [   32.161537] Restarting tasks ... done.
Jan 16 16:12:51 arend-lp-dev kernel: [   32.194440] video LNXVIDEO:00: Restoring backlight state
Jan 16 16:12:52 arend-lp-dev kernel: [   32.478127] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
Jan 16 16:12:52 arend-lp-dev kernel: [   32.572872] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
Jan 16 16:12:52 arend-lp-dev kernel: [   32.615312] ADDRCONF(NETDEV_UP): eth0: link is not ready
Jan 16 16:12:52 arend-lp-dev kernel: [   33.072987] EXT4-fs (sda5): re-mounted. Opts: errors=remount-ro,commit=0
Jan 16 16:12:52 arend-lp-dev kernel: [   33.130491] EXT4-fs (sda7): re-mounted. Opts: commit=0
Jan 16 16:12:57 arend-lp-dev kernel: [   37.306898] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
Jan 16 16:12:57 arend-lp-dev kernel: [   37.428430] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready



--------------030704090203090400040109
Content-Type: text/plain;
 name=str-devices-3.2.0-08699-ga93ce74.log
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=str-devices-3.2.0-08699-ga93ce74.log

Jan 16 16:31:05 arend-lp-dev kernel: [   31.970129] eth0: no IPv6 routers present
Jan 16 16:32:35 arend-lp-dev kernel: [  121.206168] PM: Syncing filesystems ... done.
Jan 16 16:32:35 arend-lp-dev kernel: [  121.212149] PM: Preparing system for mem sleep
Jan 16 16:32:45 arend-lp-dev kernel: [  121.218917] Freezing user space processes ... (elapsed 0.01 seconds) done.
Jan 16 16:32:45 arend-lp-dev kernel: [  121.241792] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
Jan 16 16:32:45 arend-lp-dev kernel: [  121.261752] PM: Entering mem sleep
Jan 16 16:32:45 arend-lp-dev kernel: [  121.265688] sd 0:0:0:0: [sda] Synchronizing SCSI cache
Jan 16 16:32:45 arend-lp-dev kernel: [  121.271175] sd 0:0:0:0: [sda] Stopping disk
Jan 16 16:32:45 arend-lp-dev kernel: [  122.288913] serial 00:08: disabled
Jan 16 16:32:45 arend-lp-dev kernel: [  122.289156] serial 00:08: wake-up capability disabled by ACPI
Jan 16 16:32:45 arend-lp-dev kernel: [  122.296717] ACPI handle has no context!
Jan 16 16:32:45 arend-lp-dev kernel: [  122.462403] e1000e 0000:00:19.0: wake-up capability enabled by ACPI
Jan 16 16:32:45 arend-lp-dev kernel: [  122.735645] ACPI handle has no context!
Jan 16 16:32:45 arend-lp-dev kernel: [  122.751704] PM: suspend of devices complete after 1489.550 msecs
Jan 16 16:32:45 arend-lp-dev kernel: [  122.752076] PM: suspend devices took 1.492 seconds
Jan 16 16:32:45 arend-lp-dev kernel: [  122.752383] suspend debug: Waiting for 5 seconds.
Jan 16 16:32:45 arend-lp-dev kernel: [  127.704535] ehci_hcd 0000:00:1a.0: setting latency timer to 64
Jan 16 16:32:45 arend-lp-dev kernel: [  127.705016] ehci_hcd 0000:00:1d.0: setting latency timer to 64
Jan 16 16:32:45 arend-lp-dev kernel: [  127.705079] pci 0000:00:1e.0: setting latency timer to 64
Jan 16 16:32:45 arend-lp-dev kernel: [  127.720139] serial 00:08: activated
Jan 16 16:32:45 arend-lp-dev kernel: [  127.720612] ahci 0000:00:1f.2: setting latency timer to 64
Jan 16 16:32:45 arend-lp-dev kernel: [  127.724613] e1000e 0000:00:19.0: wake-up capability disabled by ACPI
Jan 16 16:32:45 arend-lp-dev kernel: [  127.724702] snd_hda_intel 0000:00:1b.0: irq 42 for MSI/MSI-X
Jan 16 16:32:45 arend-lp-dev kernel: [  127.724859] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
Jan 16 16:32:45 arend-lp-dev kernel: [  127.746911] Extended CMOS year: 2000
Jan 16 16:32:45 arend-lp-dev kernel: [  127.776912] firewire_ohci 0000:04:00.4: irq 44 for MSI/MSI-X
Jan 16 16:32:45 arend-lp-dev kernel: [  127.824410] firewire_core: skipped bus generations, destroying all nodes
Jan 16 16:32:45 arend-lp-dev kernel: [  127.948095] usb 2-1.8: reset full-speed USB device number 4 using ehci_hcd
Jan 16 16:32:45 arend-lp-dev kernel: [  128.379055] firewire_core: rediscovered device fw0
Jan 16 16:32:45 arend-lp-dev kernel: [  128.546605] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
Jan 16 16:32:45 arend-lp-dev kernel: [  128.601041] ata1.00: ACPI cmd 00/00:00:00:00:00:a0 (NOP) rejected by device (Stat=0x51 Err=0x04)
Jan 16 16:32:45 arend-lp-dev kernel: [  130.368669] ata1.00: ACPI cmd 00/00:00:00:00:00:a0 (NOP) rejected by device (Stat=0x51 Err=0x04)
Jan 16 16:32:45 arend-lp-dev kernel: [  130.442643] ata1.00: configured for UDMA/133
Jan 16 16:32:45 arend-lp-dev kernel: [  130.481050] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
Jan 16 16:32:45 arend-lp-dev kernel: [  130.558218] sd 0:0:0:0: [sda] Starting disk
Jan 16 16:32:45 arend-lp-dev kernel: [  130.877461] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
Jan 16 16:32:45 arend-lp-dev kernel: [  130.936864] ata2.00: configured for UDMA/133
Jan 16 16:32:45 arend-lp-dev kernel: [  131.308497] ata5: SATA link down (SStatus 0 SControl 300)
Jan 16 16:32:45 arend-lp-dev kernel: [  131.687650] ata6: SATA link down (SStatus 0 SControl 300)
Jan 16 16:32:45 arend-lp-dev kernel: [  131.749779] PM: resume of devices complete after 4054.352 msecs
Jan 16 16:32:45 arend-lp-dev kernel: [  131.799418] PM: resume devices took 4.104 seconds
Jan 16 16:32:45 arend-lp-dev kernel: [  131.838746] PM: Finishing wakeup.
Jan 16 16:32:45 arend-lp-dev kernel: [  131.866444] Restarting tasks ... done.
Jan 16 16:32:45 arend-lp-dev kernel: [  131.903604] video LNXVIDEO:00: Restoring backlight state



--------------030704090203090400040109--

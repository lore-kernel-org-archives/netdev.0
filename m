From: Borislav Petkov <bp@alien8.de>
Subject: e1000e 3.9-rc1 suspend failure (was: Re: e1000e: nic does not work
 properly after cold power on)
Date: Mon, 4 Mar 2013 22:48:30 +0100
Message-ID: <20130304214830.GB22306@pd.tnic>
References: <20130304124631.2ac730f3@mdontu-l.dsd.ro>
 <5134E4AB.2010504@imt-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Mihai =?utf-8?B?RG9uyJt1?= <mihai.dontu@gmail.com>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jiri Slaby <jslaby@suse.cz>
To: Morten Stevens <mstevens@imt-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skyhub.de ([78.46.96.112]:37835 "EHLO mail.skyhub.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932538Ab3CDVsr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Mar 2013 16:48:47 -0500
Content-Disposition: inline
In-Reply-To: <5134E4AB.2010504@imt-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 04, 2013 at 07:15:07PM +0100, Morten Stevens wrote:
> Can you reproduce this with linux 3.9-rc1? 3.9-rc1 has the latest
> upstream driver (e1000e 2.2.14) which contains many bugfixes.

This e1000e thing gets more b0rked by the minute. This is what happens
when I try to suspend with 3.9-rc1:

[   83.502908] PM: Syncing filesystems ... done.
[   83.509886] Freezing user space processes ... (elapsed 0.01 seconds) done.
[   83.523352] PM: Preallocating image memory... done (allocated 95652 pages)
[   83.675083] PM: Allocated 382608 kbytes in 0.15 seconds (2550.72 MB/s)
[   83.675782] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[   83.688524] Suspending console(s) (use no_console_suspend to debug)
[   84.251024] e1000e 0000:00:19.0 eth0: Hardware Error
[   84.458866] ------------[ cut here ]------------
[   84.458871] WARNING: at kernel/irq/manage.c:1249 __free_irq+0xa3/0x1e0()
[   84.458872] Hardware name: 2320CTO
[   84.458872] Trying to free already-free IRQ 20
[   84.458898] Modules linked in: cpufreq_powersave cpufreq_userspace cpufreq_conservative cpufreq_stats uinput loop hid_generic usb
hid hid coretemp kvm_intel arc4 kvm crc32_pclmul iwldvm crc32c_intel ghash_clmulni_intel mac80211 aesni_intel xts ipv6 aes_x86_64 lr
w gf128mul ablk_helper cryptd iTCO_wdt iTCO_vendor_support iwlwifi sdhci_pci sdhci cfg80211 snd_hda_codec_hdmi snd_hda_codec_realtek
 mmc_core microcode e1000e thinkpad_acpi pcspkr lpc_ich i2c_i801 mfd_core nvram snd_hda_intel rfkill snd_hda_codec battery ac snd_hw
dep led_class snd_pcm snd_page_alloc snd_timer snd acpi_cpufreq soundcore mperf ptp wmi pps_core xhci_hcd ehci_pci ehci_hcd processo
r thermal
[   84.458900] Pid: 3353, comm: kworker/u:35 Tainted: G        W    3.9.0-rc1 #1
[   84.458901] Call Trace:
[   84.458905]  [<ffffffff8103ef7f>] warn_slowpath_common+0x7f/0xc0
[   84.458907]  [<ffffffff8103f076>] warn_slowpath_fmt+0x46/0x50
[   84.458910]  [<ffffffff81537bfe>] ? _raw_spin_lock_irqsave+0x4e/0x60
[   84.458911]  [<ffffffff810bc8d5>] ? __free_irq+0x55/0x1e0
[   84.458913]  [<ffffffff810bc923>] __free_irq+0xa3/0x1e0
[   84.458914]  [<ffffffff810bcab4>] free_irq+0x54/0xc0
[   84.458919]  [<ffffffffa017745d>] e1000_free_irq+0x7d/0x90 [e1000e]
[   84.458922]  [<ffffffffa01834af>] __e1000_shutdown+0x8f/0x8a0 [e1000e]
[   84.458924]  [<ffffffff813c92a7>] ? __device_suspend+0xb7/0x200
[   84.458927]  [<ffffffff81073b71>] ? get_parent_ip+0x11/0x50
[   84.458931]  [<ffffffffa0183d33>] e1000_suspend+0x23/0x50 [e1000e]
[   84.458932]  [<ffffffff813c92a7>] ? __device_suspend+0xb7/0x200
[   84.458933]  [<ffffffff8153c049>] ? sub_preempt_count+0x79/0xd0
[   84.458936]  [<ffffffff812a2ff5>] pci_pm_freeze+0x55/0xc0
[   84.458937]  [<ffffffff812a2fa0>] ? pci_pm_resume_noirq+0xd0/0xd0
[   84.458938]  [<ffffffff813c8b45>] dpm_run_callback.isra.5+0x25/0x50
[   84.458939]  [<ffffffff813c92d3>] __device_suspend+0xe3/0x200
[   84.458941]  [<ffffffff813c940f>] async_suspend+0x1f/0xa0
[   84.458942]  [<ffffffff8106bcfb>] async_run_entry_fn+0x3b/0x140
[   84.458944]  [<ffffffff8105d00d>] process_one_work+0x1ed/0x510
[   84.458946]  [<ffffffff8105cfab>] ? process_one_work+0x18b/0x510
[   84.458948]  [<ffffffff8105e7b5>] worker_thread+0x115/0x390
[   84.458949]  [<ffffffff8105e6a0>] ? manage_workers+0x300/0x300
[   84.458951]  [<ffffffff81064e2a>] kthread+0xea/0xf0
[   84.458953]  [<ffffffff81064d40>] ? kthread_create_on_node+0x160/0x160
[   84.458954]  [<ffffffff8153ff9c>] ret_from_fork+0x7c/0xb0
[   84.458955]  [<ffffffff81064d40>] ? kthread_create_on_node+0x160/0x160
[   84.458956] ---[ end trace 3114e23ce50d2357 ]---
[   85.082276] pci_pm_freeze(): e1000_suspend+0x0/0x50 [e1000e] returns -2
[   85.082278] dpm_run_callback(): pci_pm_freeze+0x0/0xc0 returns -2
[   85.082281] PM: Device 0000:00:19.0 failed to freeze async: error -2

Let's add more folks to CC.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

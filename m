From: c4p7n1@capitanio.org
Subject: Re: [BUG or cosmic ray] WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0xe8/0x100()
Date: Sat, 14 Jun 2008 01:08:14 +0200 (MEST)
Message-ID: <200806132308.m5DN8EM2012376@post.webmailer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Andrew Morton" <akpm@linux-foundation.org>, c4p7n1@capitanio.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759273AbYFMXId@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


----- original message --------

Subject: Re: [BUG or cosmic ray] WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0xe8/0x100()
Sent: Fri, 06 Jun 2008
From: Andrew Morton<akpm@linux-foundation.org>

> (cc netdev)
> 
> On Thu, 5 Jun 2008 09:27:36 +0200 (MEST) c4p7n1@capitanio.org wrote:
> 
> > I've got this on rc3. It's _not_ reproducible even on heavy load.
> > After that the Ethernet PCIe chip went into a borken state until next
> reboot.
> > 
> > [   46.316926] r8169: eth0: link up
> > [   48.901435] [drm] Initialized drm 1.1.0 20060810
> > [   48.904771] PCI: Setting latency timer of device 0000:00:02.0 to 64
> > [   48.908103] [drm] Initialized i915 1.6.0 20060119 on minor 0
> > [   49.544674] NET: Registered protocol family 17
> > [  125.004020] NETDEV WATCHDOG: eth0: transmit timed out
> > [  125.004043] ------------[ cut here ]------------
> > [  125.004049] WARNING: at net/sched/sch_generic.c:222
> dev_watchdog+0xe8/0x100()
> > [  125.004053] Modules linked in: af_packet i915 drm rfcomm l2cap
> bluetooth acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_userspace
> cpufreq_conservative wmi sbs sbshc iptable_filter ip_tables x_tables fuse
> usbhid hid joydev snd_hda_intel snd_pcm_oss snd_mixer_oss snd_pcm
> snd_page_alloc snd_hwdep snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi
> snd_seq_midi_event snd_seq video psmouse output snd_timer snd_seq_device snd
> r8169 backlight evdev soundcore uhci_hcd ehci_hcd iTCO_wdt
> iTCO_vendor_support usbcore
> > [  125.004143] Pid: 0, comm: swapper Not tainted
> 2.6.26-rc3c4p7n1-00308-g75d3bce #1
> > [  125.004153]  [<c0125aaf>] warn_on_slowpath+0x5f/0x90
> > [  125.004168]  [<c0138e00>] autoremove_wake_function+0x0/0x40
> > [  125.004179]  [<c011ae7b>] __wake_up_common+0x4b/0x80
> > [  125.004192]  [<c011ccae>] __wake_up+0x3e/0x60
> > [  125.004201]  [<c012626b>] wake_up_klogd+0x3b/0x40
> > [  125.004209]  [<c0126966>] vprintk+0x346/0x3b0
> > [  125.004221]  [<c012ee47>] lock_timer_base+0x27/0x60
> > [  125.004230]  [<c0135e10>] delayed_work_timer_fn+0x0/0x20
> > [  125.004238]  [<c012ef8d>] __mod_timer+0x9d/0xb0
> > [  125.004248]  [<c0136044>] queue_delayed_work_on+0x84/0xc0
> > [  125.004258]  [<c0392818>] dev_watchdog+0xe8/0x100
> > [  125.004267]  [<c012e8de>] run_timer_softirq+0x15e/0x1d0
> > [  125.004274]  [<c0392730>] dev_watchdog+0x0/0x100
> > [  125.004282]  [<c0142870>] tick_handle_oneshot_broadcast+0x100/0x120
> > [  125.004292]  [<c0392730>] dev_watchdog+0x0/0x100
> > [  125.004302]  [<c012ab13>] __do_softirq+0x63/0xc0
> > [  125.004310]  [<c012aba7>] do_softirq+0x37/0x40
> > [  125.004317]  [<c012ad18>] irq_exit+0x68/0x80
> > [  125.004323]  [<c0106370>] do_IRQ+0x40/0x70
> > [  125.004333]  [<c0104767>] common_interrupt+0x23/0x28
> > [  125.004344]  [<c01300d8>] prepare_signal+0x28/0x170
> > [  125.004352]  [<c02e67ed>] acpi_idle_enter_bm+0x28c/0x2f6
> > [  125.004365]  [<c0372cab>] cpuidle_idle_call+0x7b/0xc0
> > [  125.004373]  [<c0372c30>] cpuidle_idle_call+0x0/0xc0
> > [  125.004381]  [<c010275a>] cpu_idle+0x5a/0xe0
> > [  125.004395]  =======================
> > [  125.004399] ---[ end trace b7a56030e016660f ]---
> > [  125.682725] r8169: eth0: link up
> > ...
> > [ 1337.654531] NETDEV WATCHDOG: eth0: transmit timed out
> > [ 1338.333962] r8169: eth0: link up
...

Definitely a bug. I've got the same lock-up a second time on a rc5.

It may be related to a patch:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=21e197f231343201368338603cb0909a13961bac

Before that patch on this chip [10ec:8136] the r8169 driver crashed with a null pointer exception.
Strangely, on a .22  kernel came out (at that time always) the same lspci error:
02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8101E PCI Express Fast Ethernet controller (rev ff) (prog-if ff)
 !!! Unknown header type 7f

... just my observations ;-) 

[   73.907680] [drm] Initialized drm 1.1.0 20060810
[   73.914556] ACPI: PCI Interrupt 0000:00:02.0[A] -> GSI 16 (level, low) -> IRQ 16
[   73.914556] PCI: Setting latency timer of device 0000:00:02.0 to 64
[   73.914556] [drm] Initialized i915 1.6.0 20060119 on minor 0
[   73.942485] NET: Registered protocol family 17
[  168.360223] NETDEV WATCHDOG: eth0: transmit timed out
[  168.360245] ------------[ cut here ]------------
[  168.360250] WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0xe8/0x100()
[  168.360255] Modules linked in: af_packet i915 drm rfcomm l2cap bluetooth acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_userspace cpufreq_conservative wmi sbs sbshc iptable_filter ip_tables x_tables fuse uvcvideo compat_ioctl32 videodev v4l1_compat joydev snd_hda_intel snd_pcm_oss snd_mixer_oss video output snd_pcm snd_page_alloc snd_hwdep snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi evdev backlight snd_seq_midi_event ehci_hcd snd_seq iTCO_wdt psmouse uhci_hcd r8169 iTCO_vendor_support usbcore snd_timer snd_seq_device snd soundcore
[  168.360349] Pid: 0, comm: swapper Not tainted 2.6.26-rc5c4p7n1-00005-g2423a99 #2
[  168.360358]  [<c01255ef>] warn_on_slowpath+0x5f/0x90
[  168.360374]  [<c0138a00>] __wake_up_bit+0x10/0x40
[  168.360384]  [<c011ae3b>] __wake_up_common+0x4b/0x80
[  168.360397]  [<c011cb5e>] __wake_up+0x3e/0x60
[  168.360407]  [<c0125dab>] wake_up_klogd+0x3b/0x40
[  168.360415]  [<c0126496>] vprintk+0x346/0x3b0
[  168.360428]  [<c012e997>] lock_timer_base+0x27/0x60
[  168.360437]  [<c0135a70>] delayed_work_timer_fn+0x0/0x20
[  168.360446]  [<c012eadd>] __mod_timer+0x9d/0xb0
[  168.360456]  [<c0135ca4>] queue_delayed_work_on+0x84/0xc0
[  168.360466]  [<c0392ea8>] dev_watchdog+0xe8/0x100
[  168.360476]  [<c012e42e>] run_timer_softirq+0x15e/0x1d0
[  168.360484]  [<c0392dc0>] dev_watchdog+0x0/0x100
[  168.360492]  [<c0142410>] tick_handle_oneshot_broadcast+0x100/0x120
[  168.360503]  [<c0392dc0>] dev_watchdog+0x0/0x100
[  168.360513]  [<c012a663>] __do_softirq+0x63/0xc0
[  168.360522]  [<c012a6f7>] do_softirq+0x37/0x40
[  168.360529]  [<c012a868>] irq_exit+0x68/0x80
[  168.360535]  [<c0106360>] do_IRQ+0x40/0x70
[  168.360546]  [<c0104757>] common_interrupt+0x23/0x28
[  168.360558]  [<c01300d8>] copy_siginfo_to_user+0x118/0x1c0
[  168.360566]  [<c02e9141>] acpi_idle_enter_bm+0x28c/0x2f6
[  168.360580]  [<c037336b>] cpuidle_idle_call+0x7b/0xc0
[  168.360589]  [<c03732f0>] cpuidle_idle_call+0x0/0xc0
[  168.360597]  [<c010275a>] cpu_idle+0x5a/0xe0
[  168.360613]  =======================
[  168.360617] ---[ end trace 7867442bfd8a77ab ]---
[  169.040298] r8169: eth0: link up
[  222.360232] NETDEV WATCHDOG: eth0: transmit timed out
[  223.040764] r8169: eth0: link up
[  288.360222] NETDEV WATCHDOG: eth0: transmit timed out
[  289.041086] r8169: eth0: link up
[  361.013534] NETDEV WATCHDOG: eth0: transmit timed out
[  361.693566] r8169: eth0: link up
[  439.013739] NETDEV WATCHDOG: eth0: transmit timed out
[  439.694368] r8169: eth0: link up
[  517.013499] NETDEV WATCHDOG: eth0: transmit timed out
[  517.693589] r8169: eth0: link up
[  595.014014] NETDEV WATCHDOG: eth0: transmit timed out
[  595.694365] r8169: eth0: link up
[  673.013510] NETDEV WATCHDOG: eth0: transmit timed out
[  673.694132] r8169: eth0: link up
[  805.016284] NETDEV WATCHDOG: eth0: transmit timed out
[  805.694119] r8169: eth0: link up
[  883.013490] NETDEV WATCHDOG: eth0: transmit timed out
[  883.694028] r8169: eth0: link up
[  961.013477] NETDEV WATCHDOG: eth0: transmit timed out
[  961.694091] r8169: eth0: link up
[ 1039.014801] NETDEV WATCHDOG: eth0: transmit timed out
[ 1039.693903] r8169:

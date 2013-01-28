From: Richard Hartmann <richih.mailinglist-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: drivers/net/wireless/iwlwifi/dvm/tx.c: Kernel trace when roaming
 between different Access Points with the same ESSID
Date: Mon, 28 Jan 2013 22:55:25 +0100
Message-ID: <CAD77+gT-sLRfVK2-WJxSXg-JveRGiRqkzs00Js2vH5w=gh92Ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi all,


I can somewhat reproduce this trace. It will happen when roaming from
one AP to another AP, both having the same ESSID.

Once this happens, wireless stops working. This can be fixed by running

  rmmod iwldvm iwlwifi mac80211 cfg80211; sleep 10; modprobe iwlwifi


Trace:

[ 8920.123776] ------------[ cut here ]------------
[ 8920.123797] WARNING: at
/build/buildd-linux_3.7.1-1~experimental.1-i386-Au6THQ/linux-3.7.1/drivers/net/wireless/iwlwifi/dvm/tx.c:1189
iwlagn_rx_reply_tx+0x288/0x6e2 [iwldvm]()
[ 8920.123800] Hardware name: 4286CTO
[ 8920.123802] Modules linked in: parport_pc ppdev lp parport bnep
rfcomm cpufreq_userspace cpufreq_stats cpufreq_powersave
cpufreq_conservative uinput nfsd auth_rpcgss nfs_acl nfs lockd
dns_resolver fscache sunrpc ext4 jbd2 mbcache loop fuse
snd_hda_codec_hdmi snd_hda_codec_conexant arc4 coretemp i915
snd_hda_intel iwldvm mac80211 joydev drm_kms_helper drm snd_hda_codec
snd_hwdep snd_pcm i2c_algo_bit kvm_intel btusb kvm thinkpad_acpi
snd_page_alloc nvram bluetooth i2c_i801 iwlwifi crc32c_intel crc16
snd_seq snd_seq_device snd_timer iTCO_wdt acpi_cpufreq mperf
aesni_intel iTCO_vendor_support i2c_core psmouse pcspkr snd aes_i586
xts lrw ac soundcore battery lpc_ich evdev mei tpm_tis gf128mul
ablk_helper video serio_raw mfd_core button cfg80211 rfkill tpm cryptd
tpm_bios processor wmi xfs sg sd_mod crc_t10dif mmc_block microcode
ahci libahci xhci_hcd libata sdhci_pci sdhci mmc_core scsi_mod
ehci_hcd e1000e usbcore usb_common thermal thermal_sys
[ 8920.123891] Pid: 0, comm: swapper/0 Not tainted 3.7-trunk-686-pae
#1 Debian 3.7.1-1~experimental.1
[ 8920.123893] Call Trace:
[ 8920.123902]  [<c10310c5>] ? warn_slowpath_common+0x68/0x79
[ 8920.123912]  [<f86961e2>] ? iwlagn_rx_reply_tx+0x288/0x6e2 [iwldvm]
[ 8920.123916]  [<c10310e3>] ? warn_slowpath_null+0xd/0x10
[ 8920.123924]  [<f86961e2>] ? iwlagn_rx_reply_tx+0x288/0x6e2 [iwldvm]
[ 8920.123929]  [<c10574b0>] ? load_balance+0x33c/0x520
[ 8920.123940]  [<f869b344>] ? iwl_rx_dispatch+0x57/0x63 [iwldvm]
[ 8920.123948]  [<f85b0d14>] ? iwl_irq_tasklet+0x39c/0x698 [iwlwifi]
[ 8920.123953]  [<c1037457>] ? tasklet_action+0x62/0xa5
[ 8920.123957]  [<c103711b>] ? __do_softirq+0x90/0x192
[ 8920.123961]  [<c103708b>] ? perf_trace_irq_handler_entry+0xd7/0xd7
[ 8920.123962]  <IRQ>  [<c10372cb>] ? irq_exit+0x32/0x7d
[ 8920.123971]  [<c100d070>] ? do_IRQ+0x65/0x76
[ 8920.123976]  [<c12ed2f3>] ? common_interrupt+0x33/0x38
[ 8920.123980]  [<c10300d8>] ? copy_process.part.33+0x8a8/0xf0c
[ 8920.123985]  [<c11b1c03>] ? intel_idle+0xc4/0xec
[ 8920.123990]  [<c122ea2e>] ? cpuidle_enter+0xb/0xe
[ 8920.123994]  [<c122edb9>] ? cpuidle_enter_state+0x9/0x33
[ 8920.123998]  [<c122ee8e>] ? cpuidle_idle_call+0xab/0x146
[ 8920.124002]  [<c10114d7>] ? cpu_idle+0x88/0xac
[ 8920.124006]  [<c1464966>] ? start_kernel+0x334/0x339
[ 8920.124009] ---[ end trace fc6895e52f152baf ]---


lspci:

00:00.0 Host bridge: Intel Corporation 2nd Generation Core Processor
Family DRAM Controller (rev 09)
00:02.0 VGA compatible controller: Intel Corporation 2nd Generation
Core Processor Family Integrated Graphics Controller (rev 09)
00:16.0 Communication controller: Intel Corporation 6 Series/C200
Series Chipset Family MEI Controller #1 (rev 04)
00:16.3 Serial controller: Intel Corporation 6 Series/C200 Series
Chipset Family KT Controller (rev 04)
00:19.0 Ethernet controller: Intel Corporation 82579LM Gigabit Network
Connection (rev 04)
00:1a.0 USB controller: Intel Corporation 6 Series/C200 Series Chipset
Family USB Enhanced Host Controller #2 (rev 04)
00:1b.0 Audio device: Intel Corporation 6 Series/C200 Series Chipset
Family High Definition Audio Controller (rev 04)
00:1c.0 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset
Family PCI Express Root Port 1 (rev b4)
00:1c.1 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset
Family PCI Express Root Port 2 (rev b4)
00:1c.3 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset
Family PCI Express Root Port 4 (rev b4)
00:1c.4 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset
Family PCI Express Root Port 5 (rev b4)
00:1c.6 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset
Family PCI Express Root Port 7 (rev b4)
00:1d.0 USB controller: Intel Corporation 6 Series/C200 Series Chipset
Family USB Enhanced Host Controller #1 (rev 04)
00:1f.0 ISA bridge: Intel Corporation QM67 Express Chipset Family LPC
Controller (rev 04)
00:1f.2 SATA controller: Intel Corporation 6 Series/C200 Series
Chipset Family 6 port SATA AHCI Controller (rev 04)
00:1f.3 SMBus: Intel Corporation 6 Series/C200 Series Chipset Family
SMBus Controller (rev 04)
03:00.0 Network controller: Intel Corporation Centrino Ultimate-N 6300 (rev 35)
0d:00.0 System peripheral: Ricoh Co Ltd PCIe SDXC/MMC Host Controller (rev 07)
0e:00.0 USB controller: NEC Corporation uPD720200 USB 3.0 Host
Controller (rev 04)


If you need any more info, please let me know; I am not subscribed on
all lists so please keep me CC'ed.



Thanks,
Richard
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

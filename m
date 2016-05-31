From: Grey Christoforo <grey@christoforo.net>
Subject: 4.7-rc1 wifi driver bug report
Date: Tue, 31 May 2016 12:46:39 +0100
Message-ID: <CADbsYN1w2DT58fwuGcqSK91Dz_-GMxX5H6boULN2WZ0fbPs50w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I found the following in my dmesg today when I tried out 4.7-rc1 on my
Dell XPS15 9550. My WiFi doesn't work.

Relevant bits of my lsusb & lspci are:

$ lsusb
=2E..
Bus 001 Device 002: ID 0a5c:6410 Broadcom Corp.
=2E..
$ lspci
=2E..
02:00.0 Network controller: Broadcom Corporation BCM43602 802.11ac
Wireless LAN SoC (rev 01)
=2E..

and here's the first BUG from from dmesg:

BUG: unable to handle kernel NULL pointer dereference at 00000000000000=
48
IP: [<ffffffff814c3ce6>] enqueue_to_backlog+0x56/0x260
PGD 0
Oops: 0000 [#1] PREEMPT SMP
Modules linked in: fuse ipt_MASQUERADE nf_nat_masquerade_ipv4
iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 xt_addrtype
iptable_filter xt_conntrack nf_nat nf_conntrack br_netfilter bridge
stp llc snd_hda_codec_hdmi nls_iso8859_1 nls_cp437 vfat fat
snd_hda_codec_realtek snd_hda_codec_generic joydev mousedev mei_wdt
uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_v4l2
i2c_designware_platform videobuf2_core i2c_designware_core
hid_multitouch hid_generic videodev dell_laptop media cdc_acm
dell_smbios mxm_wmi dcdbas x86_pkg_temp_thermal intel_powerclamp
coretemp kvm_intel kvm irqbypass crct10dif_pclmul crc32_pclmul
ghash_clmulni_intel aesni_intel btusb btrtl aes_x86_64 lrw gf128mul
glue_helper ablk_helper cryptd evdev input_leds led_class
snd_hda_intel psmouse mac_hid snd_hda_codec
serio_raw pcspkr brcmfmac snd_hda_core snd_hwdep i915 i2c_i801 idma64
brcmutil snd_pcm snd_timer drm_kms_helper snd cfg80211 soundcore
rtsx_pci_ms drm memstick mei_me intel_gtt syscopyarea usbhid
sysfillrect sysimgblt mei intel_lpss_pci processor_thermal_device
fb_sys_fops i2c_hid i2c_algo_bit intel_soc_dts_iosf fan shpchp thermal
hid battery hci_uart btbcm btqca btintel bluetooth int3403_thermal
dell_smo8800 wmi video pinctrl_sunrisepoint rfkill pinctrl_intel crc16
intel_lpss_acpi intel_hid intel_lpss int3400_thermal int3402_thermal
acpi_thermal_rel int340x_thermal_zone button acpi_pad ac sparse_keymap
acpi_als kfifo_buf industrialio tpm_tis fjes tpm sch_fq_codel
ip_tables x_tables btrfs xor raid6_pq rtsx_pci_sdmmc mmc_core atkbd
libps2 crc32c_intel ahci libahci xhci_pci libata xhci_hcd
rtsx_pci scsi_mod usbcore usb_common i8042 serio nvme nvme_core
CPU: 7 PID: 1340 Comm: irq/136-brcmf_p Not tainted 4.7.0-rc1-mainline #=
1
Hardware name: Dell Inc. XPS 15 9550/0N7TVV, BIOS 01.02.00 04/07/2016
task: ffff8804a0c5bd00 ti: ffff88049e124000 task.ti: ffff88049e124000
RIP: 0010:[<ffffffff814c3ce6>] [<ffffffff814c3ce6>]
enqueue_to_backlog+0x56/0x260
RSP: 0018:ffff88049e127ca0 EFLAGS: 00010046
RAX: 0000000000000000 RBX: ffff8804bddd7c40 RCX: 000000000000002f
RDX: 0000000000000000 RSI: 0000000000000007 RDI: ffff8804bddd7d4c
RBP: ffff88049e127ce8 R08: 0000000000000000 R09: 0000000000000000
R10: ffff8804bddd12c0 R11: 000000000000149e R12: 0000000000017c40
R13: ffff88049e127d08 R14: ffff8804a9bd6d00 R15: ffff8804bddd7d4c
=46S: 0000000000000000(0000) GS:ffff8804bddc0000(0000) knlGS:0000000000=
000000
CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000048 CR3: 0000000001806000 CR4: 00000000003406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Stack:
ffff8804bdddad00 ffff8804ad089e00 0000000000000000 0000000000000282
0000000000000000 ffff8804a9bd6d00 ffff8804a1b27e00 ffff8804a9bd6d00
ffff88002ee88000 ffff88049e127d28 ffffffff814c3f3b ffffffff81311fc3
Call Trace:
[<ffffffff814c3f3b>] netif_rx_internal+0x4b/0x170
[<ffffffff81311fc3>] ? swiotlb_tbl_unmap_single+0xf3/0x120
[<ffffffff814c5467>] netif_rx_ni+0x27/0xc0
[<ffffffffa08519e9>] brcmf_netif_rx+0x49/0x70 [brcmfmac]
[<ffffffffa08564d4>] brcmf_msgbuf_process_rx+0x2b4/0x570 [brcmfmac]
[<ffffffff81020017>] ? __xen_set_pgd_hyper+0x57/0xd0
[<ffffffff810d60b0>] ? irq_forced_thread_fn+0x70/0x70
[<ffffffffa0857381>] brcmf_proto_msgbuf_rx_trigger+0x31/0xe0 [brcmfmac]
[<ffffffffa0861e8f>] brcmf_pcie_isr_thread+0x7f/0x110 [brcmfmac]
[<ffffffff810d60d0>] irq_thread_fn+0x20/0x50
[<ffffffff810d63ad>] irq_thread+0x12d/0x1c0
[<ffffffff815d07d5>] ? __schedule+0x2f5/0x7a0
[<ffffffff810d61d0>] ? wake_threads_waitq+0x30/0x30
[<ffffffff810d6280>] ? irq_thread_dtor+0xb0/0xb0
[<ffffffff81098ea8>] kthread+0xd8/0xf0
[<ffffffff815d4b7f>] ret_from_fork+0x1f/0x40
[<ffffffff81098dd0>] ? kthread_worker_fn+0x170/0x170
Code: 1c f5 60 9a 8e 81 9c 58 0f 1f 44 00 00 48 89 45 d0 fa 66 0f 1f
44 00 00 4c 8d bb 0c 01 00 00 4c 89 ff e8 5e 08 11 00 49 8b 56 20 <48>
8b 52 48 83 e2 01 74 10 8b 8b 08 01 00 00 8b 15 59 c5 42 00
RIP [<ffffffff814c3ce6>] enqueue_to_backlog+0x56/0x260
RSP <ffff88049e127ca0>
CR2: 0000000000000048
---[ end trace df3126016b38615b ]---

Cheers,
=C2=ACgrey

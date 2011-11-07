From: Josh Boyer <jwboyer@redhat.com>
Subject: softirq oops from b44_poll
Date: Mon, 7 Nov 2011 15:56:47 -0500
Message-ID: <20111107205647.GC14216@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, kernel-team@fedoraproject.org
To: Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

We've had two reports of a WARN_ON being spit out from kernel/softirq.c
that seem fairly related in symptoms.  Both seem to involved b44_poll
either during the middle of some disk I/O.  An example of the output is
here:

:WARNING: at kernel/softirq.c:159 _local_bh_enable_ip+0x44/0x8e()
:Hardware name: Vostro 1500                     
:Modules linked in: fuse lockd ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6
ip6table_filter ip6_tables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state
nf_conntrack sunrpc uinput snd_hda_codec_idt snd_hda_intel snd_hda_codec
snd_hwdep snd_seq snd_seq_device snd_pcm dell_wmi sparse_keymap dell_laptop
joydev dcdbas microcode r852 sm_common nand nand_ids b44 nand_ecc r592 mtd ssb
mii memstick arc4 i2c_i801 iTCO_wdt iTCO_vendor_support iwl3945 iwl_legacy
mac80211 cfg80211 rfkill snd_timer snd soundcore snd_page_alloc firewire_ohci
firewire_core crc_itu_t uas usb_storage sdhci_pci sdhci mmc_core nouveau ttm
drm_kms_helper drm i2c_algo_bit i2c_core mxm_wmi wmi video [last unloaded:
scsi_wait_scan]
:Pid: 1511, comm: nepomukservices Not tainted 3.1.0-1.fc16.x86_64 #1
:Call Trace:
: <IRQ>  [<ffffffff81057a56>] warn_slowpath_common+0x83/0x9b
: [<ffffffff81057a88>] warn_slowpath_null+0x1a/0x1c
: [<ffffffff8105d462>] _local_bh_enable_ip+0x44/0x8e
: [<ffffffff8105d4ba>] local_bh_enable_ip+0xe/0x10
: [<ffffffff814b5af4>] _raw_spin_unlock_bh+0x15/0x17
: [<ffffffffa03cc969>] destroy_conntrack+0x9d/0xdc [nf_conntrack]
: [<ffffffff813fa083>] nf_conntrack_destroy+0x19/0x1b
: [<ffffffff813ce4ed>] skb_release_head_state+0xa7/0xef
: [<ffffffff813ce2f1>] __kfree_skb+0x13/0x83
: [<ffffffff813ce3b7>] consume_skb+0x56/0x6b
: [<ffffffffa02e48c4>] b44_poll+0xaf/0x3ec [b44]
: [<ffffffff813d8137>] net_rx_action+0xa9/0x1b8
: [<ffffffffa02e202e>] ? br32+0x19/0x1d [b44]
: [<ffffffff8105d6b3>] __do_softirq+0xc9/0x1b5
: [<ffffffff81027719>] ? ack_APIC_irq+0x15/0x17
: [<ffffffff814be32c>] call_softirq+0x1c/0x30
: [<ffffffff81010b45>] do_softirq+0x46/0x81
: [<ffffffff8105d97b>] irq_exit+0x57/0xb1
: [<ffffffff814bec0e>] do_IRQ+0x8e/0xa5
: [<ffffffff814b5d2e>] common_interrupt+0x6e/0x6e
: <EOI>  [<ffffffff814bc1f4>] ? sysret_audit+0x16/0x20

You can find the original bug reports in the URLs below.  This has happened
on two different machines, one 32-bit and another 64-bit.  I'm fairly sure
both reports are the same issue, but I haven't a clue what that issue might
be at the moment.

Thoughts?

https://bugzilla.redhat.com/show_bug.cgi?id=749856
https://bugzilla.redhat.com/show_bug.cgi?id=741117

josh

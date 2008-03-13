From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: netconsole still hangs
Date: Wed, 12 Mar 2008 23:52:05 -0700
Message-ID: <20080312235205.dcec2d35.akpm@linux-foundation.org>
References: <20080312161637.b082b515.akpm@linux-foundation.org>
	<20080312163013.aaf07aa0.akpm@linux-foundation.org>
	<20080312165717.c0879b1d.akpm@linux-foundation.org>
	<20080312.231053.216645957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	rjw@sisk.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52087 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751715AbYCMGxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 02:53:00 -0400
In-Reply-To: <20080312.231053.216645957.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Mar 2008 23:10:53 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 12 Mar 2008 16:57:17 -0700
> 
> > I reran the test on 2.6.24 and all seemed fine: the machine didn't hang and
> > stopping the script stopped the netconsole output.
> 
> Can you go back and bisect the tree in one shot to the guilty
> commit you found last time,

That was 33f807ba0d9259e7c75c7a2ce8bd2787e5b540c7

> and make sure this test case works at that point?

argh, I'm too git-stupid to know how to get a tree which ends just prior to
33f807ba0d9259e7c75c7a2ce8bd2787e5b540c7.  Help?

> With the current data points available, the only conclusion
> I have is that I somehow mis-reverted the changes or missed
> some important detail.  Because, you said that the problem
> went away when you bisected to that specific point.

Whine.  I can _trivially_ reproduce this stuff on the two machines which I
tried it on.  Has anyone over in net land actually expended some cycles
trying to reproduce these things?


I tried it on the t61p and actually got an oops:

general protection fault: 0000 [1] SMP 
last sysfs file: /sys/class/net/wlan0/address
CPU 0 
Modules linked in: autofs4 sunrpc nf_conntrack_ipv4 ipt_REJECT iptable_filter ip_tables nf_conntrack_ipv6 xt_state nf_conntrack xt_tcpudp ip6t_ipv6header ip6t_REJECT ip6table_filter ip6_tables x_tables ipv6 cpufreq_ondemand acpi_cpufreq dm_mirror dm_log dm_multipath dm_mod snd_hda_intel snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss button arc4 ecb crypto_blkcipher snd_mixer_oss iwl4965 joydev snd_pcm mac80211 firewire_ohci battery ac thinkpad_acpi hwmon cfg80211 snd_timer snd_page_alloc snd_hwdep i2c_i801 i2c_core pcspkr firewire_core crc_itu_t snd soundcore sr_mod sg cdrom ata_piix ahci libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd [last unloaded: microcode]
Pid: 2916, comm: zsh Not tainted 2.6.25-rc5-mm1 #9
RIP: 0010:[<ffffffff8123a8ee>]  [<ffffffff8123a8ee>] zap_completion_queue+0x54/0x85
RSP: 0018:ffff810072c35938  EFLAGS: 00010002
RAX: 0000000000000000 RBX: 6b6b6b6b6b6b6b6b RCX: 0000000000000001
RDX: ffff810072d46000 RSI: 0000000000000001 RDI: ffff81007c87f6c0
RBP: ffff810072c35958 R08: 0000000000000002 R09: ffffffff81226956
R10: 00000000000000c8 R11: ffff81007e0b6fc8 R12: ffff810001069dc0
R13: 6b6b6b6b6b6b6b6b R14: ffff81007cfa8b30 R15: 0000000000000010
FS:  00007f9084c716f0(0000) GS:ffffffff81439000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 000000000069b960 CR3: 0000000072ca7000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process zsh (pid: 2916, threadinfo ffff810072c34000, task ffff810072d46000)
Stack:  00000000000000c8 ffff81007e0b6fc8 0000000000000000 ffff81007e0b6fc8
 ffff810072c359c8 ffffffff8123b5d3 ffff81007dc61298 000000008123b624
 00000000ffffffff ffff81007e0b6fc8 0000000000000046 0000000000000000
Call Trace:
 [<ffffffff8123b5d3>] netpoll_poll+0x394/0x3b3
 [<ffffffff8123b1b0>] netpoll_send_skb+0xf1/0x180
 [<ffffffff8123b8ef>] netpoll_send_udp+0x277/0x283
 [<ffffffff811d9043>] write_msg+0x80/0xbd
 [<ffffffff81033537>] __call_console_drivers+0x6a/0x7b
 [<ffffffff810335a7>] _call_console_drivers+0x5f/0x63
 [<ffffffff81033a11>] release_console_sem+0x12e/0x1ba
 [<ffffffff81033f51>] vprintk+0x32d/0x37a
 [<ffffffff812b1ed1>] ? _spin_unlock_irqrestore+0x38/0x47
 [<ffffffff81033a90>] ? release_console_sem+0x1ad/0x1ba
 [<ffffffff81033a90>] ? release_console_sem+0x1ad/0x1ba
 [<ffffffff81034005>] printk+0x67/0x69
 [<ffffffff81049efa>] ? up+0xf/0x38
 [<ffffffff81034005>] ? printk+0x67/0x69
 [<ffffffff810806c1>] ? next_zone+0x28/0x2a
 [<ffffffff81079e03>] show_free_areas+0x289/0x3b0
 [<ffffffff81049efa>] ? up+0xf/0x38
 [<ffffffff81049efa>] ? up+0xf/0x38
 [<ffffffff8102122c>] show_mem+0x2a/0x16a
 [<ffffffff811a1c3a>] sysrq_handle_showmem+0x9/0xb
 [<ffffffff811a1dd4>] __handle_sysrq+0x9c/0x139
 [<ffffffff810e74ff>] ? write_sysrq_trigger+0x0/0x37
 [<ffffffff810e752c>] write_sysrq_trigger+0x2d/0x37
 [<ffffffff810e0fb0>] proc_reg_write+0x87/0xa4
 [<ffffffff810a2386>] vfs_write+0xae/0x157
 [<ffffffff810a255a>] sys_write+0x47/0x70
 [<ffffffff8100c037>] tracesys+0xdc/0xe1


Code: fa e8 fb 58 e1 ff f6 c7 02 4d 8b 6c 24 68 49 c7 44 24 68 00 00 00 00 75 09 53 9d e8 e1 58 e1 ff eb 2c e8 8d 7e e1 ff 53 9d eb 23 <49> 83 bd 80 00 00 00 00 49 8b 5d 00 74 0a 4c 89 ef e8 06 24 ff 
RIP  [<ffffffff8123a8ee>] zap_completion_queue+0x54/0x85
 RSP <ffff810072c35938>
---[ end trace 5edf7491f5a4a975 ]---


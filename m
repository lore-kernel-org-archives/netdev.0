From: Thomas Backlund <tmb@mandriva.org>
Subject: BUG when unloading bonding on 2.6.29-rc7-git3
Date: Tue, 10 Mar 2009 22:15:06 +0200
Message-ID: <49B6CA4A.2040506@mandriva.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mbox2.netikka.net ([213.250.81.203]:51451 "EHLO
	mbox2.netikka.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154AbZCJUPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 16:15:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
[pleace cc me on reply]

I get this when trying to unloading the bonding module by doing:

service network stop
modprobe -r bonding

Oh, and I have "options ipv6 disable=1" in /etc/modprobe.conf


> Mar 10 21:43:33 tmb kernel: BUG: unable to handle kernel NULL pointer dereference at 0000000000000028
> Mar 10 21:43:33 tmb kernel: IP: [<ffffffffa038ad6b>] ipv6_sysctl_net_exit+0x1b/0x60 [ipv6]
> Mar 10 21:43:33 tmb kernel: PGD 22608d067 PUD 22a813067 PMD 0 
> Mar 10 21:43:33 tmb kernel: Oops: 0000 [#1] SMP 
> Mar 10 21:43:33 tmb kernel: last sysfs file: /sys/class/net/bond0/bonding/slaves
> Mar 10 21:43:34 tmb kernel: CPU 3 
> Mar 10 21:43:34 tmb kernel: Modules linked in: af_packet ipv6(-) binfmt_misc loop xfs exportfs dm_mod floppy cpufreq_ondemand cpufreq_conservative cpufreq_p
> owersave acpi_cpufreq freq_table raid0 snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_s
> eq_device snd_pcm_oss iTCO_wdt sky2 skge i2c_i801 rtc_cmos iTCO_vendor_support ohci1394 i2c_core thermal snd_pcm raid1 snd_timer snd_mixer_oss ieee1394 butt
> on processor evdev sr_mod sg snd soundcore snd_page_alloc pata_marvell ata_piix ahci libata sd_mod scsi_mod crc_t10dif raid456 async_xor async_memcpy async_tx xor raid10 ext3 jbd uhci_hcd ohci_hcd ehci_hcd usbcore [last unloaded: bonding]
> Mar 10 21:43:34 tmb kernel: Pid: 5203, comm: modprobe Not tainted 2.6.29-0.rc7.3.1mdv #1 P5Q-E
> Mar 10 21:43:34 tmb kernel: RIP: 0010:[<ffffffffa038ad6b>]  [<ffffffffa038ad6b>] ipv6_sysctl_net_exit+0x1b/0x60 [ipv6]
> Mar 10 21:43:34 tmb kernel: RSP: 0018:ffff8802238dbe68  EFLAGS: 00010282
> Mar 10 21:43:34 tmb kernel: RAX: ffffffffa038ad50 RBX: ffffffffa03a3d20 RCX: 000000000001ffff
> Mar 10 21:43:34 tmb kernel: RDX: ffff8800a78ed000 RSI: 0000000000000086 RDI: 0000000000000000
> Mar 10 21:43:34 tmb kernel: RBP: ffff8802238dbe88 R08: 0000000000000000 R09: 0000000000000002
> Mar 10 21:43:34 tmb kernel: R10: ffffffff807c18a0 R11: ffff8802238dbdc8 R12: ffffffffa03a5680
> Mar 10 21:43:34 tmb kernel: R13: 0000000000000080 R14: 0000000000000000 R15: ffff8802238dbee8
> Mar 10 21:43:34 tmb kernel: FS:  00007f9ea27a36f0(0000) GS:ffff88022f05b580(0000) knlGS:0000000000000000
> Mar 10 21:43:34 tmb kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Mar 10 21:43:34 tmb kernel: CR2: 0000000000000028 CR3: 000000022b165000 CR4: 00000000000006e0
> Mar 10 21:43:34 tmb kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Mar 10 21:43:34 tmb kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Mar 10 21:43:34 tmb kernel: Process modprobe (pid: 5203, threadinfo ffff8802238da000, task ffff88022242c1d0)
> Mar 10 21:43:34 tmb kernel: Stack:
> Mar 10 21:43:34 tmb kernel:  ffff8802238dbe88 ffffffffa03a3d20 ffffffffa03a5680 0000000000000080
> Mar 10 21:43:34 tmb kernel:  ffff8802238dbea8 ffffffff8046b83a ffff8802238dbea8 0000000000000000
> Mar 10 21:43:34 tmb kernel:  ffff8802238dbeb8 ffffffffa038ad4c ffff8802238dbec8 ffffffffa038debd
> Mar 10 21:43:34 tmb kernel: Call Trace:
> Mar 10 21:43:34 tmb kernel:  [<ffffffff8046b83a>] unregister_pernet_subsys+0x2a/0x40
> Mar 10 21:43:34 tmb kernel:  [<ffffffffa038ad4c>] ipv6_sysctl_unregister+0x1c/0x20 [ipv6]
> Mar 10 21:43:34 tmb kernel:  [<ffffffffa038debd>] inet6_exit+0x1d/0xf0 [ipv6]
> Mar 10 21:43:34 tmb kernel:  [<ffffffff80278339>] sys_delete_module+0x1e9/0x2b0
> Mar 10 21:43:34 tmb kernel:  [<ffffffff80387f78>] ? __up_write+0x68/0x140
> Mar 10 21:43:34 tmb kernel:  [<ffffffff8020c72a>] system_call_fastpath+0x16/0x1b
> Mar 10 21:43:34 tmb kernel: Code: 48 c7 c7 20 3d 3a a0 e8 c4 0a 0e e0 c9 c3 66 90 55 48 89 e5 48 83 ec 20 48 89 5d e8 4c 89 65 f0 4c 89 6d f8 48 8b bf e8 02 00 00 <48> 8b 5f 28 4c 8b 63 20 4c 8b 6b 70 e8 c4 8b 16 e0 48 89 df e8 
> Mar 10 21:43:34 tmb kernel: RIP  [<ffffffffa038ad6b>] ipv6_sysctl_net_exit+0x1b/0x60 [ipv6]
> Mar 10 21:43:34 tmb kernel:  RSP <ffff8802238dbe68>
> Mar 10 21:43:34 tmb kernel: CR2: 0000000000000028
> Mar 10 21:43:34 tmb kernel: ---[ end trace 08ed5752dafe6907 ]---


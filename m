From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8491] New: OOPS triggered by ip(8)
 deconfiguring a network interface
Date: Thu, 17 May 2007 10:16:08 -0700
Message-ID: <20070517101608.57466a59.akpm@linux-foundation.org>
References: <200705171359.l4HDxLgU031582@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Collins <bcollins@ubuntu.com>,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34185 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755487AbXEQRR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 13:17:58 -0400
In-Reply-To: <200705171359.l4HDxLgU031582@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 May 2007 06:59:21 -0700 bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8491
> 
>            Summary: OOPS triggered by ip(8) deconfiguring a network
>                     interface
>     Kernel Version: 2.6.22-rc1
>             Status: NEW
>           Severity: high
>              Owner: yoshfuji@linux-ipv6.org
>          Submitter: bcollins@ubuntu.com
> 
> 
> Most recent kernel where this bug did *NOT* occur:
> Distribution: Ubuntu Feisty/Gutsy
> Hardware Environment: Pentium M, e1000, ipw2200
> Software Environment: network-manager
> Problem Description: Oops removing proc entry during ifdown
> 
> Steps to reproduce: Suspend/resume with interfaces alive
> 

[42968.728000] ACPI: AC Adapter [AC] (on-line)
[42968.824000] ACPI: Battery Slot [BAT0] (battery present)
[42976.264000] eth1: no IPv6 routers present
[43039.500000] ADDRCONF(NETDEV_UP): eth1: link is not ready
[43084.092000] e1000: eth2: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[43084.096000] ADDRCONF(NETDEV_CHANGE): eth2: link becomes ready
[43092.388000] BUG: unable to handle kernel NULL pointer dereference at virtual address 00000000
[43092.388000]  printing eip:
[43092.388000] c01ade92
[43092.388000] *pde = 00000000
[43092.388000] Oops: 0000 [#1]
[43092.388000] SMP 
[43092.388000] Modules linked in: battery ac ibm_acpi thermal processor fan
button e1000 ipw2200 ieee80211 usbhid hid michael_mic arc4 ecb blkcipher
ieee80211_crypt_tkip af_packet binfmt_misc rfcomm l2cap bluetooth ipv6
nvram uinput radeon drm speedstep_centrino cpufreq_userspace cpufreq_stats
cpufreq_powersave cpufreq_ondemand freq_table cpufreq_conservative video
sbs i2c_ec i2c_core bay dock container asus_acpi lp joydev snd_intel8x0
snd_ac97_codec ac97_bus snd_pcm_oss snd_mixer_oss irtty_sir sir_dev snd_pcm
nsc_ircc snd_seq_dummy snd_seq_oss irda psmouse pcmcia crc_ccitt parport_pc
snd_seq_midi snd_rawmidi snd_seq_midi_event serio_raw parport snd_seq
snd_timer snd_seq_device pcspkr snd soundcore snd_page_alloc
ieee80211_crypt iTCO_wdt iTCO_vendor_support yenta_socket rsrc_nonstatic
pcmcia_core intel_agp agpgart shpchp pci_hotplug tsdev evdev ext3 jbd
mbcache sg sr_mod cdrom sd_mod generic piix ata_generic floppy ata_piix
libata scsi_mod ehci_hcd uhci_hcd usbcore capability commoncap
[43092.388000] CPU:    0
[43092.388000] EIP:    0060:[<c01ade92>]    Not tainted VLI
[43092.388000] EFLAGS: 00210246   (2.6.22-1-generic #1)
[43092.388000] EIP is at remove_proc_entry+0x22/0x1b0
[43092.388000] eax: 00000000   ebx: e2e8a5c0   ecx: ffffffff   edx: e2e8ae40
[43092.388000] esi: dfe0aa58   edi: 00000000   ebp: c826ca00   esp: e6b09c80
[43092.388000] ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
[43092.388000] Process ip (pid: 11893, ti=e6b08000 task=dfea8a90 task.ti=e6b08000)
[43092.388000] Stack: e30f433c cab60000 c028608e 00000000 e2e8ae40 00000000 e2e8a5c0 dfe0aa58 
[43092.388000]        c826ca00 c826ca00 f10a72ff f1088989 00a33d71 000080fe 00000000 00000001 
[43092.388000]        cab60000 e2e8a5c0 dfe0aa58 00000000 c826ca00 f1089594 c826ca54 00000040 
[43092.388000] Call Trace:
[43092.388000]  [<c028608e>] pneigh_queue_purge+0x1e/0x30
[43092.388000]  [<f10a72ff>] snmp6_unregister_dev+0x2f/0x40 [ipv6]
[43092.388000]  [<f1088989>] addrconf_ifdown+0x2b9/0x2f0 [ipv6]
[43092.388000]  [<f1089594>] inet6_addr_del+0xb4/0xe0 [ipv6]
[43092.388000]  [<f108b3d8>] inet6_rtm_deladdr+0x68/0x70 [ipv6]
[43092.388000]  [<f108b370>] inet6_rtm_deladdr+0x0/0x70 [ipv6]
[43092.388000]  [<c02896cd>] rtnetlink_rcv_msg+0x16d/0x250
[43092.388000]  [<c0289560>] rtnetlink_rcv_msg+0x0/0x250
[43092.388000]  [<c02984b2>] netlink_run_queue+0x82/0x120
[43092.388000]  [<c0289508>] rtnetlink_rcv+0x28/0x50
[43092.388000]  [<c0298962>] netlink_data_ready+0x12/0x50
[43092.388000]  [<c0297671>] netlink_sendskb+0x21/0x40
[43092.388000]  [<c0298873>] netlink_sendmsg+0x223/0x300
[43092.388000]  [<c0277012>] sock_sendmsg+0x112/0x130
[43092.388000]  [<c0129d71>] current_fs_time+0x41/0x50
[43092.388000]  [<c0138f60>] autoremove_wake_function+0x0/0x50
[43092.388000]  [<c01f3009>] copy_to_user+0x29/0x50
[43092.388000]  [<c0277b03>] move_addr_to_user+0x63/0x70
[43092.388000]  [<c0277c83>] sys_recvmsg+0x173/0x220
[43092.388000]  [<c01f2d97>] copy_from_user+0x27/0x60
[43092.388000]  [<c02773cd>] sys_sendto+0x12d/0x190
[43092.388000]  [<c0158e90>] find_get_page+0x20/0x50
[43092.388000]  [<c015b991>] filemap_nopage+0x2f1/0x3a0
[43092.388000]  [<c016602e>] __handle_mm_fault+0x23e/0x960
[43092.388000]  [<c0168b26>] __vma_link+0x36/0x70
[43092.388000]  [<c0278458>] sys_socketcall+0x198/0x280
[43092.388000]  [<c0104114>] sysenter_past_esp+0x5d/0x89
[43092.388000]  [<c02e0000>] xfrm_timer_handler+0x220/0x250
[43092.388000]  =======================
[43092.388000] Code: 00 00 8d bc 27 00 00 00 00 55 57 56 53 83 ec 18 85 d2 89 54 24 10 89 44 24 14 0f 84 40 01 00 00 8b 7c 24 14 31 c0 b9 ff ff ff ff <f2> ae f7 d1 49 b8 c0 20 3b c0 89 cd e8 8d 0e 14 00 8b 5c 24 10 
[43092.388000] EIP: [<c01ade92>] remove_proc_entry+0x22/0x1b0 SS:ESP 0068:e6b09c80

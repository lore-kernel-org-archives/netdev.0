From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: Tree for September 3
Date: Thu, 4 Sep 2008 11:34:08 -0700
Message-ID: <20080904113408.d47c65f6.akpm@linux-foundation.org>
References: <20080903191619.6b6b230e.sfr@canb.auug.org.au>
	<20080903214634.ea17ff53.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809032201510.3378@nehalem.linux-foundation.org>
	<20080903223318.84b6ce8b.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040045190.3378@nehalem.linux-foundation.org>
	<20080904012544.cabed847.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040143350.3452@nehalem.linux-foundation.org>
	<20080904015701.5959623a.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040203510.3452@nehalem.linux-foundation.org>
	<20080904104554.32ffebea.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809041058140.3400@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Sam Ravnborg <sam@ravnborg.org>,
	john stultz <johnstul@us.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47478 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754169AbYIDSf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 14:35:28 -0400
In-Reply-To: <alpine.LFD.1.10.0809041058140.3400@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Sep 2008 11:05:21 -0700 (PDT) Linus Torvalds <torvalds@linux-foundation.org> wrote:

> > This is a pull of your tree from yesterday, ending at commit 
> > fbb16e243887332dd5754e48ffe5b963378f3cd2
> 
> There's been various suggested patches by Al/Eric (added to cc) for 
> /proc/net handling, but none of them have actually even been merged yet. 
> So I don't think this code has changed in a while. 
> 
> Al, Eric, ideas?

I don't think I saw it on any other test machines.

This machine runs SELinux.  Distro is FC5.

> > config: http://userweb.kernel.org/~akpm/config-sony.txt
> > dmesg: http://userweb.kernel.org/~akpm/dmesg-sony-without.txt
> 
> That whole thing should just be a simple symlink:
> 
> 	fs/proc/proc_net.c:     proc_symlink("net", NULL, "self/net");

/proc/self/net looks fine.

> are you sure it's a plain tree of mine, without any of the patches 
> floating around between Eric/Al?

yup, it's yesterday's mainline.



Found another problem.

The way I install kernels on machine `sony' is:

- Build the kernel on machine `y', in /usr/src/25

- On machine sony, NFS mount y:/usr/src at /mnt/y/usr/src

- On sony, `cd /mnt/y/usr/src/25'

- <copy stuff>

- make modules_install

- depmod -a

IOW, I run the kernel's installation tools on the *target* machine,
within an nfs mount of the *build* machine.

This has worked happily for five or more years.  But now:

Failed to open destination file: Permission deniedihex2fw: Convert ihex files into binary representation for use by Linux kernel
usage: ihex2fw [<options>] <src.HEX> <dst.fw>
       -w: wide records (16-bit length)
       -s: sort records by address
make[1]: *** [firmware/emi26/loader.fw] Error 1
make: *** [_modinst_post] Error 2

This is because the target machine is i386 and it is trying to execute
an x86_64 binary.





and oh dear, the clockevents code just oopsed.

firmware: requesting ipw2200-bss.fw
ipw2200: Radio Frequency Kill Switch is On:
Kill switch must be turned off for wireless networking to work.
ipw2200: Detected geography ZZA (11 802.11bg channels, 13 802.11a channels)
initcall ipw_init+0x0/0x71 [ipw2200] returned 0 after 163 msecs
ipw2200: Failed to send WEP_KEY: Aborted due to RF kill switch.
BUG: unable to handle kernel NULL pointer dereference at 00000040
IP: [<c0126e7f>] get_next_timer_interrupt+0xe9/0x1ab
*pde = 00000000 
Oops: 0000 [#1] PREEMPT 
Modules linked in: ipw2200 sonypi ipv6 autofs4 hidp l2cap bluetooth sunrpc nf_conntrack_netbios_ns ipt_REJECT nf_conntrack_ipv4 xt_state nf_conntrack xt_tcpudp iptable_filter ip_tables x_tables acpi_cpufreq nvram ohci1394 ieee1394 ehci_hcd uhci_hcd sg joydev snd_hda_intel snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss ieee80211 3c59x snd_pcm ieee80211_crypt sr_mod snd_timer cdrom snd i2c_i801 soundcore snd_page_alloc button i2c_core pcspkr ext3 jbd [last unloaded: ipw2200]

Pid: 0, comm: swapper Not tainted (2.6.27-rc5 #18)
EIP: 0060:[<c0126e7f>] EFLAGS: 00010013 CPU: 0
EIP is at get_next_timer_interrupt+0xe9/0x1ab
EAX: 00000040 EBX: 00000001 ECX: 0000001d EDX: 00000040
ESI: 0000001d EDI: c05bc700 EBP: c0469f1c ESP: c0469ee4
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=c0468000 task=c04343c0 task.ti=c0468000)
Stack: ffff1cef c013cc1d c05bcf28 00000000 c05bd010 c05bc798 00ffff1d c05bcf28 
       c05bd128 c05bd328 c05bd528 00000000 b65eb8b3 0000000f c0469f4c c013816f 
       00000000 b65c1f00 0000000f ffff1cef 00000046 00000096 c04b11c0 00000000 
Call Trace:
 [<c013cc1d>] ? __lock_acquire+0x671/0x6b7
 [<c013816f>] ? tick_nohz_stop_sched_tick+0x13f/0x2ba
 [<c0123640>] ? irq_exit+0x6d/0x79
 [<c0105c6a>] ? do_IRQ+0x6d/0x7f
 [<c0104300>] ? common_interrupt+0x28/0x30
 [<c013007b>] ? set_process_cpu_timer+0x94/0xb9
 [<c0234743>] ? acpi_processor_idle+0x2a6/0x44b
 [<c010256b>] ? cpu_idle+0x5a/0x87
 [<c031e2fd>] ? rest_init+0x61/0x63
 =======================
Code: 83 e6 3f 89 f1 89 5d d0 8b 45 d0 89 d3 8d 04 c8 89 45 d8 8b 00 eb 14 8b 40 08 bb 01 00 00 00 3b 45 cc 0f 49 45 cc 89 45 cc 89 d0 <8b> 10 0f 18 02 90 3b 45 d8 75 e1 85 db 89 da 74 0c 85 f6 74 04 
EIP: [<c0126e7f>] get_next_timer_interrupt+0xe9/0x1ab SS:ESP 0068:c0469ee4
---[ end trace 2cf31fb827f3051f ]---
Kernel panic - not syncing: Attempted to kill the idle task!
BUG: NMI Watchdog detected LOCKUP on CPU0, ip c01f584e, registers:



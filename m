From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9382] New: etting MTU > 1500 on card "cold"
 sigsegs the "ip" program and produces an OOPS.
Date: Wed, 14 Nov 2007 19:23:19 -0800
Message-ID: <20071114192319.e9423144.akpm@linux-foundation.org>
References: <bug-9382-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	jnelson-kernel-bugzilla@jamponi.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54387 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753048AbXKODXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 22:23:53 -0500
In-Reply-To: <bug-9382-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Nov 2007 19:11:38 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9382
> 
>            Summary: etting MTU > 1500 on card "cold" sigsegs the "ip"
>                     program and produces an OOPS.
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: VIA Velocity > 1500 MTU cold configure -=> OOPS
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: jnelson-kernel-bugzilla@jamponi.net
> 
> 
> Most recent kernel where this bug did not occur: Still occurs on latest
> openSUSE 10.3 kernel. A brief scan of the git log for this driver does not
> suggest a fix.
> 
> Distribution: openSUSE 10.3
> Hardware Environment: AMD Athlon XP 2200
> Software Environment: kernel 2.6.22.12
> Problem Description: setting MTU > 1500 on card "cold" sigsegs the "ip" program
> and produces an OOPS.
> 
> Steps to reproduce: 
> 
> 1. have a VIA Velocity gig-e NIC, *cold* (unconfigured but module loaded).
> 2. Issue:
> 
> ip link set eth0 up 7200 192.168.1.1
> 
> This has been an issue since at least 2.6.18 but I wasn't able to reproduce it
> on demand for a whole variety of reasons. Now I am able to reproduce it, 100%
> of the time, on-demand (although this requires a reboot.)
> 
> 
> BUG: unable to handle kernel NULL pointer dereference at virtual address
> 00000003
>  printing eip:
> f96a7772
> *pde = 00000000
> Oops: 0000 [#1]
> SMP
> last sysfs file: /devices/pci0000:00/0000:00:00.0/class
> Modules linked in: xt_tcpudp xt_pkttype ipt_LOG xt_limit drbd snd_pcm_oss
> snd_mixer_oss snd_seq snd_seq_device ipt_REJECT xt_state iptable_mangle
> iptable_nat nf_nat iptable_filter nf_conntrack_ipv4 nf_conntrack nfnetlink
> ip_tables ip6_tables x_tables tcp_bic apparmor dm_crypt loop dm_mirror dm_log
> dm_mod snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm button parport_pc rtc_cmos
> via_velocity sr_mod cdrom snd_timer rtc_core parport snd crc_ccitt rtc_lib
> soundcore snd_page_alloc shpchp sis_agp pci_hotplug agpgart i2c_sis630
> i2c_sis96x i2c_core sg usbhid hid ff_memless ehci_hcd sd_mod ohci_hcd usbcore
> piix sis5513 ide_core edd ext3 mbcache jbd fan pata_sis libata scsi_mod thermal
> processor
> CPU:    0
> EIP:    0060:[<f96a7772>]    Tainted: G      N VLI
> EFLAGS: 00010046   (2.6.22.12-0.1-default #1)
> EIP is at velocity_rx_refill+0x22/0x1d1 [via_velocity]
> eax: c197a500   ebx: c197a500   ecx: 00000000   edx: df8a9c00
> esi: c197a500   edi: 00000000   ebp: 00000000   esp: f774fe84
> ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
> Process ip (pid: 4133, ti=f774e000 task=f7a31030 task.ti=f774e000)
> Stack: f774fef0 00000086 3f257025 c170a2a0 00000000 fffffff4 00000200 c197a500
>        df8a9e00 fffffff4 f96a798f c01d0360 f96a61a7 c197a500 c197a000 00001c20
>        00000000 f96a8955 00008922 00008922 00000216 c197a000 00000001 00008922
> Call Trace:
>  [<f96a798f>] velocity_init_rd_ring+0x6e/0xa0 [via_velocity]
>  [<c01d0360>] __delay+0x6/0x7
>  [<f96a61a7>] safe_disable_mii_autopoll+0x14/0x26 [via_velocity]
>  [<f96a8955>] velocity_change_mtu+0xbc/0x104 [via_velocity]
>  [<c026e62a>] dev_set_mtu+0x2d/0x5d
>  [<c0270788>] dev_ioctl+0x3b1/0x43e
>  [<c012daa8>] ptrace_notify+0x6a/0x94
>  [<c026554b>] sock_ioctl+0x19f/0x1be
>  [<c02653ac>] sock_ioctl+0x0/0x1be
>  [<c017a131>] do_ioctl+0x21/0xa0
>  [<c014dcc0>] audit_syscall_entry+0x105/0x13e
>  [<c017a3e7>] vfs_ioctl+0x237/0x249
>  [<c017a445>] sys_ioctl+0x4c/0x67
>  [<c0104ea2>] syscall_call+0x7/0xb
>  =======================
> Code: ff 31 c0 5a 5b 5e 5f 5d c3 55 57 56 53 89 c3 83 ec 18 8b a8 f8 00 00 00
> c7 44 24 10 00 00 00 00 89 ef c1 e7 04 03 bb 00 01 00 00 <80> 7f 03 00 0f 88 1d
> 01 00 00 8d 34 ed 00 00 00 00 03 b3 04 01
> EIP: [<f96a7772>] velocity_rx_refill+0x22/0x1d1 [via_velocity] SS:ESP
> 0068:f774fe84
> 

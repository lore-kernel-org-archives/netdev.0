From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: usb_mon oops Re: tcpdump crashes 2.6.29.1 (and 2.6.29-rc5)
Date: Tue, 7 Apr 2009 12:00:22 +0000
Message-ID: <20090407120022.GA6519@ff.dom.local>
References: <18906.49779.243047.207639@stoffel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Pete Zaitcev <zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: John Stoffel <john-HgN6juyGXH5AfugRpC6u6w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <18906.49779.243047.207639-HgN6juyGXH5AfugRpC6u6w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07-04-2009 05:03, John Stoffel wrote:
> Hi,
Hi,

Looks more like usb_mon crash, so some Cc added.

Jarek P.

> 
> I've got an AMD64x2 system, x86_64, SMP, PREEMPT, with 4Gb of RAM,
> running 2.6.29.1 (most recently running 2.6.29-rc5 for a while before
> that) which crashes when I run 'tcpdump host x.y.z.n'.  I'm on
> linux-kernel, but not netdev, so please keep me in the headers.
> 
> I have't tried wireshark or ethereal yet, since I just wanted to see
> if packets were getting forwarded.  My main firewall is a m0n0wall
> WRAP board, so there's no much to do there debugging wise.  Ping does
> seem to work from both the firewall (192.1681.254) to 192.168.2.200
> once I put in the proper static route via sail
> (192.168.1.3/192.168.2.3).
> 
> Background: I'm working on setting up a PXE boot environment for a new
> box without a CDROM.  My current system, sail, has eth0 on the
> 192.168.1.0/24 subnet, with an IP of 192.168.1.3, and my WAN router
> (with DHCP) is setup at 192.168.1.254.  So I setup eth1 on the
> 192.168.2.0/24 subnet, with a DHCP server on my host, and an IP of
> 192.168.2.3 on that subnet.  More details:
> 
> 
>     eth0      Link encap:Ethernet  HWaddr 00:1e:8c:45:f3:e5  
> 	      inet addr:192.168.1.3  Bcast:192.168.1.255
> 	      Mask:255.255.255.0
> 	      UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> 	      RX packets:8663 errors:0 dropped:0 overruns:0 frame:0
> 	      TX packets:10088 errors:0 dropped:0 overruns:0 carrier:0
> 	      collisions:0 txqueuelen:1000 
> 	      RX bytes:3329485 (3.3 MB)  TX bytes:2088101 (2.0 MB)
> 	      Interrupt:26 Base address:0xe000 
> 
>     eth1      Link encap:Ethernet  HWaddr 00:1e:8c:46:0e:74  
> 	      inet addr:192.168.2.3  Bcast:192.168.2.255
> 	      Mask:255.255.255.0
> 	      UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> 	      RX packets:8 errors:0 dropped:0 overruns:0 frame:0
> 	      TX packets:71 errors:0 dropped:0 overruns:0 carrier:0
> 	      collisions:0 txqueuelen:1000 
> 	      RX bytes:1608 (1.6 KB)  TX bytes:11169 (11.1 KB)
> 	      Interrupt:27 Base address:0xa000 
> 
>     > cat /proc/sys/net/ipv4/ip_forward 
>     1
> 
>     > cat /proc/version 
>     Linux version 2.6.29.1 (root@sail) (gcc version 4.3.3 (Ubuntu
>     4.3.3-5ubuntu4) ) #22 SMP PREEMPT Mon Apr 6 21:41:56 EDT 2009
> 
>     > netstat -nr
>     Kernel IP routing table
>     Destination     Gateway         Genmask         Flags   MSS Window
>     irtt Iface
>     192.168.2.0     0.0.0.0         255.255.255.0   U         0 0
>     0 eth1
>     192.168.1.0     0.0.0.0         255.255.255.0   U         0 0
>     0 eth0
>     169.254.0.0     0.0.0.0         255.255.0.0     U         0 0
>     0 eth1
>     0.0.0.0         192.168.1.254   0.0.0.0         UG        0 0
>     0 eth0
> 
>     > ip route
>     192.168.2.0/24 dev eth1  proto kernel  scope link  src 192.168.2.3 
>     192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.3 
>     169.254.0.0/16 dev eth1  scope link  metric 1000 
>     default via 192.168.1.254 dev eth0  metric 100 
> 
> 
>     > tcpdump --version
>     tcpdump version 3.9.8
>     libpcap version 1.0.0
> 
> I don't have any ip_tables stuff loaded, which might be needed for my
> setup, but which doesn't seem to be implicated in this crash right
> now.
> 
> I can now PXEboot my client just fine, but connections from the
> 192.168.2.200 PXE host don't seem to get properly forwarded out to the
> internet so I can continue the network boot and install of Debian.  So
> to figure out what I was going wrong, I would try to do 'tcpdump host
> 192.168.2.200' on 'sail' and it would instantly hang.  I mucked around
> and got netconsole setup and got the following ksymoops.
> 
> Hopefully they'll be helpful.  I'll be happy to try and bisect this,
> and I'll start moving back in versions to see if I can find where this
> crash takes place.
> 
> [ 1396.271782] BUG: unable to handle kernel paging request at ffff880020a15cc0
> [ 1396.271809] IP: [<ffffffff803f436b>] memcpy_c+0xb/0x20
> [ 1396.271837] PGD 202063 PUD 206063 PMD 20a001e2 
> [ 1396.271864] Oops: 0000 [#1] PREEMPT SMP 
> [ 1396.271887] last sysfs file: /sys/module/loop/initstate
> [ 1396.271896] CPU 1 
> [ 1396.271907] Modules linked in: cryptoloop loop kvm_amd netconsole configfs binfmt_misc radeon drm af_packet kvm nfs ftdi_sio usbserial ata_generic pata_jmicron ohci1394 ieee1394 k8temp uvcvideo videodev v4l1_compat v4l2_compat_ioctl32 i2c_nforce2 i2c_core [last unloaded: kvm_amd]
> [ 1396.272062] Pid: 0, comm: swapper Not tainted 2.6.29.1 #22 System Product Name
> [ 1396.272070] RIP: 0010:[<ffffffff803f436b>]  [<ffffffff803f436b>] memcpy_c+0xb/0x20
> [ 1396.272087] RSP: 0018:ffff88011e8b7b00  EFLAGS: 00010002
> [ 1396.272095] RAX: ffff8800cac5d2c0 RBX: 0000000000000012 RCX: 0000000000000002
> [ 1396.272103] RDX: 0000000000000002 RSI: ffff880020a15cc0 RDI: ffff8800cac5d2c0
> [ 1396.272112] RBP: ffff88011e8b7b38 R08: 0000000000000080 R09: 000000000004b000
> [ 1396.272120] R10: 0000000000000012 R11: 00000000ffffff82 R12: 00000000000002d2
> [ 1396.272129] R13: 0000000000000012 R14: ffff880020a15cc0 R15: 0000000000000012
> [ 1396.272138] FS:  00007fe36d6f1700(0000) GS:ffff88011f5d92c0(0000) knlGS:0000000000000000
> [ 1396.272146] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> [ 1396.272155] CR2: ffff880020a15cc0 CR3: 0000000115e14000 CR4: 00000000000006e0
> [ 1396.272163] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 1396.272172] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [ 1396.272181] Process swapper (pid: 0, threadinfo ffff88011e8b0000, task ffff88011e89b820)
> [ 1396.272189] Stack:
> [ 1396.272195]  ffffffff804e6444 ffff88010aab2ec0 0000000000000000 0000000000000012
> [ 1396.272216]  0000000020a15cc0 00000000000002c0 ffff88010aab2ec0 ffff88011e8b7b78
> [ 1396.272247]  ffffffff804e760e 0000000000000096 ffff8800cac5d280 ffff88010aab2ec0
> [ 1396.272279] Call Trace:
> [ 1396.272287]  <IRQ> <0> [<ffffffff804e6444>] ? mon_copy_to_buff+0x74/0xa0
> [ 1396.272309]  [<ffffffff804e760e>] mon_dmapeek_vec+0x9e/0x120
> [ 1396.272322]  [<ffffffff804e67bf>] mon_bin_event+0x34f/0x3d0
> [ 1396.272338]  [<ffffffff804e6850>] mon_bin_complete+0x10/0x20
> [ 1396.272350]  [<ffffffff804e4658>] mon_bus_complete+0x48/0x80
> [ 1396.272364]  [<ffffffff804e46b4>] mon_complete+0x24/0x40
> [ 1396.272376]  [<ffffffff804d400b>] usb_hcd_giveback_urb+0x9b/0xe0
> [ 1396.272390]  [<ffffffff804e8416>] ehci_urb_done+0x106/0x130
> [ 1396.272404]  [<ffffffff804e9d3a>] qh_completions+0x31a/0x680
> [ 1396.272417]  [<ffffffff8065dc5a>] ? _spin_unlock_irqrestore+0x4a/0x60
> [ 1396.272433]  [<ffffffff804ea183>] ehci_work+0xe3/0xbf0
> [ 1396.272446]  [<ffffffff804f1690>] ehci_irq+0x2b0/0x430
> [ 1396.272460]  [<ffffffff8026e869>] ? getnstimeofday+0x59/0xe0
> [ 1396.272474]  [<ffffffff80269979>] ? ktime_get_ts+0x59/0x60
> [ 1396.272489]  [<ffffffff804d399c>] usb_hcd_irq+0x4c/0xb0
> [ 1396.272502]  [<ffffffff8028e9d3>] handle_IRQ_event+0x43/0x80
> [ 1396.272516]  [<ffffffff802902f2>] handle_fasteoi_irq+0x82/0x100
> [ 1396.272532]  [<ffffffff802161a1>] do_IRQ+0x81/0x110
> [ 1396.272545]  [<ffffffff80214213>] ret_from_intr+0x0/0x29
> [ 1396.272558]  <EOI> <0> [<ffffffff8022ef76>] ? native_safe_halt+0x6/0x10
> [ 1396.272580]  [<ffffffff8021ad8d>] ? default_idle+0x4d/0x50
> [ 1396.272594]  [<ffffffff8021af41>] ? c1e_idle+0x51/0x120
> [ 1396.272607]  [<ffffffff80661291>] ? atomic_notifier_call_chain+0x11/0x20
> [ 1396.272620]  [<ffffffff80212679>] ? cpu_idle+0x69/0xd0
> [ 1396.272636]  [<ffffffff80656b97>] ? start_secondary+0x182/0x1db
> [ 1396.272650] Code: 81 ea d8 1f 00 00 48 3b 42 20 73 07 48 8b 50 f9 31 c0 c3 31 d2 48 c7 c0 f2 ff ff ff c3 90 90 90 48 89 f8 89 d1 c1 e9 03 83 e2 07 <f3> 48 a5 89 d1 f3 a4 c3 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 
> [ 1396.272759] RIP  [<ffffffff803f436b>] memcpy_c+0xb/0x20
> [ 1396.272759]  RSP <ffff88011e8b7b00>
> [ 1396.272759] CR2: ffff880020a15cc0
> [ 1396.272759] ---[ end trace 091310ffa51c7f18 ]---
> [ 1396.272759] Kernel panic - not syncing: Fatal exception in interrupt
> [ 1396.272759] ------------[ cut here ]------------
> [ 1396.272759] WARNING: at kernel/smp.c:329 smp_call_function_many+0x231/0x2a0()
> [ 1396.272759] Hardware name: System Product Name
> [ 1396.272759] Modules linked in: cryptoloop loop kvm_amd netconsole configfs binfmt_misc radeon drm af_packet kvm nfs ftdi_sio usbserial ata_generic pata_jmicron ohci1394 ieee1394 k8temp uvcvideo videodev v4l1_compat v4l2_compat_ioctl32 i2c_nforce2 i2c_core [last unloaded: kvm_amd]
> [ 1396.272759] Pid: 0, comm: swapper Tainted: G      D    2.6.29.1 #22
> [ 1396.272759] Call Trace:
> [ 1396.272759]  <IRQ>  [<ffffffff8024e610>] warn_slowpath+0xd0/0x130
> [ 1396.272759]  [<ffffffff803f2fa1>] ? vsnprintf+0x351/0xbb0
> [ 1396.272759]  [<ffffffff803f204f>] ? put_dec+0x11f/0x130
> [ 1396.272759]  [<ffffffff8065dc5a>] ? _spin_unlock_irqrestore+0x4a/0x60
> [ 1396.272759]  [<ffffffff8048157b>] ? nv_start_xmit_optimized+0x47b/0x5c0
> [ 1396.272759]  [<ffffffff8021b030>] ? stop_this_cpu+0x0/0x30
> [ 1396.272759]  [<ffffffff805bf535>] ? netpoll_send_udp+0x205/0x220
> [ 1396.272759]  [<ffffffff802777f1>] smp_call_function_many+0x231/0x2a0
> [ 1396.272759]  [<ffffffff8021b030>] ? stop_this_cpu+0x0/0x30
> [ 1396.272759]  [<ffffffff8022feb9>] ? default_spin_lock_flags+0x9/0x10
> [ 1396.272759]  [<ffffffff8065dc5a>] ? _spin_unlock_irqrestore+0x4a/0x60
> [ 1396.272759]  [<ffffffff8065dc5a>] ? _spin_unlock_irqrestore+0x4a/0x60
> [ 1396.272759]  [<ffffffff8024eebd>] ? release_console_sem+0x1bd/0x210
> [ 1396.272759]  [<ffffffff8024f5b0>] ? vprintk+0x3d0/0x450
> [ 1396.272759]  [<ffffffff8065dc5a>] ? _spin_unlock_irqrestore+0x4a/0x60
> [ 1396.272759]  [<ffffffff8065af15>] ? printk+0x67/0x6a
> [ 1396.272759]  [<ffffffff8027ef74>] ? crash_kexec+0x74/0x100
> [ 1396.272759]  [<ffffffff8022feb9>] ? default_spin_lock_flags+0x9/0x10
> [ 1396.272759]  [<ffffffff8065dc5a>] ? _spin_unlock_irqrestore+0x4a/0x60
> [ 1396.272759]  [<ffffffff8065dc5a>] ? _spin_unlock_irqrestore+0x4a/0x60
> [ 1396.272759]  [<ffffffff8024eebd>] ? release_console_sem+0x1bd/0x210
> [ 1396.272759]  [<ffffffff8027788f>] smp_call_function+0x2f/0x70
> [ 1396.272759]  [<ffffffff80227fd3>] native_smp_send_stop+0x23/0x50
> [ 1396.272759]  [<ffffffff8065ade9>] panic+0xbe/0x183
> [ 1396.272759]  [<ffffffff8027ef74>] ? crash_kexec+0x74/0x100
> [ 1396.272759]  [<ffffffff8065dc5a>] ? _spin_unlock_irqrestore+0x4a/0x60
> [ 1396.272759]  [<ffffffff8024eebd>] ? release_console_sem+0x1bd/0x210
> [ 1396.272759]  [<ffffffff8024f195>] ? console_unblank+0x75/0x90
> [ 1396.272759]  [<ffffffff8065ee04>] oops_end+0xe4/0xf0
> [ 1396.272759]  [<ffffffff806606fa>] do_page_fault+0x22a/0xcd0
> [ 1396.272759]  [<ffffffff8025be41>] ? complete_signal+0x121/0x210
> [ 1396.272759]  [<ffffffff8025c0fe>] ? send_signal+0x1ce/0x2d0
> [ 1396.272759]  [<ffffffff80240aa5>] ? check_preempt_wakeup+0x175/0x190
> [ 1396.272759]  [<ffffffff80249a0c>] ? try_to_wake_up+0x16c/0x240
> [ 1396.272759]  [<ffffffff804c484b>] ? nv_swncq_host_interrupt+0x17b/0x760
> [ 1396.272759]  [<ffffffff802415b8>] ? enqueue_task_fair+0x188/0x1d0
> [ 1396.272759]  [<ffffffff8065e145>] page_fault+0x25/0x30
> [ 1396.272759]  [<ffffffff803f436b>] ? memcpy_c+0xb/0x20
> [ 1396.272759]  [<ffffffff804e6444>] ? mon_copy_to_buff+0x74/0xa0
> [ 1396.272759]  [<ffffffff804e760e>] mon_dmapeek_vec+0x9e/0x120
> [ 1396.272759]  [<ffffffff804e67bf>] mon_bin_event+0x34f/0x3d0
> [ 1396.272759]  [<ffffffff804e6850>] mon_bin_complete+0x10/0x20
> [ 1396.272759]  [<ffffffff804e4658>] mon_bus_complete+0x48/0x80
> [ 1396.272759]  [<ffffffff804e46b4>] mon_complete+0x24/0x40
> [ 1396.272759]  [<ffffffff804d400b>] usb_hcd_giveback_urb+0x9b/0xe0
> [ 1396.272759]  [<ffffffff804e8416>] ehci_urb_done+0x106/0x130
> [ 1396.272759]  [<ffffffff804e9d3a>] qh_completions+0x31a/0x680
> [ 1396.272759]  [<ffffffff8065dc5a>] ? _spin_unlock_irqrestore+0x4a/0x60
> [ 1396.272759]  [<ffffffff804ea183>] ehci_work+0xe3/0xbf0
> [ 1396.272759]  [<ffffffff804f1690>] ehci_irq+0x2b0/0x430
> [ 1396.272759]  [<ffffffff8026e869>] ? getnstimeofday+0x59/0xe0
> [ 1396.272759]  [<ffffffff80269979>] ? ktime_get_ts+0x59/0x60
> [ 1396.272759]  [<ffffffff804d399c>] usb_hcd_irq+0x4c/0xb0
> [ 1396.272759]  [<ffffffff8028e9d3>] handle_IRQ_event+0x43/0x80
> [ 1396.272759]  [<ffffffff802902f2>] handle_fasteoi_irq+0x82/0x100
> [ 1396.272759]  [<ffffffff802161a1>] do_IRQ+0x81/0x110
> [ 1396.272759]  [<ffffffff80214213>] ret_from_intr+0x0/0x29
> [ 1396.272759]  <EOI>  [<ffffffff8022ef76>] ? native_safe_halt+0x6/0x10
> [ 1396.272759]  [<ffffffff8021ad8d>] ? default_idle+0x4d/0x50
> [ 1396.272759]  [<ffffffff8021af41>] ? c1e_idle+0x51/0x120
> [ 1396.272759]  [<ffffffff80661291>] ? atomic_notifier_call_chain+0x11/0x20
> [ 1396.272759]  [<ffffffff80212679>] ? cpu_idle+0x69/0xd0
> [ 1396.272759]  [<ffffffff80656b97>] ? start_secondary+0x182/0x1db
> [ 1396.272759] ---[ end trace 091310ffa51c7f19 ]---
> [ 1396.272759] ------------[ cut here ]------------
> [ 1396.272759] WARNING: at kernel/smp.c:226 smp_call_function_single+0xdf/0x170()
> [ 1396.272759] Hardware name: System Product Name
> [ 1396.272759] Modules linked in: cryptoloop loop kvm_amd netconsole configfs binfmt_misc radeon drm af_packet kvm nfs ftdi_sio usbserial ata_generic pata_jmicron ohci1394




--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

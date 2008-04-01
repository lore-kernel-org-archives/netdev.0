From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10375] New: IPSec tunnel kernel panic
Date: Tue, 1 Apr 2008 12:06:46 -0700
Message-ID: <20080401120646.9b2f3b6a.akpm@linux-foundation.org>
References: <bug-10375-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, yuri@itinteg.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60187 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755754AbYDATHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 15:07:53 -0400
In-Reply-To: <bug-10375-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue,  1 Apr 2008 11:44:10 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10375
> 
>            Summary: IPSec tunnel kernel panic
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24.3 2.6.24.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: yuri@itinteg.net
> 
> 
> Latest working kernel version:
> Earliest failing kernel version: 2.6.24.3
> Distribution: 
> Hardware Environment: 
> Software Environment:
> Problem Description:
> 
> Steps to reproduce: Configured IPSec tunnel between two Linux with same kernel
> versions. One of machines, connected via ADSL fall with kernel panic.
> 
> 2.6.24.4:
> 
> kernel BUG at include/linux/skbuff.h:948!
> invalid opcode: 0000 [#1] SMP
> Modules linked in: esp4 ah4 xfrm4_mode_tunnel ppp_synctty ppp_async
> crc_ccitt pp
> p_generic slhc deflate zlib_deflate geode_aes aes_i586 aes_generic
> blowfish des_
> generic cbc ecb blkcipher sha256_generic sha1_generic crypto_null af_key
> af_pack
> et ipt_ULOG xt_state xt_tcpudp iptable_filter ipt_MASQUERADE iptable_nat
> nf_nat
> nf_conntrack_ipv4 nf_conntrack ip_tables x_tables binfmt_misc dm_mod
> sr_mod cdro
> m generic ide_core evdev e1000 ehci_hcd pata_marvell uhci_hcd e1000e
> intel_agp a
> gpgart sg usbcore unix
> 
> 
> 
> Pid: 2867, comm: pppoe Not tainted (2.6.24.4-1 #1)
> EIP: 0060:[<dfb3d50b>] EFLAGS: 00010293 CPU: 0
> EIP is at esp_input+0x3b2/0x3b6 [esp4]
> EAX: 00000591 EBX: 00000000 ECX: 00000010 EDX: dd65b380
> ESI: 00000005 EDI: 00000014 EBP: dd71da08 ESP: dd71d9a4
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process pppoe (pid: 2867, ti=dd71c000 task=de990ab0 task.ti=dd71c000)
> Stack: 00000000 000249f0 dd71d990 dd65b380 de948a00 dd71d9a4 de3a3e40
> dd79dc80
>        0000000c 00000598 00000000 dd564840 00000001 00000008 00000000
> dd79dc80
>        dd79dca8 00000000 dd733380 00000000 de03c300 04050002 de948a00
> 00000032
> Call Trace:
>  [<c02dcd3a>] xfrm4_rcv_encap+0xba/0x426
>  [<df860475>] nf_nat_adjust+0x0/0x33 [iptable_nat]
>  [<c02a6566>] nf_iterate+0x56/0x7a
>  [<c02a65ff>] nf_hook_slow+0x4d/0xbe
>  [<c02ac08a>] ip_local_deliver_finish+0x0/0x1f8
>  [<c02dd0c1>] xfrm4_rcv+0x1b/0x1f
>  [<c02ac17f>] ip_local_deliver_finish+0xf5/0x1f8
>  [<c02abe48>] ip_rcv_finish+0xe8/0x32a
>  [<c02ac558>] ip_rcv+0x1e3/0x265
>  [<c02abd60>] ip_rcv_finish+0x0/0x32a
>  [<c02ac375>] ip_rcv+0x0/0x265
>  [<c028fdbb>] netif_receive_skb+0x298/0x3b7
>  [<dfc817b7>] ppp_receive_nonmp_frame+0x2c7/0x709 [ppp_generic]
>  [<c02923df>] process_backlog+0x63/0xc4
>  [<c0291e73>] net_rx_action+0x78/0x139
>  [<dfc7bb02>] ppp_async_process+0x1b/0x5e [ppp_async]
>  [<c011e652>] __do_softirq+0x72/0xdf
>  [<c011e6f6>] do_softirq+0x37/0x39
>  [<c011e886>] local_bh_enable_ip+0x42/0x44
>  [<dfa769ab>] packet_poll+0x54/0x62 [af_packet]
>  [<c0284d1f>] sock_poll+0xc/0xe
>  [<c0166b02>] do_select+0x251/0x46b
>  [<c016732e>] __pollwait+0x0/0xcf
>  [<c0115061>] default_wake_function+0x0/0x8
>  [<c0115061>] default_wake_function+0x0/0x8
>  [<c0115061>] default_wake_function+0x0/0x8
>  [<c0115061>] default_wake_function+0x0/0x8
>  [<df8e6bed>] e1000_clean_rx_irq+0x0/0x4ce [e1000]
>  [<df8e536b>] e1000_xmit_frame+0x716/0xba2 [e1000]
>  [<c02e709f>] _spin_lock_bh+0x8/0x18
>  [<dfc7b3f9>] ppp_async_push+0x1f7/0x424 [ppp_async]
>  [<c0158ac8>] cache_alloc_refill+0x6f/0x4ff
>  [<dfc7bb32>] ppp_async_process+0x4b/0x5e [ppp_async]
>  [<c028c994>] memcpy_toiovec+0x37/0x4e
>  [<c028cf81>] skb_copy_datagram_iovec+0x146/0x1fa
>  [<c028d39d>] skb_recv_datagram+0x146/0x219
>  [<c028b4cd>] skb_release_all+0x50/0x114
>  [<c011e801>] local_bh_enable+0x4f/0x92
>  [<dfa76223>] packet_recvmsg+0x179/0x1a1 [af_packet]
>  [<c0285aca>] sock_recvmsg+0xcf/0xf3
>  [<c0285baa>] sock_sendmsg+0xbc/0xde
>  [<c012a95b>] autoremove_wake_function+0x0/0x37
>  [<c0114ce1>] task_rq_lock+0x29/0x50
>  [<c0166ecf>] core_sys_select+0x1b3/0x2bd
>  [<c0115283>] __wake_up+0x32/0x42
>  [<c0211bf0>] tty_wakeup+0x2d/0x54
>  [<c0218764>] pty_unthrottle+0x12/0x1d
>  [<dfc7bdaf>] ppp_asynctty_receive+0x26a/0x687 [ppp_async]
>  [<c0115283>] __wake_up+0x32/0x42
>  [<c0115283>] __wake_up+0x32/0x42
>  [<c0211b57>] tty_ldisc_deref+0x46/0x69
>  [<c0213ac2>] tty_write+0x1a7/0x1b3
>  [<c01674e1>] sys_select+0xe4/0x1ab
>  [<c01027e6>] sysenter_past_esp+0x5f/0x85
>  =======================
> 
> Code: 75 ac 83 86 40 01 00 00 01 8b 65 b0 bb ea ff ff ff e9 d2 fc ff ff
> 89 c2 8b
>  45 a8 e8 58 dd 74 e0 8b 4d a8 8b 51 50 e9 41 ff ff ff <0f> 0b eb fe 55
> 57 56 53
>  83 ec 10 89 c6 8b a8 e4 00 00 00 85 ed
> 
> EIP: [<dfb3d50b>] esp_input+0x3b2/0x3b6 [esp4] SS:ESP 0068:dd71d9a4
> 
> Kernel panic - not syncing: Fatal exception in interrupt
> 
> ------------------------------------------------------------------------------
> 2.6.24.3:
> 
> kernel BUG at include/linux/skbuff.h:948!
> invalid opcode: 0000 [#1] SMP
> Modules linked in: esp4 ah4 xfrm4_mode_tunnel ppp_synctty ppp_async
> crc_ccitt pp
> p_generic slhc deflate zlib_deflate geode_aes aes_i586 aes_generic
> blowfish des_
> generic cbc ecb blkcipher sha256_generic sha1_generic crypto_null af_key
> af_pack
> et ipt_ULOG xt_state xt_tcpudp iptable_filter ipt_MASQUERADE iptable_nat
> nf_nat
> nf_conntrack_ipv4 nf_conntrack ip_tables x_tables binfmt_misc dm_mod
> sr_mod cdro
> m generic ide_core evdev e1000 pata_marvell intel_agp e1000e ehci_hcd
> uhci_hcd a
> gpgart sg usbcore unix
> 
> 
> 
> Pid: 4, comm: ksoftirqd/0 Not tainted (2.6.24.3-1 #1)
> EIP: 0060:[<dfab450b>] EFLAGS: 00010283 CPU: 0
> EIP is at esp_input+0x3b2/0x3b6 [esp4]
> EAX: 00000579 EBX: 00000000 ECX: 00000010 EDX: dcc6f540
> ESI: 00000005 EDI: 00000014 EBP: de845e74 ESP: de845e10
>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> 
> Process ksoftirqd/0 (pid: 4, ti=de844000 task=de829ab0 task.ti=de844000)
> Stack: 00000000 000249f0 de845e00 dcc6f540 dcfa0a00 de845e10 de3b69c0
> dcfa5f40
>        0000000c 00000580 00000000 dccb8840 00000001 00000008 00000000
> dcfa5f40
>        dcfa5f68 00000000 dcf3e580 00000000 de083540 04050002 dcfa0a00
> 00000032
> 
> Call Trace:
>  [<c02dce5a>] xfrm4_rcv_encap+0xba/0x426
>  [<df847475>] nf_nat_adjust+0x0/0x33 [iptable_nat]
>  [<c02a6666>] nf_iterate+0x56/0x7a
>  [<c02a66ff>] nf_hook_slow+0x4d/0xbe
>  [<c02ac18a>] ip_local_deliver_finish+0x0/0x1f8
>  [<c02dd1e1>] xfrm4_rcv+0x1b/0x1f
>  [<c02ac27f>] ip_local_deliver_finish+0xf5/0x1f8
>  [<c02abf48>] ip_rcv_finish+0xe8/0x32a
>  [<c02ac658>] ip_rcv+0x1e3/0x265
>  [<c02abe60>] ip_rcv_finish+0x0/0x32a
>  [<c02ac475>] ip_rcv+0x0/0x265
>  [<c028fecb>] netif_receive_skb+0x298/0x3b7
>  [<dfae37b7>] ppp_receive_nonmp_frame+0x2c7/0x709 [ppp_generic]
>  [<c02924ef>] process_backlog+0x63/0xc4
>  [<c0291f83>] net_rx_action+0x78/0x139
>  [<dfaaab02>] ppp_async_process+0x1b/0x5e [ppp_async]
>  [<c011e6c2>] __do_softirq+0x72/0xdf
>  [<c011e92f>] ksoftirqd+0x0/0xcf
>  [<c011e766>] do_softirq+0x37/0x39
>  [<c011e985>] ksoftirqd+0x56/0xcf
>  [<c012a753>] kthread+0x34/0x55
>  [<c012a71f>] kthread+0x0/0x55
>  [<c0103437>] kernel_thread_helper+0x7/0x10
>  =======================
> 
> Code: 75 ac 83 86 40 01 00 00 01 8b 65 b0 bb ea ff ff ff e9 d2 fc ff ff
> 89 c2 8b
>  45 a8 e8 68 6e 7d e0 8b 4d a8 8b 51 50 e9 41 ff ff ff <0f> 0b eb fe 55
> 57 56 53
>  83 ec 10 89 c6 8b a8 e4 00 00 00 85 ed
> 
> EIP: [<dfab450b>] esp_input+0x3b2/0x3b6 [esp4] SS:ESP 0068:de845e10
> Kernel panic - not syncing: Fatal exception in interrupt


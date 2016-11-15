From: Andrei Vagin <avagin@gmail.com>
Subject: Re: linux-next: BUG: unable to handle kernel NULL pointer dereference
 in __sk_mem_raise_allocated()
Date: Mon, 14 Nov 2016 16:02:10 -0800
Message-ID: <CANaxB-yeSv9sW+5=yStp+VfqsOyAWiCRWocdQafH_-XNzw+Myg@mail.gmail.com>
References: <CANaxB-yCk8hhP68L4Q2nFOJht8sqgXGGQO2AftpHs0u1xyGG5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:37998 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753048AbcKOACM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 19:02:12 -0500
Received: by mail-it0-f50.google.com with SMTP id q124so154934062itd.1
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 16:02:12 -0800 (PST)
In-Reply-To: <CANaxB-yCk8hhP68L4Q2nFOJht8sqgXGGQO2AftpHs0u1xyGG5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2016 at 3:24 PM, Andrei Vagin <avagin@gmail.com> wrote:
> Hi Paolo,
>
> Our test system detected a kernel oops. Looks like a problem in the
> "udp: refactor memory accounting" series.
>
> # good: [f970bd9e3a06f06df8d8ecf1f8ad2c8615cc17eb] udp: implement
> memory accounting helpers
> git bisect good f970bd9e3a06f06df8d8ecf1f8ad2c8615cc17eb
> # bad: [2d0e30c30f84d08dc16f0f2af41f1b8a85f0755e] bpf: add helper for
> retrieving current numa node id
> git bisect bad 2d0e30c30f84d08dc16f0f2af41f1b8a85f0755e
> # bad: [a10b91b8b81c29b87ff5a6d58c1402898337b956] Merge branch 'udpmem'
> git bisect bad a10b91b8b81c29b87ff5a6d58c1402898337b956
> # good: [850cbaddb52dfd4e0c7cabe2c168dd34b44ae0b9] udp: use it's own
> memory accounting schema
> git bisect good 850cbaddb52dfd4e0c7cabe2c168dd34b44ae0b9

I did a mistake on this step and
850cbaddb52dfd4e0c7cabe2c168dd34b44ae0b9 is the first bad commit.

> # first bad commit: [a10b91b8b81c29b87ff5a6d58c1402898337b956] Merge
> branch 'udpmem'
>
>
> [  112.472363] BUG: unable to handle kernel NULL pointer dereference
> at           (null)
> [  112.473360] IP: [<ffffffffb76f8031>] __sk_mem_raise_allocated+0x31/0x3f0
> [  112.474156] PGD 62a08067 [  112.474455] PUD 2b8bf067
> PMD 0 [  112.474856]
> [  112.475054] Oops: 0002 [#1] SMP
> [  112.475431] Modules linked in: nf_conntrack_netlink udp_diag
> tcp_diag inet_diag netlink_diag af_packet_diag unix_diag binfmt_misc
> nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4
> xt_conntrack nf_conntrack nfnetlink ip6table_filter ip6_tables ppdev
> sunrpc crc32c_intel joydev virtio_balloon virtio_net i2c_piix4
> parport_pc parport acpi_cpufreq tpm_tis tpm_tis_core tpm virtio_blk
> serio_raw virtio_pci virtio_ring virtio ata_generic pata_acpi
> [  112.480594] CPU: 1 PID: 7405 Comm: socket_udplite Not tainted 4.8.0+ #84
> [  112.481377] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS 1.9.1-1.fc24 04/01/2014
> [  112.482375] task: ffff928a5b5fa540 task.stack: ffffb3b484a0c000
> [  112.483059] RIP: 0010:[<ffffffffb76f8031>]  [<ffffffffb76f8031>]
> __sk_mem_raise_allocated+0x31/0x3f0
> [  112.484135] RSP: 0018:ffff928abfd03b18  EFLAGS: 00010296
> [  112.484758] RAX: 0000000000000001 RBX: ffff928aa293cfc0 RCX: 0000000000000001
> [  112.485585] RDX: 0000000000000000 RSI: 0000000000001000 RDI: ffff928aa293cfc0
> [  112.486414] RBP: ffff928abfd03b48 R08: 0de4c53600000000 R09: 0000000000000000
> [  112.487241] R10: 000000006226b971 R11: 0000000000000000 R12: ffff928aa293cfc0
> [  112.488064] R13: 0000000000000001 R14: ffffffffb7f0d5a0 R15: 0000000000001000
> [  112.488893] FS:  00007f058067a700(0000) GS:ffff928abfd00000(0000)
> knlGS:0000000000000000
> [  112.489807] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  112.490447] CR2: 0000000000000000 CR3: 000000002b8f5000 CR4: 00000000000006e0
> [  112.491248] DR0: 00000000000100a0 DR1: 0000000000000000 DR2: 0000000000000000
> [  112.492025] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> [  112.492808] Stack:
> [  112.493038]  0000000100000300 ffff928aa293cfc0 ffff928a651b9c00
> 0000000000000300
> [  112.493912]  ffff928aa293d108 0000000000001000 ffff928abfd03b88
> ffffffffb779e094
> [  112.494782]  ffff928abfd03b70 ffff928a651b9c00 ffff928aa293cfc0
> 0000000000000000
> [  112.495653] Call Trace:
> [  112.495930]  <IRQ> [  112.496154]  [<ffffffffb779e094>]
> __udp_enqueue_schedule_skb+0xc4/0x170
> [  112.496896]  [<ffffffffb77a15b4>] udp_queue_rcv_skb+0x1a4/0x5b0
> [  112.497551]  [<ffffffffb77a1f3e>] __udp4_lib_rcv+0x57e/0xe30
> [  112.498173]  [<ffffffffb77a2cfa>] udplite_rcv+0x1a/0x20
> [  112.498761]  [<ffffffffb776799f>] ip_local_deliver_finish+0xdf/0x370
> [  112.499466]  [<ffffffffb77678ef>] ? ip_local_deliver_finish+0x2f/0x370
> [  112.500184]  [<ffffffffb77683c4>] ip_local_deliver+0x74/0x210
> [  112.500825]  [<ffffffffb77683ec>] ? ip_local_deliver+0x9c/0x210
> [  112.501482]  [<ffffffffb77678c0>] ? inet_del_offload+0x40/0x40
> [  112.502122]  [<ffffffffb7767daa>] ip_rcv_finish+0x17a/0x540
> [  112.502749]  [<ffffffffb77687f3>] ip_rcv+0x293/0x4d0
> [  112.503305]  [<ffffffffb776882f>] ? ip_rcv+0x2cf/0x4d0
> [  112.503873]  [<ffffffffb7767c30>] ? ip_local_deliver_finish+0x370/0x370
> [  112.504607]  [<ffffffffb771683b>] __netif_receive_skb_core+0x34b/0xca0
> [  112.505327]  [<ffffffffb77180e4>] ? process_backlog+0xd4/0x240
> [  112.505967]  [<ffffffffb77180e4>] ? process_backlog+0xd4/0x240
> [  112.506617]  [<ffffffffb77171a8>] __netif_receive_skb+0x18/0x60
> [  112.507277]  [<ffffffffb7718088>] process_backlog+0x78/0x240
> [  112.507904]  [<ffffffffb77180e4>] ? process_backlog+0xd4/0x240
> [  112.508552]  [<ffffffffb7717e01>] net_rx_action+0x1d1/0x3e0
> [  112.509165]  [<ffffffffb7873b3d>] __do_softirq+0xcd/0x471
> [  112.509765]  [<ffffffffb776d312>] ? ip_finish_output2+0x242/0x640
> [  112.510446]  [<ffffffffb7871ecc>] do_softirq_own_stack+0x1c/0x30
> [  112.511106]  <EOI> [  112.511336]  [<ffffffffb709c956>]
> do_softirq.part.14+0x46/0x70
> [  112.511990]  [<ffffffffb709ca39>] __local_bh_enable_ip+0xb9/0xc0
> [  112.512661]  [<ffffffffb776d33b>] ip_finish_output2+0x26b/0x640
> [  112.513319]  [<ffffffffb776d177>] ? ip_finish_output2+0xa7/0x640
> [  112.513979]  [<ffffffffb776e27f>] ip_finish_output+0x19f/0x330
> [  112.514627]  [<ffffffffb776f533>] ip_output+0x83/0x270
> [  112.515204]  [<ffffffffb776f55b>] ? ip_output+0xab/0x270
> [  112.515794]  [<ffffffffb776e0e0>] ? ip_fragment.constprop.51+0x80/0x80
> [  112.516521]  [<ffffffffb776e699>] ip_local_out+0x39/0x70
> [  112.517107]  [<ffffffffb7770069>] ip_send_skb+0x19/0x40
> [  112.517689]  [<ffffffffb779dd22>] udp_send_skb+0x172/0x260
> [  112.518299]  [<ffffffffb779f4b0>] udp_sendmsg+0x340/0xb30
> [  112.518893]  [<ffffffffb779de70>] ? udp_push_pending_frames+0x60/0x60
> [  112.519605]  [<ffffffffb77aeff8>] inet_sendmsg+0xf8/0x1c0
> [  112.520197]  [<ffffffffb77aef05>] ? inet_sendmsg+0x5/0x1c0
> [  112.520807]  [<ffffffffb76f4b98>] sock_sendmsg+0x38/0x50
> [  112.521397]  [<ffffffffb76f51b1>] SYSC_sendto+0x101/0x190
> [  112.521993]  [<ffffffffb70efc0f>] ? up_read+0x1f/0x40
> [  112.522563]  [<ffffffffb7054dfd>] ? __do_page_fault+0x26d/0x4f0
> [  112.523221]  [<ffffffffb70f3f55>] ? trace_hardirqs_on_caller+0xf5/0x1b0
> [  112.523950]  [<ffffffffb700201a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
> [  112.524664]  [<ffffffffb76f60fe>] SyS_sendto+0xe/0x10
> [  112.525230]  [<ffffffffb7870e01>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> [  112.525939] Code: 48 89 e5 41 57 41 56 41 55 41 54 4c 63 ea 53 49
> 89 fc 41 89 f7 4c 89 e8 48 83 ec 08 4c 8b 77 28 44 89 6d d4 49 8b 96
> d0 00 00 00 <f0> 48 0f c1 02 49 8d 5c 05 00 e9 41 00 00 00 49 8b 44 24
> 28 48
> [  112.528965] RIP  [<ffffffffb76f8031>] __sk_mem_raise_allocated+0x31/0x3f0
> [  112.529732]  RSP <ffff928abfd03b18>
> [  112.530122] CR2: 0000000000000000
> [  112.530504] ---[ end trace ed0c680ae4317de5 ]---
> [  112.531019] Kernel panic - not syncing: Fatal exception in interrupt
> [  112.550850] Kernel Offset: 0x36000000 from 0xffffffff81000000
> (relocation rang

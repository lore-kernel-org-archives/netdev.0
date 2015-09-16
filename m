From: Richard Alpe <richard.alpe@ericsson.com>
Subject: Re: [linux-next] oops in ip_route_input_noref
Date: Wed, 16 Sep 2015 13:50:36 +0200
Message-ID: <55F9578C.40209@ericsson.com>
References: <20150916092447.GA945@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:63439 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216AbbIPMFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 08:05:53 -0400
In-Reply-To: <20150916092447.GA945@swordfish>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-09-16 11:24, Sergey Senozhatsky wrote:
> Hi,
> 
> 4.3.0-rc1-next-20150916
> 
> oops after removal of rndis usb device
> 
> ...
> ffffffff8146c052:       00 
> ffffffff8146c053:       0f b6 55 8a             movzbl -0x76(%rbp),%edx
> ffffffff8146c057:       49 8b bf e8 01 00 00    mov    0x1e8(%r15),%rdi
> ffffffff8146c05e:       45 89 d1                mov    %r10d,%r9d
> ffffffff8146c061:       44 89 f6                mov    %r14d,%esi
> ffffffff8146c064:       44 88 95 70 ff ff ff    mov    %r10b,-0x90(%rbp)
> ffffffff8146c06b:       0f 95 c1                setne  %cl
> ffffffff8146c06e:       81 ce 00 00 00 80       or     $0x80000000,%esi
> ffffffff8146c074:       41 83 e1 01             and    $0x1,%r9d
> ffffffff8146c078:       45 31 c0                xor    %r8d,%r8d
> ffffffff8146c07b:       e8 49 d5 ff ff          callq  ffffffff814695c9 <rt_dst_alloc>
> ffffffff8146c080:       48 85 c0                test   %rax,%rax
> ffffffff8146c083:       49 89 c5                mov    %rax,%r13
> ffffffff8146c086:       75 0a                   jne    ffffffff8146c092 <ip_route_input_noref+0xa75>
> ffffffff8146c088:       bb 97 ff ff ff          mov    $0xffffff97,%ebx
> ffffffff8146c08d:       e9 06 f8 ff ff          jmpq   ffffffff8146b898 <ip_route_input_noref+0x27b>
> ffffffff8146c092:       48 c7 40 58 a3 95 46    movq   $0xffffffff814695a3,0x58(%rax)
> ffffffff8146c099:       81 
> ffffffff8146c09a:       c6 80 a2 00 00 00 01    movb   $0x1,0xa2(%rax)
> ffffffff8146c0a1:       48 8b 45 98             mov    -0x68(%rbp),%rax
> ffffffff8146c0a5:       44 8a 95 70 ff ff ff    mov    -0x90(%rbp),%r10b
> ffffffff8146c0ac:       48 85 c0                test   %rax,%rax
> ffffffff8146c0af:       74 0a                   je     ffffffff8146c0bb <ip_route_input_noref+0xa9e>
> ffffffff8146c0b1:       8b 40 10                mov    0x10(%rax),%eax
> ^^^^^^^
> ffffffff8146c0b4:       41 89 85 b0 00 00 00    mov    %eax,0xb0(%r13)
> ffffffff8146c0bb:       65 ff 05 9e 54 ba 7e    incl   %gs:0x7eba549e(%rip)        # 11560 <rt_cache_stat>
> ffffffff8146c0c2:       80 7d 8a 07             cmpb   $0x7,-0x76(%rbp)
> ffffffff8146c0c6:       75 1a                   jne    ffffffff8146c0e2 <ip_route_input_noref+0xac5>
> ffffffff8146c0c8:       41 81 a5 9c 00 00 00    andl   $0x7fffffff,0x9c(%r13)
> ffffffff8146c0cf:       ff ff ff 7f 
> ffffffff8146c0d3:       f7 db                   neg    %ebx
> ffffffff8146c0d5:       49 c7 45 50 b1 96 46    movq   $0xffffffff814696b1,0x50(%r13)
> ffffffff8146c0dc:       81 
> ffffffff8146c0dd:       66 41 89 5d 64          mov    %bx,0x64(%r13)
> ffffffff8146c0e2:       45 84 d2                test   %r10b,%r10b
> ffffffff8146c0e5:       74 29                   je     ffffffff8146c110 <ip_route_input_noref+0xaf3>
> ffffffff8146c0e7:       0f b6 7d 89             movzbl -0x77(%rbp),%edi
> ffffffff8146c0eb:       4c 89 ee                mov    %r13,%rsi
> ffffffff8146c0ee:       48 ff c7                inc    %rdi
> ffffffff8146c0f1:       48 6b ff 60             imul   $0x60,%rdi,%rdi
> ffffffff8146c0f5:       48 03 7d 90             add    -0x70(%rbp),%rdi
> ffffffff8146c0f9:       e8 10 d1 ff ff          callq  ffffffff8146920e <rt_cache_route>
> ffffffff8146c0fe:       84 c0                   test   %al,%al
> ffffffff8146c100:       75 0e                   jne    ffffffff8146c110 <ip_route_input_noref+0xaf3>
> ffffffff8146c102:       66 41 83 4d 60 10       orw    $0x10,0x60(%r13)
> ffffffff8146c108:       4c 89 ef                mov    %r13,%rdi
> ffffffff8146c10b:       e8 7d cc ff ff          callq  ffffffff81468d8d <rt_add_uncached_list>
> ffffffff8146c110:       4d 89 6c 24 58          mov    %r13,0x58(%r12)
> ffffffff8146c115:       31 db                   xor    %ebx,%ebx
> ffffffff8146c117:       e9 7c f7 ff ff          jmpq   ffffffff8146b898 <ip_route_input_noref+0x27b>
> ffffffff8146c11c:       bb 8f ff ff ff          mov    $0xffffff8f,%ebx
> ffffffff8146c121:       c6 45 8a 07             movb   $0x7,-0x76(%rbp)
> ffffffff8146c125:       48 c7 45 90 00 00 00    movq   $0x0,-0x70(%rbp)
> ...
> 
> addr2line -e vmlinux -i 0xffffffff8146c0b1
> net/ipv4/route.c:1815
> net/ipv4/route.c:1905
> 
> 
> which seems to be this line ip_route_input_noref()->ip_route_input_slow():
> ...
> 1813         rth->rt_is_input = 1;
> 1814         if (res.table)
> 1815                 rth->rt_table_id = res.table->tb_id;
> 1816
> ...
> 
> 
> added by b7503e0cdb5dbec5d201aa69d8888c14679b5ae8
> 
>     net: Add FIB table id to rtable
>     
>     Add the FIB table id to rtable to make the information available for
>     IPv4 as it is for IPv6.
> 
> 
> 	-ss
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I to get an Oops in ip_route_input_noref(). It happens occasionally during bootup.
KVM environment using virtio driver. Let me know if you need any additional info or
if you want me to try to bisect it.

Starting network...
...
[    0.877040] BUG: unable to handle kernel NULL pointer dereference at 0000000000000056
[    0.877597] IP: [<ffffffff8155b5e2>] ip_route_input_noref+0x1a2/0xb00
[    0.877597] PGD 3fa14067 PUD 3fa6e067 PMD 0 
[    0.877597] Oops: 0000 [#1] SMP 
[    0.877597] Modules linked in: virtio_net virtio_pci virtio_ring virtio
[    0.877597] CPU: 1 PID: 119 Comm: ifconfig Not tainted 4.2.0+ #1
[    0.877597] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.877597] task: ffff88003fab0bc0 ti: ffff88003faa8000 task.ti: ffff88003faa8000
[    0.877597] RIP: 0010:[<ffffffff8155b5e2>]  [<ffffffff8155b5e2>] ip_route_input_noref+0x1a2/0xb00
[    0.877597] RSP: 0018:ffff88003ed03ba0  EFLAGS: 00010202
[    0.877597] RAX: 0000000000000046 RBX: 00000000ffffff8f RCX: 0000000000000020
[    0.877597] RDX: ffff88003fab50b8 RSI: 0000000000000200 RDI: ffffffff8152b4b8
[    0.877597] RBP: ffff88003ed03c50 R08: 0000000000000000 R09: 0000000000000000
[    0.877597] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88003fab6f00
[    0.877597] R13: ffff88003fab5000 R14: 0000000000000000 R15: ffffffff81cb5600
[    0.877597] FS:  00007f6de5751700(0000) GS:ffff88003ed00000(0000) knlGS:0000000000000000
[    0.877597] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    0.877597] CR2: 0000000000000056 CR3: 000000003fa6d000 CR4: 00000000000006e0
[    0.877597] Stack:
[    0.877597]  0000000000000000 0000000000000046 ffff88003fffa600 ffff88003ed03be0
[    0.877597]  ffff88003f9e2c00 697da8c0017da8c0 ffff880000000000 000000000007fd00
[    0.877597]  0000000000000000 0000000000000046 0000000000000000 0000000400000000
[    0.877597] Call Trace:
[    0.877597]  <IRQ> 
[    0.877597]  [<ffffffff812bfa1f>] ? cpumask_next_and+0x2f/0x40
[    0.877597]  [<ffffffff8158e13c>] arp_process+0x39c/0x690
[    0.877597]  [<ffffffff8158e57e>] arp_rcv+0x13e/0x170
[    0.877597]  [<ffffffff8151feec>] __netif_receive_skb_core+0x60c/0xa00
[    0.877597]  [<ffffffff81515795>] ? __build_skb+0x25/0x100
[    0.877597]  [<ffffffff81515795>] ? __build_skb+0x25/0x100
[    0.877597]  [<ffffffff81521ff6>] __netif_receive_skb+0x16/0x70
[    0.877597]  [<ffffffff81522078>] netif_receive_skb_internal+0x28/0x90
[    0.877597]  [<ffffffff8152288f>] napi_gro_receive+0x7f/0xd0
[    0.877597]  [<ffffffffa0017906>] virtnet_receive+0x256/0x910 [virtio_net]
[    0.877597]  [<ffffffffa0017fd8>] virtnet_poll+0x18/0x80 [virtio_net]
[    0.877597]  [<ffffffff815234cd>] net_rx_action+0x1dd/0x2f0
[    0.877597]  [<ffffffff81053228>] __do_softirq+0x98/0x260
[    0.877597]  [<ffffffff8164969c>] do_softirq_own_stack+0x1c/0x30
[    0.877597]  <EOI> 
[    0.877597]  [<ffffffff810530fd>] do_softirq.part.19+0x1d/0x20
[    0.877597]  [<ffffffff81053181>] __local_bh_enable_ip+0x81/0x90
[    0.877597]  [<ffffffffa0016202>] virtnet_napi_enable+0x52/0x60 [virtio_net]
[    0.877597]  [<ffffffffa0018200>] virtnet_open+0x40/0xb0 [virtio_net]
[    0.877597]  [<ffffffff815259ba>] __dev_open+0xaa/0x120
[    0.877597]  [<ffffffff81525c98>] __dev_change_flags+0x98/0x160
[    0.877597]  [<ffffffff81525d84>] dev_change_flags+0x24/0x60
[    0.877597]  [<ffffffff815935da>] devinet_ioctl+0x5ca/0x6a0
[    0.877597]  [<ffffffff81594beb>] inet_ioctl+0x4b/0x70
[    0.877597]  [<ffffffff81506a50>] sock_do_ioctl+0x20/0x50
[    0.877597]  [<ffffffff81506ee6>] sock_ioctl+0x1a6/0x250
[    0.877597]  [<ffffffff81156185>] do_vfs_ioctl+0x2b5/0x490
[    0.877597]  [<ffffffff811563d4>] SyS_ioctl+0x74/0x80
[    0.877597]  [<ffffffff81647a57>] entry_SYSCALL_64_fastpath+0x12/0x6a
[    0.877597] Code: 31 c0 e8 42 e8 ff ff 48 85 c0 49 89 c5 0f 84 73 08 00 00 48 c7 40 58 20 9c 55 81 c6 80 a2 00 00 00 01 48 8b 45 98 48 85 c0 74 0a <8b> 40 10 41 89 85 b0 00 00 00 65 ff 05 0d 6e ab 7e 80 7d 8a 07 
[    0.877597] RIP  [<ffffffff8155b5e2>] ip_route_input_noref+0x1a2/0xb00
[    0.877597]  RSP <ffff88003ed03ba0>
[    0.877597] CR2: 0000000000000056
[    0.877597] ---[ end trace c702820c32c78c83 ]---


Regards
Richard

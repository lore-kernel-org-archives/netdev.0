From: Jan Oravec <jan.oravec@6com.sk>
Subject: Re: IPv6/sparc64: icmp port unreachable corruption
Date: Sun, 9 Nov 2003 15:37:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031109143757.GA17943@wsx.ksp.sk>
References: <20031109122844.GA14241@wsx.ksp.sk> <20031109132552.GA17096@wsx.ksp.sk> <20031109133939.GA17333@wsx.ksp.sk>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com, yoshfuji@linux-ipv6.org
Content-Disposition: inline
In-Reply-To: <20031109133939.GA17333@wsx.ksp.sk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A colleague of mine has Opteron at home, he tried traceroute6 ::1 on
2.6.0-test9-bk4, here is the kernel output:

RDX: 0000000000000048 RSI: 000001001ec06048 RDI: 000001011ec06218
RBP: 0000000000000048 R08: 0000000000000000 R09: 0000000000000000
R10: 000001001ea6d1c0 R11: 00000000000000dc R12: 0000000000000001
R13: 0000000000000000 R14: 000001001f95f740 R15: 000001001ec06048
FS:  0000002a958d2060(0000) GS:ffffffff804f4500(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000000101000 CR4: 00000000000006a0
Process traceroute6 (pid: 787, stackpage=1001eaf04e0)
Stack: 0000000000000000 0000000000000000 0000000000000048 0000000000000048
       000001001f95f740 0000000000000000 0000000000000048 ffffffff802e710f
       0000000000000246 ffffffff8021f8d0
Call Trace:<ffffffff802e710f>{csum_partial_copy_nocheck+15} <ffffffff8021f8d0>{skb_copy_and_csum_bits+96}
       <ffffffff802bc043>{icmpv6_getfrag+35} <ffffffff802a91e6>{ip6_append_data+1158}
       <ffffffff802bc020>{icmpv6_getfrag+0} <ffffffff802bc4a4>{icmpv6_send+1044}
       <ffffffff802b8ca7>{updv6_rcv+647} <ffffffff802aa34d>{ip6_input_finish+429}
       <ffffffff802aa1a0>{ip6_input_finish+0} <ffffffff8022b403>{nf_hook_slow+227}
       <ffffffff802aa1a0>{ip6_input_finish+0} <ffffffff802aa160>{ip6_rcv_finish+0} 
       <ffffffff802aa0e6>{ip6_input+662} <ffffffff8022b01e>{nf_interate+94}
       <ffffffff802aa160>{ip6_rcv_finish+0} <ffffffff802aa17f>{ip6_rcv_finish+31}
       <ffffffff8022b403>{nf_hook_slow+227} <ffffffff802aa160>{ip6_rcv_finish+0}
       <ffffffff802a9df7>{ipv6_rcv+503} <ffffffff8022290a>{netif_receive_skb+394}
       <ffffffff802229ca>{process_backlog+138} <ffffffff80222acb>{net_rx_action+123}
       <ffffffff80130a1b>{do_softirq+123} <ffffffff80222442>{dev_queue_xmit+354}
       <ffffffff802281d2>{neigh_resolve_output+322} <ffffffff802a9a80>{ip6_output_finish+0}
       <ffffffff802a9b23>{ip6_output_finish+163} <ffffffff802a9a80>{ip6_output_finish+0}
       <ffffffff8022b403>{nf_hook_slow+227} <ffffffff802a9a80>{ip6_output_finish+0}
       <ffffffff802a9a50>{dst_output+0} <ffffffff802a69dc>{ip6_output2+540}
       <ffffffff802a9a61>{dst_output+17} <ffffffff8022b403>{nf_hook_slow+227}
       <ffffffff802a9a50>{dst_output+0} <ffffffff802a98a0>{ip6_push_pending_frames+784} 
       <ffffffff802a91e6>{ip6_append_data+1158} <ffffffff802b906f>{udp_v6_push_pending_frames+319}
       <ffffffff802b97d5>{udpv6_sendmsg+1861} <ffffffff80273154>{inet_sendmsg+84}
       <ffffffff8021adad>{sock_sendmsg+125} <ffffffff80141e4d>{find_get_page+13}
       <ffffffff80142ccd>{filemap_nopage+269} <ffffffff8014eead>{do_no_page+813}
       <ffffffff8021abd0>{sockfd_lookup+32} <ffffffff8021a897>{move_addr_to_kernel+39}
       <ffffffff8021bf99>{sys_sendto+233} <ffffffff80272312>{inet_setsockopt+18}
       <ffffffff8021c203>{sys_setsockopt+147} <ffffffff8010eb60>{system_call+124}

Code: c7 00 f2 ff ff ff eb d6 48 8b 44 24 08 c7 00 f2 ff ff ff eb
RIP <ffffffff802e72cd>{csum_partial_copy_generic+349} RSP <000001001e6354c8>
CR2: 0000000000000000
 <0>Kernel panic: Aiee, killing interrupt handler!
In interrupt handler - not syncing


On Sun, Nov 09, 2003 at 02:39:39PM +0100, Jan Oravec wrote:
> And another observation is that on 2.6.0-test9-bk4 on Opteron x86_64 when I
> do:
> 
> # traceroute6 ::1
> 
> The kernel crashs.
> 
> I will have kernel OOPS output tommorow (the box is located in office)
> 
> 
> 
> On Sun, Nov 09, 2003 at 02:25:53PM +0100, Jan Oravec wrote:
> > This may be related to the problem (on sparc64):
> > 
> > # traceroute6 3ffe:80ee:3bd:0:a00:20ff:fec7:a192
> > traceroute to 3ffe:80ee:3bd:0:a00:20ff:fec7:a192 (3ffe:80ee:3bd:0:a00:20ff:fec7:a192) from ::1, 30 hops max, 24 byte packets
> > Bus error
> > 
> > # traceroute6 3ffe:80ee:3bd:0:a00:20ff:fec7:a192 -s 3ffe:80ee:3bd:0:a00:20ff:fec7:a192
> > traceroute to 3ffe:80ee:3bd:0:a00:20ff:fec7:a192 (3ffe:80ee:3bd:0:a00:20ff:fec7:a192) from 3ffe:80ee:3bd:0:a00:20ff:fec7:a192, 30 hops max, 24 byte packets
> > Bus error
> > 
> > # traceroute6 www.kame.net
> > traceroute to orange.kame.net (2001:200:0:8002:203:47ff:fea5:3085) from 3ffe:80ee:3bd:0:a00:20ff:fec7:a192, 30 hops max, 24 byte packets
> >  1  skbra-00-01.pop.xs26.net (3ffe:80ee:3bd:0:a00:20ff:fec9:3aad)  0.953 ms 0.305 ms  0.341 ms
> > ...
> > 
> > The following lines are appearing in dmesg:
> > raw v6 hw csum failure.
> > 
> > All of this worked fine in 2.4.22-pre6.
> > 
> > 
> > The common problem of 2.4 and 2.6 is with IPv4 traceroute, but it is
> > probably because of buggy 64-bit traceroute, because it worked fine in
> > 32-bit userspace:
> > 
> > # traceroute www.google.com
> > traceroute to www.google.akadns.net (216.239.57.99), 30 hops max, 52 byte packets
> > Bus error
> > 
> > 
> > 
> > On Sun, Nov 09, 2003 at 01:28:44PM +0100, Jan Oravec wrote:
> > > Hello,
> > > 
> > > 
> > > I have found the following problem with 2.6.0-test9-bk13 on sparc64:
> > > 
> > > We do traceroute6 to 3ffe:80ee:3bd:0:a00:20ff:fec7:a192 (IP of that
> > > sparc64). We get the following corrupted answer:
> > > 
> > > 13:17:47.191547 3ffe:80ee:3bd:0:a00:20ff:fec7:a192 > 3ffe:80ee:a:0:201:3ff:fed5:bd1e: [|icmp6] (len 72, hlim 62)
> > > 0x0000   6000 0000 0048 3a3e 3ffe 80ee 03bd 0000        ....H:>?.......
> > > 0x0010   0a00 20ff fec7 a192 3ffe 80ee 000a 0000        ........?.......
> > > 0x0020   0201 03ff fed5 bd1e 0104 aa7c 0000 0000        ...........|....
> > > 0x0030   0000 0064 0000 0000 0100 0000 0100 0000        ...d............
> > > 0x0040   aaaa aaaa aaaa aaaa 9680 c00b c622 7fec        ............."..
> > > 0x0050   aaaa aaaa aaaa aaaa 9680 c00b c622 7ffc        ............."..
> > > 0x0060   aaaa aaaa 0000 0000 8a10 2000 04c2 8049        ...............I
> > > 
> > > 
> > > When doing exactly same to x86 box (with 2.6.0-test7-bk7 running), we get
> > > the correct answer:
> > > 
> > > 13:17:31.140230 3ffe:80ee:1:0:204:76ff:fe97:d69a > 3ffe:80ee:a:0:201:3ff:fed5:bd1e: icmp6: 3ffe:80ee:1:0:204:76ff:fe97:d69a udp port 33434 unreachable (len 72, hlim 63)
> > > 0x0000   6000 0000 0048 3a3f 3ffe 80ee 0001 0000        ....H:??.......
> > > 0x0010   0204 76ff fe97 d69a 3ffe 80ee 000a 0000        ..v.....?.......
> > > 0x0020   0201 03ff fed5 bd1e 0104 fb79 0000 0000        ...........y....
> > > 0x0030   6000 0000 0018 1101 3ffe 80ee 000a 0000        .......?.......
> > > 0x0040   0201 03ff fed5 bd1e 3ffe 80ee 0001 0000        ........?.......
> > > 0x0050   0204 76ff fe97 d69a 8018 829a 0018 0c82        ..v.............
> > > 0x0060   0000 1df3 0000 0005 5b30 ae3f 3512 0200        ........[0.?5...
> > > 
> > > 
> > > Jan
> > > 
> > 
> 

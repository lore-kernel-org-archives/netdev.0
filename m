From: Tuan Bui <tuan.d.bui@hp.com>
Subject: [BUG REPORT] kernel panic in tcp_sendpage() on null pointer
 dereference
Date: Tue, 07 Apr 2015 15:57:33 -0700
Message-ID: <1428447453.4074.32.camel@u64>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-AKoF5emHwQaUwEW4zyBt"
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, yoshfuji@linux-ipv6.org,
	Jason Low <jason.low2@hp.com>,
	Aswin Chandramouleeswaran <aswin@hp.com>,
	Jun Li <jun.li@hp.com>, Haris Volos <haris.volos@hp.com>,
	Wai Long <waiman.long@hp.com>,
	hideaki.yoshifuji@miraclelinux.com, alan@linux.intel.com,
	gw4pts@gw4pts.ampr.org, Tuan Bui <tuan.d.bui@hp.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-AKoF5emHwQaUwEW4zyBt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hi all,

I am consistently seeing this kernel panic on a 16 sockets machine
running Spark PageRank workload using Docker.  I am running RHEL 7.0
stock kernel which is 3.10.0-123.el7.x86_64.

I believe __skb_insert() might be dereferencing a null *prev.

Attached is a complete dmesg and disassemble log.

Stack Trace:
[ 6169.148712] BUG: unable to handle kernel NULL pointer dereference at
(null)
[ 6169.157531] IP: [<ffffffff8151829d>] tcp_sendpage+0x44d/0x6d0
[ 6169.163995] PGD 49bcfb83067 PUD 49bcfb82067 PMD 0 
[ 6169.169520] Oops: 0002 [#1] SMP 
[ 6169.173230] Modules linked in: veth xt_addrtype ipt_MASQUERADE
dm_thin_pool dm_persistent_data dm_bio_prison dm_bufio loop ext4 mbcache
jbd2 ip6t_rpfilter ip6t_REJECT ipt_REJECT xt_conntrack ebtable_nat
ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat
nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle
ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
iptable_mangle iptable_security iptable_raw iptable_filter ip_tables sg
iTCO_wdt iTCO_vendor_support coretemp kvm_intel kvm crct10dif_pclmul
crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel lrw gf128mul
glue_helper ablk_helper cryptd pcspkr ses enclosure ixgbe ptp hpilo
hpwdt pps_core mdio sb_edac ioatdma lpc_ich edac_core mfd_core
[ 6169.255799]  dca shpchp ipmi_si ipmi_msghandler mperf vfat fat btrfs
zlib_deflate raid6_pq xor xfs libcrc32c dm_service_time sd_mod
crc_t10dif crct10dif_common mgag200 syscopyarea sysfillrect sysimgblt
i2c_algo_bit qla2xxx drm_kms_helper ttm scsi_transport_fc drm scsi_tgt
i2c_core dm_mirror dm_region_hash dm_log dm_multipath dm_mod
[ 6169.289059] CPU: 87 PID: 205310 Comm: java Not tainted
3.10.0-123.el7.x86_64 #1
[ 6169.297161] Hardware name: HP Superdome2 16s x86, BIOS Bundle:
005.073.000 SFW: 015.082.000 08/08/2014
[ 6169.307538] task: ffff8c9bccf38000 ti: ffff8c94c506c000 task.ti:
ffff8c94c506c000
[ 6169.315890] RIP: 0010:[<ffffffff8151829d>]  [<ffffffff8151829d>]
tcp_sendpage+0x44d/0x6d0
[ 6169.325229] RSP: 0018:ffff8c94c506dbe0  EFLAGS: 00010202
[ 6169.331182] RAX: 0000000000000000 RBX: ffff918a6dfda800 RCX:
ffff918a6dfda938
[ 6169.339149] RDX: 0000000000000110 RSI: ffff918a6dfda938 RDI:
0000000000000000
[ 6169.347141] RBP: ffff8c94c506dc58 R08: 00000000000002c0 R09:
0000000000000500
[ 6169.355100] R10: ffff88bd7f406e80 R11: 0000000000000000 R12:
0000000000020040
[ 6169.363074] R13: 0000000000000000 R14: 0000000000000219 R15:
ffffea1253a1c800
[ 6169.371045] FS:  00007f648fefe700(0000) GS:ffff8c9cffb80000(0000)
knlGS:0000000000000000
[ 6169.380075] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 6169.386507] CR2: 0000000000000000 CR3: 0000049bd848c000 CR4:
00000000001407e0
[ 6169.394540] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[ 6169.402612] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[ 6169.410621] Stack:
[ 6169.412984]  0000000100000000 ffff8ed00a267c00 ffffffff00000de7
0000000000000de7
[ 6169.422080]  0000000000000001 ffff918a6dfda938 00000de7000005a8
000010f853ab6ec0
[ 6169.431181]  0000000000000000 00000000a54958f0 ffff918a6dfda800
ffff8c9bd5e4fd00
[ 6169.440262] Call Trace:
[ 6169.443190]  [<ffffffff811dc940>] ? splice_from_pipe_feed+0x120/0x120
[ 6169.450512]  [<ffffffff81542ade>] inet_sendpage+0x6e/0xe0
[ 6169.456766]  [<ffffffff814b668b>] kernel_sendpage+0x1b/0x30
[ 6169.463193]  [<ffffffff814b66c7>] sock_sendpage+0x27/0x30
[ 6169.469387]  [<ffffffff811dc9a3>] pipe_to_sendpage+0x63/0xa0
[ 6169.475864]  [<ffffffff811dc89e>] splice_from_pipe_feed+0x7e/0x120
[ 6169.482900]  [<ffffffff811dc940>] ? splice_from_pipe_feed+0x120/0x120
[ 6169.490215]  [<ffffffff811dcc1e>] __splice_from_pipe+0x6e/0x90
[ 6169.496881]  [<ffffffff811dc940>] ? splice_from_pipe_feed+0x120/0x120
[ 6169.504198]  [<ffffffff811de82e>] splice_from_pipe+0x5e/0x90
[ 6169.510659]  [<ffffffff811de860>] ? splice_from_pipe+0x90/0x90
[ 6169.517342]  [<ffffffff811de875>] generic_splice_sendpage+0x15/0x20
[ 6169.524464]  [<ffffffff811dd361>] do_splice_from+0x91/0x100
[ 6169.530900]  [<ffffffff811dd3f0>] direct_splice_actor+0x20/0x30
[ 6169.537686]  [<ffffffff811dd114>] splice_direct_to_actor+0xd4/0x200
[ 6169.544915]  [<ffffffff811dd3d0>] ? do_splice_from+0x100/0x100
[ 6169.551594]  [<ffffffff811de912>] do_splice_direct+0x62/0x90
[ 6169.558070]  [<ffffffff811b0193>] do_sendfile+0x1c3/0x340
[ 6169.564248]  [<ffffffff811b130e>] SyS_sendfile64+0x5e/0xb0
[ 6169.570521]  [<ffffffff815f2119>] system_call_fastpath+0x16/0x1b
[ 6169.577273] Code: 10 88 41 7c 8b 81 dc 00 00 00 48 03 81 e0 00 00 00
f0 81 40 24 00 00 01 00 48 8b 83 40 01 00 00 48 8b 75 b0 48 89 41 08 48
89 31 <48> 89 08 83 83 48 01 00 00 01 48 83 bb 68 02 00 00 00 48 89 8b 
[ 6169.606298] RIP  [<ffffffff8151829d>] tcp_sendpage+0x44d/0x6d0
[ 6169.612956]  RSP <ffff8c94c506dbe0>
[ 6169.616925] CR2: 0000000000000000






Partial disassemble up to the crash full one is attached:
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 879
0xffffffff8151823d <tcp_sendpage+1005>: test   %rax,%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 878
0xffffffff81518240 <tcp_sendpage+1008>: mov    %rax,%rcx
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 879
0xffffffff81518243 <tcp_sendpage+1011>: je     0xffffffff815181b0
<tcp_sendpage+864>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 604
0xffffffff81518249 <tcp_sendpage+1017>: movl   $0x0,0x74(%rax)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 605
0xffffffff81518250 <tcp_sendpage+1024>: mov    0x650(%rbx),%eax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 606
0xffffffff81518256 <tcp_sendpage+1030>: movb   $0x10,0x4c(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 607
0xffffffff8151825a <tcp_sendpage+1034>: movb   $0x0,0x4d(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 605
0xffffffff8151825e <tcp_sendpage+1038>: mov    %eax,0x44(%rcx)
0xffffffff81518261 <tcp_sendpage+1041>: mov    %eax,0x40(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 963
0xffffffff81518264 <tcp_sendpage+1044>: movzbl 0x7c(%rcx),%eax
0xffffffff81518268 <tcp_sendpage+1048>: test   $0x10,%al
0xffffffff8151826a <tcp_sendpage+1050>: jne    0xffffffff815184da
<tcp_sendpage+1674>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 964
0xffffffff81518270 <tcp_sendpage+1056>: or     $0x10,%eax
0xffffffff81518273 <tcp_sendpage+1059>: mov    %al,0x7c(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 792
0xffffffff81518276 <tcp_sendpage+1062>: mov    0xdc(%rcx),%eax
0xffffffff8151827c <tcp_sendpage+1068>: add    0xe0(%rcx),%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/arch/x86/include/asm/atomic.h: 49
0xffffffff81518283 <tcp_sendpage+1075>: lock addl $0x10000,0x24(%rax)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 1271
0xffffffff8151828b <tcp_sendpage+1083>: mov    0x140(%rbx),%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 1163
0xffffffff81518292 <tcp_sendpage+1090>: mov    -0x50(%rbp),%rsi
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 1164
0xffffffff81518296 <tcp_sendpage+1094>: mov    %rax,0x8(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 1163
0xffffffff8151829a <tcp_sendpage+1098>: mov    %rsi,(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 1165
0xffffffff8151829d <tcp_sendpage+1101>: mov    %rcx,(%rax)


--=-AKoF5emHwQaUwEW4zyBt
Content-Disposition: attachment; filename="dis.txt"
Content-Type: text/plain; name="dis.txt"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 959
0xffffffff81517e50 <tcp_sendpage>:	nopl   0x0(%rax,%rax,1) [FTRACE NOP]
0xffffffff81517e55 <tcp_sendpage+5>:	push   %rbp
0xffffffff81517e56 <tcp_sendpage+6>:	mov    %rsp,%rbp
0xffffffff81517e59 <tcp_sendpage+9>:	push   %r15
0xffffffff81517e5b <tcp_sendpage+11>:	mov    %rsi,%r15
0xffffffff81517e5e <tcp_sendpage+14>:	push   %r14
0xffffffff81517e60 <tcp_sendpage+16>:	mov    %rcx,%r14
0xffffffff81517e63 <tcp_sendpage+19>:	push   %r13
0xffffffff81517e65 <tcp_sendpage+21>:	push   %r12
0xffffffff81517e67 <tcp_sendpage+23>:	mov    %r8d,%r12d
0xffffffff81517e6a <tcp_sendpage+26>:	push   %rbx
0xffffffff81517e6b <tcp_sendpage+27>:	mov    %rdi,%rbx
0xffffffff81517e6e <tcp_sendpage+30>:	sub    $0x50,%rsp
0xffffffff81517e72 <tcp_sendpage+34>:	mov    %edx,-0x44(%rbp)
0xffffffff81517e75 <tcp_sendpage+37>:	mov    %gs:0x28,%rax
0xffffffff81517e7e <tcp_sendpage+46>:	mov    %rax,-0x30(%rbp)
0xffffffff81517e82 <tcp_sendpage+50>:	xor    %eax,%eax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 962
0xffffffff81517e84 <tcp_sendpage+52>:	mov    0x160(%rdi),%rax
0xffffffff81517e8b <tcp_sendpage+59>:	test   $0x1,%al
0xffffffff81517e8d <tcp_sendpage+61>:	je     0xffffffff81517e93 <tcp_sendpage+67>
0xffffffff81517e8f <tcp_sendpage+63>:	test   $0x1a,%al
0xffffffff81517e91 <tcp_sendpage+65>:	jne    0xffffffff81517ed8 <tcp_sendpage+136>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 964
0xffffffff81517e93 <tcp_sendpage+67>:	mov    0x248(%rbx),%rdi
0xffffffff81517e9a <tcp_sendpage+74>:	mov    -0x44(%rbp),%edx
0xffffffff81517e9d <tcp_sendpage+77>:	mov    %r12d,%r8d
0xffffffff81517ea0 <tcp_sendpage+80>:	mov    %r14,%rcx
0xffffffff81517ea3 <tcp_sendpage+83>:	mov    %r15,%rsi
0xffffffff81517ea6 <tcp_sendpage+86>:	callq  0xffffffff814b9df0 <sock_no_sendpage>
0xffffffff81517eab <tcp_sendpage+91>:	mov    %eax,%r13d
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 971
0xffffffff81517eae <tcp_sendpage+94>:	mov    -0x30(%rbp),%rcx
0xffffffff81517eb2 <tcp_sendpage+98>:	xor    %gs:0x28,%rcx
0xffffffff81517ebb <tcp_sendpage+107>:	mov    %r13d,%eax
0xffffffff81517ebe <tcp_sendpage+110>:	jne    0xffffffff8151848d <tcp_sendpage+1597>
0xffffffff81517ec4 <tcp_sendpage+116>:	add    $0x50,%rsp
0xffffffff81517ec8 <tcp_sendpage+120>:	pop    %rbx
0xffffffff81517ec9 <tcp_sendpage+121>:	pop    %r12
0xffffffff81517ecb <tcp_sendpage+123>:	pop    %r13
0xffffffff81517ecd <tcp_sendpage+125>:	pop    %r14
0xffffffff81517ecf <tcp_sendpage+127>:	pop    %r15
0xffffffff81517ed1 <tcp_sendpage+129>:	pop    %rbp
0xffffffff81517ed2 <tcp_sendpage+130>:	retq   
0xffffffff81517ed3 <tcp_sendpage+131>:	nopl   0x0(%rax,%rax,1)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/net/sock.h: 1505
0xffffffff81517ed8 <tcp_sendpage+136>:	xor    %esi,%esi
0xffffffff81517eda <tcp_sendpage+138>:	callq  0xffffffff814ba330 <lock_sock_nested>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/net/sock.h: 2146
0xffffffff81517edf <tcp_sendpage+143>:	xor    %eax,%eax
0xffffffff81517ee1 <tcp_sendpage+145>:	test   $0x40,%r12b
0xffffffff81517ee5 <tcp_sendpage+149>:	je     0xffffffff81518150 <tcp_sendpage+768>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 847
0xffffffff81517eeb <tcp_sendpage+155>:	mov    %rax,-0x38(%rbp)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 853
0xffffffff81517eef <tcp_sendpage+159>:	movzbl 0x12(%rbx),%eax
0xffffffff81517ef3 <tcp_sendpage+163>:	mov    $0xfffffefd,%edx
0xffffffff81517ef8 <tcp_sendpage+168>:	bt     %eax,%edx
0xffffffff81517efb <tcp_sendpage+171>:	jae    0xffffffff81517f42 <tcp_sendpage+242>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/tcp.h: 362
0xffffffff81517efd <tcp_sendpage+173>:	movzbl 0x12(%rbx),%eax
0xffffffff81517f01 <tcp_sendpage+177>:	cmp    $0x3,%al
0xffffffff81517f03 <tcp_sendpage+179>:	je     0xffffffff81517f38 <tcp_sendpage+232>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 855
0xffffffff81517f05 <tcp_sendpage+181>:	lea    -0x38(%rbp),%rsi
0xffffffff81517f09 <tcp_sendpage+185>:	mov    %rbx,%rdi
0xffffffff81517f0c <tcp_sendpage+188>:	callq  0xffffffff814c6860 <sk_stream_wait_connect>
0xffffffff81517f11 <tcp_sendpage+193>:	test   %eax,%eax
0xffffffff81517f13 <tcp_sendpage+195>:	mov    %eax,%edx
0xffffffff81517f15 <tcp_sendpage+197>:	je     0xffffffff81517f42 <tcp_sendpage+242>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 954
0xffffffff81517f17 <tcp_sendpage+199>:	mov    %r12d,%esi
0xffffffff81517f1a <tcp_sendpage+202>:	mov    %rbx,%rdi
0xffffffff81517f1d <tcp_sendpage+205>:	callq  0xffffffff814c6da0 <sk_stream_error>
0xffffffff81517f22 <tcp_sendpage+210>:	mov    %eax,%r13d
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 969
0xffffffff81517f25 <tcp_sendpage+213>:	mov    %rbx,%rdi
0xffffffff81517f28 <tcp_sendpage+216>:	callq  0xffffffff814bbf30 <release_sock>
0xffffffff81517f2d <tcp_sendpage+221>:	jmpq   0xffffffff81517eae <tcp_sendpage+94>
0xffffffff81517f32 <tcp_sendpage+226>:	nopw   0x0(%rax,%rax,1)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/tcp.h: 362
0xffffffff81517f38 <tcp_sendpage+232>:	cmpq   $0x0,0x758(%rbx)
0xffffffff81517f40 <tcp_sendpage+240>:	je     0xffffffff81517f05 <tcp_sendpage+181>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/arch/x86/include/asm/bitops.h: 104
0xffffffff81517f42 <tcp_sendpage+242>:	mov    0x248(%rbx),%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/arch/x86/include/asm/bitops.h: 103
0xffffffff81517f49 <tcp_sendpage+249>:	lock andb $0xfe,0x8(%rax)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 861
0xffffffff81517f4e <tcp_sendpage+254>:	lea    -0x3c(%rbp),%rsi
0xffffffff81517f52 <tcp_sendpage+258>:	mov    %r12d,%edx
0xffffffff81517f55 <tcp_sendpage+261>:	mov    %rbx,%rdi
0xffffffff81517f58 <tcp_sendpage+264>:	callq  0xffffffff815164c0 <tcp_send_mss>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 865
0xffffffff81517f5d <tcp_sendpage+269>:	mov    0x1b0(%rbx),%r13d
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 861
0xffffffff81517f64 <tcp_sendpage+276>:	mov    %eax,-0x48(%rbp)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 865
0xffffffff81517f67 <tcp_sendpage+279>:	test   %r13d,%r13d
0xffffffff81517f6a <tcp_sendpage+282>:	jne    0xffffffff81518160 <tcp_sendpage+784>
0xffffffff81517f70 <tcp_sendpage+288>:	testb  $0x2,0x150(%rbx)
0xffffffff81517f77 <tcp_sendpage+295>:	jne    0xffffffff81518160 <tcp_sendpage+784>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 868
0xffffffff81517f7d <tcp_sendpage+301>:	test   %r14,%r14
0xffffffff81517f80 <tcp_sendpage+304>:	je     0xffffffff81517f25 <tcp_sendpage+213>
0xffffffff81517f82 <tcp_sendpage+306>:	lea    0x138(%rbx),%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 618
0xffffffff81517f89 <tcp_sendpage+313>:	mov    %r12d,%ecx
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 868
0xffffffff81517f8c <tcp_sendpage+316>:	movq   $0x0,-0x60(%rbp)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 618
0xffffffff81517f94 <tcp_sendpage+324>:	and    $0x1,%ecx
0xffffffff81517f97 <tcp_sendpage+327>:	mov    %rax,-0x50(%rbp)
0xffffffff81517f9b <tcp_sendpage+331>:	mov    0x268(%rbx),%rax
0xffffffff81517fa2 <tcp_sendpage+338>:	mov    %ecx,-0x54(%rbp)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 1096
0xffffffff81517fa5 <tcp_sendpage+341>:	mov    0x140(%rbx),%rcx
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 1099
0xffffffff81517fac <tcp_sendpage+348>:	cmp    -0x50(%rbp),%rcx
0xffffffff81517fb0 <tcp_sendpage+352>:	mov    $0x0,%esi
0xffffffff81517fb5 <tcp_sendpage+357>:	cmove  %rsi,%rcx
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 873
0xffffffff81517fb9 <tcp_sendpage+361>:	test   %rax,%rax
0xffffffff81517fbc <tcp_sendpage+364>:	je     0xffffffff81518192 <tcp_sendpage+834>
0xffffffff81517fc2 <tcp_sendpage+370>:	mov    -0x3c(%rbp),%r8d
0xffffffff81517fc6 <tcp_sendpage+374>:	sub    0x68(%rcx),%r8d
0xffffffff81517fca <tcp_sendpage+378>:	test   %r8d,%r8d
0xffffffff81517fcd <tcp_sendpage+381>:	jle    0xffffffff81518192 <tcp_sendpage+834>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 886
0xffffffff81517fd3 <tcp_sendpage+387>:	movslq %r8d,%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 887
0xffffffff81517fd6 <tcp_sendpage+390>:	cmp    %r14,%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 792
0xffffffff81517fd9 <tcp_sendpage+393>:	mov    0xdc(%rcx),%eax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 887
0xffffffff81517fdf <tcp_sendpage+399>:	cmova  %r14d,%r8d
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 792
0xffffffff81517fe3 <tcp_sendpage+403>:	add    0xe0(%rcx),%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 889
0xffffffff81517fea <tcp_sendpage+410>:	movzbl (%rax),%r9d
0xffffffff81517fee <tcp_sendpage+414>:	movzbl %r9b,%r10d
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 2259
0xffffffff81517ff2 <tcp_sendpage+418>:	test   %r10d,%r10d
0xffffffff81517ff5 <tcp_sendpage+421>:	je     0xffffffff81518170 <tcp_sendpage+800>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 2260
0xffffffff81517ffb <tcp_sendpage+427>:	lea    -0x1(%r10),%edx
0xffffffff81517fff <tcp_sendpage+431>:	movslq %edx,%rdx
0xffffffff81518002 <tcp_sendpage+434>:	add    $0x3,%rdx
0xffffffff81518006 <tcp_sendpage+438>:	shl    $0x4,%rdx
0xffffffff8151800a <tcp_sendpage+442>:	add    %rdx,%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 2262
0xffffffff8151800d <tcp_sendpage+445>:	cmp    (%rax),%r15
0xffffffff81518010 <tcp_sendpage+448>:	jne    0xffffffff81518170 <tcp_sendpage+800>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 2263
0xffffffff81518016 <tcp_sendpage+454>:	mov    0xc(%rax),%edx
0xffffffff81518019 <tcp_sendpage+457>:	add    0x8(%rax),%edx
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 2262
0xffffffff8151801c <tcp_sendpage+460>:	cmp    %edx,-0x44(%rbp)
0xffffffff8151801f <tcp_sendpage+463>:	jne    0xffffffff81518170 <tcp_sendpage+800>
0xffffffff81518025 <tcp_sendpage+469>:	mov    $0x1,%r11d
0xffffffff8151802b <tcp_sendpage+475>:	nopl   0x0(%rax,%rax,1)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/net/sock.h: 1408
0xffffffff81518030 <tcp_sendpage+480>:	mov    0x28(%rbx),%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/net/sock.h: 1413
0xffffffff81518034 <tcp_sendpage+484>:	cmpq   $0x0,0xd8(%rax)
0xffffffff8151803c <tcp_sendpage+492>:	je     0xffffffff8151804b <tcp_sendpage+507>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/net/sock.h: 1415
0xffffffff8151803e <tcp_sendpage+494>:	cmp    0xc0(%rbx),%r8d
0xffffffff81518045 <tcp_sendpage+501>:	jg     0xffffffff8151830b <tcp_sendpage+1211>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 898
0xffffffff8151804b <tcp_sendpage+507>:	test   %r11b,%r11b
0xffffffff8151804e <tcp_sendpage+510>:	je     0xffffffff81518350 <tcp_sendpage+1280>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 792
0xffffffff81518054 <tcp_sendpage+516>:	mov    0xdc(%rcx),%edx
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 899
0xffffffff8151805a <tcp_sendpage+522>:	lea    -0x1(%r10),%eax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 792
0xffffffff8151805e <tcp_sendpage+526>:	add    0xe0(%rcx),%rdx
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 899
0xffffffff81518065 <tcp_sendpage+533>:	cltq   
0xffffffff81518067 <tcp_sendpage+535>:	add    $0x3,%rax
0xffffffff8151806b <tcp_sendpage+539>:	shl    $0x4,%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 180
0xffffffff8151806f <tcp_sendpage+543>:	add    %r8d,0xc(%rdx,%rax,1)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 792
0xffffffff81518074 <tcp_sendpage+548>:	mov    0xdc(%rcx),%eax
0xffffffff8151807a <tcp_sendpage+554>:	add    0xe0(%rcx),%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 904
0xffffffff81518081 <tcp_sendpage+561>:	orb    $0x20,0x1(%rax)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 906
0xffffffff81518085 <tcp_sendpage+565>:	add    %r8d,0x68(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 907
0xffffffff81518089 <tcp_sendpage+569>:	add    %r8d,0x6c(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 908
0xffffffff8151808d <tcp_sendpage+573>:	add    %r8d,0xf0(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/net/sock.h: 1408
0xffffffff81518094 <tcp_sendpage+580>:	mov    0x28(%rbx),%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 909
0xffffffff81518098 <tcp_sendpage+584>:	add    %r8d,0x154(%rbx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/net/sock.h: 1447
0xffffffff8151809f <tcp_sendpage+591>:	cmpq   $0x0,0xd8(%rax)
0xffffffff815180a7 <tcp_sendpage+599>:	je     0xffffffff815180b0 <tcp_sendpage+608>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/net/sock.h: 1449
0xffffffff815180a9 <tcp_sendpage+601>:	sub    %r8d,0xc0(%rbx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 911
0xffffffff815180b0 <tcp_sendpage+608>:	orb    $0xc,0x7c(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 914
0xffffffff815180b4 <tcp_sendpage+612>:	xor    %edi,%edi
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 912
0xffffffff815180b6 <tcp_sendpage+614>:	add    %r8d,0x650(%rbx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 913
0xffffffff815180bd <tcp_sendpage+621>:	add    %r8d,0x44(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 792
0xffffffff815180c1 <tcp_sendpage+625>:	mov    0xdc(%rcx),%eax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 916
0xffffffff815180c7 <tcp_sendpage+631>:	cmpq   $0x0,-0x60(%rbp)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 914
0xffffffff815180cc <tcp_sendpage+636>:	mov    0xe0(%rcx),%rdx
0xffffffff815180d3 <tcp_sendpage+643>:	mov    %di,0x4(%rdx,%rax,1)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 916
0xffffffff815180d8 <tcp_sendpage+648>:	jne    0xffffffff815180de <tcp_sendpage+654>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 917
0xffffffff815180da <tcp_sendpage+650>:	andb   $0xf7,0x4c(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 919
0xffffffff815180de <tcp_sendpage+654>:	movslq %r8d,%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 920
0xffffffff815180e1 <tcp_sendpage+657>:	add    %r8d,-0x44(%rbp)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 919
0xffffffff815180e5 <tcp_sendpage+661>:	add    %rax,-0x60(%rbp)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 921
0xffffffff815180e9 <tcp_sendpage+665>:	sub    %rax,%r14
0xffffffff815180ec <tcp_sendpage+668>:	je     0xffffffff815184ca <tcp_sendpage+1658>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 924
0xffffffff815180f2 <tcp_sendpage+674>:	mov    -0x3c(%rbp),%eax
0xffffffff815180f5 <tcp_sendpage+677>:	cmp    %eax,0x68(%rcx)
0xffffffff815180f8 <tcp_sendpage+680>:	jb     0xffffffff815182ff <tcp_sendpage+1199>
0xffffffff815180fe <tcp_sendpage+686>:	mov    -0x54(%rbp),%esi
0xffffffff81518101 <tcp_sendpage+689>:	test   %esi,%esi
0xffffffff81518103 <tcp_sendpage+691>:	jne    0xffffffff815182ff <tcp_sendpage+1199>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 596
0xffffffff81518109 <tcp_sendpage+697>:	mov    0x5c0(%rbx),%eax
0xffffffff8151810f <tcp_sendpage+703>:	shr    %eax
0xffffffff81518111 <tcp_sendpage+705>:	sub    0x650(%rbx),%eax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 927
0xffffffff81518117 <tcp_sendpage+711>:	add    0x654(%rbx),%eax
0xffffffff8151811d <tcp_sendpage+717>:	js     0xffffffff8151849e <tcp_sendpage+1614>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/net/tcp.h: 1380
0xffffffff81518123 <tcp_sendpage+723>:	mov    0x268(%rbx),%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 930
0xffffffff8151812a <tcp_sendpage+730>:	cmp    %rax,%rcx
0xffffffff8151812d <tcp_sendpage+733>:	jne    0xffffffff81517fa5 <tcp_sendpage+341>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 931
0xffffffff81518133 <tcp_sendpage+739>:	mov    -0x48(%rbp),%esi
0xffffffff81518136 <tcp_sendpage+742>:	mov    %rbx,%rdi
0xffffffff81518139 <tcp_sendpage+745>:	callq  0xffffffff815278f0 <tcp_push_one>
0xffffffff8151813e <tcp_sendpage+750>:	mov    0x268(%rbx),%rax
0xffffffff81518145 <tcp_sendpage+757>:	jmpq   0xffffffff81517fa5 <tcp_sendpage+341>
0xffffffff8151814a <tcp_sendpage+762>:	nopw   0x0(%rax,%rax,1)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/net/sock.h: 2146
0xffffffff81518150 <tcp_sendpage+768>:	mov    0x1e0(%rbx),%rax
0xffffffff81518157 <tcp_sendpage+775>:	jmpq   0xffffffff81517eeb <tcp_sendpage+155>
0xffffffff8151815c <tcp_sendpage+780>:	nopl   0x0(%rax)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 864
0xffffffff81518160 <tcp_sendpage+784>:	mov    $0xffffffe0,%edx
0xffffffff81518165 <tcp_sendpage+789>:	jmpq   0xffffffff81517f17 <tcp_sendpage+199>
0xffffffff8151816a <tcp_sendpage+794>:	nopw   0x0(%rax,%rax,1)
0xffffffff81518170 <tcp_sendpage+800>:	cmp    $0x10,%r9b
0xffffffff81518174 <tcp_sendpage+804>:	seta   %al
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 2262
0xffffffff81518177 <tcp_sendpage+807>:	xor    %r11d,%r11d
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 891
0xffffffff8151817a <tcp_sendpage+810>:	test   %al,%al
0xffffffff8151817c <tcp_sendpage+812>:	je     0xffffffff81518030 <tcp_sendpage+480>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 590
0xffffffff81518182 <tcp_sendpage+818>:	orb    $0x8,0x4c(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 591
0xffffffff81518186 <tcp_sendpage+822>:	mov    0x650(%rbx),%eax
0xffffffff8151818c <tcp_sendpage+828>:	mov    %eax,0x654(%rbx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 875
0xffffffff81518192 <tcp_sendpage+834>:	mov    0x134(%rbx),%eax
0xffffffff81518198 <tcp_sendpage+840>:	cmp    %eax,0x154(%rbx)
0xffffffff8151819e <tcp_sendpage+846>:	jl     0xffffffff8151822d <tcp_sendpage+989>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/arch/x86/include/asm/bitops.h: 66
0xffffffff815181a4 <tcp_sendpage+852>:	mov    0x248(%rbx),%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/arch/x86/include/asm/bitops.h: 65
0xffffffff815181ab <tcp_sendpage+859>:	lock orb $0x4,0x8(%rax)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 625
0xffffffff815181b0 <tcp_sendpage+864>:	cmpq   $0x0,0x268(%rbx)
0xffffffff815181b8 <tcp_sendpage+872>:	je     0xffffffff815181fb <tcp_sendpage+939>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 1096
0xffffffff815181ba <tcp_sendpage+874>:	mov    0x140(%rbx),%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 1099
0xffffffff815181c1 <tcp_sendpage+881>:	cmp    -0x50(%rbp),%rax
0xffffffff815181c5 <tcp_sendpage+885>:	mov    $0x0,%ecx
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 618
0xffffffff815181ca <tcp_sendpage+890>:	mov    -0x54(%rbp),%edx
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 1099
0xffffffff815181cd <tcp_sendpage+893>:	cmove  %rcx,%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 590
0xffffffff815181d1 <tcp_sendpage+897>:	orb    $0x8,0x4c(%rax)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 618
0xffffffff815181d5 <tcp_sendpage+901>:	test   %edx,%edx
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 591
0xffffffff815181d7 <tcp_sendpage+903>:	mov    0x650(%rbx),%eax
0xffffffff815181dd <tcp_sendpage+909>:	mov    %eax,0x654(%rbx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 618
0xffffffff815181e3 <tcp_sendpage+915>:	je     0xffffffff815181eb <tcp_sendpage+923>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 619
0xffffffff815181e5 <tcp_sendpage+917>:	mov    %eax,0x5fc(%rbx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 632
0xffffffff815181eb <tcp_sendpage+923>:	mov    -0x48(%rbp),%esi
0xffffffff815181ee <tcp_sendpage+926>:	mov    $0x4,%edx
0xffffffff815181f3 <tcp_sendpage+931>:	mov    %rbx,%rdi
0xffffffff815181f6 <tcp_sendpage+934>:	callq  0xffffffff81527830 <__tcp_push_pending_frames>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 939
0xffffffff815181fb <tcp_sendpage+939>:	lea    -0x38(%rbp),%rsi
0xffffffff815181ff <tcp_sendpage+943>:	mov    %rbx,%rdi
0xffffffff81518202 <tcp_sendpage+946>:	callq  0xffffffff814c6a20 <sk_stream_wait_memory>
0xffffffff81518207 <tcp_sendpage+951>:	test   %eax,%eax
0xffffffff81518209 <tcp_sendpage+953>:	jne    0xffffffff815183c3 <tcp_sendpage+1395>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 942
0xffffffff8151820f <tcp_sendpage+959>:	lea    -0x3c(%rbp),%rsi
0xffffffff81518213 <tcp_sendpage+963>:	mov    %r12d,%edx
0xffffffff81518216 <tcp_sendpage+966>:	mov    %rbx,%rdi
0xffffffff81518219 <tcp_sendpage+969>:	callq  0xffffffff815164c0 <tcp_send_mss>
0xffffffff8151821e <tcp_sendpage+974>:	mov    %eax,-0x48(%rbp)
0xffffffff81518221 <tcp_sendpage+977>:	mov    0x268(%rbx),%rax
0xffffffff81518228 <tcp_sendpage+984>:	jmpq   0xffffffff81517fa5 <tcp_sendpage+341>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 878
0xffffffff8151822d <tcp_sendpage+989>:	mov    0x158(%rbx),%edx
0xffffffff81518233 <tcp_sendpage+995>:	xor    %esi,%esi
0xffffffff81518235 <tcp_sendpage+997>:	mov    %rbx,%rdi
0xffffffff81518238 <tcp_sendpage+1000>:	callq  0xffffffff81517d40 <sk_stream_alloc_skb>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 879
0xffffffff8151823d <tcp_sendpage+1005>:	test   %rax,%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 878
0xffffffff81518240 <tcp_sendpage+1008>:	mov    %rax,%rcx
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 879
0xffffffff81518243 <tcp_sendpage+1011>:	je     0xffffffff815181b0 <tcp_sendpage+864>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 604
0xffffffff81518249 <tcp_sendpage+1017>:	movl   $0x0,0x74(%rax)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 605
0xffffffff81518250 <tcp_sendpage+1024>:	mov    0x650(%rbx),%eax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 606
0xffffffff81518256 <tcp_sendpage+1030>:	movb   $0x10,0x4c(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 607
0xffffffff8151825a <tcp_sendpage+1034>:	movb   $0x0,0x4d(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp.c: 605
0xffffffff8151825e <tcp_sendpage+1038>:	mov    %eax,0x44(%rcx)
0xffffffff81518261 <tcp_sendpage+1041>:	mov    %eax,0x40(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 963
0xffffffff81518264 <tcp_sendpage+1044>:	movzbl 0x7c(%rcx),%eax
0xffffffff81518268 <tcp_sendpage+1048>:	test   $0x10,%al
0xffffffff8151826a <tcp_sendpage+1050>:	jne    0xffffffff815184da <tcp_sendpage+1674>
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 964
0xffffffff81518270 <tcp_sendpage+1056>:	or     $0x10,%eax
0xffffffff81518273 <tcp_sendpage+1059>:	mov    %al,0x7c(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 792
0xffffffff81518276 <tcp_sendpage+1062>:	mov    0xdc(%rcx),%eax
0xffffffff8151827c <tcp_sendpage+1068>:	add    0xe0(%rcx),%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/arch/x86/include/asm/atomic.h: 49
0xffffffff81518283 <tcp_sendpage+1075>:	lock addl $0x10000,0x24(%rax)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 1271
0xffffffff8151828b <tcp_sendpage+1083>:	mov    0x140(%rbx),%rax
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 1163
0xffffffff81518292 <tcp_sendpage+1090>:	mov    -0x50(%rbp),%rsi
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 1164
0xffffffff81518296 <tcp_sendpage+1094>:	mov    %rax,0x8(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 1163
0xffffffff8151829a <tcp_sendpage+1098>:	mov    %rsi,(%rcx)
/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/include/linux/skbuff.h: 1165
0xffffffff8151829d <tcp_sendpage+1101>:	mov    %rcx,(%rax)

--=-AKoF5emHwQaUwEW4zyBt
Content-Disposition: attachment; filename="dmesg.txt"
Content-Type: text/plain; name="dmesg.txt"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

[   45.190810] microcode: CPU280 sig=0x306e7, pf=0x80, revision=0x70e
[   45.197795] microcode: CPU281 sig=0x306e7, pf=0x80, revision=0x70e
[   45.204778] microcode: CPU282 sig=0x306e7, pf=0x80, revision=0x70e
[   45.211760] microcode: CPU283 sig=0x306e7, pf=0x80, revision=0x70e
[   45.218742] microcode: CPU284 sig=0x306e7, pf=0x80, revision=0x70e
[   45.225735] microcode: CPU285 sig=0x306e7, pf=0x80, revision=0x70e
[   45.232786] microcode: CPU286 sig=0x306e7, pf=0x80, revision=0x70e
[   45.239811] microcode: CPU287 sig=0x306e7, pf=0x80, revision=0x70e
[   45.246793] microcode: CPU288 sig=0x306e7, pf=0x80, revision=0x70e
[   45.253770] microcode: CPU289 sig=0x306e7, pf=0x80, revision=0x70e
[   45.260750] microcode: CPU290 sig=0x306e7, pf=0x80, revision=0x70e
[   45.267729] microcode: CPU291 sig=0x306e7, pf=0x80, revision=0x70e
[   45.274712] microcode: CPU292 sig=0x306e7, pf=0x80, revision=0x70e
[   45.281684] microcode: CPU293 sig=0x306e7, pf=0x80, revision=0x70e
[   45.288667] microcode: CPU294 sig=0x306e7, pf=0x80, revision=0x70e
[   45.295646] microcode: CPU295 sig=0x306e7, pf=0x80, revision=0x70e
[   45.302623] microcode: CPU296 sig=0x306e7, pf=0x80, revision=0x70e
[   45.309605] microcode: CPU297 sig=0x306e7, pf=0x80, revision=0x70e
[   45.316587] microcode: CPU298 sig=0x306e7, pf=0x80, revision=0x70e
[   45.323564] microcode: CPU299 sig=0x306e7, pf=0x80, revision=0x70e
[   45.330557] microcode: CPU300 sig=0x306e7, pf=0x80, revision=0x70e
[   45.337572] microcode: CPU301 sig=0x306e7, pf=0x80, revision=0x70e
[   45.344548] microcode: CPU302 sig=0x306e7, pf=0x80, revision=0x70e
[   45.351523] microcode: CPU303 sig=0x306e7, pf=0x80, revision=0x70e
[   45.358499] microcode: CPU304 sig=0x306e7, pf=0x80, revision=0x70e
[   45.365471] microcode: CPU305 sig=0x306e7, pf=0x80, revision=0x70e
[   45.372448] microcode: CPU306 sig=0x306e7, pf=0x80, revision=0x70e
[   45.379430] microcode: CPU307 sig=0x306e7, pf=0x80, revision=0x70e
[   45.386396] microcode: CPU308 sig=0x306e7, pf=0x80, revision=0x70e
[   45.393376] microcode: CPU309 sig=0x306e7, pf=0x80, revision=0x70e
[   45.400405] microcode: CPU310 sig=0x306e7, pf=0x80, revision=0x70e
[   45.407428] microcode: CPU311 sig=0x306e7, pf=0x80, revision=0x70e
[   45.414410] microcode: CPU312 sig=0x306e7, pf=0x80, revision=0x70e
[   45.421386] microcode: CPU313 sig=0x306e7, pf=0x80, revision=0x70e
[   45.428365] microcode: CPU314 sig=0x306e7, pf=0x80, revision=0x70e
[   45.435352] microcode: CPU315 sig=0x306e7, pf=0x80, revision=0x70e
[   45.442362] microcode: CPU316 sig=0x306e7, pf=0x80, revision=0x70e
[   45.449338] microcode: CPU317 sig=0x306e7, pf=0x80, revision=0x70e
[   45.456323] microcode: CPU318 sig=0x306e7, pf=0x80, revision=0x70e
[   45.463306] microcode: CPU319 sig=0x306e7, pf=0x80, revision=0x70e
[   45.470281] microcode: CPU320 sig=0x306e7, pf=0x80, revision=0x70e
[   45.477258] microcode: CPU321 sig=0x306e7, pf=0x80, revision=0x70e
[   45.484234] microcode: CPU322 sig=0x306e7, pf=0x80, revision=0x70e
[   45.491220] microcode: CPU323 sig=0x306e7, pf=0x80, revision=0x70e
[   45.498206] microcode: CPU324 sig=0x306e7, pf=0x80, revision=0x70e
[   45.505183] microcode: CPU325 sig=0x306e7, pf=0x80, revision=0x70e
[   45.512167] microcode: CPU326 sig=0x306e7, pf=0x80, revision=0x70e
[   45.519148] microcode: CPU327 sig=0x306e7, pf=0x80, revision=0x70e
[   45.526135] microcode: CPU328 sig=0x306e7, pf=0x80, revision=0x70e
[   45.533120] microcode: CPU329 sig=0x306e7, pf=0x80, revision=0x70e
[   45.540116] microcode: CPU330 sig=0x306e7, pf=0x80, revision=0x70e
[   45.547135] microcode: CPU331 sig=0x306e7, pf=0x80, revision=0x70e
[   45.554119] microcode: CPU332 sig=0x306e7, pf=0x80, revision=0x70e
[   45.561099] microcode: CPU333 sig=0x306e7, pf=0x80, revision=0x70e
[   45.568125] microcode: CPU334 sig=0x306e7, pf=0x80, revision=0x70e
[   45.575140] microcode: CPU335 sig=0x306e7, pf=0x80, revision=0x70e
[   45.582122] microcode: CPU336 sig=0x306e7, pf=0x80, revision=0x70e
[   45.589123] microcode: CPU337 sig=0x306e7, pf=0x80, revision=0x70e
[   45.596102] microcode: CPU338 sig=0x306e7, pf=0x80, revision=0x70e
[   45.603085] microcode: CPU339 sig=0x306e7, pf=0x80, revision=0x70e
[   45.610066] microcode: CPU340 sig=0x306e7, pf=0x80, revision=0x70e
[   45.617040] microcode: CPU341 sig=0x306e7, pf=0x80, revision=0x70e
[   45.624022] microcode: CPU342 sig=0x306e7, pf=0x80, revision=0x70e
[   45.631007] microcode: CPU343 sig=0x306e7, pf=0x80, revision=0x70e
[   45.637987] microcode: CPU344 sig=0x306e7, pf=0x80, revision=0x70e
[   45.644976] microcode: CPU345 sig=0x306e7, pf=0x80, revision=0x70e
[   45.651996] microcode: CPU346 sig=0x306e7, pf=0x80, revision=0x70e
[   45.658986] microcode: CPU347 sig=0x306e7, pf=0x80, revision=0x70e
[   45.665972] microcode: CPU348 sig=0x306e7, pf=0x80, revision=0x70e
[   45.672955] microcode: CPU349 sig=0x306e7, pf=0x80, revision=0x70e
[   45.679931] microcode: CPU350 sig=0x306e7, pf=0x80, revision=0x70e
[   45.686914] microcode: CPU351 sig=0x306e7, pf=0x80, revision=0x70e
[   45.693892] microcode: CPU352 sig=0x306e7, pf=0x80, revision=0x70e
[   45.700875] microcode: CPU353 sig=0x306e7, pf=0x80, revision=0x70e
[   45.707859] microcode: CPU354 sig=0x306e7, pf=0x80, revision=0x70e
[   45.714845] microcode: CPU355 sig=0x306e7, pf=0x80, revision=0x70e
[   45.721829] microcode: CPU356 sig=0x306e7, pf=0x80, revision=0x70e
[   45.728824] microcode: CPU357 sig=0x306e7, pf=0x80, revision=0x70e
[   45.735805] microcode: CPU358 sig=0x306e7, pf=0x80, revision=0x70e
[   45.742831] microcode: CPU359 sig=0x306e7, pf=0x80, revision=0x70e
[   45.749852] microcode: CPU360 sig=0x306e7, pf=0x80, revision=0x70e
[   45.756854] microcode: CPU361 sig=0x306e7, pf=0x80, revision=0x70e
[   45.763836] microcode: CPU362 sig=0x306e7, pf=0x80, revision=0x70e
[   45.770816] microcode: CPU363 sig=0x306e7, pf=0x80, revision=0x70e
[   45.777791] microcode: CPU364 sig=0x306e7, pf=0x80, revision=0x70e
[   45.784774] microcode: CPU365 sig=0x306e7, pf=0x80, revision=0x70e
[   45.791754] microcode: CPU366 sig=0x306e7, pf=0x80, revision=0x70e
[   45.798731] microcode: CPU367 sig=0x306e7, pf=0x80, revision=0x70e
[   45.805710] microcode: CPU368 sig=0x306e7, pf=0x80, revision=0x70e
[   45.812687] microcode: CPU369 sig=0x306e7, pf=0x80, revision=0x70e
[   45.819672] microcode: CPU370 sig=0x306e7, pf=0x80, revision=0x70e
[   45.826658] microcode: CPU371 sig=0x306e7, pf=0x80, revision=0x70e
[   45.833630] microcode: CPU372 sig=0x306e7, pf=0x80, revision=0x70e
[   45.840600] microcode: CPU373 sig=0x306e7, pf=0x80, revision=0x70e
[   45.847572] microcode: CPU374 sig=0x306e7, pf=0x80, revision=0x70e
[   45.854562] microcode: CPU375 sig=0x306e7, pf=0x80, revision=0x70e
[   45.861555] microcode: CPU376 sig=0x306e7, pf=0x80, revision=0x70e
[   45.868535] microcode: CPU377 sig=0x306e7, pf=0x80, revision=0x70e
[   45.875512] microcode: CPU378 sig=0x306e7, pf=0x80, revision=0x70e
[   45.882496] microcode: CPU379 sig=0x306e7, pf=0x80, revision=0x70e
[   45.889480] microcode: CPU380 sig=0x306e7, pf=0x80, revision=0x70e
[   45.896459] microcode: CPU381 sig=0x306e7, pf=0x80, revision=0x70e
[   45.903435] microcode: CPU382 sig=0x306e7, pf=0x80, revision=0x70e
[   45.910487] microcode: CPU383 sig=0x306e7, pf=0x80, revision=0x70e
[   45.917492] microcode: CPU384 sig=0x306e7, pf=0x80, revision=0x70e
[   45.924478] microcode: CPU385 sig=0x306e7, pf=0x80, revision=0x70e
[   45.931460] microcode: CPU386 sig=0x306e7, pf=0x80, revision=0x70e
[   45.938440] microcode: CPU387 sig=0x306e7, pf=0x80, revision=0x70e
[   45.945414] microcode: CPU388 sig=0x306e7, pf=0x80, revision=0x70e
[   45.952392] microcode: CPU389 sig=0x306e7, pf=0x80, revision=0x70e
[   45.959375] microcode: CPU390 sig=0x306e7, pf=0x80, revision=0x70e
[   45.966376] microcode: CPU391 sig=0x306e7, pf=0x80, revision=0x70e
[   45.973351] microcode: CPU392 sig=0x306e7, pf=0x80, revision=0x70e
[   45.980329] microcode: CPU393 sig=0x306e7, pf=0x80, revision=0x70e
[   45.987312] microcode: CPU394 sig=0x306e7, pf=0x80, revision=0x70e
[   45.994300] microcode: CPU395 sig=0x306e7, pf=0x80, revision=0x70e
[   46.001284] microcode: CPU396 sig=0x306e7, pf=0x80, revision=0x70e
[   46.008262] microcode: CPU397 sig=0x306e7, pf=0x80, revision=0x70e
[   46.015246] microcode: CPU398 sig=0x306e7, pf=0x80, revision=0x70e
[   46.022229] microcode: CPU399 sig=0x306e7, pf=0x80, revision=0x70e
[   46.029206] microcode: CPU400 sig=0x306e7, pf=0x80, revision=0x70e
[   46.036186] microcode: CPU401 sig=0x306e7, pf=0x80, revision=0x70e
[   46.043164] microcode: CPU402 sig=0x306e7, pf=0x80, revision=0x70e
[   46.050140] microcode: CPU403 sig=0x306e7, pf=0x80, revision=0x70e
[   46.057122] microcode: CPU404 sig=0x306e7, pf=0x80, revision=0x70e
[   46.064103] microcode: CPU405 sig=0x306e7, pf=0x80, revision=0x70e
[   46.071100] microcode: CPU406 sig=0x306e7, pf=0x80, revision=0x70e
[   46.078122] microcode: CPU407 sig=0x306e7, pf=0x80, revision=0x70e
[   46.085127] microcode: CPU408 sig=0x306e7, pf=0x80, revision=0x70e
[   46.092104] microcode: CPU409 sig=0x306e7, pf=0x80, revision=0x70e
[   46.099083] microcode: CPU410 sig=0x306e7, pf=0x80, revision=0x70e
[   46.106061] microcode: CPU411 sig=0x306e7, pf=0x80, revision=0x70e
[   46.113043] microcode: CPU412 sig=0x306e7, pf=0x80, revision=0x70e
[   46.120021] microcode: CPU413 sig=0x306e7, pf=0x80, revision=0x70e
[   46.127004] microcode: CPU414 sig=0x306e7, pf=0x80, revision=0x70e
[   46.133984] microcode: CPU415 sig=0x306e7, pf=0x80, revision=0x70e
[   46.140968] microcode: CPU416 sig=0x306e7, pf=0x80, revision=0x70e
[   46.147952] microcode: CPU417 sig=0x306e7, pf=0x80, revision=0x70e
[   46.154935] microcode: CPU418 sig=0x306e7, pf=0x80, revision=0x70e
[   46.161916] microcode: CPU419 sig=0x306e7, pf=0x80, revision=0x70e
[   46.168903] microcode: CPU420 sig=0x306e7, pf=0x80, revision=0x70e
[   46.175902] microcode: CPU421 sig=0x306e7, pf=0x80, revision=0x70e
[   46.182885] microcode: CPU422 sig=0x306e7, pf=0x80, revision=0x70e
[   46.189875] microcode: CPU423 sig=0x306e7, pf=0x80, revision=0x70e
[   46.196859] microcode: CPU424 sig=0x306e7, pf=0x80, revision=0x70e
[   46.203841] microcode: CPU425 sig=0x306e7, pf=0x80, revision=0x70e
[   46.210824] microcode: CPU426 sig=0x306e7, pf=0x80, revision=0x70e
[   46.217821] microcode: CPU427 sig=0x306e7, pf=0x80, revision=0x70e
[   46.224832] microcode: CPU428 sig=0x306e7, pf=0x80, revision=0x70e
[   46.231813] microcode: CPU429 sig=0x306e7, pf=0x80, revision=0x70e
[   46.238799] microcode: CPU430 sig=0x306e7, pf=0x80, revision=0x70e
[   46.245786] microcode: CPU431 sig=0x306e7, pf=0x80, revision=0x70e
[   46.252779] microcode: CPU432 sig=0x306e7, pf=0x80, revision=0x70e
[   46.259803] microcode: CPU433 sig=0x306e7, pf=0x80, revision=0x70e
[   46.266790] microcode: CPU434 sig=0x306e7, pf=0x80, revision=0x70e
[   46.273772] microcode: CPU435 sig=0x306e7, pf=0x80, revision=0x70e
[   46.280778] microcode: CPU436 sig=0x306e7, pf=0x80, revision=0x70e
[   46.287762] microcode: CPU437 sig=0x306e7, pf=0x80, revision=0x70e
[   46.294741] microcode: CPU438 sig=0x306e7, pf=0x80, revision=0x70e
[   46.301722] microcode: CPU439 sig=0x306e7, pf=0x80, revision=0x70e
[   46.308709] microcode: CPU440 sig=0x306e7, pf=0x80, revision=0x70e
[   46.315690] microcode: CPU441 sig=0x306e7, pf=0x80, revision=0x70e
[   46.322671] microcode: CPU442 sig=0x306e7, pf=0x80, revision=0x70e
[   46.329648] microcode: CPU443 sig=0x306e7, pf=0x80, revision=0x70e
[   46.336631] microcode: CPU444 sig=0x306e7, pf=0x80, revision=0x70e
[   46.343605] microcode: CPU445 sig=0x306e7, pf=0x80, revision=0x70e
[   46.350594] microcode: CPU446 sig=0x306e7, pf=0x80, revision=0x70e
[   46.357575] microcode: CPU447 sig=0x306e7, pf=0x80, revision=0x70e
[   46.364549] microcode: CPU448 sig=0x306e7, pf=0x80, revision=0x70e
[   46.371530] microcode: CPU449 sig=0x306e7, pf=0x80, revision=0x70e
[   46.378514] microcode: CPU450 sig=0x306e7, pf=0x80, revision=0x70e
[   46.385512] microcode: CPU451 sig=0x306e7, pf=0x80, revision=0x70e
[   46.392490] microcode: CPU452 sig=0x306e7, pf=0x80, revision=0x70e
[   46.399469] microcode: CPU453 sig=0x306e7, pf=0x80, revision=0x70e
[   46.406447] microcode: CPU454 sig=0x306e7, pf=0x80, revision=0x70e
[   46.413434] microcode: CPU455 sig=0x306e7, pf=0x80, revision=0x70e
[   46.420462] microcode: CPU456 sig=0x306e7, pf=0x80, revision=0x70e
[   46.427472] microcode: CPU457 sig=0x306e7, pf=0x80, revision=0x70e
[   46.434466] microcode: CPU458 sig=0x306e7, pf=0x80, revision=0x70e
[   46.441447] microcode: CPU459 sig=0x306e7, pf=0x80, revision=0x70e
[   46.448423] microcode: CPU460 sig=0x306e7, pf=0x80, revision=0x70e
[   46.455402] microcode: CPU461 sig=0x306e7, pf=0x80, revision=0x70e
[   46.462385] microcode: CPU462 sig=0x306e7, pf=0x80, revision=0x70e
[   46.469365] microcode: CPU463 sig=0x306e7, pf=0x80, revision=0x70e
[   46.476350] microcode: CPU464 sig=0x306e7, pf=0x80, revision=0x70e
[   46.483339] microcode: CPU465 sig=0x306e7, pf=0x80, revision=0x70e
[   46.490334] microcode: CPU466 sig=0x306e7, pf=0x80, revision=0x70e
[   46.497348] microcode: CPU467 sig=0x306e7, pf=0x80, revision=0x70e
[   46.504341] microcode: CPU468 sig=0x306e7, pf=0x80, revision=0x70e
[   46.511313] microcode: CPU469 sig=0x306e7, pf=0x80, revision=0x70e
[   46.518286] microcode: CPU470 sig=0x306e7, pf=0x80, revision=0x70e
[   46.525262] microcode: CPU471 sig=0x306e7, pf=0x80, revision=0x70e
[   46.532245] microcode: CPU472 sig=0x306e7, pf=0x80, revision=0x70e
[   46.539217] microcode: CPU473 sig=0x306e7, pf=0x80, revision=0x70e
[   46.546202] microcode: CPU474 sig=0x306e7, pf=0x80, revision=0x70e
[   46.553186] microcode: CPU475 sig=0x306e7, pf=0x80, revision=0x70e
[   46.560166] microcode: CPU476 sig=0x306e7, pf=0x80, revision=0x70e
[   46.567150] microcode: CPU477 sig=0x306e7, pf=0x80, revision=0x70e
[   46.574131] microcode: CPU478 sig=0x306e7, pf=0x80, revision=0x70e
[   46.581103] microcode: CPU479 sig=0x306e7, pf=0x80, revision=0x70e
[   46.588499] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[   46.601591] futex hash table entries: 131072 (order: 11, 8388608 bytes)
[   46.619746] Initialise system trusted keyring
[   46.625629] audit: initializing netlink socket (disabled)
[   46.631866] type=2000 audit(1427268658.973:1): initialized
[   46.671079] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[   46.681168] zbud: loaded
[   46.684837] VFS: Disk quotas dquot_6.5.2
[   46.689780] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[   46.699081] msgmni has been set to 32768
[   46.704301] Key type big_key registered
[   46.708700] SELinux:  Registering netfilter hooks
[   46.752669] alg: No test for stdrng (krng)
[   46.757351] NET: Registered protocol family 38
[   46.762439] Key type asymmetric registered
[   46.767119] Asymmetric key parser 'x509' registered
[   46.772905] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[   46.784736] io scheduler noop registered
[   46.789210] io scheduler deadline registered (default)
[   46.795311] io scheduler cfq registered
[   46.803793] pcieport 0000:00:02.0: irq 608 for MSI/MSI-X
[   46.804265] pcieport 0000:00:02.2: irq 609 for MSI/MSI-X
[   46.804700] pcieport 0000:00:03.0: irq 610 for MSI/MSI-X
[   46.805132] pcieport 0000:00:11.0: irq 611 for MSI/MSI-X
[   46.805481] pcieport 0000:00:1c.0: irq 612 for MSI/MSI-X
[   46.806867] pcieport 0000:10:02.0: irq 613 for MSI/MSI-X
[   46.807406] pcieport 0000:10:02.2: irq 614 for MSI/MSI-X
[   46.807825] pcieport 0000:10:03.0: irq 615 for MSI/MSI-X
[   46.809197] pcieport 0000:20:02.0: irq 616 for MSI/MSI-X
[   46.809709] pcieport 0000:20:02.2: irq 617 for MSI/MSI-X
[   46.810165] pcieport 0000:20:03.0: irq 618 for MSI/MSI-X
[   46.810865] pcieport 0000:20:11.0: irq 619 for MSI/MSI-X
[   46.811351] pcieport 0000:20:1c.0: irq 620 for MSI/MSI-X
[   46.812867] pcieport 0000:30:02.0: irq 621 for MSI/MSI-X
[   46.813405] pcieport 0000:30:02.2: irq 622 for MSI/MSI-X
[   46.813824] pcieport 0000:30:03.0: irq 623 for MSI/MSI-X
[   46.815276] pcieport 0000:40:02.0: irq 624 for MSI/MSI-X
[   46.815874] pcieport 0000:40:02.2: irq 625 for MSI/MSI-X
[   46.816314] pcieport 0000:40:03.0: irq 626 for MSI/MSI-X
[   46.816808] pcieport 0000:40:11.0: irq 627 for MSI/MSI-X
[   46.817311] pcieport 0000:40:1c.0: irq 628 for MSI/MSI-X
[   46.818898] pcieport 0000:50:02.0: irq 629 for MSI/MSI-X
[   46.819434] pcieport 0000:50:02.2: irq 630 for MSI/MSI-X
[   46.819855] pcieport 0000:50:03.0: irq 631 for MSI/MSI-X
[   46.821316] pcieport 0000:60:02.0: irq 632 for MSI/MSI-X
[   46.821951] pcieport 0000:60:02.2: irq 633 for MSI/MSI-X
[   46.822456] pcieport 0000:60:03.0: irq 634 for MSI/MSI-X
[   46.822942] pcieport 0000:60:11.0: irq 635 for MSI/MSI-X
[   46.823460] pcieport 0000:60:1c.0: irq 636 for MSI/MSI-X
[   46.825031] pcieport 0000:70:02.0: irq 637 for MSI/MSI-X
[   46.825596] pcieport 0000:70:02.2: irq 638 for MSI/MSI-X
[   46.826088] pcieport 0000:70:03.0: irq 639 for MSI/MSI-X
[   46.826941] pcieport 0000:84:02.0: irq 640 for MSI/MSI-X
[   46.827416] pcieport 0000:84:02.2: irq 641 for MSI/MSI-X
[   46.827847] pcieport 0000:84:03.0: irq 642 for MSI/MSI-X
[   46.828301] pcieport 0000:84:11.0: irq 643 for MSI/MSI-X
[   46.828791] pcieport 0000:84:1c.0: irq 644 for MSI/MSI-X
[   46.830284] pcieport 0000:90:02.0: irq 645 for MSI/MSI-X
[   46.830795] pcieport 0000:90:02.2: irq 646 for MSI/MSI-X
[   46.831201] pcieport 0000:90:03.0: irq 647 for MSI/MSI-X
[   46.832756] pcieport 0000:a0:02.0: irq 648 for MSI/MSI-X
[   46.833288] pcieport 0000:a0:02.2: irq 649 for MSI/MSI-X
[   46.833750] pcieport 0000:a0:03.0: irq 650 for MSI/MSI-X
[   46.834478] pcieport 0000:a0:11.0: irq 651 for MSI/MSI-X
[   46.834945] pcieport 0000:a0:1c.0: irq 652 for MSI/MSI-X
[   46.836546] pcieport 0000:b0:02.0: irq 653 for MSI/MSI-X
[   46.837105] pcieport 0000:b0:02.2: irq 654 for MSI/MSI-X
[   46.837511] pcieport 0000:b0:03.0: irq 655 for MSI/MSI-X
[   46.838992] pcieport 0000:c0:02.0: irq 656 for MSI/MSI-X
[   46.839510] pcieport 0000:c0:02.2: irq 657 for MSI/MSI-X
[   46.839928] pcieport 0000:c0:03.0: irq 658 for MSI/MSI-X
[   46.840410] pcieport 0000:c0:11.0: irq 659 for MSI/MSI-X
[   46.840886] pcieport 0000:c0:1c.0: irq 660 for MSI/MSI-X
[   46.842564] pcieport 0000:d0:02.0: irq 661 for MSI/MSI-X
[   46.843054] pcieport 0000:d0:02.2: irq 662 for MSI/MSI-X
[   46.843486] pcieport 0000:d0:03.0: irq 663 for MSI/MSI-X
[   46.845011] pcieport 0000:e0:02.0: irq 664 for MSI/MSI-X
[   46.845529] pcieport 0000:e0:02.2: irq 665 for MSI/MSI-X
[   46.845957] pcieport 0000:e0:03.0: irq 666 for MSI/MSI-X
[   46.846410] pcieport 0000:e0:11.0: irq 667 for MSI/MSI-X
[   46.846880] pcieport 0000:e0:1c.0: irq 668 for MSI/MSI-X
[   46.848495] pcieport 0000:f0:02.0: irq 669 for MSI/MSI-X
[   46.848980] pcieport 0000:f0:02.2: irq 670 for MSI/MSI-X
[   46.849401] pcieport 0000:f0:03.0: irq 671 for MSI/MSI-X
[   46.849644] pcieport 0000:00:02.0: Signaling PME through PCIe PME interrupt
[   46.857487] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
[   46.864846] pci 0000:01:00.1: Signaling PME through PCIe PME interrupt
[   46.872210] pcie_pme 0000:00:02.0:pcie01: service driver pcie_pme loaded
[   46.872245] pcieport 0000:00:02.2: Signaling PME through PCIe PME interrupt
[   46.880077] pci 0000:03:00.0: Signaling PME through PCIe PME interrupt
[   46.887447] pci 0000:03:00.1: Signaling PME through PCIe PME interrupt
[   46.894805] pcie_pme 0000:00:02.2:pcie01: service driver pcie_pme loaded
[   46.894839] pcieport 0000:00:03.0: Signaling PME through PCIe PME interrupt
[   46.902673] pcie_pme 0000:00:03.0:pcie01: service driver pcie_pme loaded
[   46.902704] pcieport 0000:00:11.0: Signaling PME through PCIe PME interrupt
[   46.910556] pcie_pme 0000:00:11.0:pcie01: service driver pcie_pme loaded
[   46.910616] pcieport 0000:00:1c.0: Signaling PME through PCIe PME interrupt
[   46.918450] pci 0000:07:00.0: Signaling PME through PCIe PME interrupt
[   46.925810] pci 0000:07:00.1: Signaling PME through PCIe PME interrupt
[   46.933177] pci 0000:07:00.2: Signaling PME through PCIe PME interrupt
[   46.940540] pci 0000:07:00.4: Signaling PME through PCIe PME interrupt
[   46.947908] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
[   46.947946] pcieport 0000:10:02.0: Signaling PME through PCIe PME interrupt
[   46.955720] pcie_pme 0000:10:02.0:pcie01: service driver pcie_pme loaded
[   46.955751] pcieport 0000:10:02.2: Signaling PME through PCIe PME interrupt
[   46.963579] pcie_pme 0000:10:02.2:pcie01: service driver pcie_pme loaded
[   46.963637] pcieport 0000:10:03.0: Signaling PME through PCIe PME interrupt
[   46.971472] pci 0000:13:00.0: Signaling PME through PCIe PME interrupt
[   46.978836] pci 0000:13:00.1: Signaling PME through PCIe PME interrupt
[   46.986208] pcie_pme 0000:10:03.0:pcie01: service driver pcie_pme loaded
[   46.986246] pcieport 0000:20:02.0: Signaling PME through PCIe PME interrupt
[   46.994082] pci 0000:21:00.0: Signaling PME through PCIe PME interrupt
[   47.001444] pci 0000:21:00.1: Signaling PME through PCIe PME interrupt
[   47.008808] pcie_pme 0000:20:02.0:pcie01: service driver pcie_pme loaded
[   47.008836] pcieport 0000:20:02.2: Signaling PME through PCIe PME interrupt
[   47.016681] pci 0000:23:00.0: Signaling PME through PCIe PME interrupt
[   47.024049] pci 0000:23:00.1: Signaling PME through PCIe PME interrupt
[   47.031419] pcie_pme 0000:20:02.2:pcie01: service driver pcie_pme loaded
[   47.031448] pcieport 0000:20:03.0: Signaling PME through PCIe PME interrupt
[   47.039286] pcie_pme 0000:20:03.0:pcie01: service driver pcie_pme loaded
[   47.039319] pcieport 0000:20:11.0: Signaling PME through PCIe PME interrupt
[   47.047175] pcie_pme 0000:20:11.0:pcie01: service driver pcie_pme loaded
[   47.047216] pcieport 0000:20:1c.0: Signaling PME through PCIe PME interrupt
[   47.055088] pci 0000:27:00.0: Signaling PME through PCIe PME interrupt
[   47.062448] pci 0000:27:00.2: Signaling PME through PCIe PME interrupt
[   47.069818] pcie_pme 0000:20:1c.0:pcie01: service driver pcie_pme loaded
[   47.069852] pcieport 0000:30:02.0: Signaling PME through PCIe PME interrupt
[   47.077693] pcie_pme 0000:30:02.0:pcie01: service driver pcie_pme loaded
[   47.077719] pcieport 0000:30:02.2: Signaling PME through PCIe PME interrupt
[   47.085557] pcie_pme 0000:30:02.2:pcie01: service driver pcie_pme loaded
[   47.085627] pcieport 0000:30:03.0: Signaling PME through PCIe PME interrupt
[   47.093476] pci 0000:33:00.0: Signaling PME through PCIe PME interrupt
[   47.100835] pci 0000:33:00.1: Signaling PME through PCIe PME interrupt
[   47.108199] pcie_pme 0000:30:03.0:pcie01: service driver pcie_pme loaded
[   47.108233] pcieport 0000:40:02.0: Signaling PME through PCIe PME interrupt
[   47.116091] pci 0000:41:00.0: Signaling PME through PCIe PME interrupt
[   47.123461] pci 0000:41:00.1: Signaling PME through PCIe PME interrupt
[   47.130826] pcie_pme 0000:40:02.0:pcie01: service driver pcie_pme loaded
[   47.130852] pcieport 0000:40:02.2: Signaling PME through PCIe PME interrupt
[   47.138691] pci 0000:43:00.0: Signaling PME through PCIe PME interrupt
[   47.146058] pci 0000:43:00.1: Signaling PME through PCIe PME interrupt
[   47.153423] pcie_pme 0000:40:02.2:pcie01: service driver pcie_pme loaded
[   47.153459] pcieport 0000:40:03.0: Signaling PME through PCIe PME interrupt
[   47.161298] pcie_pme 0000:40:03.0:pcie01: service driver pcie_pme loaded
[   47.161323] pcieport 0000:40:11.0: Signaling PME through PCIe PME interrupt
[   47.169158] pcie_pme 0000:40:11.0:pcie01: service driver pcie_pme loaded
[   47.169260] pcieport 0000:40:1c.0: Signaling PME through PCIe PME interrupt
[   47.177115] pci 0000:47:00.0: Signaling PME through PCIe PME interrupt
[   47.184479] pci 0000:47:00.2: Signaling PME through PCIe PME interrupt
[   47.191839] pcie_pme 0000:40:1c.0:pcie01: service driver pcie_pme loaded
[   47.191875] pcieport 0000:50:02.0: Signaling PME through PCIe PME interrupt
[   47.199729] pcie_pme 0000:50:02.0:pcie01: service driver pcie_pme loaded
[   47.199762] pcieport 0000:50:02.2: Signaling PME through PCIe PME interrupt
[   47.207613] pcie_pme 0000:50:02.2:pcie01: service driver pcie_pme loaded
[   47.207639] pcieport 0000:50:03.0: Signaling PME through PCIe PME interrupt
[   47.215483] pci 0000:53:00.0: Signaling PME through PCIe PME interrupt
[   47.222847] pci 0000:53:00.1: Signaling PME through PCIe PME interrupt
[   47.230216] pcie_pme 0000:50:03.0:pcie01: service driver pcie_pme loaded
[   47.230278] pcieport 0000:60:02.0: Signaling PME through PCIe PME interrupt
[   47.238106] pci 0000:61:00.0: Signaling PME through PCIe PME interrupt
[   47.245459] pci 0000:61:00.1: Signaling PME through PCIe PME interrupt
[   47.252824] pcie_pme 0000:60:02.0:pcie01: service driver pcie_pme loaded
[   47.252854] pcieport 0000:60:02.2: Signaling PME through PCIe PME interrupt
[   47.260681] pci 0000:63:00.0: Signaling PME through PCIe PME interrupt
[   47.268051] pci 0000:63:00.1: Signaling PME through PCIe PME interrupt
[   47.275421] pcie_pme 0000:60:02.2:pcie01: service driver pcie_pme loaded
[   47.275450] pcieport 0000:60:03.0: Signaling PME through PCIe PME interrupt
[   47.283290] pcie_pme 0000:60:03.0:pcie01: service driver pcie_pme loaded
[   47.283320] pcieport 0000:60:11.0: Signaling PME through PCIe PME interrupt
[   47.291164] pcie_pme 0000:60:11.0:pcie01: service driver pcie_pme loaded
[   47.291194] pcieport 0000:60:1c.0: Signaling PME through PCIe PME interrupt
[   47.299040] pci 0000:67:00.0: Signaling PME through PCIe PME interrupt
[   47.306405] pci 0000:67:00.2: Signaling PME through PCIe PME interrupt
[   47.313766] pcie_pme 0000:60:1c.0:pcie01: service driver pcie_pme loaded
[   47.313806] pcieport 0000:70:02.0: Signaling PME through PCIe PME interrupt
[   47.321653] pcie_pme 0000:70:02.0:pcie01: service driver pcie_pme loaded
[   47.321679] pcieport 0000:70:02.2: Signaling PME through PCIe PME interrupt
[   47.329518] pcie_pme 0000:70:02.2:pcie01: service driver pcie_pme loaded
[   47.329543] pcieport 0000:70:03.0: Signaling PME through PCIe PME interrupt
[   47.337391] pci 0000:73:00.0: Signaling PME through PCIe PME interrupt
[   47.344753] pci 0000:73:00.1: Signaling PME through PCIe PME interrupt
[   47.352115] pcie_pme 0000:70:03.0:pcie01: service driver pcie_pme loaded
[   47.352164] pcieport 0000:84:02.0: Signaling PME through PCIe PME interrupt
[   47.359993] pci 0000:85:00.0: Signaling PME through PCIe PME interrupt
[   47.367356] pci 0000:85:00.1: Signaling PME through PCIe PME interrupt
[   47.374722] pcie_pme 0000:84:02.0:pcie01: service driver pcie_pme loaded
[   47.374756] pcieport 0000:84:02.2: Signaling PME through PCIe PME interrupt
[   47.382594] pci 0000:87:00.0: Signaling PME through PCIe PME interrupt
[   47.389954] pci 0000:87:00.1: Signaling PME through PCIe PME interrupt
[   47.397317] pcie_pme 0000:84:02.2:pcie01: service driver pcie_pme loaded
[   47.397335] pcieport 0000:84:03.0: Signaling PME through PCIe PME interrupt
[   47.405179] pcie_pme 0000:84:03.0:pcie01: service driver pcie_pme loaded
[   47.405198] pcieport 0000:84:11.0: Signaling PME through PCIe PME interrupt
[   47.413045] pcie_pme 0000:84:11.0:pcie01: service driver pcie_pme loaded
[   47.413066] pcieport 0000:84:1c.0: Signaling PME through PCIe PME interrupt
[   47.420912] pci 0000:8b:00.0: Signaling PME through PCIe PME interrupt
[   47.428276] pci 0000:8b:00.2: Signaling PME through PCIe PME interrupt
[   47.435641] pcie_pme 0000:84:1c.0:pcie01: service driver pcie_pme loaded
[   47.435670] pcieport 0000:90:02.0: Signaling PME through PCIe PME interrupt
[   47.443501] pcie_pme 0000:90:02.0:pcie01: service driver pcie_pme loaded
[   47.443523] pcieport 0000:90:02.2: Signaling PME through PCIe PME interrupt
[   47.451367] pcie_pme 0000:90:02.2:pcie01: service driver pcie_pme loaded
[   47.451389] pcieport 0000:90:03.0: Signaling PME through PCIe PME interrupt
[   47.459219] pci 0000:93:00.0: Signaling PME through PCIe PME interrupt
[   47.466579] pci 0000:93:00.1: Signaling PME through PCIe PME interrupt
[   47.473943] pcie_pme 0000:90:03.0:pcie01: service driver pcie_pme loaded
[   47.473972] pcieport 0000:a0:02.0: Signaling PME through PCIe PME interrupt
[   47.481838] pci 0000:a1:00.0: Signaling PME through PCIe PME interrupt
[   47.489195] pci 0000:a1:00.1: Signaling PME through PCIe PME interrupt
[   47.496564] pcie_pme 0000:a0:02.0:pcie01: service driver pcie_pme loaded
[   47.496652] pcieport 0000:a0:02.2: Signaling PME through PCIe PME interrupt
[   47.504484] pci 0000:a3:00.0: Signaling PME through PCIe PME interrupt
[   47.511851] pci 0000:a3:00.1: Signaling PME through PCIe PME interrupt
[   47.519213] pcie_pme 0000:a0:02.2:pcie01: service driver pcie_pme loaded
[   47.519242] pcieport 0000:a0:03.0: Signaling PME through PCIe PME interrupt
[   47.527080] pcie_pme 0000:a0:03.0:pcie01: service driver pcie_pme loaded
[   47.527107] pcieport 0000:a0:11.0: Signaling PME through PCIe PME interrupt
[   47.534952] pcie_pme 0000:a0:11.0:pcie01: service driver pcie_pme loaded
[   47.534981] pcieport 0000:a0:1c.0: Signaling PME through PCIe PME interrupt
[   47.542823] pci 0000:a7:00.0: Signaling PME through PCIe PME interrupt
[   47.550180] pci 0000:a7:00.2: Signaling PME through PCIe PME interrupt
[   47.557534] pcie_pme 0000:a0:1c.0:pcie01: service driver pcie_pme loaded
[   47.557567] pcieport 0000:b0:02.0: Signaling PME through PCIe PME interrupt
[   47.565405] pcie_pme 0000:b0:02.0:pcie01: service driver pcie_pme loaded
[   47.565439] pcieport 0000:b0:02.2: Signaling PME through PCIe PME interrupt
[   47.573282] pcie_pme 0000:b0:02.2:pcie01: service driver pcie_pme loaded
[   47.573308] pcieport 0000:b0:03.0: Signaling PME through PCIe PME interrupt
[   47.581147] pci 0000:b3:00.0: Signaling PME through PCIe PME interrupt
[   47.588508] pci 0000:b3:00.1: Signaling PME through PCIe PME interrupt
[   47.595871] pcie_pme 0000:b0:03.0:pcie01: service driver pcie_pme loaded
[   47.595899] pcieport 0000:c0:02.0: Signaling PME through PCIe PME interrupt
[   47.603739] pci 0000:c1:00.0: Signaling PME through PCIe PME interrupt
[   47.611096] pci 0000:c1:00.1: Signaling PME through PCIe PME interrupt
[   47.618453] pcie_pme 0000:c0:02.0:pcie01: service driver pcie_pme loaded
[   47.618508] pcieport 0000:c0:02.2: Signaling PME through PCIe PME interrupt
[   47.626344] pci 0000:c3:00.0: Signaling PME through PCIe PME interrupt
[   47.633707] pci 0000:c3:00.1: Signaling PME through PCIe PME interrupt
[   47.641074] pcie_pme 0000:c0:02.2:pcie01: service driver pcie_pme loaded
[   47.641108] pcieport 0000:c0:03.0: Signaling PME through PCIe PME interrupt
[   47.648955] pcie_pme 0000:c0:03.0:pcie01: service driver pcie_pme loaded
[   47.648981] pcieport 0000:c0:11.0: Signaling PME through PCIe PME interrupt
[   47.656822] pcie_pme 0000:c0:11.0:pcie01: service driver pcie_pme loaded
[   47.656848] pcieport 0000:c0:1c.0: Signaling PME through PCIe PME interrupt
[   47.664689] pci 0000:c7:00.0: Signaling PME through PCIe PME interrupt
[   47.672047] pci 0000:c7:00.2: Signaling PME through PCIe PME interrupt
[   47.679422] pcie_pme 0000:c0:1c.0:pcie01: service driver pcie_pme loaded
[   47.679459] pcieport 0000:d0:02.0: Signaling PME through PCIe PME interrupt
[   47.687302] pcie_pme 0000:d0:02.0:pcie01: service driver pcie_pme loaded
[   47.687343] pcieport 0000:d0:02.2: Signaling PME through PCIe PME interrupt
[   47.695184] pcie_pme 0000:d0:02.2:pcie01: service driver pcie_pme loaded
[   47.695211] pcieport 0000:d0:03.0: Signaling PME through PCIe PME interrupt
[   47.703056] pci 0000:d3:00.0: Signaling PME through PCIe PME interrupt
[   47.710421] pci 0000:d3:00.1: Signaling PME through PCIe PME interrupt
[   47.717791] pcie_pme 0000:d0:03.0:pcie01: service driver pcie_pme loaded
[   47.717820] pcieport 0000:e0:02.0: Signaling PME through PCIe PME interrupt
[   47.725660] pci 0000:e1:00.0: Signaling PME through PCIe PME interrupt
[   47.733024] pci 0000:e1:00.1: Signaling PME through PCIe PME interrupt
[   47.740403] pcie_pme 0000:e0:02.0:pcie01: service driver pcie_pme loaded
[   47.740450] pcieport 0000:e0:02.2: Signaling PME through PCIe PME interrupt
[   47.748274] pci 0000:e3:00.0: Signaling PME through PCIe PME interrupt
[   47.755641] pci 0000:e3:00.1: Signaling PME through PCIe PME interrupt
[   47.763012] pcie_pme 0000:e0:02.2:pcie01: service driver pcie_pme loaded
[   47.763044] pcieport 0000:e0:03.0: Signaling PME through PCIe PME interrupt
[   47.770885] pcie_pme 0000:e0:03.0:pcie01: service driver pcie_pme loaded
[   47.770915] pcieport 0000:e0:11.0: Signaling PME through PCIe PME interrupt
[   47.778750] pcie_pme 0000:e0:11.0:pcie01: service driver pcie_pme loaded
[   47.778780] pcieport 0000:e0:1c.0: Signaling PME through PCIe PME interrupt
[   47.786625] pci 0000:e7:00.0: Signaling PME through PCIe PME interrupt
[   47.793986] pci 0000:e7:00.2: Signaling PME through PCIe PME interrupt
[   47.801347] pcie_pme 0000:e0:1c.0:pcie01: service driver pcie_pme loaded
[   47.801399] pcieport 0000:f0:02.0: Signaling PME through PCIe PME interrupt
[   47.809245] pcie_pme 0000:f0:02.0:pcie01: service driver pcie_pme loaded
[   47.809280] pcieport 0000:f0:02.2: Signaling PME through PCIe PME interrupt
[   47.817127] pcie_pme 0000:f0:02.2:pcie01: service driver pcie_pme loaded
[   47.817186] pcieport 0000:f0:03.0: Signaling PME through PCIe PME interrupt
[   47.825036] pci 0000:f3:00.0: Signaling PME through PCIe PME interrupt
[   47.832397] pci 0000:f3:00.1: Signaling PME through PCIe PME interrupt
[   47.839765] pcie_pme 0000:f0:03.0:pcie01: service driver pcie_pme loaded
[   47.839889] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   47.846219] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[   47.854098] efifb: probing for efifb
[   47.859391] efifb: framebuffer at 0x92000000, mapped to 0xffffc90844480000, using 3072k, total 3072k
[   47.869607] efifb: mode is 1024x768x32, linelength=4096, pages=1
[   47.876398] efifb: scrolling: redraw
[   47.880522] efifb: Truecolor: size=8:8:8:8, shift=24:16:8:0
[   47.919940] Console: switching to colour frame buffer device 128x48
[   47.959072] fb0: EFI VGA frame buffer device
[   47.964000] intel_idle: MWAIT substates: 0x1120
[   47.964002] intel_idle: v0.4 model 0x3E
[   47.964003] intel_idle: lapic_timer_reliable_states 0xffffffff
[   47.967871] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
[   47.977035] ACPI: Power Button [PWRB]
[   47.981427] ACPI: Requesting acpi_cpufreq
[   48.001068] GHES: APEI firmware first mode is enabled by APEI bit and WHEA _OSC.
[   48.009716] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   48.037582] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   48.046843] Non-volatile memory driver v1.3
[   48.051594] Linux agpgart interface v0.103
[   48.057336] crash memory driver: version 1.1
[   48.065059] rdac: device handler registered
[   48.070541] hp_sw: device handler registered
[   48.075382] emc: device handler registered
[   48.080054] alua: device handler registered
[   48.084885] libphy: Fixed MDIO Bus: probed
[   48.089664] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   48.096998] ehci-pci: EHCI PCI platform driver
[   48.103725] ehci-pci 0000:00:1d.0: EHCI Host Controller
[   48.109944] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 1
[   48.118231] ehci-pci 0000:00:1d.0: debug port 2
[   48.127289] ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
[   48.127348] ehci-pci 0000:00:1d.0: irq 23, io mem 0x90700000
[   48.139309] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[   48.145868] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[   48.153486] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   48.161598] usb usb1: Product: EHCI Host Controller
[   48.167127] usb usb1: Manufacturer: Linux 3.10.0-123.el7.x86_64 ehci_hcd
[   48.174662] usb usb1: SerialNumber: 0000:00:1d.0
[   48.180206] hub 1-0:1.0: USB hub found
[   48.184491] hub 1-0:1.0: 2 ports detected
[   48.191401] ehci-pci 0000:20:1d.0: EHCI Host Controller
[   48.197589] ehci-pci 0000:20:1d.0: new USB bus registered, assigned bus number 2
[   48.205899] ehci-pci 0000:20:1d.0: debug port 2
[   48.214984] ehci-pci 0000:20:1d.0: cache line size of 64 is not supported
[   48.215050] ehci-pci 0000:20:1d.0: irq 95, io mem 0x98600000
[   48.227420] ehci-pci 0000:20:1d.0: USB 2.0 started, EHCI 1.00
[   48.234019] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[   48.241649] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   48.249759] usb usb2: Product: EHCI Host Controller
[   48.255286] usb usb2: Manufacturer: Linux 3.10.0-123.el7.x86_64 ehci_hcd
[   48.262819] usb usb2: SerialNumber: 0000:20:1d.0
[   48.268360] hub 2-0:1.0: USB hub found
[   48.272646] hub 2-0:1.0: 2 ports detected
[   48.279598] ehci-pci 0000:40:1d.0: EHCI Host Controller
[   48.286036] ehci-pci 0000:40:1d.0: new USB bus registered, assigned bus number 3
[   48.294355] ehci-pci 0000:40:1d.0: debug port 2
[   48.303448] ehci-pci 0000:40:1d.0: cache line size of 64 is not supported
[   48.303535] ehci-pci 0000:40:1d.0: irq 167, io mem 0xa0600000
[   48.315530] ehci-pci 0000:40:1d.0: USB 2.0 started, EHCI 1.00
[   48.322121] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
[   48.329741] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   48.337856] usb usb3: Product: EHCI Host Controller
[   48.343381] usb usb3: Manufacturer: Linux 3.10.0-123.el7.x86_64 ehci_hcd
[   48.350925] usb usb3: SerialNumber: 0000:40:1d.0
[   48.356501] hub 3-0:1.0: USB hub found
[   48.360789] hub 3-0:1.0: 2 ports detected
[   48.367697] ehci-pci 0000:60:1d.0: EHCI Host Controller
[   48.374194] ehci-pci 0000:60:1d.0: new USB bus registered, assigned bus number 4
[   48.382525] ehci-pci 0000:60:1d.0: debug port 2
[   48.391617] ehci-pci 0000:60:1d.0: cache line size of 64 is not supported
[   48.391694] ehci-pci 0000:60:1d.0: irq 239, io mem 0xa8600000
[   48.491809] usb 1-1: new high-speed USB device number 2 using ehci-pci
[   48.497772] ehci-pci 0000:60:1d.0: USB 2.0 started, EHCI 1.00
[   48.497882] usb usb4: New USB device found, idVendor=1d6b, idProduct=0002
[   48.497883] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   48.497885] usb usb4: Product: EHCI Host Controller
[   48.497886] usb usb4: Manufacturer: Linux 3.10.0-123.el7.x86_64 ehci_hcd
[   48.497887] usb usb4: SerialNumber: 0000:60:1d.0
[   48.498233] hub 4-0:1.0: USB hub found
[   48.498244] hub 4-0:1.0: 2 ports detected
[   48.499943] ehci-pci 0000:84:1d.0: EHCI Host Controller
[   48.500247] ehci-pci 0000:84:1d.0: new USB bus registered, assigned bus number 5
[   48.500272] ehci-pci 0000:84:1d.0: debug port 2
[   48.504197] ehci-pci 0000:84:1d.0: cache line size of 64 is not supported
[   48.504244] ehci-pci 0000:84:1d.0: irq 311, io mem 0xb0600000
[   48.509776] ehci-pci 0000:84:1d.0: USB 2.0 started, EHCI 1.00
[   48.509896] usb usb5: New USB device found, idVendor=1d6b, idProduct=0002
[   48.509897] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   48.509900] usb usb5: Product: EHCI Host Controller
[   48.509902] usb usb5: Manufacturer: Linux 3.10.0-123.el7.x86_64 ehci_hcd
[   48.509903] usb usb5: SerialNumber: 0000:84:1d.0
[   48.510212] hub 5-0:1.0: USB hub found
[   48.510220] hub 5-0:1.0: 2 ports detected
[   48.512566] ehci-pci 0000:a0:1d.0: EHCI Host Controller
[   48.513105] ehci-pci 0000:a0:1d.0: new USB bus registered, assigned bus number 6
[   48.513126] ehci-pci 0000:a0:1d.0: debug port 2
[   48.517055] ehci-pci 0000:a0:1d.0: cache line size of 64 is not supported
[   48.517120] ehci-pci 0000:a0:1d.0: irq 383, io mem 0xb8600000
[   48.522796] ehci-pci 0000:a0:1d.0: USB 2.0 started, EHCI 1.00
[   48.522900] usb usb6: New USB device found, idVendor=1d6b, idProduct=0002
[   48.522902] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   48.522903] usb usb6: Product: EHCI Host Controller
[   48.522905] usb usb6: Manufacturer: Linux 3.10.0-123.el7.x86_64 ehci_hcd
[   48.522905] usb usb6: SerialNumber: 0000:a0:1d.0
[   48.523252] hub 6-0:1.0: USB hub found
[   48.523262] hub 6-0:1.0: 2 ports detected
[   48.525571] ehci-pci 0000:c0:1d.0: EHCI Host Controller
[   48.526133] ehci-pci 0000:c0:1d.0: new USB bus registered, assigned bus number 7
[   48.526154] ehci-pci 0000:c0:1d.0: debug port 2
[   48.530106] ehci-pci 0000:c0:1d.0: cache line size of 64 is not supported
[   48.530173] ehci-pci 0000:c0:1d.0: irq 455, io mem 0xc0600000
[   48.535810] ehci-pci 0000:c0:1d.0: USB 2.0 started, EHCI 1.00
[   48.535923] usb usb7: New USB device found, idVendor=1d6b, idProduct=0002
[   48.535925] usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   48.535926] usb usb7: Product: EHCI Host Controller
[   48.535928] usb usb7: Manufacturer: Linux 3.10.0-123.el7.x86_64 ehci_hcd
[   48.535928] usb usb7: SerialNumber: 0000:c0:1d.0
[   48.536284] hub 7-0:1.0: USB hub found
[   48.536293] hub 7-0:1.0: 2 ports detected
[   48.538654] ehci-pci 0000:e0:1d.0: EHCI Host Controller
[   48.539218] ehci-pci 0000:e0:1d.0: new USB bus registered, assigned bus number 8
[   48.539239] ehci-pci 0000:e0:1d.0: debug port 2
[   48.543163] ehci-pci 0000:e0:1d.0: cache line size of 64 is not supported
[   48.543240] ehci-pci 0000:e0:1d.0: irq 527, io mem 0xc8600000
[   48.548826] ehci-pci 0000:e0:1d.0: USB 2.0 started, EHCI 1.00
[   48.548935] usb usb8: New USB device found, idVendor=1d6b, idProduct=0002
[   48.548937] usb usb8: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   48.548939] usb usb8: Product: EHCI Host Controller
[   48.548940] usb usb8: Manufacturer: Linux 3.10.0-123.el7.x86_64 ehci_hcd
[   48.548941] usb usb8: SerialNumber: 0000:e0:1d.0
[   48.549293] hub 8-0:1.0: USB hub found
[   48.549304] hub 8-0:1.0: 2 ports detected
[   48.549810] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   48.549812] ohci-pci: OHCI PCI platform driver
[   48.549981] uhci_hcd: USB Universal Host Controller Interface driver
[   48.550061] uhci_hcd 0000:07:00.4: UHCI Host Controller
[   48.550322] uhci_hcd 0000:07:00.4: new USB bus registered, assigned bus number 9
[   48.550348] uhci_hcd 0000:07:00.4: port count misdetected? forcing to 2 ports
[   48.550409] uhci_hcd 0000:07:00.4: irq 16, io base 0x00001500
[   48.550472] usb usb9: New USB device found, idVendor=1d6b, idProduct=0001
[   48.550473] usb usb9: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   48.550474] usb usb9: Product: UHCI Host Controller
[   48.550475] usb usb9: Manufacturer: Linux 3.10.0-123.el7.x86_64 uhci_hcd
[   48.550476] usb usb9: SerialNumber: 0000:07:00.4
[   48.550774] hub 9-0:1.0: USB hub found
[   48.550779] hub 9-0:1.0: 2 ports detected
[   48.552139] usbcore: registered new interface driver usbserial
[   48.552148] usbcore: registered new interface driver usbserial_generic
[   48.552155] usbserial: USB Serial support registered for generic
[   48.552186] i8042: PNP: No PS/2 controller found. Probing ports directly.
[   49.085163] usb 1-1: New USB device found, idVendor=8087, idProduct=0024
[   49.092704] usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   49.101321] hub 1-1:1.0: USB hub found
[   49.105825] hub 1-1:1.0: 8 ports detected
[   49.214657] usb 2-1: new high-speed USB device number 2 using ehci-pci
[   49.337481] usb 2-1: New USB device found, idVendor=8087, idProduct=0024
[   49.345028] usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   49.353648] hub 2-1:1.0: USB hub found
[   49.358153] hub 2-1:1.0: 8 ports detected
[   49.467975] usb 3-1: new high-speed USB device number 2 using ehci-pci
[   49.580065] i8042: No controller found
[   49.584626] mousedev: PS/2 mouse device common for all mice
[   49.589824] usb 3-1: New USB device found, idVendor=8087, idProduct=0024
[   49.589826] usb 3-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   49.590304] hub 3-1:1.0: USB hub found
[   49.590478] hub 3-1:1.0: 8 ports detected
[   49.616069] rtc_cmos 00:02: RTC can wake from S4
[   49.621627] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
[   49.628538] rtc_cmos 00:02: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
[   49.637146] Intel P-state driver initializing.
[   49.642324] Intel pstate controlling: cpu 0
[   49.647234] Intel pstate controlling: cpu 1
[   49.652163] Intel pstate controlling: cpu 2
[   49.657097] Intel pstate controlling: cpu 3
[   49.662022] Intel pstate controlling: cpu 4
[   49.666966] Intel pstate controlling: cpu 5
[   49.671895] Intel pstate controlling: cpu 6
[   49.676828] Intel pstate controlling: cpu 7
[   49.681758] Intel pstate controlling: cpu 8
[   49.686702] Intel pstate controlling: cpu 9
[   49.691624] Intel pstate controlling: cpu 10
[   49.696261] usb 4-1: new high-speed USB device number 2 using ehci-pci
[   49.703979] Intel pstate controlling: cpu 11
[   49.709005] Intel pstate controlling: cpu 12
[   49.714027] Intel pstate controlling: cpu 13
[   49.719067] Intel pstate controlling: cpu 14
[   49.724127] Intel pstate controlling: cpu 15
[   49.729190] Intel pstate controlling: cpu 16
[   49.734226] Intel pstate controlling: cpu 17
[   49.739266] Intel pstate controlling: cpu 18
[   49.744316] Intel pstate controlling: cpu 19
[   49.749352] Intel pstate controlling: cpu 20
[   49.754388] Intel pstate controlling: cpu 21
[   49.759434] Intel pstate controlling: cpu 22
[   49.764483] Intel pstate controlling: cpu 23
[   49.769518] Intel pstate controlling: cpu 24
[   49.774573] Intel pstate controlling: cpu 25
[   49.779531] Intel pstate controlling: cpu 26
[   49.784573] Intel pstate controlling: cpu 27
[   49.789606] Intel pstate controlling: cpu 28
[   49.794639] Intel pstate controlling: cpu 29
[   49.799671] Intel pstate controlling: cpu 30
[   49.804702] Intel pstate controlling: cpu 31
[   49.809727] Intel pstate controlling: cpu 32
[   49.811097] usb 4-1: New USB device found, idVendor=8087, idProduct=0024
[   49.811099] usb 4-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   49.811594] hub 4-1:1.0: USB hub found
[   49.811802] hub 4-1:1.0: 8 ports detected
[   49.839159] Intel pstate controlling: cpu 33
[   49.844185] Intel pstate controlling: cpu 34
[   49.849208] Intel pstate controlling: cpu 35
[   49.854235] Intel pstate controlling: cpu 36
[   49.859257] Intel pstate controlling: cpu 37
[   49.864280] Intel pstate controlling: cpu 38
[   49.869291] Intel pstate controlling: cpu 39
[   49.874324] Intel pstate controlling: cpu 40
[   49.879357] Intel pstate controlling: cpu 41
[   49.884397] Intel pstate controlling: cpu 42
[   49.889431] Intel pstate controlling: cpu 43
[   49.894476] Intel pstate controlling: cpu 44
[   49.899521] Intel pstate controlling: cpu 45
[   49.904557] Intel pstate controlling: cpu 46
[   49.909612] Intel pstate controlling: cpu 47
[   49.914635] Intel pstate controlling: cpu 48
[   49.915537] usb 5-1: new high-speed USB device number 2 using ehci-pci
[   49.927011] Intel pstate controlling: cpu 49
[   49.932052] Intel pstate controlling: cpu 50
[   49.937085] Intel pstate controlling: cpu 51
[   49.942116] Intel pstate controlling: cpu 52
[   49.947151] Intel pstate controlling: cpu 53
[   49.952194] Intel pstate controlling: cpu 54
[   49.957228] Intel pstate controlling: cpu 55
[   49.962246] Intel pstate controlling: cpu 56
[   49.967274] Intel pstate controlling: cpu 57
[   49.972332] Intel pstate controlling: cpu 58
[   49.977372] Intel pstate controlling: cpu 59
[   49.982406] Intel pstate controlling: cpu 60
[   49.987460] Intel pstate controlling: cpu 61
[   49.992493] Intel pstate controlling: cpu 62
[   49.997571] Intel pstate controlling: cpu 63
[   50.002681] Intel pstate controlling: cpu 64
[   50.007709] Intel pstate controlling: cpu 65
[   50.012746] Intel pstate controlling: cpu 66
[   50.017737] Intel pstate controlling: cpu 67
[   50.022748] Intel pstate controlling: cpu 68
[   50.027785] Intel pstate controlling: cpu 69
[   50.032812] Intel pstate controlling: cpu 70
[   50.033255] usb 5-1: New USB device found, idVendor=8087, idProduct=0024
[   50.033256] usb 5-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   50.033757] hub 5-1:1.0: USB hub found
[   50.033955] hub 5-1:1.0: 8 ports detected
[   50.062240] Intel pstate controlling: cpu 71
[   50.067287] Intel pstate controlling: cpu 72
[   50.072322] Intel pstate controlling: cpu 73
[   50.077355] Intel pstate controlling: cpu 74
[   50.082377] Intel pstate controlling: cpu 75
[   50.087413] Intel pstate controlling: cpu 76
[   50.092451] Intel pstate controlling: cpu 77
[   50.097489] Intel pstate controlling: cpu 78
[   50.102550] Intel pstate controlling: cpu 79
[   50.107597] Intel pstate controlling: cpu 80
[   50.112646] Intel pstate controlling: cpu 81
[   50.117680] Intel pstate controlling: cpu 82
[   50.122733] Intel pstate controlling: cpu 83
[   50.127768] Intel pstate controlling: cpu 84
[   50.132818] Intel pstate controlling: cpu 85
[   50.137812] usb 6-1: new high-speed USB device number 2 using ehci-pci
[   50.137855] Intel pstate controlling: cpu 86
[   50.138006] Intel pstate controlling: cpu 87
[   50.138157] Intel pstate controlling: cpu 88
[   50.138335] Intel pstate controlling: cpu 89
[   50.138482] Intel pstate controlling: cpu 90
[   50.138636] Intel pstate controlling: cpu 91
[   50.138782] Intel pstate controlling: cpu 92
[   50.138917] Intel pstate controlling: cpu 93
[   50.139021] Intel pstate controlling: cpu 94
[   50.139196] Intel pstate controlling: cpu 95
[   50.139321] Intel pstate controlling: cpu 96
[   50.139450] Intel pstate controlling: cpu 97
[   50.139568] Intel pstate controlling: cpu 98
[   50.139725] Intel pstate controlling: cpu 99
[   50.139919] Intel pstate controlling: cpu 100
[   50.140040] Intel pstate controlling: cpu 101
[   50.140167] Intel pstate controlling: cpu 102
[   50.140306] Intel pstate controlling: cpu 103
[   50.140462] Intel pstate controlling: cpu 104
[   50.140624] Intel pstate controlling: cpu 105
[   50.140809] Intel pstate controlling: cpu 106
[   50.140920] Intel pstate controlling: cpu 107
[   50.141087] Intel pstate controlling: cpu 108
[   50.141262] Intel pstate controlling: cpu 109
[   50.141419] Intel pstate controlling: cpu 110
[   50.141617] Intel pstate controlling: cpu 111
[   50.141779] Intel pstate controlling: cpu 112
[   50.141928] Intel pstate controlling: cpu 113
[   50.142065] Intel pstate controlling: cpu 114
[   50.142194] Intel pstate controlling: cpu 115
[   50.142295] Intel pstate controlling: cpu 116
[   50.142442] Intel pstate controlling: cpu 117
[   50.142602] Intel pstate controlling: cpu 118
[   50.142756] Intel pstate controlling: cpu 119
[   50.142919] Intel pstate controlling: cpu 120
[   50.143052] Intel pstate controlling: cpu 121
[   50.143169] Intel pstate controlling: cpu 122
[   50.143296] Intel pstate controlling: cpu 123
[   50.143455] Intel pstate controlling: cpu 124
[   50.143588] Intel pstate controlling: cpu 125
[   50.143736] Intel pstate controlling: cpu 126
[   50.143917] Intel pstate controlling: cpu 127
[   50.144143] Intel pstate controlling: cpu 128
[   50.144312] Intel pstate controlling: cpu 129
[   50.144471] Intel pstate controlling: cpu 130
[   50.144629] Intel pstate controlling: cpu 131
[   50.144784] Intel pstate controlling: cpu 132
[   50.144951] Intel pstate controlling: cpu 133
[   50.145126] Intel pstate controlling: cpu 134
[   50.145303] Intel pstate controlling: cpu 135
[   50.145478] Intel pstate controlling: cpu 136
[   50.145640] Intel pstate controlling: cpu 137
[   50.145819] Intel pstate controlling: cpu 138
[   50.145991] Intel pstate controlling: cpu 139
[   50.146115] Intel pstate controlling: cpu 140
[   50.146252] Intel pstate controlling: cpu 141
[   50.146412] Intel pstate controlling: cpu 142
[   50.146591] Intel pstate controlling: cpu 143
[   50.146757] Intel pstate controlling: cpu 144
[   50.146945] Intel pstate controlling: cpu 145
[   50.147073] Intel pstate controlling: cpu 146
[   50.147197] Intel pstate controlling: cpu 147
[   50.147346] Intel pstate controlling: cpu 148
[   50.147496] Intel pstate controlling: cpu 149
[   50.147668] Intel pstate controlling: cpu 150
[   50.147882] Intel pstate controlling: cpu 151
[   50.148031] Intel pstate controlling: cpu 152
[   50.148192] Intel pstate controlling: cpu 153
[   50.148351] Intel pstate controlling: cpu 154
[   50.148506] Intel pstate controlling: cpu 155
[   50.148693] Intel pstate controlling: cpu 156
[   50.148873] Intel pstate controlling: cpu 157
[   50.149016] Intel pstate controlling: cpu 158
[   50.149177] Intel pstate controlling: cpu 159
[   50.149307] Intel pstate controlling: cpu 160
[   50.149457] Intel pstate controlling: cpu 161
[   50.149632] Intel pstate controlling: cpu 162
[   50.149790] Intel pstate controlling: cpu 163
[   50.149946] Intel pstate controlling: cpu 164
[   50.150059] Intel pstate controlling: cpu 165
[   50.150189] Intel pstate controlling: cpu 166
[   50.150312] Intel pstate controlling: cpu 167
[   50.150440] Intel pstate controlling: cpu 168
[   50.150559] Intel pstate controlling: cpu 169
[   50.150710] Intel pstate controlling: cpu 170
[   50.150886] Intel pstate controlling: cpu 171
[   50.151039] Intel pstate controlling: cpu 172
[   50.151200] Intel pstate controlling: cpu 173
[   50.151321] Intel pstate controlling: cpu 174
[   50.151503] Intel pstate controlling: cpu 175
[   50.151662] Intel pstate controlling: cpu 176
[   50.151835] Intel pstate controlling: cpu 177
[   50.151994] Intel pstate controlling: cpu 178
[   50.152165] Intel pstate controlling: cpu 179
[   50.152318] Intel pstate controlling: cpu 180
[   50.152493] Intel pstate controlling: cpu 181
[   50.152650] Intel pstate controlling: cpu 182
[   50.152826] Intel pstate controlling: cpu 183
[   50.153000] Intel pstate controlling: cpu 184
[   50.153129] Intel pstate controlling: cpu 185
[   50.153278] Intel pstate controlling: cpu 186
[   50.153418] Intel pstate controlling: cpu 187
[   50.153576] Intel pstate controlling: cpu 188
[   50.153738] Intel pstate controlling: cpu 189
[   50.153945] Intel pstate controlling: cpu 190
[   50.154079] Intel pstate controlling: cpu 191
[   50.154256] Intel pstate controlling: cpu 192
[   50.154432] Intel pstate controlling: cpu 193
[   50.154622] Intel pstate controlling: cpu 194
[   50.154788] Intel pstate controlling: cpu 195
[   50.154965] Intel pstate controlling: cpu 196
[   50.155089] Intel pstate controlling: cpu 197
[   50.155213] Intel pstate controlling: cpu 198
[   50.155374] Intel pstate controlling: cpu 199
[   50.155529] Intel pstate controlling: cpu 200
[   50.155723] Intel pstate controlling: cpu 201
[   50.155882] Intel pstate controlling: cpu 202
[   50.156031] Intel pstate controlling: cpu 203
[   50.156164] Intel pstate controlling: cpu 204
[   50.156294] Intel pstate controlling: cpu 205
[   50.156439] Intel pstate controlling: cpu 206
[   50.156639] Intel pstate controlling: cpu 207
[   50.156800] Intel pstate controlling: cpu 208
[   50.156965] Intel pstate controlling: cpu 209
[   50.157078] Intel pstate controlling: cpu 210
[   50.157239] Intel pstate controlling: cpu 211
[   50.157396] Intel pstate controlling: cpu 212
[   50.157523] Intel pstate controlling: cpu 213
[   50.157688] Intel pstate controlling: cpu 214
[   50.157859] Intel pstate controlling: cpu 215
[   50.158016] Intel pstate controlling: cpu 216
[   50.158188] Intel pstate controlling: cpu 217
[   50.158361] Intel pstate controlling: cpu 218
[   50.158512] Intel pstate controlling: cpu 219
[   50.158666] Intel pstate controlling: cpu 220
[   50.158833] Intel pstate controlling: cpu 221
[   50.158979] Intel pstate controlling: cpu 222
[   50.159168] Intel pstate controlling: cpu 223
[   50.159334] Intel pstate controlling: cpu 224
[   50.159505] Intel pstate controlling: cpu 225
[   50.159669] Intel pstate controlling: cpu 226
[   50.159848] Intel pstate controlling: cpu 227
[   50.159995] Intel pstate controlling: cpu 228
[   50.160176] Intel pstate controlling: cpu 229
[   50.160299] Intel pstate controlling: cpu 230
[   50.160457] Intel pstate controlling: cpu 231
[   50.160627] Intel pstate controlling: cpu 232
[   50.160793] Intel pstate controlling: cpu 233
[   50.160962] Intel pstate controlling: cpu 234
[   50.161123] Intel pstate controlling: cpu 235
[   50.161290] Intel pstate controlling: cpu 236
[   50.161448] Intel pstate controlling: cpu 237
[   50.161619] Intel pstate controlling: cpu 238
[   50.161798] Intel pstate controlling: cpu 239
[   50.161985] Intel pstate controlling: cpu 240
[   50.162117] Intel pstate controlling: cpu 241
[   50.162274] Intel pstate controlling: cpu 242
[   50.162433] Intel pstate controlling: cpu 243
[   50.162597] Intel pstate controlling: cpu 244
[   50.162755] Intel pstate controlling: cpu 245
[   50.162942] Intel pstate controlling: cpu 246
[   50.163089] Intel pstate controlling: cpu 247
[   50.163242] Intel pstate controlling: cpu 248
[   50.163400] Intel pstate controlling: cpu 249
[   50.163558] Intel pstate controlling: cpu 250
[   50.163722] Intel pstate controlling: cpu 251
[   50.163899] Intel pstate controlling: cpu 252
[   50.164053] Intel pstate controlling: cpu 253
[   50.164198] Intel pstate controlling: cpu 254
[   50.164370] Intel pstate controlling: cpu 255
[   50.164588] Intel pstate controlling: cpu 256
[   50.164760] Intel pstate controlling: cpu 257
[   50.164930] Intel pstate controlling: cpu 258
[   50.165086] Intel pstate controlling: cpu 259
[   50.165241] Intel pstate controlling: cpu 260
[   50.165404] Intel pstate controlling: cpu 261
[   50.165567] Intel pstate controlling: cpu 262
[   50.165742] Intel pstate controlling: cpu 263
[   50.165907] Intel pstate controlling: cpu 264
[   50.166065] Intel pstate controlling: cpu 265
[   50.166220] Intel pstate controlling: cpu 266
[   50.166387] Intel pstate controlling: cpu 267
[   50.166549] Intel pstate controlling: cpu 268
[   50.166713] Intel pstate controlling: cpu 269
[   50.166878] Intel pstate controlling: cpu 270
[   50.167037] Intel pstate controlling: cpu 271
[   50.167188] Intel pstate controlling: cpu 272
[   50.167342] Intel pstate controlling: cpu 273
[   50.167504] Intel pstate controlling: cpu 274
[   50.167664] Intel pstate controlling: cpu 275
[   50.167826] Intel pstate controlling: cpu 276
[   50.167978] Intel pstate controlling: cpu 277
[   50.168129] Intel pstate controlling: cpu 278
[   50.168275] Intel pstate controlling: cpu 279
[   50.168437] Intel pstate controlling: cpu 280
[   50.168585] Intel pstate controlling: cpu 281
[   50.168748] Intel pstate controlling: cpu 282
[   50.168922] Intel pstate controlling: cpu 283
[   50.169074] Intel pstate controlling: cpu 284
[   50.169250] Intel pstate controlling: cpu 285
[   50.169411] Intel pstate controlling: cpu 286
[   50.169593] Intel pstate controlling: cpu 287
[   50.169750] Intel pstate controlling: cpu 288
[   50.169924] Intel pstate controlling: cpu 289
[   50.170060] Intel pstate controlling: cpu 290
[   50.170225] Intel pstate controlling: cpu 291
[   50.170396] Intel pstate controlling: cpu 292
[   50.170555] Intel pstate controlling: cpu 293
[   50.170727] Intel pstate controlling: cpu 294
[   50.170906] Intel pstate controlling: cpu 295
[   50.171052] Intel pstate controlling: cpu 296
[   50.171230] Intel pstate controlling: cpu 297
[   50.171379] Intel pstate controlling: cpu 298
[   50.171536] Intel pstate controlling: cpu 299
[   50.171697] Intel pstate controlling: cpu 300
[   50.171873] Intel pstate controlling: cpu 301
[   50.172048] Intel pstate controlling: cpu 302
[   50.172190] Intel pstate controlling: cpu 303
[   50.172357] Intel pstate controlling: cpu 304
[   50.172526] Intel pstate controlling: cpu 305
[   50.172695] Intel pstate controlling: cpu 306
[   50.172861] Intel pstate controlling: cpu 307
[   50.173035] Intel pstate controlling: cpu 308
[   50.173177] Intel pstate controlling: cpu 309
[   50.173357] Intel pstate controlling: cpu 310
[   50.173535] Intel pstate controlling: cpu 311
[   50.173679] Intel pstate controlling: cpu 312
[   50.173866] Intel pstate controlling: cpu 313
[   50.174040] Intel pstate controlling: cpu 314
[   50.174174] Intel pstate controlling: cpu 315
[   50.174325] Intel pstate controlling: cpu 316
[   50.174455] Intel pstate controlling: cpu 317
[   50.174637] Intel pstate controlling: cpu 318
[   50.174856] Intel pstate controlling: cpu 319
[   50.175100] Intel pstate controlling: cpu 320
[   50.175258] Intel pstate controlling: cpu 321
[   50.175428] Intel pstate controlling: cpu 322
[   50.175597] Intel pstate controlling: cpu 323
[   50.175765] Intel pstate controlling: cpu 324
[   50.175955] Intel pstate controlling: cpu 325
[   50.176102] Intel pstate controlling: cpu 326
[   50.176245] Intel pstate controlling: cpu 327
[   50.176412] Intel pstate controlling: cpu 328
[   50.176574] Intel pstate controlling: cpu 329
[   50.176755] Intel pstate controlling: cpu 330
[   50.176929] Intel pstate controlling: cpu 331
[   50.177089] Intel pstate controlling: cpu 332
[   50.177252] Intel pstate controlling: cpu 333
[   50.177425] Intel pstate controlling: cpu 334
[   50.177611] Intel pstate controlling: cpu 335
[   50.177788] Intel pstate controlling: cpu 336
[   50.177969] Intel pstate controlling: cpu 337
[   50.178135] Intel pstate controlling: cpu 338
[   50.178278] Intel pstate controlling: cpu 339
[   50.178440] Intel pstate controlling: cpu 340
[   50.178604] Intel pstate controlling: cpu 341
[   50.178804] Intel pstate controlling: cpu 342
[   50.178997] Intel pstate controlling: cpu 343
[   50.179166] Intel pstate controlling: cpu 344
[   50.179321] Intel pstate controlling: cpu 345
[   50.179478] Intel pstate controlling: cpu 346
[   50.179670] Intel pstate controlling: cpu 347
[   50.179846] Intel pstate controlling: cpu 348
[   50.179992] Intel pstate controlling: cpu 349
[   50.180154] Intel pstate controlling: cpu 350
[   50.180340] Intel pstate controlling: cpu 351
[   50.180509] Intel pstate controlling: cpu 352
[   50.180690] Intel pstate controlling: cpu 353
[   50.180880] Intel pstate controlling: cpu 354
[   50.181045] Intel pstate controlling: cpu 355
[   50.181209] Intel pstate controlling: cpu 356
[   50.181389] Intel pstate controlling: cpu 357
[   50.181572] Intel pstate controlling: cpu 358
[   50.181746] Intel pstate controlling: cpu 359
[   50.181934] Intel pstate controlling: cpu 360
[   50.182071] Intel pstate controlling: cpu 361
[   50.182218] Intel pstate controlling: cpu 362
[   50.182385] Intel pstate controlling: cpu 363
[   50.182608] Intel pstate controlling: cpu 364
[   50.182790] Intel pstate controlling: cpu 365
[   50.182958] Intel pstate controlling: cpu 366
[   50.183117] Intel pstate controlling: cpu 367
[   50.183271] Intel pstate controlling: cpu 368
[   50.183437] Intel pstate controlling: cpu 369
[   50.183611] Intel pstate controlling: cpu 370
[   50.183774] Intel pstate controlling: cpu 371
[   50.183957] Intel pstate controlling: cpu 372
[   50.184119] Intel pstate controlling: cpu 373
[   50.184279] Intel pstate controlling: cpu 374
[   50.184461] Intel pstate controlling: cpu 375
[   50.184637] Intel pstate controlling: cpu 376
[   50.184813] Intel pstate controlling: cpu 377
[   50.185005] Intel pstate controlling: cpu 378
[   50.185158] Intel pstate controlling: cpu 379
[   50.185319] Intel pstate controlling: cpu 380
[   50.185499] Intel pstate controlling: cpu 381
[   50.185682] Intel pstate controlling: cpu 382
[   50.185886] Intel pstate controlling: cpu 383
[   50.186085] Intel pstate controlling: cpu 384
[   50.186266] Intel pstate controlling: cpu 385
[   50.186441] Intel pstate controlling: cpu 386
[   50.186602] Intel pstate controlling: cpu 387
[   50.186770] Intel pstate controlling: cpu 388
[   50.186958] Intel pstate controlling: cpu 389
[   50.187130] Intel pstate controlling: cpu 390
[   50.187307] Intel pstate controlling: cpu 391
[   50.187489] Intel pstate controlling: cpu 392
[   50.187650] Intel pstate controlling: cpu 393
[   50.187810] Intel pstate controlling: cpu 394
[   50.187979] Intel pstate controlling: cpu 395
[   50.188131] Intel pstate controlling: cpu 396
[   50.188280] Intel pstate controlling: cpu 397
[   50.188463] Intel pstate controlling: cpu 398
[   50.188660] Intel pstate controlling: cpu 399
[   50.188819] Intel pstate controlling: cpu 400
[   50.189005] Intel pstate controlling: cpu 401
[   50.189165] Intel pstate controlling: cpu 402
[   50.189344] Intel pstate controlling: cpu 403
[   50.189507] Intel pstate controlling: cpu 404
[   50.189665] Intel pstate controlling: cpu 405
[   50.189835] Intel pstate controlling: cpu 406
[   50.189998] Intel pstate controlling: cpu 407
[   50.190142] Intel pstate controlling: cpu 408
[   50.190334] Intel pstate controlling: cpu 409
[   50.190496] Intel pstate controlling: cpu 410
[   50.190651] Intel pstate controlling: cpu 411
[   50.190814] Intel pstate controlling: cpu 412
[   50.191004] Intel pstate controlling: cpu 413
[   50.191158] Intel pstate controlling: cpu 414
[   50.191362] Intel pstate controlling: cpu 415
[   50.191516] Intel pstate controlling: cpu 416
[   50.191703] Intel pstate controlling: cpu 417
[   50.191878] Intel pstate controlling: cpu 418
[   50.192043] Intel pstate controlling: cpu 419
[   50.192230] Intel pstate controlling: cpu 420
[   50.192396] Intel pstate controlling: cpu 421
[   50.192573] Intel pstate controlling: cpu 422
[   50.192759] Intel pstate controlling: cpu 423
[   50.192951] Intel pstate controlling: cpu 424
[   50.193120] Intel pstate controlling: cpu 425
[   50.193308] Intel pstate controlling: cpu 426
[   50.193472] Intel pstate controlling: cpu 427
[   50.193640] Intel pstate controlling: cpu 428
[   50.193831] Intel pstate controlling: cpu 429
[   50.194009] Intel pstate controlling: cpu 430
[   50.194217] Intel pstate controlling: cpu 431
[   50.194368] Intel pstate controlling: cpu 432
[   50.194529] Intel pstate controlling: cpu 433
[   50.194706] Intel pstate controlling: cpu 434
[   50.194878] Intel pstate controlling: cpu 435
[   50.195045] Intel pstate controlling: cpu 436
[   50.195212] Intel pstate controlling: cpu 437
[   50.195382] Intel pstate controlling: cpu 438
[   50.195551] Intel pstate controlling: cpu 439
[   50.195719] Intel pstate controlling: cpu 440
[   50.195901] Intel pstate controlling: cpu 441
[   50.196066] Intel pstate controlling: cpu 442
[   50.196282] Intel pstate controlling: cpu 443
[   50.196444] Intel pstate controlling: cpu 444
[   50.196632] Intel pstate controlling: cpu 445
[   50.196811] Intel pstate controlling: cpu 446
[   50.196994] Intel pstate controlling: cpu 447
[   50.197231] Intel pstate controlling: cpu 448
[   50.197407] Intel pstate controlling: cpu 449
[   50.197583] Intel pstate controlling: cpu 450
[   50.197741] Intel pstate controlling: cpu 451
[   50.197909] Intel pstate controlling: cpu 452
[   50.198089] Intel pstate controlling: cpu 453
[   50.198277] Intel pstate controlling: cpu 454
[   50.198438] Intel pstate controlling: cpu 455
[   50.198607] Intel pstate controlling: cpu 456
[   50.198781] Intel pstate controlling: cpu 457
[   50.198957] Intel pstate controlling: cpu 458
[   50.199127] Intel pstate controlling: cpu 459
[   50.199283] Intel pstate controlling: cpu 460
[   50.199446] Intel pstate controlling: cpu 461
[   50.199621] Intel pstate controlling: cpu 462
[   50.199811] Intel pstate controlling: cpu 463
[   50.199997] Intel pstate controlling: cpu 464
[   50.200202] Intel pstate controlling: cpu 465
[   50.200368] Intel pstate controlling: cpu 466
[   50.200533] Intel pstate controlling: cpu 467
[   50.200699] Intel pstate controlling: cpu 468
[   50.200871] Intel pstate controlling: cpu 469
[   50.201055] Intel pstate controlling: cpu 470
[   50.201250] Intel pstate controlling: cpu 471
[   50.201407] Intel pstate controlling: cpu 472
[   50.201572] Intel pstate controlling: cpu 473
[   50.201757] Intel pstate controlling: cpu 474
[   50.201932] Intel pstate controlling: cpu 475
[   50.202100] Intel pstate controlling: cpu 476
[   50.202261] Intel pstate controlling: cpu 477
[   50.202434] Intel pstate controlling: cpu 478
[   50.202619] Intel pstate controlling: cpu 479
[   50.215516] cpuidle: using governor menu
[   50.240316] EFI Variables Facility v0.08 2004-May-17
[   50.291698] hidraw: raw HID events driver (C) Jiri Kosina
[   50.291829] usbcore: registered new interface driver usbhid
[   50.291831] usbhid: USB HID core driver
[   50.295502] drop_monitor: Initializing network drop monitor service
[   50.297626] TCP: cubic registered
[   50.297629] Initializing XFRM netlink socket
[   50.298357] NET: Registered protocol family 10
[   50.301613] NET: Registered protocol family 17
[   50.320737] Loading compiled-in X.509 certificates
[   50.321251] Loaded X.509 cert 'Red Hat Enterprise Linux Driver Update Program (key 3): bf57f3e87362bc7229d9f465321773dfd1f77a80'
[   50.321696] Loaded X.509 cert 'Red Hat Enterprise Linux kpatch signing key: 4d38fd864ebe18c5f0b72e3852e2014c3a676fc8'
[   50.322148] Loaded X.509 cert 'Red Hat Enterprise Linux kernel signing key: 00aa5f56c587bd82f2f99d64ba83dd1e9e0d334a'
[   50.322181] registered taskstats version 1
[   50.325395] Key type trusted registered
[   50.329998] Key type encrypted registered
[   50.333404] IMA: No TPM chip found, activating TPM-bypass!
[   52.247616] rtc_cmos 00:02: setting system clock to 2015-03-25 07:31:33 UTC (1427268693)
[   52.260916] Freeing unused kernel memory: 1584k freed
[   52.386385] usb 6-1: New USB device found, idVendor=8087, idProduct=0024
[   52.393925] usb 6-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   52.394301] hub 6-1:1.0: USB hub found
[   52.394391] hub 6-1:1.0: 8 ports detected
[   52.418081] systemd[1]: systemd 208 running in system mode. (+PAM +LIBWRAP +AUDIT +SELINUX +IMA +SYSVINIT +LIBCRYPTSETUP +GCRYPT +ACL +XZ)
[   52.439458] systemd[1]: Running in initial RAM disk.
[   52.456463] systemd[1]: Set hostname to <hawk041os1.fchst.usa.hp.com>.
[   52.497831] usb 7-1: new high-speed USB device number 2 using ehci-pci
[   52.545352] systemd[1]: Expecting device dev-disk-by\x2duuid-ba143790\x2dbec5\x2d4ef3\x2db1b0\x2d908708426def.device...
[   52.566942] systemd[1]: Starting -.slice.
[   52.576960] systemd[1]: Created slice -.slice.
[   52.582094] systemd[1]: Starting System Slice.
[   52.591962] systemd[1]: Created slice System Slice.
[   52.597579] systemd[1]: Starting Slices.
[   52.606987] systemd[1]: Reached target Slices.
[   52.612080] systemd[1]: Starting Timers.
[   52.619742] usb 7-1: New USB device found, idVendor=8087, idProduct=0024
[   52.628077] usb 7-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   52.628129] systemd[1]: Reached target Timers.
[   52.628194] systemd[1]: Starting Journal Socket.
[   52.647171] hub 7-1:1.0: USB hub found
[   52.652531] hub 7-1:1.0: 8 ports detected
[   52.660079] systemd[1]: Listening on Journal Socket.
[   52.666023] systemd[1]: Starting dracut cmdline hook...
[   52.678014] systemd[1]: Started Load Kernel Modules.
[   52.683652] systemd[1]: Starting Setup Virtual Console...
[   52.695730] systemd[1]: Starting Journal Service...
[   52.714348] systemd[1]: Started Journal Service.
[   52.762163] usb 8-1: new high-speed USB device number 2 using ehci-pci
[   52.764334] systemd-journald[3645]: Vacuuming done, freed 0 bytes
[   52.826527] device-mapper: uevent: version 1.0.3
[   52.831912] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialised: dm-devel@redhat.com
[   52.858373] device-mapper: multipath: version 1.6.0 loaded
[   52.891321] usb 8-1: New USB device found, idVendor=8087, idProduct=0024
[   52.900216] usb 8-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   52.910630] hub 8-1:1.0: USB hub found
[   52.915807] hub 8-1:1.0: 8 ports detected
[   52.997724] usb 1-1.3: new high-speed USB device number 3 using ehci-pci
[   53.032859] systemd-udevd[4099]: starting version 208
[   53.091141] usb 1-1.3: New USB device found, idVendor=0424, idProduct=2660
[   53.098872] usb 1-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   53.112670] hub 1-1.3:1.0: USB hub found
[   53.117417] hub 1-1.3:1.0: 2 ports detected
[   53.195902] usb 2-1.3: new high-speed USB device number 3 using ehci-pci
[   53.279016] usb 2-1.3: device descriptor read/64, error -71
[   53.472252] usb 2-1.3: device descriptor read/64, error -71
[   53.652474] usb 2-1.3: new high-speed USB device number 4 using ehci-pci
[   53.735631] usb 2-1.3: device descriptor read/64, error -71
[   53.917805] usb 2-1.3: device descriptor read/64, error -71
[   54.098036] usb 2-1.3: new high-speed USB device number 5 using ehci-pci
[   54.515331] usb 2-1.3: device not accepting address 5, error -71
[   54.595645] usb 2-1.3: new high-speed USB device number 6 using ehci-pci
[   55.012964] usb 2-1.3: device not accepting address 6, error -71
[   55.019977] hub 2-1:1.0: unable to enumerate USB device on port 3
[   55.100280] usb 3-1.3: new high-speed USB device number 3 using ehci-pci
[   55.193788] usb 3-1.3: New USB device found, idVendor=0424, idProduct=2660
[   55.201444] usb 3-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   55.215689] hub 3-1.3:1.0: USB hub found
[   55.220585] hub 3-1.3:1.0: 2 ports detected
[   55.302484] usb 4-1.3: new high-speed USB device number 3 using ehci-pci
[   55.395903] usb 4-1.3: New USB device found, idVendor=0424, idProduct=2660
[   55.403594] usb 4-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   55.419507] hub 4-1.3:1.0: USB hub found
[   55.424274] hub 4-1.3:1.0: 2 ports detected
[   55.503849] usb 5-1.3: new high-speed USB device number 3 using ehci-pci
[   55.530924] [drm] Initialized drm 1.1.0 20060810
[   55.568693] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.06.00.08.07.0-k2.
[   55.579526] qla2xxx [0000:13:00.0]-011c: : MSI-X vector count: 31.
[   55.586417] qla2xxx [0000:13:00.0]-001d: : Found an ISP2031 irq 64 iobase 0xffffc9001031a000.
[   55.597797] qla2xxx 0000:13:00.0: irq 672 for MSI/MSI-X
[   55.597847] qla2xxx 0000:13:00.0: irq 673 for MSI/MSI-X
[   55.597852] usb 5-1.3: New USB device found, idVendor=0424, idProduct=2660
[   55.605544] usb 5-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   55.615370] hub 5-1.3:1.0: USB hub found
[   55.619979] hub 5-1.3:1.0: 2 ports detected
[   55.627818] checking generic (92000000 300000) vs hw (92000000 1000000)
[   55.627823] fb: conflicting fb hw usage mgag200drmfb vs EFI VGA - removing generic driver
[   55.636964] Console: switching to colour dummy device 80x25
[   55.661656] [TTM] Zone  kernel: Available graphics memory: 6341392578 kiB
[   55.669208] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
[   55.676492] [TTM] Initializing pool allocator
[   55.681424] [TTM] Initializing DMA pool allocator
[   55.698960] usb 6-1.3: new high-speed USB device number 3 using ehci-pci
[   55.718618] fbcon: mgadrmfb (fb0) is primary device
[   55.791026] [drm] mga base 0
[   55.792294] usb 6-1.3: New USB device found, idVendor=0424, idProduct=2660
[   55.792296] usb 6-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   55.793031] hub 6-1.3:1.0: USB hub found
[   55.793174] hub 6-1.3:1.0: 2 ports detected
[   55.840936] Console: switching to colour frame buffer device 128x48
[   55.870151] usb 7-1.3: new high-speed USB device number 3 using ehci-pci
[   55.921083] mgag200 0000:07:00.1: fb0: mgadrmfb frame buffer device
[   55.928087] mgag200 0000:07:00.1: registered panic notifier
[   55.934343] [drm] Initialized mgag200 1.0.0 20110418 for 0000:07:00.1 on minor 0
[   55.955685] usb 7-1.3: New USB device found, idVendor=0424, idProduct=2660
[   55.963331] usb 7-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   55.973202] hub 7-1.3:1.0: USB hub found
[   55.977782] hub 7-1.3:1.0: 2 ports detected
[   56.056445] usb 8-1.3: new high-speed USB device number 3 using ehci-pci
[   56.149977] usb 8-1.3: New USB device found, idVendor=0424, idProduct=2660
[   56.157651] usb 8-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   56.166967] hub 8-1.3:1.0: USB hub found
[   56.171569] hub 8-1.3:1.0: 2 ports detected
[   56.833378] scsi0 : qla2xxx
[   56.852368] qla2xxx [0000:13:00.0]-00fb:0: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   56.861241] qla2xxx [0000:13:00.0]-00fc:0: ISP2031: PCIe (8.0GT/s x8) @ 0000:13:00.0 hdma+ host#=0 fw=7.03.01 (d0d5).
[   56.873804] qla2xxx [0000:13:00.1]-011c: : MSI-X vector count: 31.
[   56.880702] qla2xxx [0000:13:00.1]-001d: : Found an ISP2031 irq 68 iobase 0xffffc9001030e000.
[   56.891615] qla2xxx 0000:13:00.1: irq 674 for MSI/MSI-X
[   56.891843] qla2xxx 0000:13:00.1: irq 675 for MSI/MSI-X
[   57.607073] qla2xxx [0000:13:00.0]-505f:0: Link is operational (8 Gbps).
[   58.113132] scsi1 : qla2xxx
[   58.133033] qla2xxx [0000:13:00.1]-00fb:1: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   58.141863] qla2xxx [0000:13:00.1]-00fc:1: ISP2031: PCIe (8.0GT/s x8) @ 0000:13:00.1 hdma+ host#=1 fw=7.03.01 (d0d5).
[   58.155138] qla2xxx [0000:33:00.0]-011c: : MSI-X vector count: 31.
[   58.162512] qla2xxx [0000:33:00.0]-001d: : Found an ISP2031 irq 136 iobase 0xffffc900303d6000.
[   58.175663] qla2xxx 0000:33:00.0: irq 676 for MSI/MSI-X
[   58.175696] qla2xxx 0000:33:00.0: irq 677 for MSI/MSI-X
[   58.849836] scsi: waiting for bus probes to complete ...
[   58.885115] qla2xxx [0000:13:00.1]-505f:1: Link is operational (8 Gbps).
[   59.418929] scsi2 : qla2xxx
[   59.437659] qla2xxx [0000:33:00.0]-00fb:2: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   59.446509] qla2xxx [0000:33:00.0]-00fc:2: ISP2031: PCIe (8.0GT/s x8) @ 0000:33:00.0 hdma+ host#=2 fw=7.03.01 (d0d5).
[   59.459167] qla2xxx [0000:33:00.1]-011c: : MSI-X vector count: 31.
[   59.466141] qla2xxx [0000:33:00.1]-001d: : Found an ISP2031 irq 140 iobase 0xffffc9005042c000.
[   59.477285] qla2xxx 0000:33:00.1: irq 678 for MSI/MSI-X
[   59.477316] qla2xxx 0000:33:00.1: irq 679 for MSI/MSI-X
[   59.511587] scsi 0:0:0:0: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   59.522101] scsi 0:0:0:0: alua: supports implicit TPGS
[   59.528032] scsi 0:0:0:0: alua: port group 01 rel port 05
[   59.534168] scsi 0:0:0:0: alua: port group 01 state N non-preferred supports tolusNA
[   59.542822] scsi 0:0:0:0: alua: Attached
[   59.548926] scsi 0:0:0:1: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   59.557992] scsi 0:0:0:1: alua: supports implicit TPGS
[   59.563918] scsi 0:0:0:1: alua: port group 01 rel port 05
[   59.570064] scsi 0:0:0:1: alua: port group 01 state N non-preferred supports tolusNA
[   59.578735] scsi 0:0:0:1: alua: Attached
[   59.583962] scsi 0:0:0:2: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   59.593051] scsi 0:0:0:2: alua: supports implicit TPGS
[   59.598913] scsi 0:0:0:2: alua: port group 01 rel port 05
[   59.605080] scsi 0:0:0:2: alua: port group 01 state N non-preferred supports tolusNA
[   59.613745] scsi 0:0:0:2: alua: Attached
[   59.618819] scsi 0:0:0:3: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   59.627910] scsi 0:0:0:3: alua: supports implicit TPGS
[   59.633806] scsi 0:0:0:3: alua: port group 01 rel port 05
[   59.639933] scsi 0:0:0:3: alua: port group 01 state N non-preferred supports tolusNA
[   59.648580] scsi 0:0:0:3: alua: Attached
[   59.653247] scsi: waiting for bus probes to complete ...
[   60.129283] scsi: waiting for bus probes to complete ...
[   60.189875] qla2xxx [0000:33:00.0]-505f:2: Link is operational (8 Gbps).
[   60.704705] scsi3 : qla2xxx
[   60.722627] qla2xxx [0000:33:00.1]-00fb:3: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   60.731519] qla2xxx [0000:33:00.1]-00fc:3: ISP2031: PCIe (8.0GT/s x8) @ 0000:33:00.1 hdma+ host#=3 fw=7.03.01 (d0d5).
[   60.744909] qla2xxx [0000:53:00.0]-011c: : MSI-X vector count: 31.
[   60.751854] qla2xxx [0000:53:00.0]-001d: : Found an ISP2031 irq 208 iobase 0xffffc90050436000.
[   60.763402] qla2xxx 0000:53:00.0: irq 680 for MSI/MSI-X
[   60.763435] qla2xxx 0000:53:00.0: irq 681 for MSI/MSI-X
[   60.828284] scsi 0:0:1:0: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   60.837663] scsi 1:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   60.837700] scsi 0:0:1:0: alua: supports implicit TPGS
[   60.838122] scsi 0:0:1:0: alua: port group 00 rel port 01
[   60.838349] scsi 0:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   60.838351] scsi 0:0:1:0: alua: Attached
[   60.839960] scsi 0:0:1:1: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   60.840001] scsi 0:0:1:1: alua: supports implicit TPGS
[   60.840103] scsi 0:0:1:1: alua: port group 00 rel port 01
[   60.840160] scsi 0:0:1:1: alua: port group 00 state A preferred supports tolusNA
[   60.840162] scsi 0:0:1:1: alua: Attached
[   60.841038] scsi 0:0:1:2: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   60.841086] scsi 0:0:1:2: alua: supports implicit TPGS
[   60.841186] scsi 0:0:1:2: alua: port group 00 rel port 01
[   60.841236] scsi 0:0:1:2: alua: port group 00 state A preferred supports tolusNA
[   60.841237] scsi 0:0:1:2: alua: Attached
[   60.841859] scsi 0:0:1:3: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   60.842784] scsi 0:0:1:3: alua: supports implicit TPGS
[   60.842885] scsi 0:0:1:3: alua: port group 00 rel port 01
[   60.842937] scsi 0:0:1:3: alua: port group 00 state A preferred supports tolusNA
[   60.842938] scsi 0:0:1:3: alua: Attached
[   60.972046] scsi 1:0:0:0: alua: supports implicit TPGS
[   60.978276] scsi 1:0:0:0: alua: port group 01 rel port 05
[   60.984653] scsi 1:0:0:0: alua: port group 01 state A preferred supports tolusNA
[   60.992948] scsi 1:0:0:0: alua: Attached
[   60.998158] scsi: waiting for bus probes to complete ...
[   61.435214] scsi: waiting for bus probes to complete ...
[   61.476079] qla2xxx [0000:33:00.1]-505f:3: Link is operational (8 Gbps).
[   61.999108] scsi4 : qla2xxx
[   62.017700] qla2xxx [0000:53:00.0]-00fb:4: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   62.026548] qla2xxx [0000:53:00.0]-00fc:4: ISP2031: PCIe (8.0GT/s x8) @ 0000:53:00.0 hdma+ host#=4 fw=7.03.01 (d0d5).
[   62.039283] qla2xxx [0000:53:00.1]-011c: : MSI-X vector count: 31.
[   62.046222] qla2xxx [0000:53:00.1]-001d: : Found an ISP2031 irq 212 iobase 0xffffc90050440000.
[   62.057330] qla2xxx 0000:53:00.1: irq 682 for MSI/MSI-X
[   62.057374] qla2xxx 0000:53:00.1: irq 683 for MSI/MSI-X
[   62.114847] scsi 1:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.115186] scsi 2:0:0:0: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.115343] scsi 2:0:0:0: alua: supports implicit TPGS
[   62.115729] scsi 2:0:0:0: alua: port group 01 rel port 05
[   62.115941] scsi 2:0:0:0: alua: port group 01 state N non-preferred supports tolusNA
[   62.115942] scsi 2:0:0:0: alua: Attached
[   62.117967] scsi 2:0:0:100: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.118045] scsi 2:0:0:100: alua: supports implicit TPGS
[   62.118464] scsi 2:0:0:100: alua: port group 01 rel port 05
[   62.118711] scsi 2:0:0:100: alua: port group 01 state N non-preferred supports tolusNA
[   62.118712] scsi 2:0:0:100: alua: Attached
[   62.119434] scsi 2:0:0:101: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.119457] scsi 2:0:0:101: alua: supports implicit TPGS
[   62.119915] scsi 2:0:0:101: alua: port group 01 rel port 05
[   62.120116] scsi 2:0:0:101: alua: port group 01 state N non-preferred supports tolusNA
[   62.120117] scsi 2:0:0:101: alua: Attached
[   62.120701] scsi 2:0:0:102: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.120781] scsi 2:0:0:102: alua: supports implicit TPGS
[   62.121174] scsi 2:0:0:102: alua: port group 01 rel port 05
[   62.121227] scsi 2:0:0:102: alua: port group 01 state N non-preferred supports tolusNA
[   62.121228] scsi 2:0:0:102: alua: Attached
[   62.121879] scsi 2:0:0:103: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.121907] scsi 2:0:0:103: alua: supports implicit TPGS
[   62.122342] scsi 2:0:0:103: alua: port group 01 rel port 05
[   62.122399] scsi 2:0:0:103: alua: port group 01 state N non-preferred supports tolusNA
[   62.122400] scsi 2:0:0:103: alua: Attached
[   62.122917] scsi 2:0:0:104: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.123038] scsi 2:0:0:104: alua: supports implicit TPGS
[   62.123347] scsi 2:0:0:104: alua: port group 01 rel port 05
[   62.123400] scsi 2:0:0:104: alua: port group 01 state N non-preferred supports tolusNA
[   62.123402] scsi 2:0:0:104: alua: Attached
[   62.123850] scsi 2:0:0:105: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.123891] scsi 2:0:0:105: alua: supports implicit TPGS
[   62.124264] scsi 2:0:0:105: alua: port group 01 rel port 05
[   62.124316] scsi 2:0:0:105: alua: port group 01 state N non-preferred supports tolusNA
[   62.124320] scsi 2:0:0:105: alua: Attached
[   62.125023] scsi 2:0:0:106: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.125049] scsi 2:0:0:106: alua: supports implicit TPGS
[   62.125520] scsi 2:0:0:106: alua: port group 01 rel port 05
[   62.125746] scsi 2:0:0:106: alua: port group 01 state N non-preferred supports tolusNA
[   62.125747] scsi 2:0:0:106: alua: Attached
[   62.126215] scsi 2:0:0:107: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.126260] scsi 2:0:0:107: alua: supports implicit TPGS
[   62.126550] scsi 2:0:0:107: alua: port group 01 rel port 05
[   62.126599] scsi 2:0:0:107: alua: port group 01 state N non-preferred supports tolusNA
[   62.126601] scsi 2:0:0:107: alua: Attached
[   62.127307] scsi 2:0:0:108: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.127446] scsi 2:0:0:108: alua: supports implicit TPGS
[   62.127697] scsi 2:0:0:108: alua: port group 01 rel port 05
[   62.127754] scsi 2:0:0:108: alua: port group 01 state N non-preferred supports tolusNA
[   62.127780] scsi 2:0:0:108: alua: Attached
[   62.128292] scsi 2:0:0:109: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.128367] scsi 2:0:0:109: alua: supports implicit TPGS
[   62.128617] scsi 2:0:0:109: alua: port group 01 rel port 05
[   62.128667] scsi 2:0:0:109: alua: port group 01 state N non-preferred supports tolusNA
[   62.128668] scsi 2:0:0:109: alua: Attached
[   62.129053] scsi 2:0:0:110: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.129113] scsi 2:0:0:110: alua: supports implicit TPGS
[   62.129397] scsi 2:0:0:110: alua: port group 01 rel port 05
[   62.129451] scsi 2:0:0:110: alua: port group 01 state N non-preferred supports tolusNA
[   62.129453] scsi 2:0:0:110: alua: Attached
[   62.130039] scsi 2:0:0:111: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.130115] scsi 2:0:0:111: alua: supports implicit TPGS
[   62.130229] scsi 2:0:0:111: alua: port group 01 rel port 05
[   62.130279] scsi 2:0:0:111: alua: port group 01 state N non-preferred supports tolusNA
[   62.130280] scsi 2:0:0:111: alua: Attached
[   62.130553] scsi 2:0:0:112: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.130606] scsi 2:0:0:112: alua: supports implicit TPGS
[   62.130707] scsi 2:0:0:112: alua: port group 01 rel port 05
[   62.130761] scsi 2:0:0:112: alua: port group 01 state N non-preferred supports tolusNA
[   62.130764] scsi 2:0:0:112: alua: Attached
[   62.131236] scsi 2:0:0:113: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.131289] scsi 2:0:0:113: alua: supports implicit TPGS
[   62.131385] scsi 2:0:0:113: alua: port group 01 rel port 05
[   62.131435] scsi 2:0:0:113: alua: port group 01 state N non-preferred supports tolusNA
[   62.131436] scsi 2:0:0:113: alua: Attached
[   62.131901] scsi 2:0:0:114: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.131949] scsi 2:0:0:114: alua: supports implicit TPGS
[   62.132052] scsi 2:0:0:114: alua: port group 01 rel port 05
[   62.132104] scsi 2:0:0:114: alua: port group 01 state N non-preferred supports tolusNA
[   62.132105] scsi 2:0:0:114: alua: Attached
[   62.132408] scsi 2:0:0:115: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.132458] scsi 2:0:0:115: alua: supports implicit TPGS
[   62.132559] scsi 2:0:0:115: alua: port group 01 rel port 05
[   62.132611] scsi 2:0:0:115: alua: port group 01 state N non-preferred supports tolusNA
[   62.132612] scsi 2:0:0:115: alua: Attached
[   62.133077] scsi 2:0:0:116: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.133145] scsi 2:0:0:116: alua: supports implicit TPGS
[   62.133248] scsi 2:0:0:116: alua: port group 01 rel port 05
[   62.133300] scsi 2:0:0:116: alua: port group 01 state N non-preferred supports tolusNA
[   62.133301] scsi 2:0:0:116: alua: Attached
[   62.133587] scsi 2:0:0:117: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.133604] scsi 2:0:0:117: alua: supports implicit TPGS
[   62.133708] scsi 2:0:0:117: alua: port group 01 rel port 05
[   62.133765] scsi 2:0:0:117: alua: port group 01 state N non-preferred supports tolusNA
[   62.133766] scsi 2:0:0:117: alua: Attached
[   62.134044] scsi 2:0:0:118: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.134119] scsi 2:0:0:118: alua: supports implicit TPGS
[   62.134220] scsi 2:0:0:118: alua: port group 01 rel port 05
[   62.134274] scsi 2:0:0:118: alua: port group 01 state N non-preferred supports tolusNA
[   62.134276] scsi 2:0:0:118: alua: Attached
[   62.134781] scsi 2:0:0:119: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   62.134797] scsi 2:0:0:119: alua: supports implicit TPGS
[   62.134913] scsi 2:0:0:119: alua: port group 01 rel port 05
[   62.134964] scsi 2:0:0:119: alua: port group 01 state N non-preferred supports tolusNA
[   62.134965] scsi 2:0:0:119: alua: Attached
[   62.135086] scsi: waiting for bus probes to complete ...
[   62.720517] scsi: waiting for bus probes to complete ...
[   62.772566] qla2xxx [0000:53:00.0]-505f:4: Link is operational (8 Gbps).
[   62.876163] scsi 1:0:1:0: alua: supports implicit TPGS
[   62.882423] scsi 1:0:1:0: alua: port group 00 rel port 01
[   62.888693] scsi 1:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   62.896980] scsi 1:0:1:0: alua: Attached
[   63.271274] scsi5 : qla2xxx
[   63.289064] qla2xxx [0000:53:00.1]-00fb:5: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   63.297984] qla2xxx [0000:53:00.1]-00fc:5: ISP2031: PCIe (8.0GT/s x8) @ 0000:53:00.1 hdma+ host#=5 fw=7.03.01 (d0d5).
[   63.311384] qla2xxx [0000:73:00.0]-011c: : MSI-X vector count: 31.
[   63.318295] qla2xxx [0000:73:00.0]-001d: : Found an ISP2031 irq 280 iobase 0xffffc90050444000.
[   63.329972] qla2xxx 0000:73:00.0: irq 684 for MSI/MSI-X
[   63.330008] qla2xxx 0000:73:00.0: irq 685 for MSI/MSI-X
[   63.406772] scsi 2:0:1:0: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.408402] scsi 3:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.408665] scsi 3:0:0:0: alua: supports implicit TPGS
[   63.409012] scsi 3:0:0:0: alua: port group 01 rel port 05
[   63.409204] scsi 3:0:0:0: alua: port group 01 state A preferred supports tolusNA
[   63.409205] scsi 3:0:0:0: alua: Attached
[   63.409917] scsi: waiting for bus probes to complete ...
[   63.455636] scsi 2:0:1:0: alua: supports implicit TPGS
[   63.461893] scsi 2:0:1:0: alua: port group 00 rel port 01
[   63.468230] scsi 2:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   63.476524] scsi 2:0:1:0: alua: Attached
[   63.482852] scsi 2:0:1:100: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.492129] scsi 2:0:1:100: alua: supports implicit TPGS
[   63.498526] scsi 2:0:1:100: alua: port group 00 rel port 01
[   63.505034] scsi 2:0:1:100: alua: port group 00 state A preferred supports tolusNA
[   63.513521] scsi 2:0:1:100: alua: Attached
[   63.519230] scsi 2:0:1:101: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.528555] scsi 2:0:1:101: alua: supports implicit TPGS
[   63.534683] scsi 2:0:1:101: alua: port group 00 rel port 01
[   63.541056] scsi 2:0:1:101: alua: port group 00 state A preferred supports tolusNA
[   63.549546] scsi 2:0:1:101: alua: Attached
[   63.555018] scsi 2:0:1:102: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.564283] scsi 2:0:1:102: alua: supports implicit TPGS
[   63.570441] scsi 2:0:1:102: alua: port group 00 rel port 01
[   63.576822] scsi 2:0:1:102: alua: port group 00 state A preferred supports tolusNA
[   63.585321] scsi 2:0:1:102: alua: Attached
[   63.590599] scsi 2:0:1:103: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.599857] scsi 2:0:1:103: alua: supports implicit TPGS
[   63.605988] scsi 2:0:1:103: alua: port group 00 rel port 01
[   63.612443] scsi 2:0:1:103: alua: port group 00 state A preferred supports tolusNA
[   63.620927] scsi 2:0:1:103: alua: Attached
[   63.626417] scsi 2:0:1:104: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.635703] scsi 2:0:1:104: alua: supports implicit TPGS
[   63.641834] scsi 2:0:1:104: alua: port group 00 rel port 01
[   63.648207] scsi 2:0:1:104: alua: port group 00 state A preferred supports tolusNA
[   63.656702] scsi 2:0:1:104: alua: Attached
[   63.662101] scsi 2:0:1:105: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.671375] scsi 2:0:1:105: alua: supports implicit TPGS
[   63.677505] scsi 2:0:1:105: alua: port group 00 rel port 01
[   63.683874] scsi 2:0:1:105: alua: port group 00 state A preferred supports tolusNA
[   63.692361] scsi 2:0:1:105: alua: Attached
[   63.697551] scsi 2:0:1:106: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.706818] scsi 2:0:1:106: alua: supports implicit TPGS
[   63.712959] scsi 2:0:1:106: alua: port group 00 rel port 01
[   63.719323] scsi 2:0:1:106: alua: port group 00 state A preferred supports tolusNA
[   63.727800] scsi 2:0:1:106: alua: Attached
[   63.733399] scsi 2:0:1:107: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.742657] scsi 2:0:1:107: alua: supports implicit TPGS
[   63.742772] scsi 2:0:1:107: alua: port group 00 rel port 01
[   63.742826] scsi 2:0:1:107: alua: port group 00 state A preferred supports tolusNA
[   63.742828] scsi 2:0:1:107: alua: Attached
[   63.743532] scsi 2:0:1:108: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.743554] scsi 2:0:1:108: alua: supports implicit TPGS
[   63.743650] scsi 2:0:1:108: alua: port group 00 rel port 01
[   63.743701] scsi 2:0:1:108: alua: port group 00 state A preferred supports tolusNA
[   63.743702] scsi 2:0:1:108: alua: Attached
[   63.744745] scsi 2:0:1:109: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.744771] scsi 2:0:1:109: alua: supports implicit TPGS
[   63.745148] scsi 2:0:1:109: alua: port group 00 rel port 01
[   63.745348] scsi 2:0:1:109: alua: port group 00 state A preferred supports tolusNA
[   63.745351] scsi 2:0:1:109: alua: Attached
[   63.746483] scsi 2:0:1:110: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.746520] scsi 2:0:1:110: alua: supports implicit TPGS
[   63.746618] scsi 2:0:1:110: alua: port group 00 rel port 01
[   63.746670] scsi 2:0:1:110: alua: port group 00 state A preferred supports tolusNA
[   63.746674] scsi 2:0:1:110: alua: Attached
[   63.748309] scsi 2:0:1:111: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.748335] scsi 2:0:1:111: alua: supports implicit TPGS
[   63.748434] scsi 2:0:1:111: alua: port group 00 rel port 01
[   63.748494] scsi 2:0:1:111: alua: port group 00 state A preferred supports tolusNA
[   63.748496] scsi 2:0:1:111: alua: Attached
[   63.749409] scsi 2:0:1:112: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.749425] scsi 2:0:1:112: alua: supports implicit TPGS
[   63.749520] scsi 2:0:1:112: alua: port group 00 rel port 01
[   63.749569] scsi 2:0:1:112: alua: port group 00 state A preferred supports tolusNA
[   63.749570] scsi 2:0:1:112: alua: Attached
[   63.750086] scsi 2:0:1:113: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.750109] scsi 2:0:1:113: alua: supports implicit TPGS
[   63.750216] scsi 2:0:1:113: alua: port group 00 rel port 01
[   63.750272] scsi 2:0:1:113: alua: port group 00 state A preferred supports tolusNA
[   63.750274] scsi 2:0:1:113: alua: Attached
[   63.750988] scsi 2:0:1:114: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.751008] scsi 2:0:1:114: alua: supports implicit TPGS
[   63.751103] scsi 2:0:1:114: alua: port group 00 rel port 01
[   63.751152] scsi 2:0:1:114: alua: port group 00 state A preferred supports tolusNA
[   63.751154] scsi 2:0:1:114: alua: Attached
[   63.752072] scsi 2:0:1:115: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.752086] scsi 2:0:1:115: alua: supports implicit TPGS
[   63.752186] scsi 2:0:1:115: alua: port group 00 rel port 01
[   63.752237] scsi 2:0:1:115: alua: port group 00 state A preferred supports tolusNA
[   63.752238] scsi 2:0:1:115: alua: Attached
[   63.752734] scsi 2:0:1:116: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.752757] scsi 2:0:1:116: alua: supports implicit TPGS
[   63.753090] scsi 2:0:1:116: alua: port group 00 rel port 01
[   63.753297] scsi 2:0:1:116: alua: port group 00 state A preferred supports tolusNA
[   63.753301] scsi 2:0:1:116: alua: Attached
[   63.754178] scsi 2:0:1:117: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.754197] scsi 2:0:1:117: alua: supports implicit TPGS
[   63.754301] scsi 2:0:1:117: alua: port group 00 rel port 01
[   63.754352] scsi 2:0:1:117: alua: port group 00 state A preferred supports tolusNA
[   63.754354] scsi 2:0:1:117: alua: Attached
[   63.755247] scsi 2:0:1:118: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.755266] scsi 2:0:1:118: alua: supports implicit TPGS
[   63.755362] scsi 2:0:1:118: alua: port group 00 rel port 01
[   63.755411] scsi 2:0:1:118: alua: port group 00 state A preferred supports tolusNA
[   63.755413] scsi 2:0:1:118: alua: Attached
[   63.755874] scsi 2:0:1:119: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   63.755890] scsi 2:0:1:119: alua: supports implicit TPGS
[   63.755986] scsi 2:0:1:119: alua: port group 00 rel port 01
[   63.756035] scsi 2:0:1:119: alua: port group 00 state A preferred supports tolusNA
[   63.756040] scsi 2:0:1:119: alua: Attached
[   64.014902] scsi: waiting for bus probes to complete ...
[   64.042401] qla2xxx [0000:53:00.1]-505f:5: Link is operational (8 Gbps).
[   64.566780] scsi6 : qla2xxx
[   64.580767] qla2xxx [0000:73:00.0]-00fb:6: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   64.580775] qla2xxx [0000:73:00.0]-00fc:6: ISP2031: PCIe (8.0GT/s x8) @ 0000:73:00.0 hdma+ host#=6 fw=7.03.01 (d0d5).
[   64.581480] qla2xxx [0000:73:00.1]-011c: : MSI-X vector count: 31.
[   64.581483] qla2xxx [0000:73:00.1]-001d: : Found an ISP2031 irq 284 iobase 0xffffc90050456000.
[   64.582756] qla2xxx 0000:73:00.1: irq 686 for MSI/MSI-X
[   64.582995] qla2xxx 0000:73:00.1: irq 687 for MSI/MSI-X
[   64.667811] scsi 3:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   64.667880] scsi 3:0:1:0: alua: supports implicit TPGS
[   64.668306] scsi 3:0:1:0: alua: port group 00 rel port 01
[   64.668514] scsi 3:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   64.668516] scsi 3:0:1:0: alua: Attached
[   64.668589] scsi 4:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   64.668906] scsi 4:0:0:0: alua: supports implicit TPGS
[   64.669391] scsi 4:0:0:0: alua: port group 01 rel port 05
[   64.669593] scsi 4:0:0:0: alua: port group 01 state A preferred supports tolusNA
[   64.669595] scsi 4:0:0:0: alua: Attached
[   64.670733] scsi: waiting for bus probes to complete ...
[   65.288187] scsi: waiting for bus probes to complete ...
[   65.338575] qla2xxx [0000:73:00.0]-505f:6: Link is operational (8 Gbps).
[   65.794861] scsi7 : qla2xxx
[   65.808960] qla2xxx [0000:73:00.1]-00fb:7: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   65.808967] qla2xxx [0000:73:00.1]-00fc:7: ISP2031: PCIe (8.0GT/s x8) @ 0000:73:00.1 hdma+ host#=7 fw=7.03.01 (d0d5).
[   65.810602] qla2xxx [0000:93:00.0]-011c: : MSI-X vector count: 31.
[   65.810611] qla2xxx [0000:93:00.0]-001d: : Found an ISP2031 irq 352 iobase 0xffffc90050460000.
[   65.812511] qla2xxx 0000:93:00.0: irq 688 for MSI/MSI-X
[   65.812550] qla2xxx 0000:93:00.0: irq 689 for MSI/MSI-X
[   65.969159] scsi 4:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   65.969161] scsi 5:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   65.969271] scsi 5:0:0:0: alua: supports implicit TPGS
[   65.969278] scsi 4:0:1:0: alua: supports implicit TPGS
[   65.969811] scsi 4:0:1:0: alua: port group 00 rel port 01
[   65.969817] scsi 5:0:0:0: alua: port group 01 rel port 05
[   65.970045] scsi 4:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   65.970047] scsi 4:0:1:0: alua: Attached
[   65.970053] scsi 5:0:0:0: alua: port group 01 state A preferred supports tolusNA
[   65.970055] scsi 5:0:0:0: alua: Attached
[   65.971421] scsi: waiting for bus probes to complete ...
[   66.565689] qla2xxx [0000:73:00.1]-505f:7: Link is operational (8 Gbps).
[   66.581612] scsi: waiting for bus probes to complete ...
[   67.042089] scsi8 : qla2xxx
[   67.056215] qla2xxx [0000:93:00.0]-00fb:8: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   67.056223] qla2xxx [0000:93:00.0]-00fc:8: ISP2031: PCIe (8.0GT/s x8) @ 0000:93:00.0 hdma+ host#=8 fw=7.03.01 (d0d5).
[   67.057120] qla2xxx [0000:93:00.1]-011c: : MSI-X vector count: 31.
[   67.057125] qla2xxx [0000:93:00.1]-001d: : Found an ISP2031 irq 356 iobase 0xffffc90050464000.
[   67.058520] qla2xxx 0000:93:00.1: irq 690 for MSI/MSI-X
[   67.058553] qla2xxx 0000:93:00.1: irq 691 for MSI/MSI-X
[   67.187755] scsi 5:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   67.187926] scsi 5:0:1:0: alua: supports implicit TPGS
[   67.188462] scsi 5:0:1:0: alua: port group 00 rel port 01
[   67.188641] scsi 5:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   67.188643] scsi 5:0:1:0: alua: Attached
[   67.188776] scsi 6:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   67.189328] scsi 6:0:0:0: alua: supports implicit TPGS
[   67.189750] scsi 6:0:0:0: alua: port group 01 rel port 05
[   67.189986] scsi 6:0:0:0: alua: port group 01 state A preferred supports tolusNA
[   67.189987] scsi 6:0:0:0: alua: Attached
[   67.191131] scsi: waiting for bus probes to complete ...
[   67.812051] scsi: waiting for bus probes to complete ...
[   67.814317] qla2xxx [0000:93:00.0]-505f:8: Link is operational (8 Gbps).
[   68.271168] scsi9 : qla2xxx
[   68.286188] qla2xxx [0000:93:00.1]-00fb:9: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   68.286193] qla2xxx [0000:93:00.1]-00fc:9: ISP2031: PCIe (8.0GT/s x8) @ 0000:93:00.1 hdma+ host#=9 fw=7.03.01 (d0d5).
[   68.287856] qla2xxx [0000:b3:00.0]-011c: : MSI-X vector count: 31.
[   68.287864] qla2xxx [0000:b3:00.0]-001d: : Found an ISP2031 irq 424 iobase 0xffffc9005046e000.
[   68.289764] qla2xxx 0000:b3:00.0: irq 692 for MSI/MSI-X
[   68.289801] qla2xxx 0000:b3:00.0: irq 693 for MSI/MSI-X
[   68.446776] scsi 7:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   68.446883] scsi 7:0:0:0: alua: supports implicit TPGS
[   68.447160] scsi 6:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   68.447365] scsi 7:0:0:0: alua: port group 01 rel port 05
[   68.447554] scsi 7:0:0:0: alua: port group 01 state A preferred supports tolusNA
[   68.447555] scsi 7:0:0:0: alua: Attached
[   68.447573] scsi 6:0:1:0: alua: supports implicit TPGS
[   68.448034] scsi 6:0:1:0: alua: port group 00 rel port 01
[   68.448220] scsi 6:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   68.448222] scsi 6:0:1:0: alua: Attached
[   68.448720] scsi: waiting for bus probes to complete ...
[   69.043307] qla2xxx [0000:93:00.1]-505f:9: Link is operational (8 Gbps).
[   69.058993] scsi: waiting for bus probes to complete ...
[   69.521589] scsi10 : qla2xxx
[   69.536715] qla2xxx [0000:b3:00.0]-00fb:10: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   69.536724] qla2xxx [0000:b3:00.0]-00fc:10: ISP2031: PCIe (8.0GT/s x8) @ 0000:b3:00.0 hdma+ host#=10 fw=7.03.01 (d0d5).
[   69.537524] qla2xxx [0000:b3:00.1]-011c: : MSI-X vector count: 31.
[   69.537529] qla2xxx [0000:b3:00.1]-001d: : Found an ISP2031 irq 428 iobase 0xffffc9005047e000.
[   69.539096] qla2xxx 0000:b3:00.1: irq 694 for MSI/MSI-X
[   69.539128] qla2xxx 0000:b3:00.1: irq 695 for MSI/MSI-X
[   69.675956] scsi 7:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   69.676056] scsi 7:0:1:0: alua: supports implicit TPGS
[   69.676566] scsi 7:0:1:0: alua: port group 00 rel port 01
[   69.676808] scsi 7:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   69.676812] scsi 7:0:1:0: alua: Attached
[   69.676988] scsi 8:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   69.677488] scsi 8:0:0:0: alua: supports implicit TPGS
[   69.677953] scsi 8:0:0:0: alua: port group 01 rel port 05
[   69.678197] scsi 8:0:0:0: alua: port group 01 state A preferred supports tolusNA
[   69.678199] scsi 8:0:0:0: alua: Attached
[   69.679126] scsi: waiting for bus probes to complete ...
[   70.286185] scsi: waiting for bus probes to complete ...
[   70.292590] qla2xxx [0000:b3:00.0]-505f:10: Link is operational (8 Gbps).
[   70.753959] scsi11 : qla2xxx
[   70.768486] qla2xxx [0000:b3:00.1]-00fb:11: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   70.768497] qla2xxx [0000:b3:00.1]-00fc:11: ISP2031: PCIe (8.0GT/s x8) @ 0000:b3:00.1 hdma+ host#=11 fw=7.03.01 (d0d5).
[   70.770183] qla2xxx [0000:d3:00.0]-011c: : MSI-X vector count: 31.
[   70.770192] qla2xxx [0000:d3:00.0]-001d: : Found an ISP2031 irq 496 iobase 0xffffc90070484000.
[   70.772044] qla2xxx 0000:d3:00.0: irq 696 for MSI/MSI-X
[   70.772089] qla2xxx 0000:d3:00.0: irq 697 for MSI/MSI-X
[   70.925366] scsi 8:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   70.925438] scsi 8:0:1:0: alua: supports implicit TPGS
[   70.925925] scsi 8:0:1:0: alua: port group 00 rel port 01
[   70.926127] scsi 9:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   70.926196] scsi 8:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   70.926200] scsi 8:0:1:0: alua: Attached
[   70.926395] scsi 9:0:0:0: alua: supports implicit TPGS
[   70.926803] scsi 9:0:0:0: alua: port group 01 rel port 05
[   70.927028] scsi 9:0:0:0: alua: port group 01 state A preferred supports tolusNA
[   70.927037] scsi 9:0:0:0: alua: Attached
[   70.927945] scsi: waiting for bus probes to complete ...
[   71.526039] qla2xxx [0000:b3:00.1]-505f:11: Link is operational (8 Gbps).
[   71.537804] scsi: waiting for bus probes to complete ...
[   72.003008] scsi12 : qla2xxx
[   72.017512] qla2xxx [0000:d3:00.0]-00fb:12: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   72.017521] qla2xxx [0000:d3:00.0]-00fc:12: ISP2031: PCIe (8.0GT/s x8) @ 0000:d3:00.0 hdma+ host#=12 fw=7.03.01 (d0d5).
[   72.018233] qla2xxx [0000:d3:00.1]-011c: : MSI-X vector count: 31.
[   72.018238] qla2xxx [0000:d3:00.1]-001d: : Found an ISP2031 irq 500 iobase 0xffffc9007048e000.
[   72.019448] qla2xxx 0000:d3:00.1: irq 698 for MSI/MSI-X
[   72.019703] qla2xxx 0000:d3:00.1: irq 699 for MSI/MSI-X
[   72.159370] scsi 9:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   72.159392] scsi 10:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   72.159617] scsi 9:0:1:0: alua: supports implicit TPGS
[   72.159630] scsi 10:0:0:0: alua: supports implicit TPGS
[   72.160038] scsi 9:0:1:0: alua: port group 00 rel port 01
[   72.160056] scsi 10:0:0:0: alua: port group 01 rel port 05
[   72.160254] scsi 9:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   72.160256] scsi 9:0:1:0: alua: Attached
[   72.160300] scsi 10:0:0:0: alua: port group 01 state A preferred supports tolusNA
[   72.160311] scsi 10:0:0:0: alua: Attached
[   72.532408] scsi: waiting for bus probes to complete ...
[   72.769032] scsi: waiting for bus probes to complete ...
[   72.793428] qla2xxx [0000:d3:00.0]-505f:12: Link is operational (8 Gbps).
[   73.231487] scsi13 : qla2xxx
[   73.246566] qla2xxx [0000:d3:00.1]-00fb:13: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   73.246572] qla2xxx [0000:d3:00.1]-00fc:13: ISP2031: PCIe (8.0GT/s x8) @ 0000:d3:00.1 hdma+ host#=13 fw=7.03.01 (d0d5).
[   73.248105] qla2xxx [0000:f3:00.0]-011c: : MSI-X vector count: 31.
[   73.248110] qla2xxx [0000:f3:00.0]-001d: : Found an ISP2031 irq 568 iobase 0xffffc9007049e000.
[   73.249847] qla2xxx 0000:f3:00.0: irq 700 for MSI/MSI-X
[   73.249892] qla2xxx 0000:f3:00.0: irq 701 for MSI/MSI-X
[   73.419000] scsi 11:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   73.419105] scsi 11:0:0:0: alua: supports implicit TPGS
[   73.419378] scsi 10:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   73.419590] scsi 11:0:0:0: alua: port group 01 rel port 05
[   73.419805] scsi 11:0:0:0: alua: port group 01 state A preferred supports tolusNA
[   73.419809] scsi 11:0:0:0: alua: Attached
[   73.419832] scsi 10:0:1:0: alua: supports implicit TPGS
[   73.420207] scsi 10:0:1:0: alua: port group 00 rel port 01
[   73.420430] scsi 10:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   73.420442] scsi 10:0:1:0: alua: Attached
[   73.420818] scsi: waiting for bus probes to complete ...
[   74.019328] scsi: waiting for bus probes to complete ...
[   74.021539] qla2xxx [0000:d3:00.1]-505f:13: Link is operational (8 Gbps).
[   74.486452] scsi14 : qla2xxx
[   74.500720] qla2xxx [0000:f3:00.0]-00fb:14: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   74.500726] qla2xxx [0000:f3:00.0]-00fc:14: ISP2031: PCIe (8.0GT/s x8) @ 0000:f3:00.0 hdma+ host#=14 fw=7.03.01 (d0d5).
[   74.501478] qla2xxx [0000:f3:00.1]-011c: : MSI-X vector count: 31.
[   74.501482] qla2xxx [0000:f3:00.1]-001d: : Found an ISP2031 irq 572 iobase 0xffffc900704a8000.
[   74.502874] qla2xxx 0000:f3:00.1: irq 702 for MSI/MSI-X
[   74.502905] qla2xxx 0000:f3:00.1: irq 703 for MSI/MSI-X
[   74.648600] scsi 11:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   74.648698] scsi 11:0:1:0: alua: supports implicit TPGS
[   74.648982] scsi 12:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   74.649164] scsi 11:0:1:0: alua: port group 00 rel port 01
[   74.649332] scsi 12:0:0:0: alua: supports implicit TPGS
[   74.649385] scsi 11:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   74.649390] scsi 11:0:1:0: alua: Attached
[   74.649814] scsi 12:0:0:0: alua: port group 01 rel port 05
[   74.650016] scsi 12:0:0:0: alua: port group 01 state A preferred supports tolusNA
[   74.650021] scsi 12:0:0:0: alua: Attached
[   74.651266] scsi: waiting for bus probes to complete ...
[   75.248704] scsi: waiting for bus probes to complete ...
[   75.258823] qla2xxx [0000:f3:00.0]-505f:14: Link is operational (8 Gbps).
[   75.711284] scsi15 : qla2xxx
[   75.725031] qla2xxx [0000:f3:00.1]-00fb:15: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[   75.725037] qla2xxx [0000:f3:00.1]-00fc:15: ISP2031: PCIe (8.0GT/s x8) @ 0000:f3:00.1 hdma+ host#=15 fw=7.03.01 (d0d5).
[   75.869866] sd 0:0:0:0: [sda] 136716288 512-byte logical blocks: (69.9 GB/65.1 GiB)
[   75.870788] sd 0:0:0:0: [sda] Write Protect is off
[   75.870791] sd 0:0:0:0: [sda] Mode Sense: ef 00 00 08
[   75.871205] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.873376] sd 0:0:0:1: [sdb] 195305472 512-byte logical blocks: (99.9 GB/93.1 GiB)
[   75.873997] sd 0:0:0:1: [sdb] Write Protect is off
[   75.874001] sd 0:0:0:1: [sdb] Mode Sense: ef 00 00 08
[   75.874393] sd 0:0:0:1: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.874639] sd 0:0:0:2: [sdc] 195305472 512-byte logical blocks: (99.9 GB/93.1 GiB)
[   75.879369] sd 0:0:0:2: [sdc] Write Protect is off
[   75.879372] sd 0:0:0:2: [sdc] Mode Sense: ef 00 00 08
[   75.879477] sd 0:0:0:2: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.884799] sd 0:0:0:3: [sdd] 1367179264 512-byte logical blocks: (699 GB/651 GiB)
[   75.885534] sd 0:0:0:3: [sdd] Write Protect is off
[   75.885536] sd 0:0:0:3: [sdd] Mode Sense: ef 00 00 08
[   75.885566] sd 0:0:1:0: [sde] 136716288 512-byte logical blocks: (69.9 GB/65.1 GiB)
[   75.885771] sd 0:0:0:3: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.886040] sd 0:0:1:1: [sdf] 195305472 512-byte logical blocks: (99.9 GB/93.1 GiB)
[   75.886413] sd 0:0:1:0: [sde] Write Protect is off
[   75.886416] sd 0:0:1:0: [sde] Mode Sense: ef 00 00 08
[   75.886564] sd 0:0:1:2: [sdg] 195305472 512-byte logical blocks: (99.9 GB/93.1 GiB)
[   75.886823] sd 0:0:1:0: [sde] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.886837] sd 0:0:1:1: [sdf] Write Protect is off
[   75.886840] sd 0:0:1:1: [sdf] Mode Sense: ef 00 00 08
[   75.886981] sd 2:0:0:0: [sdi] 136716288 512-byte logical blocks: (69.9 GB/65.1 GiB)
[   75.887041] sd 0:0:1:3: [sdh] 1367179264 512-byte logical blocks: (699 GB/651 GiB)
[   75.887280] sd 0:0:1:1: [sdf] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.887336]  sda: sda1 sda2 sda3
[   75.887515] sd 0:0:1:2: [sdg] Write Protect is off
[   75.887519] sd 0:0:1:2: [sdg] Mode Sense: ef 00 00 08
[   75.887908] sd 0:0:1:3: [sdh] Write Protect is off
[   75.887911] sd 0:0:1:3: [sdh] Mode Sense: ef 00 00 08
[   75.887929] sd 0:0:1:2: [sdg] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.888279] sd 2:0:0:100: [sdj] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.888299] sd 2:0:0:101: [sdk] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.888346] sd 0:0:1:3: [sdh] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.888463]  sdd: unknown partition table
[   75.888773] sd 2:0:0:0: [sdi] Write Protect is off
[   75.888775] sd 2:0:0:0: [sdi] Mode Sense: ef 00 00 08
[   75.888818] sd 2:0:0:102: [sdl] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.888975] sd 2:0:0:0: [sdi] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.889225] sd 2:0:0:103: [sdm] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.889369] sd 2:0:0:100: [sdj] Write Protect is off
[   75.889372] sd 2:0:0:100: [sdj] Mode Sense: ef 00 00 08
[   75.889397] sd 2:0:0:101: [sdk] Write Protect is off
[   75.889399] sd 2:0:0:101: [sdk] Mode Sense: ef 00 00 08
[   75.889546] sd 2:0:0:101: [sdk] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.889561] sd 2:0:0:100: [sdj] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.889719]  sde: sde1 sde2 sde3
[   75.889890] sd 2:0:0:103: [sdm] Write Protect is off
[   75.889894] sd 2:0:0:103: [sdm] Mode Sense: ef 00 00 08
[   75.889960] sd 2:0:0:105: [sdo] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.890033] sd 2:0:0:106: [sdp] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.890085] sd 0:0:0:3: [sdd] Attached SCSI disk
[   75.890145] sd 2:0:0:102: [sdl] Write Protect is off
[   75.890148] sd 2:0:0:102: [sdl] Mode Sense: ef 00 00 08
[   75.890266] sd 2:0:0:103: [sdm] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.890281] sd 2:0:0:104: [sdn] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.890297]  sdh: unknown partition table
[   75.890373] sd 2:0:0:107: [sdq] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.890532] sd 2:0:0:102: [sdl] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.890728] sd 2:0:0:105: [sdo] Write Protect is off
[   75.890732] sd 2:0:0:105: [sdo] Mode Sense: ef 00 00 08
[   75.890743] sd 0:0:0:0: [sda] Attached SCSI disk
[   75.890909] sd 2:0:0:108: [sdr] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.891147] sd 2:0:0:110: [sdt] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.891207] sd 2:0:0:109: [sds] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.891260] sd 2:0:0:105: [sdo] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.891288] sd 2:0:0:106: [sdp] Write Protect is off
[   75.891291] sd 2:0:0:106: [sdp] Mode Sense: ef 00 00 08
[   75.891306] sd 2:0:0:107: [sdq] Write Protect is off
[   75.891309] sd 2:0:0:107: [sdq] Mode Sense: ef 00 00 08
[   75.891323] sd 0:0:1:3: [sdh] Attached SCSI disk
[   75.891477] sd 2:0:0:106: [sdp] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.891547] sd 2:0:0:107: [sdq] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.891551] sd 2:0:0:110: [sdt] Write Protect is off
[   75.891556] sd 2:0:0:110: [sdt] Mode Sense: ef 00 00 08
[   75.891669] sd 2:0:0:110: [sdt] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.891793] sd 2:0:0:104: [sdn] Write Protect is off
[   75.891796] sd 2:0:0:104: [sdn] Mode Sense: ef 00 00 08
[   75.892115] sd 2:0:0:108: [sdr] Write Protect is off
[   75.892118] sd 2:0:0:108: [sdr] Mode Sense: ef 00 00 08
[   75.892262] sd 2:0:0:111: [sdu] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.892273] sd 2:0:0:109: [sds] Write Protect is off
[   75.892277] sd 2:0:0:109: [sds] Mode Sense: ef 00 00 08
[   75.892524] sd 0:0:1:0: [sde] Attached SCSI disk
[   75.892551] sd 2:0:0:108: [sdr] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.892703] sd 2:0:0:104: [sdn] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.892713] sd 2:0:0:109: [sds] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.892960] sd 2:0:0:112: [sdv] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.893026] sd 2:0:0:111: [sdu] Write Protect is off
[   75.893030] sd 2:0:0:111: [sdu] Mode Sense: ef 00 00 08
[   75.893222] sd 2:0:0:113: [sdw] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.893391] sd 2:0:0:111: [sdu] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.893440] sd 2:0:0:114: [sdx] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.893718] sd 2:0:0:112: [sdv] Write Protect is off
[   75.893721] sd 2:0:0:112: [sdv] Mode Sense: ef 00 00 08
[   75.894066] sd 2:0:0:114: [sdx] Write Protect is off
[   75.894070] sd 2:0:0:112: [sdv] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.894075] sd 2:0:0:114: [sdx] Mode Sense: ef 00 00 08
[   75.894116] sd 2:0:0:113: [sdw] Write Protect is off
[   75.894120] sd 2:0:0:113: [sdw] Mode Sense: ef 00 00 08
[   75.894412] sd 2:0:0:114: [sdx] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.894580] sd 2:0:0:113: [sdw] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.896322] scsi 12:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   75.896325] scsi 13:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   75.896478] sd 2:0:0:115: [sdy] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.896847] sd 2:0:0:115: [sdy] Write Protect is off
[   75.896850] sd 2:0:0:115: [sdy] Mode Sense: ef 00 00 08
[   75.896998] sd 2:0:0:115: [sdy] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.898854] sd 2:0:0:116: [sdz] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.899077]  sdk: unknown partition table
[   75.899629] sd 2:0:0:116: [sdz] Write Protect is off
[   75.899633] sd 2:0:0:116: [sdz] Mode Sense: ef 00 00 08
[   75.900153] sd 2:0:0:116: [sdz] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.900185] scsi 13:0:0:0: alua: supports implicit TPGS
[   75.900196] scsi 12:0:1:0: alua: supports implicit TPGS
[   75.900377] scsi 12:0:1:0: alua: port group 00 rel port 01
[   75.900509] scsi 12:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   75.900512] scsi 13:0:0:0: alua: port group 01 rel port 05
[   75.900514] scsi 12:0:1:0: alua: Attached
[   75.900578] scsi 13:0:0:0: alua: port group 01 state A preferred supports tolusNA
[   75.900590] scsi 13:0:0:0: alua: Attached
[   75.900953] sd 2:0:0:118: [sdab] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.901413] sd 2:0:0:117: [sdaa] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.901647] sd 2:0:0:118: [sdab] Write Protect is off
[   75.901650] sd 2:0:0:118: [sdab] Mode Sense: ef 00 00 08
[   75.901705] sd 2:0:0:101: [sdk] Attached SCSI disk
[   75.901760] sd 2:0:0:118: [sdab] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.901768] sd 2:0:0:117: [sdaa] Write Protect is off
[   75.901770] sd 2:0:0:117: [sdaa] Mode Sense: ef 00 00 08
[   75.902025] sd 2:0:0:117: [sdaa] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.902068] sd 2:0:0:119: [sdac] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.902830] sd 2:0:1:0: [sdad] 136716288 512-byte logical blocks: (69.9 GB/65.1 GiB)
[   75.902857] sd 2:0:1:100: [sdae] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.902995] sd 2:0:0:119: [sdac] Write Protect is off
[   75.902998] sd 2:0:0:119: [sdac] Mode Sense: ef 00 00 08
[   75.903096] sd 2:0:1:101: [sdaf] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.903158] sd 2:0:0:119: [sdac] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.903431] sd 2:0:1:0: [sdad] Write Protect is off
[   75.903434] sd 2:0:1:0: [sdad] Mode Sense: ef 00 00 08
[   75.903887] sd 2:0:1:100: [sdae] Write Protect is off
[   75.903890] sd 2:0:1:100: [sdae] Mode Sense: ef 00 00 08
[   75.903931] sd 2:0:1:101: [sdaf] Write Protect is off
[   75.903932] sd 2:0:1:101: [sdaf] Mode Sense: ef 00 00 08
[   75.903954] sd 2:0:1:103: [sdah] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.904003] sd 2:0:1:0: [sdad] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.904051] sd 2:0:1:102: [sdag] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.904130] sd 2:0:1:101: [sdaf] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.904748] sd 2:0:1:100: [sdae] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.905031] sd 2:0:1:103: [sdah] Write Protect is off
[   75.905034] sd 2:0:1:103: [sdah] Mode Sense: ef 00 00 08
[   75.905286] sd 2:0:1:103: [sdah] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.905355] sd 2:0:1:105: [sdaj] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.905419] sd 2:0:1:102: [sdag] Write Protect is off
[   75.905425] sd 2:0:1:102: [sdag] Mode Sense: ef 00 00 08
[   75.905546] sd 2:0:1:106: [sdak] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.905866] sd 2:0:1:104: [sdai] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.905945] sd 2:0:1:102: [sdag] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.905993] sd 2:0:1:107: [sdal] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.906045]  sdp: unknown partition table
[   75.906648] sd 2:0:1:107: [sdal] Write Protect is off
[   75.906651] sd 2:0:1:107: [sdal] Mode Sense: ef 00 00 08
[   75.906735] sd 2:0:1:107: [sdal] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.906875]  sdaf: unknown partition table
[   75.907229] sd 2:0:1:109: [sdan] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.907898] sd 2:0:1:106: [sdak] Write Protect is off
[   75.907901] sd 2:0:1:106: [sdak] Mode Sense: ef 00 00 08
[   75.907920] sd 2:0:1:105: [sdaj] Write Protect is off
[   75.907922] sd 2:0:1:105: [sdaj] Mode Sense: ef 00 00 08
[   75.908137] sd 2:0:1:104: [sdai] Write Protect is off
[   75.908147] sd 2:0:1:104: [sdai] Mode Sense: ef 00 00 08
[   75.908168] sd 2:0:1:109: [sdan] Write Protect is off
[   75.908170] sd 2:0:1:109: [sdan] Mode Sense: ef 00 00 08
[   75.908172] sd 2:0:1:106: [sdak] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.908190] sd 2:0:1:108: [sdam] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.908366] sd 2:0:1:105: [sdaj] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.908569] sd 2:0:1:104: [sdai] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.908589] sd 2:0:1:109: [sdan] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.908714] sd 2:0:1:110: [sdao] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.909489] sd 2:0:1:108: [sdam] Write Protect is off
[   75.909492] sd 2:0:1:108: [sdam] Mode Sense: ef 00 00 08
[   75.909514] sd 2:0:1:110: [sdao] Write Protect is off
[   75.909516] sd 2:0:1:110: [sdao] Mode Sense: ef 00 00 08
[   75.909918] sd 2:0:1:108: [sdam] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.909932] sd 2:0:1:110: [sdao] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.909981] sd 2:0:0:106: [sdp] Attached SCSI disk
[   75.910214] sd 2:0:1:112: [sdaq] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.910551] sd 2:0:1:112: [sdaq] Write Protect is off
[   75.910555] sd 2:0:1:112: [sdaq] Mode Sense: ef 00 00 08
[   75.910740] sd 2:0:1:113: [sdar] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.910805] sd 2:0:1:112: [sdaq] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.910931] sd 2:0:1:111: [sdap] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.911773] sd 2:0:1:113: [sdar] Write Protect is off
[   75.911777] sd 2:0:1:114: [sdas] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.911780] sd 2:0:1:113: [sdar] Mode Sense: ef 00 00 08
[   75.912052] sd 2:0:1:111: [sdap] Write Protect is off
[   75.912055] sd 2:0:1:111: [sdap] Mode Sense: ef 00 00 08
[   75.912185] sd 2:0:1:113: [sdar] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.912467] sd 2:0:1:111: [sdap] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.912673] sd 2:0:1:114: [sdas] Write Protect is off
[   75.912680] sd 2:0:1:114: [sdas] Mode Sense: ef 00 00 08
[   75.912737]  sdc: sdc1 sdc2 sdc3
[   75.912907]  sdg: sdg1 sdg2 sdg3
[   75.913136]  sdf: sdf1 sdf2 sdf3
[   75.913529]  sdb: sdb1 sdb2 sdb3
[   75.914266] sd 2:0:1:101: [sdaf] Attached SCSI disk
[   75.914311] sd 2:0:1:114: [sdas] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.915596] sd 2:0:1:115: [sdat] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.915881]  sdak: unknown partition table
[   75.916268] sd 2:0:1:115: [sdat] Write Protect is off
[   75.916271] sd 2:0:1:115: [sdat] Mode Sense: ef 00 00 08
[   75.916685] sd 2:0:1:115: [sdat] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.923528]  sdad: sdad1 sdad2 sdad3
[   75.923605]  sdi: sdi1 sdi2 sdi3
[   75.929871] sd 2:0:1:116: [sdau] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.930653] sd 2:0:1:116: [sdau] Write Protect is off
[   75.930656] sd 2:0:1:116: [sdau] Mode Sense: ef 00 00 08
[   75.931033] sd 2:0:1:116: [sdau] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.931051] sd 2:0:1:106: [sdak] Attached SCSI disk
[   75.931244]  sdae: unknown partition table
[   75.931267]  sdj: unknown partition table
[   75.931351]  sdag: unknown partition table
[   75.931446]  sdl: unknown partition table
[   75.931476]  sdah: unknown partition table
[   75.931536]  sdm: unknown partition table
[   75.931561]  sdai: unknown partition table
[   75.931635]  sdaj: unknown partition table
[   75.931685]  sdal: unknown partition table
[   75.931769]  sdo: unknown partition table
[   75.931806]  sdq: unknown partition table
[   75.931916]  sdan: unknown partition table
[   75.931919]  sdr: unknown partition table
[   75.932015]  sds: unknown partition table
[   75.932072]  sdt: unknown partition table
[   75.932109]  sdaq: unknown partition table
[   75.932163]  sdao: unknown partition table
[   75.932234]  sdv: unknown partition table
[   75.932390]  sdam: unknown partition table
[   75.932529]  sdn: unknown partition table
[   75.932727]  sdas: unknown partition table
[   75.932877]  sdy: unknown partition table
[   75.932966]  sdz: unknown partition table
[   75.933275]  sdu: unknown partition table
[   75.933353]  sdap: unknown partition table
[   75.933496]  sdx: unknown partition table
[   75.933499]  sdab: unknown partition table
[   75.934253]  sdac: unknown partition table
[   75.935028]  sdar: unknown partition table
[   75.935075]  sdw: unknown partition table
[   75.935535]  sdaa: unknown partition table
[   75.936858] sd 2:0:1:117: [sdav] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.937539] sd 2:0:1:117: [sdav] Write Protect is off
[   75.937542] sd 2:0:1:117: [sdav] Mode Sense: ef 00 00 08
[   75.937556]  sdat: unknown partition table
[   75.937976] sd 2:0:1:117: [sdav] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.939220] sd 2:0:0:115: [sdy] Attached SCSI disk
[   75.940454] sd 2:0:1:113: [sdar] Attached SCSI disk
[   75.941619] sd 2:0:0:108: [sdr] Attached SCSI disk
[   75.941623] sd 2:0:1:102: [sdag] Attached SCSI disk
[   75.941761] sd 2:0:1:109: [sdan] Attached SCSI disk
[   75.944836] sd 2:0:1:105: [sdaj] Attached SCSI disk
[   75.945270] sd 2:0:1:118: [sdaw] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.945781] sd 2:0:0:107: [sdq] Attached SCSI disk
[   75.946253] sd 2:0:1:118: [sdaw] Write Protect is off
[   75.946257] sd 2:0:1:118: [sdaw] Mode Sense: ef 00 00 08
[   75.946791] sd 2:0:1:118: [sdaw] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.946812] sd 2:0:0:114: [sdx] Attached SCSI disk
[   75.946843] sd 2:0:1:104: [sdai] Attached SCSI disk
[   75.947107] sd 2:0:1:107: [sdal] Attached SCSI disk
[   75.947116] sd 2:0:0:102: [sdl] Attached SCSI disk
[   75.947371] sd 2:0:0:104: [sdn] Attached SCSI disk
[   75.947598] sd 2:0:0:109: [sds] Attached SCSI disk
[   75.947604] sd 2:0:0:116: [sdz] Attached SCSI disk
[   75.948026] sd 2:0:0:103: [sdm] Attached SCSI disk
[   75.948037] sd 2:0:0:113: [sdw] Attached SCSI disk
[   75.950375] sd 2:0:1:100: [sdae] Attached SCSI disk
[   75.950386] sd 2:0:0:111: [sdu] Attached SCSI disk
[   75.950390] sd 2:0:1:112: [sdaq] Attached SCSI disk
[   75.950583] sd 0:0:0:1: [sdb] Attached SCSI disk
[   75.951577] sd 2:0:0:119: [sdac] Attached SCSI disk
[   75.951826] sd 2:0:1:119: [sdax] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[   75.952005] sd 2:0:0:117: [sdaa] Attached SCSI disk
[   75.952015] sd 2:0:0:110: [sdt] Attached SCSI disk
[   75.952557] sd 2:0:1:119: [sdax] Write Protect is off
[   75.952559] sd 2:0:1:119: [sdax] Mode Sense: ef 00 00 08
[   75.952915] sd 2:0:1:119: [sdax] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   75.953332] sd 2:0:1:115: [sdat] Attached SCSI disk
[   75.954041] sd 2:0:0:118: [sdab] Attached SCSI disk
[   75.954060] sd 2:0:0:105: [sdo] Attached SCSI disk
[   75.954575] sd 2:0:1:110: [sdao] Attached SCSI disk
[   75.954605] sd 2:0:1:114: [sdas] Attached SCSI disk
[   75.955197]  sdav: unknown partition table
[   75.965186] sd 2:0:0:112: [sdv] Attached SCSI disk
[   75.965411] sd 2:0:1:103: [sdah] Attached SCSI disk
[   75.965614] sd 0:0:0:2: [sdc] Attached SCSI disk
[   75.966349] sd 2:0:1:117: [sdav] Attached SCSI disk
[   75.966941] sd 0:0:1:1: [sdf] Attached SCSI disk
[   75.968094] sd 2:0:1:111: [sdap] Attached SCSI disk
[   75.968344]  sdau: unknown partition table
[   75.969066] sd 0:0:1:2: [sdg] Attached SCSI disk
[   75.971209] sd 2:0:1:108: [sdam] Attached SCSI disk
[   75.974408] sd 2:0:0:0: [sdi] Attached SCSI disk
[   75.976084] sd 2:0:0:100: [sdj] Attached SCSI disk
[   75.978531]  sdax: unknown partition table
[   75.980499] sd 2:0:1:116: [sdau] Attached SCSI disk
[   75.980644] sd 2:0:1:0: [sdad] Attached SCSI disk
[   75.980662]  sdaw: unknown partition table
[   75.981961] sd 2:0:1:119: [sdax] Attached SCSI disk
[   75.982156] sd 2:0:1:118: [sdaw] Attached SCSI disk
[   76.156881] device-mapper: multipath service-time: version 0.2.0 loaded
[   76.158899] bio: create slab <bio-1> at 1
[   76.252981] scsi: waiting for bus probes to complete ...
[   76.483585] qla2xxx [0000:f3:00.1]-505f:15: Link is operational (8 Gbps).
[   76.502707] scsi: waiting for bus probes to complete ...
[   76.709800] bio: create slab <bio-0> at 0
[   76.754787] bio: create slab <bio-0> at 0
[   76.815618] bio: create slab <bio-0> at 0
[   76.831269] bio: create slab <bio-0> at 0
[   76.847459] bio: create slab <bio-0> at 0
[   76.932435] bio: create slab <bio-0> at 0
[   77.118939] scsi 13:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   77.119289] scsi 13:0:1:0: alua: supports implicit TPGS
[   77.119981] scsi 14:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   77.120327] scsi 13:0:1:0: alua: port group 00 rel port 01
[   77.120390] scsi 14:0:0:0: alua: supports implicit TPGS
[   77.120705] scsi 13:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   77.120708] scsi 13:0:1:0: alua: Attached
[   77.122419] scsi 14:0:0:0: alua: port group 01 rel port 05
[   77.123690] scsi 14:0:0:0: alua: port group 01 state A preferred supports tolusNA
[   77.123693] scsi 14:0:0:0: alua: Attached
[   77.127628] scsi 14:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   77.127696] scsi 14:0:1:0: alua: supports implicit TPGS
[   77.129132] scsi 14:0:1:0: alua: port group 00 rel port 01
[   77.129500] scsi 14:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   77.129502] scsi 14:0:1:0: alua: Attached
[   77.733411] scsi 15:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   77.733581] scsi 15:0:0:0: alua: supports implicit TPGS
[   77.734092] scsi 15:0:0:0: alua: port group 01 rel port 05
[   77.734550] scsi 15:0:0:0: alua: port group 01 state A preferred supports tolusNA
[   77.734552] scsi 15:0:0:0: alua: Attached
[   78.018134] bio: create slab <bio-0> at 0
[   78.736289] scsi 15:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[   78.736404] scsi 15:0:1:0: alua: supports implicit TPGS
[   78.738446] scsi 15:0:1:0: alua: port group 00 rel port 01
[   78.739007] scsi 15:0:1:0: alua: port group 00 state A preferred supports tolusNA
[   78.739010] scsi 15:0:1:0: alua: Attached
[   78.782608] SGI XFS with ACLs, security attributes, large block/inode numbers, no debug enabled
[   78.848544] XFS (dm-37): Mounting Filesystem
[   78.901530] XFS (dm-37): Starting recovery (logdev: internal)
[   79.123024] XFS (dm-37): Ending recovery (logdev: internal)
[   79.890380] systemd-journald[3645]: Received SIGTERM
[   80.145050] SELinux:  Disabled at runtime.
[   80.145106] SELinux:  Unregistering netfilter hooks
[   80.228804] type=1404 audit(1427268723.337:2): selinux=0 auid=4294967295 ses=4294967295
[   81.118403] systemd-journald[5609]: Vacuuming done, freed 0 bytes
[   81.231552] systemd-udevd[5650]: starting version 208
[   81.382297] bio: create slab <bio-0> at 0
[   81.397854] bio: create slab <bio-0> at 0
[   81.411749] bio: create slab <bio-0> at 0
[   81.416084] bio: create slab <bio-0> at 0
[   81.431603] bio: create slab <bio-0> at 0
[   81.449429] bio: create slab <bio-0> at 0
[   81.457040] bio: create slab <bio-0> at 0
[   81.472979] bio: create slab <bio-0> at 0
[   81.485538] bio: create slab <bio-0> at 0
[   81.537978] xor: automatically using best checksumming function:
[   81.548015]    avx       : 20720.000 MB/sec
[   81.584064] raid6: sse2x1    5425 MB/s
[   81.601093] raid6: sse2x2    8234 MB/s
[   81.618116] raid6: sse2x4    9218 MB/s
[   81.618121] raid6: using algorithm sse2x4 (9218 MB/s)
[   81.618126] raid6: using ssse3x2 recovery algorithm
[   81.644268] XFS (dm-15): Mounting Filesystem
[   81.666209] bio: create slab <bio-0> at 0
[   81.674866] Btrfs loaded
[   81.681051] btrfs: device fsid e15e7b18-bed6-4fad-ba82-c7a2cf0d6f3b devid 1 transid 9906 /dev/dm-22
[   81.695679] XFS (dm-15): Starting recovery (logdev: internal)
[   81.749272] XFS (dm-15): Ending recovery (logdev: internal)
[   81.808102] FAT-fs (dm-14): Volume was not properly unmounted. Some data may be corrupt. Please run fsck.
[   82.258770] bio: create slab <bio-2> at 2
[   82.363576] ipmi message handler version 39.2
[   82.384271] IPMI System Interface driver.
[   82.385728] ipmi_si: probing via ACPI
[   82.385749] ipmi_si 00:01: [mem 0xfe062110000-0xfe062110002] regsize 1 spacing 1 irq 20
[   82.385751] ipmi_si: Adding ACPI-specified bt state machine
[   82.385831] ipmi_si: probing via SPMI
[   82.385833] ipmi_si: SPMI: mem 0xfe062110000 regsize 1 spacing 1 irq 20
[   82.385835] ipmi_si: Adding SPMI-specified bt state machine duplicate interface
[   82.385837] ipmi_si: Trying ACPI-specified bt state machine at mem address 0xfe062110000, slave address 0x0, irq 20
[   82.391227] ipmi_si 00:01: Using irq 20
[   82.398781] XFS (dm-40): Mounting Filesystem
[   82.422283] IPMI BT: req2rsp=6 secs retries=16
[   82.430946] ipmi_si 00:01: Found new BMC (man_id: 0x00000b, prod_id: 0x1002, dev_id: 0x40)
[   82.430979] ipmi_si 00:01: IPMI bt interface initialized
[   82.474561] XFS (dm-40): Starting recovery (logdev: internal)
[   82.633855] XFS (dm-40): Ending recovery (logdev: internal)
[   82.660985] systemd-journald[5609]: Received request to flush runtime journal from PID 1
[   82.691419] type=1305 audit(1427268725.796:3): audit_pid=6223 old=0 auid=4294967295 ses=4294967295 res=1
[   82.960889] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[   82.964074] dca service started, version 1.12.1
[   82.969033] EDAC MC: Ver: 3.0.0
[   83.037363] lpc_ich 0000:20:1f.0: I/O space for ACPI uninitialized
[   83.037371] lpc_ich 0000:20:1f.0: I/O space for ACPI uninitialized
[   83.037375] lpc_ich 0000:20:1f.0: I/O space for GPIO uninitialized
[   83.037376] lpc_ich 0000:20:1f.0: No MFD cells added
[   83.037501] lpc_ich 0000:40:1f.0: I/O space for ACPI uninitialized
[   83.037508] lpc_ich 0000:40:1f.0: I/O space for ACPI uninitialized
[   83.037511] lpc_ich 0000:40:1f.0: I/O space for GPIO uninitialized
[   83.037513] lpc_ich 0000:40:1f.0: No MFD cells added
[   83.037844] lpc_ich 0000:60:1f.0: I/O space for ACPI uninitialized
[   83.037852] lpc_ich 0000:60:1f.0: I/O space for ACPI uninitialized
[   83.037855] lpc_ich 0000:60:1f.0: I/O space for GPIO uninitialized
[   83.037857] lpc_ich 0000:60:1f.0: No MFD cells added
[   83.038044] lpc_ich 0000:84:1f.0: I/O space for ACPI uninitialized
[   83.038052] lpc_ich 0000:84:1f.0: I/O space for ACPI uninitialized
[   83.038056] lpc_ich 0000:84:1f.0: I/O space for GPIO uninitialized
[   83.038057] lpc_ich 0000:84:1f.0: No MFD cells added
[   83.038241] lpc_ich 0000:a0:1f.0: I/O space for ACPI uninitialized
[   83.038249] lpc_ich 0000:a0:1f.0: I/O space for ACPI uninitialized
[   83.038257] lpc_ich 0000:a0:1f.0: I/O space for GPIO uninitialized
[   83.038259] lpc_ich 0000:a0:1f.0: No MFD cells added
[   83.038393] lpc_ich 0000:c0:1f.0: I/O space for ACPI uninitialized
[   83.038400] lpc_ich 0000:c0:1f.0: I/O space for ACPI uninitialized
[   83.038404] lpc_ich 0000:c0:1f.0: I/O space for GPIO uninitialized
[   83.038406] lpc_ich 0000:c0:1f.0: No MFD cells added
[   83.038689] lpc_ich 0000:e0:1f.0: I/O space for ACPI uninitialized
[   83.038701] lpc_ich 0000:e0:1f.0: I/O space for ACPI uninitialized
[   83.038704] lpc_ich 0000:e0:1f.0: I/O space for GPIO uninitialized
[   83.038706] lpc_ich 0000:e0:1f.0: No MFD cells added
[   83.050951] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.050986] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.050999] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.051012] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.051024] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.051038] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.051050] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.051061] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.051074] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.051089] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.051104] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.051121] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.051136] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.051164] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.051178] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.051215] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.051244] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:0ea0
[   83.051261] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051282] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051288] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051294] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051301] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051307] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051313] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051319] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051325] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051330] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051336] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051342] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051347] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051357] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051362] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051368] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051384] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:0ea8
[   83.051405] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051419] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051425] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051431] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051437] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051443] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051449] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051454] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051459] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051464] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051470] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051485] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051490] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051497] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051508] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051525] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051531] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:0e71
[   83.051537] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051550] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051555] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051569] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051584] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051602] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051612] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051617] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051623] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051628] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051639] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051644] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051650] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051657] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051663] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051669] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051674] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:0eaa
[   83.051677] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051695] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051701] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051706] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051712] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051718] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051723] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051728] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051734] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051739] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051750] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051760] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051767] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051783] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051792] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051804] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051809] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:0eab
[   83.051811] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051823] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051829] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051835] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051850] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051864] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051893] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051904] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051909] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051913] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051918] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051923] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051933] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051939] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051944] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051949] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051963] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:0eac
[   83.051967] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.051984] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.051990] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.051995] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.052001] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.052006] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.052011] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.052017] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.052022] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.052028] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.052033] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.052038] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.052043] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.052048] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.052053] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.052059] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.052064] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:0ead
[   83.052067] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052080] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052084] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052091] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052096] ioatdma: Intel(R) QuickData Technology Driver 4.00
[   83.052110] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052115] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052121] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052126] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052131] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052136] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052141] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052147] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052156] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052162] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052167] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052172] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052177] EDAC sbridge: Seeking for: dev 16.0 PCI ID 8086:0ec8
[   83.052179] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052192] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052197] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052203] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052208] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052213] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052218] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052224] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052229] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052234] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052240] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052245] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052278] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052284] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052290] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052295] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052301] EDAC sbridge: Seeking for: dev 16.1 PCI ID 8086:0ec9
[   83.052302] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052316] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052322] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052331] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052336] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052341] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052347] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052352] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052357] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052363] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052368] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052373] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052389] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052401] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052406] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052411] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052417] EDAC sbridge: Seeking for: dev 16.2 PCI ID 8086:0eca
[   83.052419] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052433] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052439] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052454] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052459] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052466] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052472] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052485] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052497] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052504] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052528] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052534] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052542] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052547] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052563] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052569] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052599] EDAC sbridge: Seeking for: dev 1c.0 PCI ID 8086:0e60
[   83.052601] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052614] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052620] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052626] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052631] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052636] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052645] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052650] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052655] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052661] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052666] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052672] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052678] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052684] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052689] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052695] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052700] EDAC sbridge: Seeking for: dev 1d.2 PCI ID 8086:0e6a
[   83.052702] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052715] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052721] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052726] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052731] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052737] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052742] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052747] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052755] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052763] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052769] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052777] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052784] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052794] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052803] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052808] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052815] EDAC sbridge: Seeking for: dev 1d.3 PCI ID 8086:0e6b
[   83.052816] EDAC sbridge: Seeking for: dev 11.0 PCI ID 8086:0eb8
[   83.052861] EDAC sbridge: Seeking for: dev 11.4 PCI ID 8086:0ebc
[   83.055332] ioatdma 0000:00:04.0: irq 704 for MSI/MSI-X
[   83.059751] EDAC MC0: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#0': DEV 0000:0f:0e.0
[   83.061600] ioatdma 0000:00:04.1: irq 705 for MSI/MSI-X
[   83.062562] pps_core: LinuxPPS API ver. 1 registered
[   83.062565] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[   83.070754] hpwdt 0000:07:00.0: HP Watchdog Timer Driver: NMI decoding initialized, allow kernel dump: ON (default = 0/OFF)
[   83.072593] ioatdma 0000:00:04.2: irq 706 for MSI/MSI-X
[   83.077582] hpwdt 0000:07:00.0: HP Watchdog Timer Driver: 1.3.2, timer margin: 30 seconds (nowayout=0).
[   83.084356] PTP clock support registered
[   83.084939] ioatdma 0000:00:04.3: irq 707 for MSI/MSI-X
[   83.092491] ioatdma 0000:00:04.4: irq 708 for MSI/MSI-X
[   83.094719] EDAC MC1: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#1': DEV 0000:1f:0e.0
[   83.102290] ioatdma 0000:00:04.5: irq 709 for MSI/MSI-X
[   83.106567] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.15.1-k
[   83.106570] ixgbe: Copyright (c) 1999-2013 Intel Corporation.
[   83.117019] ioatdma 0000:00:04.6: irq 710 for MSI/MSI-X
[   83.117391] EDAC MC2: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#2': DEV 0000:2f:0e.0
[   83.117602] EDAC MC3: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#3': DEV 0000:3f:0e.0
[   83.117777] EDAC MC4: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#4': DEV 0000:4f:0e.0
[   83.117945] EDAC MC5: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#5': DEV 0000:5f:0e.0
[   83.118130] EDAC MC6: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#6': DEV 0000:6f:0e.0
[   83.118276] EDAC MC7: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#7': DEV 0000:7b:0e.0
[   83.118496] EDAC MC8: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#8': DEV 0000:8f:0e.0
[   83.118652] EDAC MC9: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#9': DEV 0000:9f:0e.0
[   83.118828] EDAC MC10: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#10': DEV 0000:af:0e.0
[   83.118990] EDAC MC11: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#11': DEV 0000:bf:0e.0
[   83.119159] EDAC MC12: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#12': DEV 0000:cf:0e.0
[   83.119343] EDAC MC13: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#13': DEV 0000:df:0e.0
[   83.119507] EDAC MC14: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#14': DEV 0000:ef:0e.0
[   83.119687] EDAC MC15: Giving out device to 'sbridge_edac.c' 'Ivy Bridge Socket#15': DEV 0000:ff:0e.0
[   83.119688] EDAC sbridge: Driver loaded.
[   83.130880] ioatdma 0000:00:04.7: irq 711 for MSI/MSI-X
[   83.141773] ioatdma 0000:10:04.0: irq 712 for MSI/MSI-X
[   83.145414] ses 1:0:0:0: Attached Enclosure device
[   83.145542] ses 1:0:1:0: Attached Enclosure device
[   83.146053] ses 3:0:0:0: Attached Enclosure device
[   83.146100] ioatdma 0000:10:04.1: irq 713 for MSI/MSI-X
[   83.146515] ses 3:0:1:0: Attached Enclosure device
[   83.146643] ses 4:0:0:0: Attached Enclosure device
[   83.146754] ses 5:0:0:0: Attached Enclosure device
[   83.146996] ses 4:0:1:0: Attached Enclosure device
[   83.147419] ses 5:0:1:0: Attached Enclosure device
[   83.147615] ses 6:0:0:0: Attached Enclosure device
[   83.148450] ses 7:0:0:0: Attached Enclosure device
[   83.148647] ses 6:0:1:0: Attached Enclosure device
[   83.149509] ses 7:0:1:0: Attached Enclosure device
[   83.149547] ses 8:0:0:0: Attached Enclosure device
[   83.149583] ses 8:0:1:0: Attached Enclosure device
[   83.149894] ses 9:0:0:0: Attached Enclosure device
[   83.150398] ses 10:0:0:0: Attached Enclosure device
[   83.150737] ses 9:0:1:0: Attached Enclosure device
[   83.151358] ses 11:0:0:0: Attached Enclosure device
[   83.151405] ses 10:0:1:0: Attached Enclosure device
[   83.151460] ses 11:0:1:0: Attached Enclosure device
[   83.151633] ses 12:0:0:0: Attached Enclosure device
[   83.151693] ses 12:0:1:0: Attached Enclosure device
[   83.151759] ses 13:0:0:0: Attached Enclosure device
[   83.151869] ses 13:0:1:0: Attached Enclosure device
[   83.152117] ioatdma 0000:10:04.2: irq 714 for MSI/MSI-X
[   83.153198] ses 14:0:0:0: Attached Enclosure device
[   83.153703] ses 14:0:1:0: Attached Enclosure device
[   83.153743] ses 15:0:0:0: Attached Enclosure device
[   83.153819] ses 15:0:1:0: Attached Enclosure device
[   83.157935] ioatdma 0000:10:04.3: irq 715 for MSI/MSI-X
[   83.161748] ioatdma 0000:10:04.4: irq 716 for MSI/MSI-X
[   83.164069] ioatdma 0000:10:04.5: irq 717 for MSI/MSI-X
[   83.166776] ioatdma 0000:10:04.6: irq 718 for MSI/MSI-X
[   83.168683] ioatdma 0000:10:04.7: irq 719 for MSI/MSI-X
[   83.173282] ioatdma 0000:20:04.0: irq 720 for MSI/MSI-X
[   83.177127] ioatdma 0000:20:04.1: irq 721 for MSI/MSI-X
[   83.179172] ioatdma 0000:20:04.2: irq 722 for MSI/MSI-X
[   83.180896] ioatdma 0000:20:04.3: irq 723 for MSI/MSI-X
[   83.184970] ioatdma 0000:20:04.4: irq 724 for MSI/MSI-X
[   83.186715] ioatdma 0000:20:04.5: irq 725 for MSI/MSI-X
[   83.189022] ioatdma 0000:20:04.6: irq 726 for MSI/MSI-X
[   83.192050] ioatdma 0000:20:04.7: irq 727 for MSI/MSI-X
[   83.195731] ioatdma 0000:30:04.0: irq 728 for MSI/MSI-X
[   83.199029] ioatdma 0000:30:04.1: irq 729 for MSI/MSI-X
[   83.201267] ioatdma 0000:30:04.2: irq 730 for MSI/MSI-X
[   83.202768] ioatdma 0000:30:04.3: irq 731 for MSI/MSI-X
[   83.206258] ioatdma 0000:30:04.4: irq 732 for MSI/MSI-X
[   83.206771] ixgbe 0000:01:00.0: irq 733 for MSI/MSI-X
[   83.206804] ixgbe 0000:01:00.0: irq 734 for MSI/MSI-X
[   83.206836] ixgbe 0000:01:00.0: irq 735 for MSI/MSI-X
[   83.206867] ixgbe 0000:01:00.0: irq 736 for MSI/MSI-X
[   83.206903] ixgbe 0000:01:00.0: irq 737 for MSI/MSI-X
[   83.207123] ixgbe 0000:01:00.0: irq 738 for MSI/MSI-X
[   83.207155] ixgbe 0000:01:00.0: irq 739 for MSI/MSI-X
[   83.207187] ixgbe 0000:01:00.0: irq 740 for MSI/MSI-X
[   83.207232] ixgbe 0000:01:00.0: irq 741 for MSI/MSI-X
[   83.207266] ixgbe 0000:01:00.0: irq 742 for MSI/MSI-X
[   83.207301] ixgbe 0000:01:00.0: irq 743 for MSI/MSI-X
[   83.207335] ixgbe 0000:01:00.0: irq 744 for MSI/MSI-X
[   83.207675] ixgbe 0000:01:00.0: irq 745 for MSI/MSI-X
[   83.207715] ixgbe 0000:01:00.0: irq 746 for MSI/MSI-X
[   83.207746] ixgbe 0000:01:00.0: irq 747 for MSI/MSI-X
[   83.207776] ixgbe 0000:01:00.0: irq 748 for MSI/MSI-X
[   83.207806] ixgbe 0000:01:00.0: irq 749 for MSI/MSI-X
[   83.207996] ixgbe 0000:01:00.0: irq 750 for MSI/MSI-X
[   83.208028] ixgbe 0000:01:00.0: irq 751 for MSI/MSI-X
[   83.208058] ixgbe 0000:01:00.0: irq 752 for MSI/MSI-X
[   83.208099] ixgbe 0000:01:00.0: irq 753 for MSI/MSI-X
[   83.208135] ixgbe 0000:01:00.0: irq 754 for MSI/MSI-X
[   83.208166] ixgbe 0000:01:00.0: irq 755 for MSI/MSI-X
[   83.208195] ixgbe 0000:01:00.0: irq 756 for MSI/MSI-X
[   83.208225] ixgbe 0000:01:00.0: irq 757 for MSI/MSI-X
[   83.208255] ixgbe 0000:01:00.0: irq 758 for MSI/MSI-X
[   83.208285] ixgbe 0000:01:00.0: irq 759 for MSI/MSI-X
[   83.208315] ixgbe 0000:01:00.0: irq 760 for MSI/MSI-X
[   83.208345] ixgbe 0000:01:00.0: irq 761 for MSI/MSI-X
[   83.208426] ixgbe 0000:01:00.0: irq 762 for MSI/MSI-X
[   83.208457] ixgbe 0000:01:00.0: irq 763 for MSI/MSI-X
[   83.208487] ixgbe 0000:01:00.0: irq 764 for MSI/MSI-X
[   83.208517] ixgbe 0000:01:00.0: irq 765 for MSI/MSI-X
[   83.208717] ixgbe 0000:01:00.0: irq 766 for MSI/MSI-X
[   83.208748] ixgbe 0000:01:00.0: irq 767 for MSI/MSI-X
[   83.208779] ixgbe 0000:01:00.0: irq 768 for MSI/MSI-X
[   83.208811] ixgbe 0000:01:00.0: irq 769 for MSI/MSI-X
[   83.208849] ixgbe 0000:01:00.0: irq 770 for MSI/MSI-X
[   83.208887] ixgbe 0000:01:00.0: irq 771 for MSI/MSI-X
[   83.208918] ixgbe 0000:01:00.0: irq 772 for MSI/MSI-X
[   83.208960] ixgbe 0000:01:00.0: irq 773 for MSI/MSI-X
[   83.209004] ixgbe 0000:01:00.0: irq 774 for MSI/MSI-X
[   83.209034] ixgbe 0000:01:00.0: irq 775 for MSI/MSI-X
[   83.209066] ixgbe 0000:01:00.0: irq 776 for MSI/MSI-X
[   83.209110] ixgbe 0000:01:00.0: irq 777 for MSI/MSI-X
[   83.209147] ixgbe 0000:01:00.0: irq 778 for MSI/MSI-X
[   83.209177] ixgbe 0000:01:00.0: irq 779 for MSI/MSI-X
[   83.209207] ixgbe 0000:01:00.0: irq 780 for MSI/MSI-X
[   83.209251] ixgbe 0000:01:00.0: irq 781 for MSI/MSI-X
[   83.209450] ixgbe 0000:01:00.0: irq 782 for MSI/MSI-X
[   83.209481] ixgbe 0000:01:00.0: irq 783 for MSI/MSI-X
[   83.209512] ixgbe 0000:01:00.0: irq 784 for MSI/MSI-X
[   83.209543] ixgbe 0000:01:00.0: irq 785 for MSI/MSI-X
[   83.209579] ixgbe 0000:01:00.0: irq 786 for MSI/MSI-X
[   83.209610] ixgbe 0000:01:00.0: irq 787 for MSI/MSI-X
[   83.209640] ixgbe 0000:01:00.0: irq 788 for MSI/MSI-X
[   83.209686] ixgbe 0000:01:00.0: irq 789 for MSI/MSI-X
[   83.209716] ixgbe 0000:01:00.0: irq 790 for MSI/MSI-X
[   83.209747] ixgbe 0000:01:00.0: irq 791 for MSI/MSI-X
[   83.209777] ixgbe 0000:01:00.0: irq 792 for MSI/MSI-X
[   83.209808] ixgbe 0000:01:00.0: irq 793 for MSI/MSI-X
[   83.209883] ixgbe 0000:01:00.0: irq 794 for MSI/MSI-X
[   83.209914] ixgbe 0000:01:00.0: irq 795 for MSI/MSI-X
[   83.209945] ixgbe 0000:01:00.0: irq 796 for MSI/MSI-X
[   83.212952] ioatdma 0000:30:04.5: irq 797 for MSI/MSI-X
[   83.218373] ioatdma 0000:30:04.6: irq 798 for MSI/MSI-X
[   83.235143] ioatdma 0000:30:04.7: irq 799 for MSI/MSI-X
[   83.242720] ixgbe 0000:01:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   83.242857] ixgbe 0000:01:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:91:1b:74
[   83.243191] ixgbe 0000:01:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[   83.243196] ixgbe 0000:01:00.0: PCI Express bandwidth of 32GT/s available
[   83.243198] ixgbe 0000:01:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   83.245014] ioatdma 0000:40:04.0: irq 800 for MSI/MSI-X
[   83.254307] ioatdma 0000:40:04.1: irq 801 for MSI/MSI-X
[   83.265441] ioatdma 0000:40:04.2: irq 802 for MSI/MSI-X
[   83.270101] ioatdma 0000:40:04.3: irq 803 for MSI/MSI-X
[   83.276704] ioatdma 0000:40:04.4: irq 804 for MSI/MSI-X
[   83.283081] ioatdma 0000:40:04.5: irq 805 for MSI/MSI-X
[   83.284996] ioatdma 0000:40:04.6: irq 806 for MSI/MSI-X
[   83.288765] ioatdma 0000:40:04.7: irq 807 for MSI/MSI-X
[   83.294752] ioatdma 0000:50:04.0: irq 808 for MSI/MSI-X
[   83.299625] ioatdma 0000:50:04.1: irq 809 for MSI/MSI-X
[   83.305155] ioatdma 0000:50:04.2: irq 810 for MSI/MSI-X
[   83.310231] ioatdma 0000:50:04.3: irq 811 for MSI/MSI-X
[   83.314898] ioatdma 0000:50:04.4: irq 812 for MSI/MSI-X
[   83.319266] ioatdma 0000:50:04.5: irq 813 for MSI/MSI-X
[   83.323863] ioatdma 0000:50:04.6: irq 814 for MSI/MSI-X
[   83.328279] ioatdma 0000:50:04.7: irq 815 for MSI/MSI-X
[   83.336192] ioatdma 0000:60:04.0: irq 816 for MSI/MSI-X
[   83.345454] ioatdma 0000:60:04.1: irq 817 for MSI/MSI-X
[   83.346975] ixgbe 0000:01:00.0: Intel(R) 10 Gigabit Network Connection
[   83.350006] ioatdma 0000:60:04.2: irq 818 for MSI/MSI-X
[   83.354938] ioatdma 0000:60:04.3: irq 819 for MSI/MSI-X
[   83.360247] ioatdma 0000:60:04.4: irq 820 for MSI/MSI-X
[   83.365425] ioatdma 0000:60:04.5: irq 821 for MSI/MSI-X
[   83.371674] ioatdma 0000:60:04.6: irq 822 for MSI/MSI-X
[   83.376741] ioatdma 0000:60:04.7: irq 823 for MSI/MSI-X
[   83.381041] ioatdma 0000:70:04.0: irq 824 for MSI/MSI-X
[   83.387451] ioatdma 0000:70:04.1: irq 825 for MSI/MSI-X
[   83.391791] ioatdma 0000:70:04.2: irq 826 for MSI/MSI-X
[   83.395751] ioatdma 0000:70:04.3: irq 827 for MSI/MSI-X
[   83.398122] ioatdma 0000:70:04.4: irq 828 for MSI/MSI-X
[   83.406884] ioatdma 0000:70:04.5: irq 829 for MSI/MSI-X
[   83.410354] ioatdma 0000:70:04.6: irq 830 for MSI/MSI-X
[   83.415716] ioatdma 0000:70:04.7: irq 831 for MSI/MSI-X
[   83.421292] ioatdma 0000:84:04.0: irq 832 for MSI/MSI-X
[   83.426143] ioatdma 0000:84:04.1: irq 833 for MSI/MSI-X
[   83.434185] ioatdma 0000:84:04.2: irq 834 for MSI/MSI-X
[   83.440647] ioatdma 0000:84:04.3: irq 835 for MSI/MSI-X
[   83.441980] ixgbe 0000:01:00.1: irq 836 for MSI/MSI-X
[   83.442017] ixgbe 0000:01:00.1: irq 837 for MSI/MSI-X
[   83.442250] ixgbe 0000:01:00.1: irq 838 for MSI/MSI-X
[   83.442280] ixgbe 0000:01:00.1: irq 839 for MSI/MSI-X
[   83.442311] ixgbe 0000:01:00.1: irq 840 for MSI/MSI-X
[   83.442343] ixgbe 0000:01:00.1: irq 841 for MSI/MSI-X
[   83.442386] ixgbe 0000:01:00.1: irq 842 for MSI/MSI-X
[   83.442466] ixgbe 0000:01:00.1: irq 843 for MSI/MSI-X
[   83.442501] ixgbe 0000:01:00.1: irq 844 for MSI/MSI-X
[   83.442532] ixgbe 0000:01:00.1: irq 845 for MSI/MSI-X
[   83.442570] ixgbe 0000:01:00.1: irq 846 for MSI/MSI-X
[   83.442603] ixgbe 0000:01:00.1: irq 847 for MSI/MSI-X
[   83.442635] ixgbe 0000:01:00.1: irq 848 for MSI/MSI-X
[   83.442666] ixgbe 0000:01:00.1: irq 849 for MSI/MSI-X
[   83.442698] ixgbe 0000:01:00.1: irq 850 for MSI/MSI-X
[   83.442730] ixgbe 0000:01:00.1: irq 851 for MSI/MSI-X
[   83.442763] ixgbe 0000:01:00.1: irq 852 for MSI/MSI-X
[   83.442795] ixgbe 0000:01:00.1: irq 853 for MSI/MSI-X
[   83.443018] ixgbe 0000:01:00.1: irq 854 for MSI/MSI-X
[   83.443048] ixgbe 0000:01:00.1: irq 855 for MSI/MSI-X
[   83.443079] ixgbe 0000:01:00.1: irq 856 for MSI/MSI-X
[   83.443111] ixgbe 0000:01:00.1: irq 857 for MSI/MSI-X
[   83.443142] ixgbe 0000:01:00.1: irq 858 for MSI/MSI-X
[   83.443173] ixgbe 0000:01:00.1: irq 859 for MSI/MSI-X
[   83.443204] ixgbe 0000:01:00.1: irq 860 for MSI/MSI-X
[   83.443240] ixgbe 0000:01:00.1: irq 861 for MSI/MSI-X
[   83.443280] ixgbe 0000:01:00.1: irq 862 for MSI/MSI-X
[   83.443317] ixgbe 0000:01:00.1: irq 863 for MSI/MSI-X
[   83.443353] ixgbe 0000:01:00.1: irq 864 for MSI/MSI-X
[   83.443397] ixgbe 0000:01:00.1: irq 865 for MSI/MSI-X
[   83.443434] ixgbe 0000:01:00.1: irq 866 for MSI/MSI-X
[   83.443471] ixgbe 0000:01:00.1: irq 867 for MSI/MSI-X
[   83.443507] ixgbe 0000:01:00.1: irq 868 for MSI/MSI-X
[   83.443543] ixgbe 0000:01:00.1: irq 869 for MSI/MSI-X
[   83.443773] ixgbe 0000:01:00.1: irq 870 for MSI/MSI-X
[   83.443809] ixgbe 0000:01:00.1: irq 871 for MSI/MSI-X
[   83.443863] ixgbe 0000:01:00.1: irq 872 for MSI/MSI-X
[   83.443941] ixgbe 0000:01:00.1: irq 873 for MSI/MSI-X
[   83.443978] ixgbe 0000:01:00.1: irq 874 for MSI/MSI-X
[   83.444014] ixgbe 0000:01:00.1: irq 875 for MSI/MSI-X
[   83.444051] ixgbe 0000:01:00.1: irq 876 for MSI/MSI-X
[   83.444088] ixgbe 0000:01:00.1: irq 877 for MSI/MSI-X
[   83.444130] ixgbe 0000:01:00.1: irq 878 for MSI/MSI-X
[   83.444178] ixgbe 0000:01:00.1: irq 879 for MSI/MSI-X
[   83.444215] ixgbe 0000:01:00.1: irq 880 for MSI/MSI-X
[   83.444265] ixgbe 0000:01:00.1: irq 881 for MSI/MSI-X
[   83.444302] ixgbe 0000:01:00.1: irq 882 for MSI/MSI-X
[   83.444341] ixgbe 0000:01:00.1: irq 883 for MSI/MSI-X
[   83.444391] ixgbe 0000:01:00.1: irq 884 for MSI/MSI-X
[   83.444428] ixgbe 0000:01:00.1: irq 885 for MSI/MSI-X
[   83.444637] ixgbe 0000:01:00.1: irq 886 for MSI/MSI-X
[   83.444690] ixgbe 0000:01:00.1: irq 887 for MSI/MSI-X
[   83.444727] ixgbe 0000:01:00.1: irq 888 for MSI/MSI-X
[   83.444764] ixgbe 0000:01:00.1: irq 889 for MSI/MSI-X
[   83.444812] ixgbe 0000:01:00.1: irq 890 for MSI/MSI-X
[   83.444852] ixgbe 0000:01:00.1: irq 891 for MSI/MSI-X
[   83.444888] ixgbe 0000:01:00.1: irq 892 for MSI/MSI-X
[   83.444925] ixgbe 0000:01:00.1: irq 893 for MSI/MSI-X
[   83.444988] ixgbe 0000:01:00.1: irq 894 for MSI/MSI-X
[   83.445026] ixgbe 0000:01:00.1: irq 895 for MSI/MSI-X
[   83.445063] ixgbe 0000:01:00.1: irq 896 for MSI/MSI-X
[   83.445101] ixgbe 0000:01:00.1: irq 897 for MSI/MSI-X
[   83.445138] ixgbe 0000:01:00.1: irq 898 for MSI/MSI-X
[   83.445176] ixgbe 0000:01:00.1: irq 899 for MSI/MSI-X
[   83.446287] ioatdma 0000:84:04.4: irq 900 for MSI/MSI-X
[   83.452512] ioatdma 0000:84:04.5: irq 901 for MSI/MSI-X
[   83.453902] ixgbe 0000:01:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   83.454035] ixgbe 0000:01:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:91:1b:75
[   83.454373] ixgbe 0000:01:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[   83.454377] ixgbe 0000:01:00.1: PCI Express bandwidth of 32GT/s available
[   83.454379] ixgbe 0000:01:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   83.456160] ioatdma 0000:84:04.6: irq 902 for MSI/MSI-X
[   83.459890] ioatdma 0000:84:04.7: irq 903 for MSI/MSI-X
[   83.467239] ioatdma 0000:90:04.0: irq 904 for MSI/MSI-X
[   83.473776] ioatdma 0000:90:04.1: irq 905 for MSI/MSI-X
[   83.478339] ioatdma 0000:90:04.2: irq 906 for MSI/MSI-X
[   83.483607] ioatdma 0000:90:04.3: irq 907 for MSI/MSI-X
[   83.490543] ioatdma 0000:90:04.4: irq 908 for MSI/MSI-X
[   83.503658] ioatdma 0000:90:04.5: irq 909 for MSI/MSI-X
[   83.510734] ioatdma 0000:90:04.6: irq 910 for MSI/MSI-X
[   83.519037] ioatdma 0000:90:04.7: irq 911 for MSI/MSI-X
[   83.525426] ioatdma 0000:a0:04.0: irq 912 for MSI/MSI-X
[   83.536166] ioatdma 0000:a0:04.1: irq 913 for MSI/MSI-X
[   83.545291] ioatdma 0000:a0:04.2: irq 914 for MSI/MSI-X
[   83.553358] ioatdma 0000:a0:04.3: irq 915 for MSI/MSI-X
[   83.559947] ioatdma 0000:a0:04.4: irq 916 for MSI/MSI-X
[   83.566019] ioatdma 0000:a0:04.5: irq 917 for MSI/MSI-X
[   83.578576] ioatdma 0000:a0:04.6: irq 918 for MSI/MSI-X
[   83.588468] ioatdma 0000:a0:04.7: irq 919 for MSI/MSI-X
[   83.599051] ioatdma 0000:b0:04.0: irq 920 for MSI/MSI-X
[   83.602638] ixgbe 0000:01:00.1: Intel(R) 10 Gigabit Network Connection
[   83.604741] ioatdma 0000:b0:04.1: irq 921 for MSI/MSI-X
[   83.609115] ioatdma 0000:b0:04.2: irq 922 for MSI/MSI-X
[   83.613264] ioatdma 0000:b0:04.3: irq 923 for MSI/MSI-X
[   83.619054] ioatdma 0000:b0:04.4: irq 924 for MSI/MSI-X
[   83.623532] ioatdma 0000:b0:04.5: irq 925 for MSI/MSI-X
[   83.628896] ioatdma 0000:b0:04.6: irq 926 for MSI/MSI-X
[   83.633203] ioatdma 0000:b0:04.7: irq 927 for MSI/MSI-X
[   83.641228] ioatdma 0000:c0:04.0: irq 928 for MSI/MSI-X
[   83.648688] ioatdma 0000:c0:04.1: irq 929 for MSI/MSI-X
[   83.653764] ioatdma 0000:c0:04.2: irq 930 for MSI/MSI-X
[   83.658139] ioatdma 0000:c0:04.3: irq 931 for MSI/MSI-X
[   83.662878] ioatdma 0000:c0:04.4: irq 932 for MSI/MSI-X
[   83.669535] ioatdma 0000:c0:04.5: irq 933 for MSI/MSI-X
[   83.674848] ioatdma 0000:c0:04.6: irq 934 for MSI/MSI-X
[   83.679120] ioatdma 0000:c0:04.7: irq 935 for MSI/MSI-X
[   83.685010] ioatdma 0000:d0:04.0: irq 936 for MSI/MSI-X
[   83.690072] ioatdma 0000:d0:04.1: irq 937 for MSI/MSI-X
[   83.694519] ixgbe 0000:03:00.0: irq 938 for MSI/MSI-X
[   83.694560] ixgbe 0000:03:00.0: irq 939 for MSI/MSI-X
[   83.694598] ixgbe 0000:03:00.0: irq 940 for MSI/MSI-X
[   83.694636] ixgbe 0000:03:00.0: irq 941 for MSI/MSI-X
[   83.694674] ixgbe 0000:03:00.0: irq 942 for MSI/MSI-X
[   83.694719] ixgbe 0000:03:00.0: irq 943 for MSI/MSI-X
[   83.694757] ixgbe 0000:03:00.0: irq 944 for MSI/MSI-X
[   83.694812] ixgbe 0000:03:00.0: irq 945 for MSI/MSI-X
[   83.695031] ixgbe 0000:03:00.0: irq 946 for MSI/MSI-X
[   83.695076] ixgbe 0000:03:00.0: irq 947 for MSI/MSI-X
[   83.695115] ixgbe 0000:03:00.0: irq 948 for MSI/MSI-X
[   83.695154] ixgbe 0000:03:00.0: irq 949 for MSI/MSI-X
[   83.695192] ixgbe 0000:03:00.0: irq 950 for MSI/MSI-X
[   83.695229] ixgbe 0000:03:00.0: irq 951 for MSI/MSI-X
[   83.695440] ixgbe 0000:03:00.0: irq 952 for MSI/MSI-X
[   83.695600] ioatdma 0000:d0:04.2: irq 953 for MSI/MSI-X
[   83.695635] ixgbe 0000:03:00.0: irq 954 for MSI/MSI-X
[   83.695680] ixgbe 0000:03:00.0: irq 955 for MSI/MSI-X
[   83.695725] ixgbe 0000:03:00.0: irq 956 for MSI/MSI-X
[   83.695761] ixgbe 0000:03:00.0: irq 957 for MSI/MSI-X
[   83.695799] ixgbe 0000:03:00.0: irq 958 for MSI/MSI-X
[   83.695836] ixgbe 0000:03:00.0: irq 959 for MSI/MSI-X
[   83.695873] ixgbe 0000:03:00.0: irq 960 for MSI/MSI-X
[   83.695909] ixgbe 0000:03:00.0: irq 961 for MSI/MSI-X
[   83.696108] ixgbe 0000:03:00.0: irq 962 for MSI/MSI-X
[   83.696168] ixgbe 0000:03:00.0: irq 963 for MSI/MSI-X
[   83.696203] ixgbe 0000:03:00.0: irq 964 for MSI/MSI-X
[   83.696240] ixgbe 0000:03:00.0: irq 965 for MSI/MSI-X
[   83.696278] ixgbe 0000:03:00.0: irq 966 for MSI/MSI-X
[   83.696315] ixgbe 0000:03:00.0: irq 967 for MSI/MSI-X
[   83.696353] ixgbe 0000:03:00.0: irq 968 for MSI/MSI-X
[   83.696391] ixgbe 0000:03:00.0: irq 969 for MSI/MSI-X
[   83.696744] ixgbe 0000:03:00.0: irq 970 for MSI/MSI-X
[   83.696786] ixgbe 0000:03:00.0: irq 971 for MSI/MSI-X
[   83.696822] ixgbe 0000:03:00.0: irq 972 for MSI/MSI-X
[   83.696858] ixgbe 0000:03:00.0: irq 973 for MSI/MSI-X
[   83.697066] ixgbe 0000:03:00.0: irq 974 for MSI/MSI-X
[   83.697104] ixgbe 0000:03:00.0: irq 975 for MSI/MSI-X
[   83.697141] ixgbe 0000:03:00.0: irq 976 for MSI/MSI-X
[   83.697177] ixgbe 0000:03:00.0: irq 977 for MSI/MSI-X
[   83.697216] ixgbe 0000:03:00.0: irq 978 for MSI/MSI-X
[   83.697257] ixgbe 0000:03:00.0: irq 979 for MSI/MSI-X
[   83.697292] ixgbe 0000:03:00.0: irq 980 for MSI/MSI-X
[   83.697330] ixgbe 0000:03:00.0: irq 981 for MSI/MSI-X
[   83.697366] ixgbe 0000:03:00.0: irq 982 for MSI/MSI-X
[   83.697407] ixgbe 0000:03:00.0: irq 983 for MSI/MSI-X
[   83.697444] ixgbe 0000:03:00.0: irq 984 for MSI/MSI-X
[   83.697483] ixgbe 0000:03:00.0: irq 985 for MSI/MSI-X
[   83.697523] ixgbe 0000:03:00.0: irq 986 for MSI/MSI-X
[   83.697566] ixgbe 0000:03:00.0: irq 987 for MSI/MSI-X
[   83.697603] ixgbe 0000:03:00.0: irq 988 for MSI/MSI-X
[   83.697643] ixgbe 0000:03:00.0: irq 989 for MSI/MSI-X
[   83.697857] ixgbe 0000:03:00.0: irq 990 for MSI/MSI-X
[   83.697894] ixgbe 0000:03:00.0: irq 991 for MSI/MSI-X
[   83.697929] ixgbe 0000:03:00.0: irq 992 for MSI/MSI-X
[   83.697969] ixgbe 0000:03:00.0: irq 993 for MSI/MSI-X
[   83.698005] ixgbe 0000:03:00.0: irq 994 for MSI/MSI-X
[   83.698047] ixgbe 0000:03:00.0: irq 995 for MSI/MSI-X
[   83.698084] ixgbe 0000:03:00.0: irq 996 for MSI/MSI-X
[   83.698122] ixgbe 0000:03:00.0: irq 997 for MSI/MSI-X
[   83.698159] ixgbe 0000:03:00.0: irq 998 for MSI/MSI-X
[   83.698197] ixgbe 0000:03:00.0: irq 999 for MSI/MSI-X
[   83.698235] ixgbe 0000:03:00.0: irq 1000 for MSI/MSI-X
[   83.698276] ixgbe 0000:03:00.0: irq 1001 for MSI/MSI-X
[   83.698313] ixgbe 0000:03:00.0: irq 1002 for MSI/MSI-X
[   83.701024] ioatdma 0000:d0:04.3: irq 1003 for MSI/MSI-X
[   83.701438] ixgbe 0000:03:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   83.701571] ixgbe 0000:03:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8c:db:b8
[   83.701912] ixgbe 0000:03:00.0: MAC: 2, PHY: 1, PBA No: G43498-007
[   83.701916] ixgbe 0000:03:00.0: PCI Express bandwidth of 32GT/s available
[   83.701918] ixgbe 0000:03:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   83.705659] ioatdma 0000:d0:04.4: irq 1004 for MSI/MSI-X
[   83.709449] ioatdma 0000:d0:04.5: irq 1005 for MSI/MSI-X
[   83.713699] ioatdma 0000:d0:04.6: irq 1006 for MSI/MSI-X
[   83.719166] ioatdma 0000:d0:04.7: irq 1007 for MSI/MSI-X
[   83.725006] ioatdma 0000:e0:04.0: irq 1008 for MSI/MSI-X
[   83.731017] ioatdma 0000:e0:04.1: irq 1009 for MSI/MSI-X
[   83.736481] ioatdma 0000:e0:04.2: irq 1010 for MSI/MSI-X
[   83.743930] ioatdma 0000:e0:04.3: irq 1011 for MSI/MSI-X
[   83.747490] ixgbe 0000:03:00.0: Intel(R) 10 Gigabit Network Connection
[   83.748491] ioatdma 0000:e0:04.4: irq 1012 for MSI/MSI-X
[   83.753040] ioatdma 0000:e0:04.5: irq 1013 for MSI/MSI-X
[   83.757762] ioatdma 0000:e0:04.6: irq 1014 for MSI/MSI-X
[   83.762172] ioatdma 0000:e0:04.7: irq 1015 for MSI/MSI-X
[   83.769389] ioatdma 0000:f0:04.0: irq 1016 for MSI/MSI-X
[   83.774856] ioatdma 0000:f0:04.1: irq 1017 for MSI/MSI-X
[   83.780086] ioatdma 0000:f0:04.2: irq 1018 for MSI/MSI-X
[   83.785020] ioatdma 0000:f0:04.3: irq 1019 for MSI/MSI-X
[   83.789298] ioatdma 0000:f0:04.4: irq 1020 for MSI/MSI-X
[   83.793309] ioatdma 0000:f0:04.5: irq 1021 for MSI/MSI-X
[   83.801497] ioatdma 0000:f0:04.6: irq 1022 for MSI/MSI-X
[   83.807931] ioatdma 0000:f0:04.7: irq 1023 for MSI/MSI-X
[   83.852730] ixgbe 0000:03:00.1: irq 1024 for MSI/MSI-X
[   83.852769] ixgbe 0000:03:00.1: irq 1025 for MSI/MSI-X
[   83.852808] ixgbe 0000:03:00.1: irq 1026 for MSI/MSI-X
[   83.852845] ixgbe 0000:03:00.1: irq 1027 for MSI/MSI-X
[   83.853075] ixgbe 0000:03:00.1: irq 1028 for MSI/MSI-X
[   83.853112] ixgbe 0000:03:00.1: irq 1029 for MSI/MSI-X
[   83.853154] ixgbe 0000:03:00.1: irq 1030 for MSI/MSI-X
[   83.853203] ixgbe 0000:03:00.1: irq 1031 for MSI/MSI-X
[   83.853242] ixgbe 0000:03:00.1: irq 1032 for MSI/MSI-X
[   83.853278] ixgbe 0000:03:00.1: irq 1033 for MSI/MSI-X
[   83.853317] ixgbe 0000:03:00.1: irq 1034 for MSI/MSI-X
[   83.853353] ixgbe 0000:03:00.1: irq 1035 for MSI/MSI-X
[   83.853392] ixgbe 0000:03:00.1: irq 1036 for MSI/MSI-X
[   83.853428] ixgbe 0000:03:00.1: irq 1037 for MSI/MSI-X
[   83.853466] ixgbe 0000:03:00.1: irq 1038 for MSI/MSI-X
[   83.853507] ixgbe 0000:03:00.1: irq 1039 for MSI/MSI-X
[   83.853543] ixgbe 0000:03:00.1: irq 1040 for MSI/MSI-X
[   83.853578] ixgbe 0000:03:00.1: irq 1041 for MSI/MSI-X
[   83.853615] ixgbe 0000:03:00.1: irq 1042 for MSI/MSI-X
[   83.853651] ixgbe 0000:03:00.1: irq 1043 for MSI/MSI-X
[   83.853850] ixgbe 0000:03:00.1: irq 1044 for MSI/MSI-X
[   83.853895] ixgbe 0000:03:00.1: irq 1045 for MSI/MSI-X
[   83.853933] ixgbe 0000:03:00.1: irq 1046 for MSI/MSI-X
[   83.853975] ixgbe 0000:03:00.1: irq 1047 for MSI/MSI-X
[   83.854012] ixgbe 0000:03:00.1: irq 1048 for MSI/MSI-X
[   83.854048] ixgbe 0000:03:00.1: irq 1049 for MSI/MSI-X
[   83.854084] ixgbe 0000:03:00.1: irq 1050 for MSI/MSI-X
[   83.854120] ixgbe 0000:03:00.1: irq 1051 for MSI/MSI-X
[   83.854155] ixgbe 0000:03:00.1: irq 1052 for MSI/MSI-X
[   83.854191] ixgbe 0000:03:00.1: irq 1053 for MSI/MSI-X
[   83.854229] ixgbe 0000:03:00.1: irq 1054 for MSI/MSI-X
[   83.854271] ixgbe 0000:03:00.1: irq 1055 for MSI/MSI-X
[   83.854307] ixgbe 0000:03:00.1: irq 1056 for MSI/MSI-X
[   83.854343] ixgbe 0000:03:00.1: irq 1057 for MSI/MSI-X
[   83.854380] ixgbe 0000:03:00.1: irq 1058 for MSI/MSI-X
[   83.854418] ixgbe 0000:03:00.1: irq 1059 for MSI/MSI-X
[   83.854616] ixgbe 0000:03:00.1: irq 1060 for MSI/MSI-X
[   83.854652] ixgbe 0000:03:00.1: irq 1061 for MSI/MSI-X
[   83.854699] ixgbe 0000:03:00.1: irq 1062 for MSI/MSI-X
[   83.854740] ixgbe 0000:03:00.1: irq 1063 for MSI/MSI-X
[   83.854775] ixgbe 0000:03:00.1: irq 1064 for MSI/MSI-X
[   83.854811] ixgbe 0000:03:00.1: irq 1065 for MSI/MSI-X
[   83.854847] ixgbe 0000:03:00.1: irq 1066 for MSI/MSI-X
[   83.854893] ixgbe 0000:03:00.1: irq 1067 for MSI/MSI-X
[   83.854940] ixgbe 0000:03:00.1: irq 1068 for MSI/MSI-X
[   83.854981] ixgbe 0000:03:00.1: irq 1069 for MSI/MSI-X
[   83.855029] ixgbe 0000:03:00.1: irq 1070 for MSI/MSI-X
[   83.855072] ixgbe 0000:03:00.1: irq 1071 for MSI/MSI-X
[   83.855110] ixgbe 0000:03:00.1: irq 1072 for MSI/MSI-X
[   83.855147] ixgbe 0000:03:00.1: irq 1073 for MSI/MSI-X
[   83.855185] ixgbe 0000:03:00.1: irq 1074 for MSI/MSI-X
[   83.855224] ixgbe 0000:03:00.1: irq 1075 for MSI/MSI-X
[   83.855426] ixgbe 0000:03:00.1: irq 1076 for MSI/MSI-X
[   83.855465] ixgbe 0000:03:00.1: irq 1077 for MSI/MSI-X
[   83.855505] ixgbe 0000:03:00.1: irq 1078 for MSI/MSI-X
[   83.855547] ixgbe 0000:03:00.1: irq 1079 for MSI/MSI-X
[   83.855583] ixgbe 0000:03:00.1: irq 1080 for MSI/MSI-X
[   83.855619] ixgbe 0000:03:00.1: irq 1081 for MSI/MSI-X
[   83.855657] ixgbe 0000:03:00.1: irq 1082 for MSI/MSI-X
[   83.855696] ixgbe 0000:03:00.1: irq 1083 for MSI/MSI-X
[   83.855732] ixgbe 0000:03:00.1: irq 1084 for MSI/MSI-X
[   83.855770] ixgbe 0000:03:00.1: irq 1085 for MSI/MSI-X
[   83.855807] ixgbe 0000:03:00.1: irq 1086 for MSI/MSI-X
[   83.855861] ixgbe 0000:03:00.1: irq 1087 for MSI/MSI-X
[   83.859117] ixgbe 0000:03:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   83.859248] ixgbe 0000:03:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8c:db:b9
[   83.859587] ixgbe 0000:03:00.1: MAC: 2, PHY: 1, PBA No: G43498-007
[   83.859590] ixgbe 0000:03:00.1: PCI Express bandwidth of 32GT/s available
[   83.859592] ixgbe 0000:03:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   83.901007] ixgbe 0000:03:00.1: Intel(R) 10 Gigabit Network Connection
[   83.915630] input: PC Speaker as /devices/platform/pcspkr/input/input1
[   83.992777] ixgbe 0000:21:00.0: irq 1088 for MSI/MSI-X
[   83.992826] ixgbe 0000:21:00.0: irq 1089 for MSI/MSI-X
[   83.993040] ixgbe 0000:21:00.0: irq 1090 for MSI/MSI-X
[   83.993104] ixgbe 0000:21:00.0: irq 1091 for MSI/MSI-X
[   83.993146] ixgbe 0000:21:00.0: irq 1092 for MSI/MSI-X
[   83.993218] ixgbe 0000:21:00.0: irq 1093 for MSI/MSI-X
[   83.993312] ixgbe 0000:21:00.0: irq 1094 for MSI/MSI-X
[   83.993364] ixgbe 0000:21:00.0: irq 1095 for MSI/MSI-X
[   83.993413] ixgbe 0000:21:00.0: irq 1096 for MSI/MSI-X
[   83.993454] ixgbe 0000:21:00.0: irq 1097 for MSI/MSI-X
[   83.993496] ixgbe 0000:21:00.0: irq 1098 for MSI/MSI-X
[   83.993537] ixgbe 0000:21:00.0: irq 1099 for MSI/MSI-X
[   83.993605] ixgbe 0000:21:00.0: irq 1100 for MSI/MSI-X
[   83.993648] ixgbe 0000:21:00.0: irq 1101 for MSI/MSI-X
[   83.993697] ixgbe 0000:21:00.0: irq 1102 for MSI/MSI-X
[   83.993744] ixgbe 0000:21:00.0: irq 1103 for MSI/MSI-X
[   83.993787] ixgbe 0000:21:00.0: irq 1104 for MSI/MSI-X
[   83.993833] ixgbe 0000:21:00.0: irq 1105 for MSI/MSI-X
[   83.994185] ixgbe 0000:21:00.0: irq 1106 for MSI/MSI-X
[   83.994254] ixgbe 0000:21:00.0: irq 1107 for MSI/MSI-X
[   83.994309] ixgbe 0000:21:00.0: irq 1108 for MSI/MSI-X
[   83.994367] ixgbe 0000:21:00.0: irq 1109 for MSI/MSI-X
[   83.994417] ixgbe 0000:21:00.0: irq 1110 for MSI/MSI-X
[   83.994480] ixgbe 0000:21:00.0: irq 1111 for MSI/MSI-X
[   83.994529] ixgbe 0000:21:00.0: irq 1112 for MSI/MSI-X
[   83.994576] ixgbe 0000:21:00.0: irq 1113 for MSI/MSI-X
[   83.994634] ixgbe 0000:21:00.0: irq 1114 for MSI/MSI-X
[   83.994684] ixgbe 0000:21:00.0: irq 1115 for MSI/MSI-X
[   83.994733] ixgbe 0000:21:00.0: irq 1116 for MSI/MSI-X
[   83.994780] ixgbe 0000:21:00.0: irq 1117 for MSI/MSI-X
[   83.994827] ixgbe 0000:21:00.0: irq 1118 for MSI/MSI-X
[   83.994881] ixgbe 0000:21:00.0: irq 1119 for MSI/MSI-X
[   83.994928] ixgbe 0000:21:00.0: irq 1120 for MSI/MSI-X
[   83.994975] ixgbe 0000:21:00.0: irq 1121 for MSI/MSI-X
[   83.995203] ixgbe 0000:21:00.0: irq 1122 for MSI/MSI-X
[   83.995250] ixgbe 0000:21:00.0: irq 1123 for MSI/MSI-X
[   83.995297] ixgbe 0000:21:00.0: irq 1124 for MSI/MSI-X
[   83.995344] ixgbe 0000:21:00.0: irq 1125 for MSI/MSI-X
[   83.995396] ixgbe 0000:21:00.0: irq 1126 for MSI/MSI-X
[   83.995455] ixgbe 0000:21:00.0: irq 1127 for MSI/MSI-X
[   83.995504] ixgbe 0000:21:00.0: irq 1128 for MSI/MSI-X
[   83.995552] ixgbe 0000:21:00.0: irq 1129 for MSI/MSI-X
[   83.995599] ixgbe 0000:21:00.0: irq 1130 for MSI/MSI-X
[   83.995646] ixgbe 0000:21:00.0: irq 1131 for MSI/MSI-X
[   83.995697] ixgbe 0000:21:00.0: irq 1132 for MSI/MSI-X
[   83.995747] ixgbe 0000:21:00.0: irq 1133 for MSI/MSI-X
[   83.995794] ixgbe 0000:21:00.0: irq 1134 for MSI/MSI-X
[   83.995850] ixgbe 0000:21:00.0: irq 1135 for MSI/MSI-X
[   83.995899] ixgbe 0000:21:00.0: irq 1136 for MSI/MSI-X
[   83.995946] ixgbe 0000:21:00.0: irq 1137 for MSI/MSI-X
[   83.996186] ixgbe 0000:21:00.0: irq 1138 for MSI/MSI-X
[   83.996234] ixgbe 0000:21:00.0: irq 1139 for MSI/MSI-X
[   83.996280] ixgbe 0000:21:00.0: irq 1140 for MSI/MSI-X
[   83.996328] ixgbe 0000:21:00.0: irq 1141 for MSI/MSI-X
[   83.996375] ixgbe 0000:21:00.0: irq 1142 for MSI/MSI-X
[   83.996430] ixgbe 0000:21:00.0: irq 1143 for MSI/MSI-X
[   83.996476] ixgbe 0000:21:00.0: irq 1144 for MSI/MSI-X
[   83.996525] ixgbe 0000:21:00.0: irq 1145 for MSI/MSI-X
[   83.996574] ixgbe 0000:21:00.0: irq 1146 for MSI/MSI-X
[   83.996621] ixgbe 0000:21:00.0: irq 1147 for MSI/MSI-X
[   83.996707] ixgbe 0000:21:00.0: irq 1148 for MSI/MSI-X
[   83.996764] ixgbe 0000:21:00.0: irq 1149 for MSI/MSI-X
[   83.996818] ixgbe 0000:21:00.0: irq 1150 for MSI/MSI-X
[   83.996872] ixgbe 0000:21:00.0: irq 1151 for MSI/MSI-X
[   84.006652] alg: No test for __gcm-aes-aesni (__driver-gcm-aes-aesni)
[   84.008371] ixgbe 0000:21:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   84.008511] ixgbe 0000:21:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:91:65:ac
[   84.008854] ixgbe 0000:21:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[   84.008860] ixgbe 0000:21:00.0: PCI Express bandwidth of 32GT/s available
[   84.008863] ixgbe 0000:21:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   84.074024] alg: No test for crc32 (crc32-pclmul)
[   84.095025] ixgbe 0000:21:00.0: Intel(R) 10 Gigabit Network Connection
[   84.196096] ixgbe 0000:21:00.1: irq 1152 for MSI/MSI-X
[   84.196149] ixgbe 0000:21:00.1: irq 1153 for MSI/MSI-X
[   84.196203] ixgbe 0000:21:00.1: irq 1154 for MSI/MSI-X
[   84.196419] ixgbe 0000:21:00.1: irq 1155 for MSI/MSI-X
[   84.196472] ixgbe 0000:21:00.1: irq 1156 for MSI/MSI-X
[   84.196523] ixgbe 0000:21:00.1: irq 1157 for MSI/MSI-X
[   84.196573] ixgbe 0000:21:00.1: irq 1158 for MSI/MSI-X
[   84.196624] ixgbe 0000:21:00.1: irq 1159 for MSI/MSI-X
[   84.196674] ixgbe 0000:21:00.1: irq 1160 for MSI/MSI-X
[   84.196725] ixgbe 0000:21:00.1: irq 1161 for MSI/MSI-X
[   84.196774] ixgbe 0000:21:00.1: irq 1162 for MSI/MSI-X
[   84.196978] ixgbe 0000:21:00.1: irq 1163 for MSI/MSI-X
[   84.197029] ixgbe 0000:21:00.1: irq 1164 for MSI/MSI-X
[   84.197077] ixgbe 0000:21:00.1: irq 1165 for MSI/MSI-X
[   84.197123] ixgbe 0000:21:00.1: irq 1166 for MSI/MSI-X
[   84.197170] ixgbe 0000:21:00.1: irq 1167 for MSI/MSI-X
[   84.197218] ixgbe 0000:21:00.1: irq 1168 for MSI/MSI-X
[   84.197265] ixgbe 0000:21:00.1: irq 1169 for MSI/MSI-X
[   84.197325] ixgbe 0000:21:00.1: irq 1170 for MSI/MSI-X
[   84.197374] ixgbe 0000:21:00.1: irq 1171 for MSI/MSI-X
[   84.197429] ixgbe 0000:21:00.1: irq 1172 for MSI/MSI-X
[   84.197476] ixgbe 0000:21:00.1: irq 1173 for MSI/MSI-X
[   84.197524] ixgbe 0000:21:00.1: irq 1174 for MSI/MSI-X
[   84.197579] ixgbe 0000:21:00.1: irq 1175 for MSI/MSI-X
[   84.197629] ixgbe 0000:21:00.1: irq 1176 for MSI/MSI-X
[   84.197679] ixgbe 0000:21:00.1: irq 1177 for MSI/MSI-X
[   84.197730] ixgbe 0000:21:00.1: irq 1178 for MSI/MSI-X
[   84.197957] ixgbe 0000:21:00.1: irq 1179 for MSI/MSI-X
[   84.198005] ixgbe 0000:21:00.1: irq 1180 for MSI/MSI-X
[   84.198051] ixgbe 0000:21:00.1: irq 1181 for MSI/MSI-X
[   84.198097] ixgbe 0000:21:00.1: irq 1182 for MSI/MSI-X
[   84.198144] ixgbe 0000:21:00.1: irq 1183 for MSI/MSI-X
[   84.198190] ixgbe 0000:21:00.1: irq 1184 for MSI/MSI-X
[   84.198236] ixgbe 0000:21:00.1: irq 1185 for MSI/MSI-X
[   84.198282] ixgbe 0000:21:00.1: irq 1186 for MSI/MSI-X
[   84.198333] ixgbe 0000:21:00.1: irq 1187 for MSI/MSI-X
[   84.198384] ixgbe 0000:21:00.1: irq 1188 for MSI/MSI-X
[   84.198432] ixgbe 0000:21:00.1: irq 1189 for MSI/MSI-X
[   84.198478] ixgbe 0000:21:00.1: irq 1190 for MSI/MSI-X
[   84.198524] ixgbe 0000:21:00.1: irq 1191 for MSI/MSI-X
[   84.198571] ixgbe 0000:21:00.1: irq 1192 for MSI/MSI-X
[   84.198617] ixgbe 0000:21:00.1: irq 1193 for MSI/MSI-X
[   84.198666] ixgbe 0000:21:00.1: irq 1194 for MSI/MSI-X
[   84.198885] ixgbe 0000:21:00.1: irq 1195 for MSI/MSI-X
[   84.198932] ixgbe 0000:21:00.1: irq 1196 for MSI/MSI-X
[   84.198977] ixgbe 0000:21:00.1: irq 1197 for MSI/MSI-X
[   84.199031] ixgbe 0000:21:00.1: irq 1198 for MSI/MSI-X
[   84.199078] ixgbe 0000:21:00.1: irq 1199 for MSI/MSI-X
[   84.199130] ixgbe 0000:21:00.1: irq 1200 for MSI/MSI-X
[   84.199176] ixgbe 0000:21:00.1: irq 1201 for MSI/MSI-X
[   84.199222] ixgbe 0000:21:00.1: irq 1202 for MSI/MSI-X
[   84.199268] ixgbe 0000:21:00.1: irq 1203 for MSI/MSI-X
[   84.199323] ixgbe 0000:21:00.1: irq 1204 for MSI/MSI-X
[   84.199370] ixgbe 0000:21:00.1: irq 1205 for MSI/MSI-X
[   84.199422] ixgbe 0000:21:00.1: irq 1206 for MSI/MSI-X
[   84.199469] ixgbe 0000:21:00.1: irq 1207 for MSI/MSI-X
[   84.199515] ixgbe 0000:21:00.1: irq 1208 for MSI/MSI-X
[   84.199563] ixgbe 0000:21:00.1: irq 1209 for MSI/MSI-X
[   84.199622] ixgbe 0000:21:00.1: irq 1210 for MSI/MSI-X
[   84.199848] ixgbe 0000:21:00.1: irq 1211 for MSI/MSI-X
[   84.199903] ixgbe 0000:21:00.1: irq 1212 for MSI/MSI-X
[   84.199960] ixgbe 0000:21:00.1: irq 1213 for MSI/MSI-X
[   84.200011] ixgbe 0000:21:00.1: irq 1214 for MSI/MSI-X
[   84.200063] ixgbe 0000:21:00.1: irq 1215 for MSI/MSI-X
[   84.244546] ixgbe 0000:21:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   84.244681] ixgbe 0000:21:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:91:65:ad
[   84.245020] ixgbe 0000:21:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[   84.245024] ixgbe 0000:21:00.1: PCI Express bandwidth of 32GT/s available
[   84.245027] ixgbe 0000:21:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   84.830808] ixgbe 0000:21:00.1: Intel(R) 10 Gigabit Network Connection
[   84.923689] ixgbe 0000:23:00.0: irq 1216 for MSI/MSI-X
[   84.923754] ixgbe 0000:23:00.0: irq 1217 for MSI/MSI-X
[   84.923818] ixgbe 0000:23:00.0: irq 1218 for MSI/MSI-X
[   84.923861] ixgbe 0000:23:00.0: irq 1219 for MSI/MSI-X
[   84.924101] ixgbe 0000:23:00.0: irq 1220 for MSI/MSI-X
[   84.924145] ixgbe 0000:23:00.0: irq 1221 for MSI/MSI-X
[   84.924192] ixgbe 0000:23:00.0: irq 1222 for MSI/MSI-X
[   84.924316] ixgbe 0000:23:00.0: irq 1223 for MSI/MSI-X
[   84.924363] ixgbe 0000:23:00.0: irq 1224 for MSI/MSI-X
[   84.924415] ixgbe 0000:23:00.0: irq 1225 for MSI/MSI-X
[   84.924458] ixgbe 0000:23:00.0: irq 1226 for MSI/MSI-X
[   84.924501] ixgbe 0000:23:00.0: irq 1227 for MSI/MSI-X
[   84.924542] ixgbe 0000:23:00.0: irq 1228 for MSI/MSI-X
[   84.924772] ixgbe 0000:23:00.0: irq 1229 for MSI/MSI-X
[   84.924815] ixgbe 0000:23:00.0: irq 1230 for MSI/MSI-X
[   84.924859] ixgbe 0000:23:00.0: irq 1231 for MSI/MSI-X
[   84.924905] ixgbe 0000:23:00.0: irq 1232 for MSI/MSI-X
[   84.925033] ixgbe 0000:23:00.0: irq 1233 for MSI/MSI-X
[   84.925076] ixgbe 0000:23:00.0: irq 1234 for MSI/MSI-X
[   84.925120] ixgbe 0000:23:00.0: irq 1235 for MSI/MSI-X
[   84.925162] ixgbe 0000:23:00.0: irq 1236 for MSI/MSI-X
[   84.925204] ixgbe 0000:23:00.0: irq 1237 for MSI/MSI-X
[   84.925258] ixgbe 0000:23:00.0: irq 1238 for MSI/MSI-X
[   84.925312] ixgbe 0000:23:00.0: irq 1239 for MSI/MSI-X
[   84.925391] ixgbe 0000:23:00.0: irq 1240 for MSI/MSI-X
[   84.925450] ixgbe 0000:23:00.0: irq 1241 for MSI/MSI-X
[   84.925495] ixgbe 0000:23:00.0: irq 1242 for MSI/MSI-X
[   84.925538] ixgbe 0000:23:00.0: irq 1243 for MSI/MSI-X
[   84.925581] ixgbe 0000:23:00.0: irq 1244 for MSI/MSI-X
[   84.925784] ixgbe 0000:23:00.0: irq 1245 for MSI/MSI-X
[   84.925859] ixgbe 0000:23:00.0: irq 1246 for MSI/MSI-X
[   84.925905] ixgbe 0000:23:00.0: irq 1247 for MSI/MSI-X
[   84.925959] ixgbe 0000:23:00.0: irq 1248 for MSI/MSI-X
[   84.926008] ixgbe 0000:23:00.0: irq 1249 for MSI/MSI-X
[   84.926051] ixgbe 0000:23:00.0: irq 1250 for MSI/MSI-X
[   84.926093] ixgbe 0000:23:00.0: irq 1251 for MSI/MSI-X
[   84.926136] ixgbe 0000:23:00.0: irq 1252 for MSI/MSI-X
[   84.926178] ixgbe 0000:23:00.0: irq 1253 for MSI/MSI-X
[   84.926261] ixgbe 0000:23:00.0: irq 1254 for MSI/MSI-X
[   84.926309] ixgbe 0000:23:00.0: irq 1255 for MSI/MSI-X
[   84.926354] ixgbe 0000:23:00.0: irq 1256 for MSI/MSI-X
[   84.926402] ixgbe 0000:23:00.0: irq 1257 for MSI/MSI-X
[   84.926451] ixgbe 0000:23:00.0: irq 1258 for MSI/MSI-X
[   84.926495] ixgbe 0000:23:00.0: irq 1259 for MSI/MSI-X
[   84.926545] ixgbe 0000:23:00.0: irq 1260 for MSI/MSI-X
[   84.926805] ixgbe 0000:23:00.0: irq 1261 for MSI/MSI-X
[   84.926850] ixgbe 0000:23:00.0: irq 1262 for MSI/MSI-X
[   84.926897] ixgbe 0000:23:00.0: irq 1263 for MSI/MSI-X
[   84.926942] ixgbe 0000:23:00.0: irq 1264 for MSI/MSI-X
[   84.926993] ixgbe 0000:23:00.0: irq 1265 for MSI/MSI-X
[   84.927052] ixgbe 0000:23:00.0: irq 1266 for MSI/MSI-X
[   84.927113] ixgbe 0000:23:00.0: irq 1267 for MSI/MSI-X
[   84.927156] ixgbe 0000:23:00.0: irq 1268 for MSI/MSI-X
[   84.927202] ixgbe 0000:23:00.0: irq 1269 for MSI/MSI-X
[   84.927260] ixgbe 0000:23:00.0: irq 1270 for MSI/MSI-X
[   84.927304] ixgbe 0000:23:00.0: irq 1271 for MSI/MSI-X
[   84.927357] ixgbe 0000:23:00.0: irq 1272 for MSI/MSI-X
[   84.927405] ixgbe 0000:23:00.0: irq 1273 for MSI/MSI-X
[   84.927455] ixgbe 0000:23:00.0: irq 1274 for MSI/MSI-X
[   84.927508] ixgbe 0000:23:00.0: irq 1275 for MSI/MSI-X
[   84.927554] ixgbe 0000:23:00.0: irq 1276 for MSI/MSI-X
[   84.927869] ixgbe 0000:23:00.0: irq 1277 for MSI/MSI-X
[   84.927916] ixgbe 0000:23:00.0: irq 1278 for MSI/MSI-X
[   84.927961] ixgbe 0000:23:00.0: irq 1279 for MSI/MSI-X
[   84.929139] ixgbe 0000:23:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   84.929293] ixgbe 0000:23:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8c:db:a8
[   84.929630] ixgbe 0000:23:00.0: MAC: 2, PHY: 1, PBA No: G43498-007
[   84.929637] ixgbe 0000:23:00.0: PCI Express bandwidth of 32GT/s available
[   84.929638] ixgbe 0000:23:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   84.970100] ixgbe 0000:23:00.0: Intel(R) 10 Gigabit Network Connection
[   85.078195] ixgbe 0000:23:00.1: irq 1280 for MSI/MSI-X
[   85.078258] ixgbe 0000:23:00.1: irq 1281 for MSI/MSI-X
[   85.078313] ixgbe 0000:23:00.1: irq 1282 for MSI/MSI-X
[   85.078368] ixgbe 0000:23:00.1: irq 1283 for MSI/MSI-X
[   85.078473] ixgbe 0000:23:00.1: irq 1284 for MSI/MSI-X
[   85.078536] ixgbe 0000:23:00.1: irq 1285 for MSI/MSI-X
[   85.078596] ixgbe 0000:23:00.1: irq 1286 for MSI/MSI-X
[   85.078811] ixgbe 0000:23:00.1: irq 1287 for MSI/MSI-X
[   85.078866] ixgbe 0000:23:00.1: irq 1288 for MSI/MSI-X
[   85.078923] ixgbe 0000:23:00.1: irq 1289 for MSI/MSI-X
[   85.078984] ixgbe 0000:23:00.1: irq 1290 for MSI/MSI-X
[   85.079043] ixgbe 0000:23:00.1: irq 1291 for MSI/MSI-X
[   85.079098] ixgbe 0000:23:00.1: irq 1292 for MSI/MSI-X
[   85.079154] ixgbe 0000:23:00.1: irq 1293 for MSI/MSI-X
[   85.079217] ixgbe 0000:23:00.1: irq 1294 for MSI/MSI-X
[   85.079273] ixgbe 0000:23:00.1: irq 1295 for MSI/MSI-X
[   85.079329] ixgbe 0000:23:00.1: irq 1296 for MSI/MSI-X
[   85.079384] ixgbe 0000:23:00.1: irq 1297 for MSI/MSI-X
[   85.079472] ixgbe 0000:23:00.1: irq 1298 for MSI/MSI-X
[   85.079530] ixgbe 0000:23:00.1: irq 1299 for MSI/MSI-X
[   85.079586] ixgbe 0000:23:00.1: irq 1300 for MSI/MSI-X
[   85.079642] ixgbe 0000:23:00.1: irq 1301 for MSI/MSI-X
[   85.079704] ixgbe 0000:23:00.1: irq 1302 for MSI/MSI-X
[   85.079929] ixgbe 0000:23:00.1: irq 1303 for MSI/MSI-X
[   85.079984] ixgbe 0000:23:00.1: irq 1304 for MSI/MSI-X
[   85.080041] ixgbe 0000:23:00.1: irq 1305 for MSI/MSI-X
[   85.080096] ixgbe 0000:23:00.1: irq 1306 for MSI/MSI-X
[   85.080153] ixgbe 0000:23:00.1: irq 1307 for MSI/MSI-X
[   85.080211] ixgbe 0000:23:00.1: irq 1308 for MSI/MSI-X
[   85.080276] ixgbe 0000:23:00.1: irq 1309 for MSI/MSI-X
[   85.080347] ixgbe 0000:23:00.1: irq 1310 for MSI/MSI-X
[   85.080411] ixgbe 0000:23:00.1: irq 1311 for MSI/MSI-X
[   85.080512] ixgbe 0000:23:00.1: irq 1312 for MSI/MSI-X
[   85.080576] ixgbe 0000:23:00.1: irq 1313 for MSI/MSI-X
[   85.080641] ixgbe 0000:23:00.1: irq 1314 for MSI/MSI-X
[   85.080704] ixgbe 0000:23:00.1: irq 1315 for MSI/MSI-X
[   85.080768] ixgbe 0000:23:00.1: irq 1316 for MSI/MSI-X
[   85.080839] ixgbe 0000:23:00.1: irq 1317 for MSI/MSI-X
[   85.080916] ixgbe 0000:23:00.1: irq 1318 for MSI/MSI-X
[   85.081144] ixgbe 0000:23:00.1: irq 1319 for MSI/MSI-X
[   85.081213] ixgbe 0000:23:00.1: irq 1320 for MSI/MSI-X
[   85.081277] ixgbe 0000:23:00.1: irq 1321 for MSI/MSI-X
[   85.081342] ixgbe 0000:23:00.1: irq 1322 for MSI/MSI-X
[   85.081405] ixgbe 0000:23:00.1: irq 1323 for MSI/MSI-X
[   85.081505] ixgbe 0000:23:00.1: irq 1324 for MSI/MSI-X
[   85.081568] ixgbe 0000:23:00.1: irq 1325 for MSI/MSI-X
[   85.081638] ixgbe 0000:23:00.1: irq 1326 for MSI/MSI-X
[   85.081702] ixgbe 0000:23:00.1: irq 1327 for MSI/MSI-X
[   85.081767] ixgbe 0000:23:00.1: irq 1328 for MSI/MSI-X
[   85.081833] ixgbe 0000:23:00.1: irq 1329 for MSI/MSI-X
[   85.081896] ixgbe 0000:23:00.1: irq 1330 for MSI/MSI-X
[   85.081970] ixgbe 0000:23:00.1: irq 1331 for MSI/MSI-X
[   85.082039] ixgbe 0000:23:00.1: irq 1332 for MSI/MSI-X
[   85.082103] ixgbe 0000:23:00.1: irq 1333 for MSI/MSI-X
[   85.082174] ixgbe 0000:23:00.1: irq 1334 for MSI/MSI-X
[   85.082395] ixgbe 0000:23:00.1: irq 1335 for MSI/MSI-X
[   85.082491] ixgbe 0000:23:00.1: irq 1336 for MSI/MSI-X
[   85.082564] ixgbe 0000:23:00.1: irq 1337 for MSI/MSI-X
[   85.082630] ixgbe 0000:23:00.1: irq 1338 for MSI/MSI-X
[   85.082695] ixgbe 0000:23:00.1: irq 1339 for MSI/MSI-X
[   85.082758] ixgbe 0000:23:00.1: irq 1340 for MSI/MSI-X
[   85.082826] ixgbe 0000:23:00.1: irq 1341 for MSI/MSI-X
[   85.082898] ixgbe 0000:23:00.1: irq 1342 for MSI/MSI-X
[   85.082964] ixgbe 0000:23:00.1: irq 1343 for MSI/MSI-X
[   85.083486] ixgbe 0000:23:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   85.083617] ixgbe 0000:23:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8c:db:a9
[   85.083959] ixgbe 0000:23:00.1: MAC: 2, PHY: 1, PBA No: G43498-007
[   85.083964] ixgbe 0000:23:00.1: PCI Express bandwidth of 32GT/s available
[   85.083966] ixgbe 0000:23:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   85.140915] ixgbe 0000:23:00.1: Intel(R) 10 Gigabit Network Connection
[   85.259850] ixgbe 0000:41:00.0: irq 1344 for MSI/MSI-X
[   85.259905] ixgbe 0000:41:00.0: irq 1345 for MSI/MSI-X
[   85.259952] ixgbe 0000:41:00.0: irq 1346 for MSI/MSI-X
[   85.259999] ixgbe 0000:41:00.0: irq 1347 for MSI/MSI-X
[   85.260046] ixgbe 0000:41:00.0: irq 1348 for MSI/MSI-X
[   85.260258] ixgbe 0000:41:00.0: irq 1349 for MSI/MSI-X
[   85.260311] ixgbe 0000:41:00.0: irq 1350 for MSI/MSI-X
[   85.260358] ixgbe 0000:41:00.0: irq 1351 for MSI/MSI-X
[   85.260405] ixgbe 0000:41:00.0: irq 1352 for MSI/MSI-X
[   85.260452] ixgbe 0000:41:00.0: irq 1353 for MSI/MSI-X
[   85.260499] ixgbe 0000:41:00.0: irq 1354 for MSI/MSI-X
[   85.260546] ixgbe 0000:41:00.0: irq 1355 for MSI/MSI-X
[   85.260593] ixgbe 0000:41:00.0: irq 1356 for MSI/MSI-X
[   85.260681] ixgbe 0000:41:00.0: irq 1357 for MSI/MSI-X
[   85.260734] ixgbe 0000:41:00.0: irq 1358 for MSI/MSI-X
[   85.260781] ixgbe 0000:41:00.0: irq 1359 for MSI/MSI-X
[   85.260829] ixgbe 0000:41:00.0: irq 1360 for MSI/MSI-X
[   85.260876] ixgbe 0000:41:00.0: irq 1361 for MSI/MSI-X
[   85.260923] ixgbe 0000:41:00.0: irq 1362 for MSI/MSI-X
[   85.260970] ixgbe 0000:41:00.0: irq 1363 for MSI/MSI-X
[   85.261019] ixgbe 0000:41:00.0: irq 1364 for MSI/MSI-X
[   85.261230] ixgbe 0000:41:00.0: irq 1365 for MSI/MSI-X
[   85.261286] ixgbe 0000:41:00.0: irq 1366 for MSI/MSI-X
[   85.261336] ixgbe 0000:41:00.0: irq 1367 for MSI/MSI-X
[   85.261385] ixgbe 0000:41:00.0: irq 1368 for MSI/MSI-X
[   85.261435] ixgbe 0000:41:00.0: irq 1369 for MSI/MSI-X
[   85.261484] ixgbe 0000:41:00.0: irq 1370 for MSI/MSI-X
[   85.261534] ixgbe 0000:41:00.0: irq 1371 for MSI/MSI-X
[   85.261583] ixgbe 0000:41:00.0: irq 1372 for MSI/MSI-X
[   85.261688] ixgbe 0000:41:00.0: irq 1373 for MSI/MSI-X
[   85.261764] ixgbe 0000:41:00.0: irq 1374 for MSI/MSI-X
[   85.261829] ixgbe 0000:41:00.0: irq 1375 for MSI/MSI-X
[   85.261892] ixgbe 0000:41:00.0: irq 1376 for MSI/MSI-X
[   85.261947] ixgbe 0000:41:00.0: irq 1377 for MSI/MSI-X
[   85.262005] ixgbe 0000:41:00.0: irq 1378 for MSI/MSI-X
[   85.262061] ixgbe 0000:41:00.0: irq 1379 for MSI/MSI-X
[   85.262112] ixgbe 0000:41:00.0: irq 1380 for MSI/MSI-X
[   85.262326] ixgbe 0000:41:00.0: irq 1381 for MSI/MSI-X
[   85.262378] ixgbe 0000:41:00.0: irq 1382 for MSI/MSI-X
[   85.262426] ixgbe 0000:41:00.0: irq 1383 for MSI/MSI-X
[   85.262473] ixgbe 0000:41:00.0: irq 1384 for MSI/MSI-X
[   85.262520] ixgbe 0000:41:00.0: irq 1385 for MSI/MSI-X
[   85.262571] ixgbe 0000:41:00.0: irq 1386 for MSI/MSI-X
[   85.262673] ixgbe 0000:41:00.0: irq 1387 for MSI/MSI-X
[   85.262741] ixgbe 0000:41:00.0: irq 1388 for MSI/MSI-X
[   85.262810] ixgbe 0000:41:00.0: irq 1389 for MSI/MSI-X
[   85.262880] ixgbe 0000:41:00.0: irq 1390 for MSI/MSI-X
[   85.262944] ixgbe 0000:41:00.0: irq 1391 for MSI/MSI-X
[   85.263010] ixgbe 0000:41:00.0: irq 1392 for MSI/MSI-X
[   85.263075] ixgbe 0000:41:00.0: irq 1393 for MSI/MSI-X
[   85.263138] ixgbe 0000:41:00.0: irq 1394 for MSI/MSI-X
[   85.263202] ixgbe 0000:41:00.0: irq 1395 for MSI/MSI-X
[   85.263266] ixgbe 0000:41:00.0: irq 1396 for MSI/MSI-X
[   85.263491] ixgbe 0000:41:00.0: irq 1397 for MSI/MSI-X
[   85.263559] ixgbe 0000:41:00.0: irq 1398 for MSI/MSI-X
[   85.263617] ixgbe 0000:41:00.0: irq 1399 for MSI/MSI-X
[   85.263726] ixgbe 0000:41:00.0: irq 1400 for MSI/MSI-X
[   85.263781] ixgbe 0000:41:00.0: irq 1401 for MSI/MSI-X
[   85.263835] ixgbe 0000:41:00.0: irq 1402 for MSI/MSI-X
[   85.263883] ixgbe 0000:41:00.0: irq 1403 for MSI/MSI-X
[   85.263932] ixgbe 0000:41:00.0: irq 1404 for MSI/MSI-X
[   85.263980] ixgbe 0000:41:00.0: irq 1405 for MSI/MSI-X
[   85.264044] ixgbe 0000:41:00.0: irq 1406 for MSI/MSI-X
[   85.264091] ixgbe 0000:41:00.0: irq 1407 for MSI/MSI-X
[   85.264550] ixgbe 0000:41:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   85.264700] ixgbe 0000:41:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:91:22:e4
[   85.265041] ixgbe 0000:41:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[   85.265048] ixgbe 0000:41:00.0: PCI Express bandwidth of 32GT/s available
[   85.265050] ixgbe 0000:41:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   85.303768] ixgbe 0000:41:00.0: Intel(R) 10 Gigabit Network Connection
[   85.399317] ixgbe 0000:41:00.1: irq 1408 for MSI/MSI-X
[   85.399387] ixgbe 0000:41:00.1: irq 1409 for MSI/MSI-X
[   85.399456] ixgbe 0000:41:00.1: irq 1410 for MSI/MSI-X
[   85.399682] ixgbe 0000:41:00.1: irq 1411 for MSI/MSI-X
[   85.399749] ixgbe 0000:41:00.1: irq 1412 for MSI/MSI-X
[   85.399862] ixgbe 0000:41:00.1: irq 1413 for MSI/MSI-X
[   85.399927] ixgbe 0000:41:00.1: irq 1414 for MSI/MSI-X
[   85.399995] ixgbe 0000:41:00.1: irq 1415 for MSI/MSI-X
[   85.400058] ixgbe 0000:41:00.1: irq 1416 for MSI/MSI-X
[   85.400122] ixgbe 0000:41:00.1: irq 1417 for MSI/MSI-X
[   85.400192] ixgbe 0000:41:00.1: irq 1418 for MSI/MSI-X
[   85.400254] ixgbe 0000:41:00.1: irq 1419 for MSI/MSI-X
[   85.400317] ixgbe 0000:41:00.1: irq 1420 for MSI/MSI-X
[   85.400381] ixgbe 0000:41:00.1: irq 1421 for MSI/MSI-X
[   85.400444] ixgbe 0000:41:00.1: irq 1422 for MSI/MSI-X
[   85.400509] ixgbe 0000:41:00.1: irq 1423 for MSI/MSI-X
[   85.400575] ixgbe 0000:41:00.1: irq 1424 for MSI/MSI-X
[   85.400639] ixgbe 0000:41:00.1: irq 1425 for MSI/MSI-X
[   85.400713] ixgbe 0000:41:00.1: irq 1426 for MSI/MSI-X
[   85.400982] ixgbe 0000:41:00.1: irq 1427 for MSI/MSI-X
[   85.401046] ixgbe 0000:41:00.1: irq 1428 for MSI/MSI-X
[   85.401110] ixgbe 0000:41:00.1: irq 1429 for MSI/MSI-X
[   85.401173] ixgbe 0000:41:00.1: irq 1430 for MSI/MSI-X
[   85.401236] ixgbe 0000:41:00.1: irq 1431 for MSI/MSI-X
[   85.401300] ixgbe 0000:41:00.1: irq 1432 for MSI/MSI-X
[   85.401365] ixgbe 0000:41:00.1: irq 1433 for MSI/MSI-X
[   85.401435] ixgbe 0000:41:00.1: irq 1434 for MSI/MSI-X
[   85.401500] ixgbe 0000:41:00.1: irq 1435 for MSI/MSI-X
[   85.401564] ixgbe 0000:41:00.1: irq 1436 for MSI/MSI-X
[   85.401627] ixgbe 0000:41:00.1: irq 1437 for MSI/MSI-X
[   85.401701] ixgbe 0000:41:00.1: irq 1438 for MSI/MSI-X
[   85.401768] ixgbe 0000:41:00.1: irq 1439 for MSI/MSI-X
[   85.401862] ixgbe 0000:41:00.1: irq 1440 for MSI/MSI-X
[   85.401931] ixgbe 0000:41:00.1: irq 1441 for MSI/MSI-X
[   85.402001] ixgbe 0000:41:00.1: irq 1442 for MSI/MSI-X
[   85.402225] ixgbe 0000:41:00.1: irq 1443 for MSI/MSI-X
[   85.402289] ixgbe 0000:41:00.1: irq 1444 for MSI/MSI-X
[   85.402352] ixgbe 0000:41:00.1: irq 1445 for MSI/MSI-X
[   85.402414] ixgbe 0000:41:00.1: irq 1446 for MSI/MSI-X
[   85.402482] ixgbe 0000:41:00.1: irq 1447 for MSI/MSI-X
[   85.402547] ixgbe 0000:41:00.1: irq 1448 for MSI/MSI-X
[   85.402613] ixgbe 0000:41:00.1: irq 1449 for MSI/MSI-X
[   85.402681] ixgbe 0000:41:00.1: irq 1450 for MSI/MSI-X
[   85.402747] ixgbe 0000:41:00.1: irq 1451 for MSI/MSI-X
[   85.402812] ixgbe 0000:41:00.1: irq 1452 for MSI/MSI-X
[   85.402919] ixgbe 0000:41:00.1: irq 1453 for MSI/MSI-X
[   85.402982] ixgbe 0000:41:00.1: irq 1454 for MSI/MSI-X
[   85.403046] ixgbe 0000:41:00.1: irq 1455 for MSI/MSI-X
[   85.403113] ixgbe 0000:41:00.1: irq 1456 for MSI/MSI-X
[   85.403177] ixgbe 0000:41:00.1: irq 1457 for MSI/MSI-X
[   85.403248] ixgbe 0000:41:00.1: irq 1458 for MSI/MSI-X
[   85.403473] ixgbe 0000:41:00.1: irq 1459 for MSI/MSI-X
[   85.403542] ixgbe 0000:41:00.1: irq 1460 for MSI/MSI-X
[   85.403605] ixgbe 0000:41:00.1: irq 1461 for MSI/MSI-X
[   85.403672] ixgbe 0000:41:00.1: irq 1462 for MSI/MSI-X
[   85.403742] ixgbe 0000:41:00.1: irq 1463 for MSI/MSI-X
[   85.403806] ixgbe 0000:41:00.1: irq 1464 for MSI/MSI-X
[   85.403922] ixgbe 0000:41:00.1: irq 1465 for MSI/MSI-X
[   85.403993] ixgbe 0000:41:00.1: irq 1466 for MSI/MSI-X
[   85.404059] ixgbe 0000:41:00.1: irq 1467 for MSI/MSI-X
[   85.404123] ixgbe 0000:41:00.1: irq 1468 for MSI/MSI-X
[   85.404191] ixgbe 0000:41:00.1: irq 1469 for MSI/MSI-X
[   85.404259] ixgbe 0000:41:00.1: irq 1470 for MSI/MSI-X
[   85.404327] ixgbe 0000:41:00.1: irq 1471 for MSI/MSI-X
[   85.404935] ixgbe 0000:41:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   85.405072] ixgbe 0000:41:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:91:22:e5
[   85.405415] ixgbe 0000:41:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[   85.405421] ixgbe 0000:41:00.1: PCI Express bandwidth of 32GT/s available
[   85.405424] ixgbe 0000:41:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   85.443013] ixgbe 0000:41:00.1: Intel(R) 10 Gigabit Network Connection
[   85.534736] ixgbe 0000:43:00.0: irq 1472 for MSI/MSI-X
[   85.534945] ixgbe 0000:43:00.0: irq 1473 for MSI/MSI-X
[   85.535023] ixgbe 0000:43:00.0: irq 1474 for MSI/MSI-X
[   85.535074] ixgbe 0000:43:00.0: irq 1475 for MSI/MSI-X
[   85.535121] ixgbe 0000:43:00.0: irq 1476 for MSI/MSI-X
[   85.535170] ixgbe 0000:43:00.0: irq 1477 for MSI/MSI-X
[   85.535217] ixgbe 0000:43:00.0: irq 1478 for MSI/MSI-X
[   85.535264] ixgbe 0000:43:00.0: irq 1479 for MSI/MSI-X
[   85.535317] ixgbe 0000:43:00.0: irq 1480 for MSI/MSI-X
[   85.535364] ixgbe 0000:43:00.0: irq 1481 for MSI/MSI-X
[   85.535412] ixgbe 0000:43:00.0: irq 1482 for MSI/MSI-X
[   85.535460] ixgbe 0000:43:00.0: irq 1483 for MSI/MSI-X
[   85.535507] ixgbe 0000:43:00.0: irq 1484 for MSI/MSI-X
[   85.535555] ixgbe 0000:43:00.0: irq 1485 for MSI/MSI-X
[   85.535602] ixgbe 0000:43:00.0: irq 1486 for MSI/MSI-X
[   85.535651] ixgbe 0000:43:00.0: irq 1487 for MSI/MSI-X
[   85.535703] ixgbe 0000:43:00.0: irq 1488 for MSI/MSI-X
[   85.535906] ixgbe 0000:43:00.0: irq 1489 for MSI/MSI-X
[   85.535953] ixgbe 0000:43:00.0: irq 1490 for MSI/MSI-X
[   85.536024] ixgbe 0000:43:00.0: irq 1491 for MSI/MSI-X
[   85.536071] ixgbe 0000:43:00.0: irq 1492 for MSI/MSI-X
[   85.536118] ixgbe 0000:43:00.0: irq 1493 for MSI/MSI-X
[   85.536166] ixgbe 0000:43:00.0: irq 1494 for MSI/MSI-X
[   85.536213] ixgbe 0000:43:00.0: irq 1495 for MSI/MSI-X
[   85.536266] ixgbe 0000:43:00.0: irq 1496 for MSI/MSI-X
[   85.536314] ixgbe 0000:43:00.0: irq 1497 for MSI/MSI-X
[   85.536361] ixgbe 0000:43:00.0: irq 1498 for MSI/MSI-X
[   85.536409] ixgbe 0000:43:00.0: irq 1499 for MSI/MSI-X
[   85.536456] ixgbe 0000:43:00.0: irq 1500 for MSI/MSI-X
[   85.536504] ixgbe 0000:43:00.0: irq 1501 for MSI/MSI-X
[   85.536551] ixgbe 0000:43:00.0: irq 1502 for MSI/MSI-X
[   85.536599] ixgbe 0000:43:00.0: irq 1503 for MSI/MSI-X
[   85.536651] ixgbe 0000:43:00.0: irq 1504 for MSI/MSI-X
[   85.536860] ixgbe 0000:43:00.0: irq 1505 for MSI/MSI-X
[   85.536907] ixgbe 0000:43:00.0: irq 1506 for MSI/MSI-X
[   85.536955] ixgbe 0000:43:00.0: irq 1507 for MSI/MSI-X
[   85.537032] ixgbe 0000:43:00.0: irq 1508 for MSI/MSI-X
[   85.537080] ixgbe 0000:43:00.0: irq 1509 for MSI/MSI-X
[   85.537133] ixgbe 0000:43:00.0: irq 1510 for MSI/MSI-X
[   85.537186] ixgbe 0000:43:00.0: irq 1511 for MSI/MSI-X
[   85.537246] ixgbe 0000:43:00.0: irq 1512 for MSI/MSI-X
[   85.537298] ixgbe 0000:43:00.0: irq 1513 for MSI/MSI-X
[   85.537351] ixgbe 0000:43:00.0: irq 1514 for MSI/MSI-X
[   85.537406] ixgbe 0000:43:00.0: irq 1515 for MSI/MSI-X
[   85.537458] ixgbe 0000:43:00.0: irq 1516 for MSI/MSI-X
[   85.537511] ixgbe 0000:43:00.0: irq 1517 for MSI/MSI-X
[   85.537563] ixgbe 0000:43:00.0: irq 1518 for MSI/MSI-X
[   85.537626] ixgbe 0000:43:00.0: irq 1519 for MSI/MSI-X
[   85.537685] ixgbe 0000:43:00.0: irq 1520 for MSI/MSI-X
[   85.537900] ixgbe 0000:43:00.0: irq 1521 for MSI/MSI-X
[   85.537956] ixgbe 0000:43:00.0: irq 1522 for MSI/MSI-X
[   85.538029] ixgbe 0000:43:00.0: irq 1523 for MSI/MSI-X
[   85.538082] ixgbe 0000:43:00.0: irq 1524 for MSI/MSI-X
[   85.538135] ixgbe 0000:43:00.0: irq 1525 for MSI/MSI-X
[   85.538190] ixgbe 0000:43:00.0: irq 1526 for MSI/MSI-X
[   85.538242] ixgbe 0000:43:00.0: irq 1527 for MSI/MSI-X
[   85.538301] ixgbe 0000:43:00.0: irq 1528 for MSI/MSI-X
[   85.538357] ixgbe 0000:43:00.0: irq 1529 for MSI/MSI-X
[   85.538411] ixgbe 0000:43:00.0: irq 1530 for MSI/MSI-X
[   85.538464] ixgbe 0000:43:00.0: irq 1531 for MSI/MSI-X
[   85.538519] ixgbe 0000:43:00.0: irq 1532 for MSI/MSI-X
[   85.538573] ixgbe 0000:43:00.0: irq 1533 for MSI/MSI-X
[   85.538628] ixgbe 0000:43:00.0: irq 1534 for MSI/MSI-X
[   85.538680] ixgbe 0000:43:00.0: irq 1535 for MSI/MSI-X
[   85.539096] ixgbe 0000:43:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   85.539229] ixgbe 0000:43:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8b:21:d8
[   85.539565] ixgbe 0000:43:00.0: MAC: 2, PHY: 1, PBA No: G43498-000
[   85.539569] ixgbe 0000:43:00.0: PCI Express bandwidth of 32GT/s available
[   85.539571] ixgbe 0000:43:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   85.584327] ixgbe 0000:43:00.0: Intel(R) 10 Gigabit Network Connection
[   85.691224] ixgbe 0000:43:00.1: irq 1536 for MSI/MSI-X
[   85.691301] ixgbe 0000:43:00.1: irq 1537 for MSI/MSI-X
[   85.691372] ixgbe 0000:43:00.1: irq 1538 for MSI/MSI-X
[   85.691446] ixgbe 0000:43:00.1: irq 1539 for MSI/MSI-X
[   85.691515] ixgbe 0000:43:00.1: irq 1540 for MSI/MSI-X
[   85.691593] ixgbe 0000:43:00.1: irq 1541 for MSI/MSI-X
[   85.691668] ixgbe 0000:43:00.1: irq 1542 for MSI/MSI-X
[   85.691741] ixgbe 0000:43:00.1: irq 1543 for MSI/MSI-X
[   85.691814] ixgbe 0000:43:00.1: irq 1544 for MSI/MSI-X
[   85.691884] ixgbe 0000:43:00.1: irq 1545 for MSI/MSI-X
[   85.691959] ixgbe 0000:43:00.1: irq 1546 for MSI/MSI-X
[   85.692029] ixgbe 0000:43:00.1: irq 1547 for MSI/MSI-X
[   85.692106] ixgbe 0000:43:00.1: irq 1548 for MSI/MSI-X
[   85.692222] ixgbe 0000:43:00.1: irq 1549 for MSI/MSI-X
[   85.692297] ixgbe 0000:43:00.1: irq 1550 for MSI/MSI-X
[   85.692536] ixgbe 0000:43:00.1: irq 1551 for MSI/MSI-X
[   85.692615] ixgbe 0000:43:00.1: irq 1552 for MSI/MSI-X
[   85.692687] ixgbe 0000:43:00.1: irq 1553 for MSI/MSI-X
[   85.692761] ixgbe 0000:43:00.1: irq 1554 for MSI/MSI-X
[   85.692839] ixgbe 0000:43:00.1: irq 1555 for MSI/MSI-X
[   85.692911] ixgbe 0000:43:00.1: irq 1556 for MSI/MSI-X
[   85.692998] ixgbe 0000:43:00.1: irq 1557 for MSI/MSI-X
[   85.693072] ixgbe 0000:43:00.1: irq 1558 for MSI/MSI-X
[   85.693145] ixgbe 0000:43:00.1: irq 1559 for MSI/MSI-X
[   85.693258] ixgbe 0000:43:00.1: irq 1560 for MSI/MSI-X
[   85.693333] ixgbe 0000:43:00.1: irq 1561 for MSI/MSI-X
[   85.693407] ixgbe 0000:43:00.1: irq 1562 for MSI/MSI-X
[   85.693484] ixgbe 0000:43:00.1: irq 1563 for MSI/MSI-X
[   85.693561] ixgbe 0000:43:00.1: irq 1564 for MSI/MSI-X
[   85.693645] ixgbe 0000:43:00.1: irq 1565 for MSI/MSI-X
[   85.693728] ixgbe 0000:43:00.1: irq 1566 for MSI/MSI-X
[   85.693965] ixgbe 0000:43:00.1: irq 1567 for MSI/MSI-X
[   85.694039] ixgbe 0000:43:00.1: irq 1568 for MSI/MSI-X
[   85.694118] ixgbe 0000:43:00.1: irq 1569 for MSI/MSI-X
[   85.694218] ixgbe 0000:43:00.1: irq 1570 for MSI/MSI-X
[   85.694295] ixgbe 0000:43:00.1: irq 1571 for MSI/MSI-X
[   85.694368] ixgbe 0000:43:00.1: irq 1572 for MSI/MSI-X
[   85.694454] ixgbe 0000:43:00.1: irq 1573 for MSI/MSI-X
[   85.694527] ixgbe 0000:43:00.1: irq 1574 for MSI/MSI-X
[   85.694599] ixgbe 0000:43:00.1: irq 1575 for MSI/MSI-X
[   85.694676] ixgbe 0000:43:00.1: irq 1576 for MSI/MSI-X
[   85.694759] ixgbe 0000:43:00.1: irq 1577 for MSI/MSI-X
[   85.694833] ixgbe 0000:43:00.1: irq 1578 for MSI/MSI-X
[   85.694915] ixgbe 0000:43:00.1: irq 1579 for MSI/MSI-X
[   85.694986] ixgbe 0000:43:00.1: irq 1580 for MSI/MSI-X
[   85.695065] ixgbe 0000:43:00.1: irq 1581 for MSI/MSI-X
[   85.695142] ixgbe 0000:43:00.1: irq 1582 for MSI/MSI-X
[   85.695488] ixgbe 0000:43:00.1: irq 1583 for MSI/MSI-X
[   85.695567] ixgbe 0000:43:00.1: irq 1584 for MSI/MSI-X
[   85.695642] ixgbe 0000:43:00.1: irq 1585 for MSI/MSI-X
[   85.695722] ixgbe 0000:43:00.1: irq 1586 for MSI/MSI-X
[   85.695797] ixgbe 0000:43:00.1: irq 1587 for MSI/MSI-X
[   85.695872] ixgbe 0000:43:00.1: irq 1588 for MSI/MSI-X
[   85.695955] ixgbe 0000:43:00.1: irq 1589 for MSI/MSI-X
[   85.696031] ixgbe 0000:43:00.1: irq 1590 for MSI/MSI-X
[   85.696132] ixgbe 0000:43:00.1: irq 1591 for MSI/MSI-X
[   85.696244] ixgbe 0000:43:00.1: irq 1592 for MSI/MSI-X
[   85.696318] ixgbe 0000:43:00.1: irq 1593 for MSI/MSI-X
[   85.696404] ixgbe 0000:43:00.1: irq 1594 for MSI/MSI-X
[   85.696482] ixgbe 0000:43:00.1: irq 1595 for MSI/MSI-X
[   85.696555] ixgbe 0000:43:00.1: irq 1596 for MSI/MSI-X
[   85.696633] ixgbe 0000:43:00.1: irq 1597 for MSI/MSI-X
[   85.696707] ixgbe 0000:43:00.1: irq 1598 for MSI/MSI-X
[   85.696972] ixgbe 0000:43:00.1: irq 1599 for MSI/MSI-X
[   85.697413] ixgbe 0000:43:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   85.697585] ixgbe 0000:43:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8b:21:d9
[   85.697927] ixgbe 0000:43:00.1: MAC: 2, PHY: 1, PBA No: G43498-000
[   85.697931] ixgbe 0000:43:00.1: PCI Express bandwidth of 32GT/s available
[   85.697934] ixgbe 0000:43:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   85.735068] ixgbe 0000:43:00.1: Intel(R) 10 Gigabit Network Connection
[   85.828261] ixgbe 0000:61:00.0: irq 1600 for MSI/MSI-X
[   85.828317] ixgbe 0000:61:00.0: irq 1601 for MSI/MSI-X
[   85.828377] ixgbe 0000:61:00.0: irq 1602 for MSI/MSI-X
[   85.828427] ixgbe 0000:61:00.0: irq 1603 for MSI/MSI-X
[   85.828489] ixgbe 0000:61:00.0: irq 1604 for MSI/MSI-X
[   85.828541] ixgbe 0000:61:00.0: irq 1605 for MSI/MSI-X
[   85.828594] ixgbe 0000:61:00.0: irq 1606 for MSI/MSI-X
[   85.828648] ixgbe 0000:61:00.0: irq 1607 for MSI/MSI-X
[   85.828700] ixgbe 0000:61:00.0: irq 1608 for MSI/MSI-X
[   85.828753] ixgbe 0000:61:00.0: irq 1609 for MSI/MSI-X
[   85.828807] ixgbe 0000:61:00.0: irq 1610 for MSI/MSI-X
[   85.828860] ixgbe 0000:61:00.0: irq 1611 for MSI/MSI-X
[   85.828916] ixgbe 0000:61:00.0: irq 1612 for MSI/MSI-X
[   85.829120] ixgbe 0000:61:00.0: irq 1613 for MSI/MSI-X
[   85.829169] ixgbe 0000:61:00.0: irq 1614 for MSI/MSI-X
[   85.829220] ixgbe 0000:61:00.0: irq 1615 for MSI/MSI-X
[   85.829271] ixgbe 0000:61:00.0: irq 1616 for MSI/MSI-X
[   85.829322] ixgbe 0000:61:00.0: irq 1617 for MSI/MSI-X
[   85.829377] ixgbe 0000:61:00.0: irq 1618 for MSI/MSI-X
[   85.829430] ixgbe 0000:61:00.0: irq 1619 for MSI/MSI-X
[   85.829479] ixgbe 0000:61:00.0: irq 1620 for MSI/MSI-X
[   85.829534] ixgbe 0000:61:00.0: irq 1621 for MSI/MSI-X
[   85.829585] ixgbe 0000:61:00.0: irq 1622 for MSI/MSI-X
[   85.829637] ixgbe 0000:61:00.0: irq 1623 for MSI/MSI-X
[   85.829688] ixgbe 0000:61:00.0: irq 1624 for MSI/MSI-X
[   85.829738] ixgbe 0000:61:00.0: irq 1625 for MSI/MSI-X
[   85.829795] ixgbe 0000:61:00.0: irq 1626 for MSI/MSI-X
[   85.829847] ixgbe 0000:61:00.0: irq 1627 for MSI/MSI-X
[   85.829898] ixgbe 0000:61:00.0: irq 1628 for MSI/MSI-X
[   85.830117] ixgbe 0000:61:00.0: irq 1629 for MSI/MSI-X
[   85.830169] ixgbe 0000:61:00.0: irq 1630 for MSI/MSI-X
[   85.830219] ixgbe 0000:61:00.0: irq 1631 for MSI/MSI-X
[   85.830272] ixgbe 0000:61:00.0: irq 1632 for MSI/MSI-X
[   85.830322] ixgbe 0000:61:00.0: irq 1633 for MSI/MSI-X
[   85.830378] ixgbe 0000:61:00.0: irq 1634 for MSI/MSI-X
[   85.830429] ixgbe 0000:61:00.0: irq 1635 for MSI/MSI-X
[   85.830479] ixgbe 0000:61:00.0: irq 1636 for MSI/MSI-X
[   85.830536] ixgbe 0000:61:00.0: irq 1637 for MSI/MSI-X
[   85.830587] ixgbe 0000:61:00.0: irq 1638 for MSI/MSI-X
[   85.830640] ixgbe 0000:61:00.0: irq 1639 for MSI/MSI-X
[   85.830691] ixgbe 0000:61:00.0: irq 1640 for MSI/MSI-X
[   85.830744] ixgbe 0000:61:00.0: irq 1641 for MSI/MSI-X
[   85.830797] ixgbe 0000:61:00.0: irq 1642 for MSI/MSI-X
[   85.830849] ixgbe 0000:61:00.0: irq 1643 for MSI/MSI-X
[   85.830901] ixgbe 0000:61:00.0: irq 1644 for MSI/MSI-X
[   85.831122] ixgbe 0000:61:00.0: irq 1645 for MSI/MSI-X
[   85.831172] ixgbe 0000:61:00.0: irq 1646 for MSI/MSI-X
[   85.831224] ixgbe 0000:61:00.0: irq 1647 for MSI/MSI-X
[   85.831277] ixgbe 0000:61:00.0: irq 1648 for MSI/MSI-X
[   85.831330] ixgbe 0000:61:00.0: irq 1649 for MSI/MSI-X
[   85.831386] ixgbe 0000:61:00.0: irq 1650 for MSI/MSI-X
[   85.831438] ixgbe 0000:61:00.0: irq 1651 for MSI/MSI-X
[   85.831491] ixgbe 0000:61:00.0: irq 1652 for MSI/MSI-X
[   85.831549] ixgbe 0000:61:00.0: irq 1653 for MSI/MSI-X
[   85.831601] ixgbe 0000:61:00.0: irq 1654 for MSI/MSI-X
[   85.831654] ixgbe 0000:61:00.0: irq 1655 for MSI/MSI-X
[   85.831704] ixgbe 0000:61:00.0: irq 1656 for MSI/MSI-X
[   85.831764] ixgbe 0000:61:00.0: irq 1657 for MSI/MSI-X
[   85.831817] ixgbe 0000:61:00.0: irq 1658 for MSI/MSI-X
[   85.831868] ixgbe 0000:61:00.0: irq 1659 for MSI/MSI-X
[   85.831922] ixgbe 0000:61:00.0: irq 1660 for MSI/MSI-X
[   85.832140] ixgbe 0000:61:00.0: irq 1661 for MSI/MSI-X
[   85.832194] ixgbe 0000:61:00.0: irq 1662 for MSI/MSI-X
[   85.832253] ixgbe 0000:61:00.0: irq 1663 for MSI/MSI-X
[   85.832724] ixgbe 0000:61:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   85.832865] ixgbe 0000:61:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:91:65:40
[   85.833206] ixgbe 0000:61:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[   85.833211] ixgbe 0000:61:00.0: PCI Express bandwidth of 32GT/s available
[   85.833212] ixgbe 0000:61:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   85.870210] ixgbe 0000:61:00.0: Intel(R) 10 Gigabit Network Connection
[   85.964326] ixgbe 0000:61:00.1: irq 1664 for MSI/MSI-X
[   85.964380] ixgbe 0000:61:00.1: irq 1665 for MSI/MSI-X
[   85.964431] ixgbe 0000:61:00.1: irq 1666 for MSI/MSI-X
[   85.964485] ixgbe 0000:61:00.1: irq 1667 for MSI/MSI-X
[   85.964549] ixgbe 0000:61:00.1: irq 1668 for MSI/MSI-X
[   85.964609] ixgbe 0000:61:00.1: irq 1669 for MSI/MSI-X
[   85.964663] ixgbe 0000:61:00.1: irq 1670 for MSI/MSI-X
[   85.964716] ixgbe 0000:61:00.1: irq 1671 for MSI/MSI-X
[   85.964771] ixgbe 0000:61:00.1: irq 1672 for MSI/MSI-X
[   85.964826] ixgbe 0000:61:00.1: irq 1673 for MSI/MSI-X
[   85.964882] ixgbe 0000:61:00.1: irq 1674 for MSI/MSI-X
[   85.965089] ixgbe 0000:61:00.1: irq 1675 for MSI/MSI-X
[   85.965148] ixgbe 0000:61:00.1: irq 1676 for MSI/MSI-X
[   85.965201] ixgbe 0000:61:00.1: irq 1677 for MSI/MSI-X
[   85.965253] ixgbe 0000:61:00.1: irq 1678 for MSI/MSI-X
[   85.965306] ixgbe 0000:61:00.1: irq 1679 for MSI/MSI-X
[   85.965359] ixgbe 0000:61:00.1: irq 1680 for MSI/MSI-X
[   85.965411] ixgbe 0000:61:00.1: irq 1681 for MSI/MSI-X
[   85.965464] ixgbe 0000:61:00.1: irq 1682 for MSI/MSI-X
[   85.965531] ixgbe 0000:61:00.1: irq 1683 for MSI/MSI-X
[   85.965584] ixgbe 0000:61:00.1: irq 1684 for MSI/MSI-X
[   85.965636] ixgbe 0000:61:00.1: irq 1685 for MSI/MSI-X
[   85.965689] ixgbe 0000:61:00.1: irq 1686 for MSI/MSI-X
[   85.965742] ixgbe 0000:61:00.1: irq 1687 for MSI/MSI-X
[   85.965797] ixgbe 0000:61:00.1: irq 1688 for MSI/MSI-X
[   85.965850] ixgbe 0000:61:00.1: irq 1689 for MSI/MSI-X
[   85.965902] ixgbe 0000:61:00.1: irq 1690 for MSI/MSI-X
[   85.966114] ixgbe 0000:61:00.1: irq 1691 for MSI/MSI-X
[   85.966167] ixgbe 0000:61:00.1: irq 1692 for MSI/MSI-X
[   85.966222] ixgbe 0000:61:00.1: irq 1693 for MSI/MSI-X
[   85.966277] ixgbe 0000:61:00.1: irq 1694 for MSI/MSI-X
[   85.966334] ixgbe 0000:61:00.1: irq 1695 for MSI/MSI-X
[   85.966387] ixgbe 0000:61:00.1: irq 1696 for MSI/MSI-X
[   85.966439] ixgbe 0000:61:00.1: irq 1697 for MSI/MSI-X
[   85.966492] ixgbe 0000:61:00.1: irq 1698 for MSI/MSI-X
[   85.966555] ixgbe 0000:61:00.1: irq 1699 for MSI/MSI-X
[   85.966609] ixgbe 0000:61:00.1: irq 1700 for MSI/MSI-X
[   85.966664] ixgbe 0000:61:00.1: irq 1701 for MSI/MSI-X
[   85.966719] ixgbe 0000:61:00.1: irq 1702 for MSI/MSI-X
[   85.966773] ixgbe 0000:61:00.1: irq 1703 for MSI/MSI-X
[   85.966828] ixgbe 0000:61:00.1: irq 1704 for MSI/MSI-X
[   85.966886] ixgbe 0000:61:00.1: irq 1705 for MSI/MSI-X
[   85.966941] ixgbe 0000:61:00.1: irq 1706 for MSI/MSI-X
[   85.967167] ixgbe 0000:61:00.1: irq 1707 for MSI/MSI-X
[   85.967222] ixgbe 0000:61:00.1: irq 1708 for MSI/MSI-X
[   85.967275] ixgbe 0000:61:00.1: irq 1709 for MSI/MSI-X
[   85.967326] ixgbe 0000:61:00.1: irq 1710 for MSI/MSI-X
[   85.967383] ixgbe 0000:61:00.1: irq 1711 for MSI/MSI-X
[   85.967441] ixgbe 0000:61:00.1: irq 1712 for MSI/MSI-X
[   85.967497] ixgbe 0000:61:00.1: irq 1713 for MSI/MSI-X
[   85.967561] ixgbe 0000:61:00.1: irq 1714 for MSI/MSI-X
[   85.967625] ixgbe 0000:61:00.1: irq 1715 for MSI/MSI-X
[   85.967682] ixgbe 0000:61:00.1: irq 1716 for MSI/MSI-X
[   85.967739] ixgbe 0000:61:00.1: irq 1717 for MSI/MSI-X
[   85.967797] ixgbe 0000:61:00.1: irq 1718 for MSI/MSI-X
[   85.967863] ixgbe 0000:61:00.1: irq 1719 for MSI/MSI-X
[   85.967922] ixgbe 0000:61:00.1: irq 1720 for MSI/MSI-X
[   85.967980] ixgbe 0000:61:00.1: irq 1721 for MSI/MSI-X
[   85.968049] ixgbe 0000:61:00.1: irq 1722 for MSI/MSI-X
[   85.968280] ixgbe 0000:61:00.1: irq 1723 for MSI/MSI-X
[   85.968340] ixgbe 0000:61:00.1: irq 1724 for MSI/MSI-X
[   85.968399] ixgbe 0000:61:00.1: irq 1725 for MSI/MSI-X
[   85.968457] ixgbe 0000:61:00.1: irq 1726 for MSI/MSI-X
[   85.968532] ixgbe 0000:61:00.1: irq 1727 for MSI/MSI-X
[   85.968912] ixgbe 0000:61:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   85.969045] ixgbe 0000:61:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:91:65:41
[   85.969385] ixgbe 0000:61:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[   85.969389] ixgbe 0000:61:00.1: PCI Express bandwidth of 32GT/s available
[   85.969391] ixgbe 0000:61:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   86.008474] ixgbe 0000:61:00.1: Intel(R) 10 Gigabit Network Connection
[   86.108219] ixgbe 0000:63:00.0: irq 1728 for MSI/MSI-X
[   86.108274] ixgbe 0000:63:00.0: irq 1729 for MSI/MSI-X
[   86.108330] ixgbe 0000:63:00.0: irq 1730 for MSI/MSI-X
[   86.108384] ixgbe 0000:63:00.0: irq 1731 for MSI/MSI-X
[   86.108438] ixgbe 0000:63:00.0: irq 1732 for MSI/MSI-X
[   86.108492] ixgbe 0000:63:00.0: irq 1733 for MSI/MSI-X
[   86.108546] ixgbe 0000:63:00.0: irq 1734 for MSI/MSI-X
[   86.108600] ixgbe 0000:63:00.0: irq 1735 for MSI/MSI-X
[   86.108653] ixgbe 0000:63:00.0: irq 1736 for MSI/MSI-X
[   86.108750] ixgbe 0000:63:00.0: irq 1737 for MSI/MSI-X
[   86.108824] ixgbe 0000:63:00.0: irq 1738 for MSI/MSI-X
[   86.108883] ixgbe 0000:63:00.0: irq 1739 for MSI/MSI-X
[   86.108941] ixgbe 0000:63:00.0: irq 1740 for MSI/MSI-X
[   86.109002] ixgbe 0000:63:00.0: irq 1741 for MSI/MSI-X
[   86.109066] ixgbe 0000:63:00.0: irq 1742 for MSI/MSI-X
[   86.109122] ixgbe 0000:63:00.0: irq 1743 for MSI/MSI-X
[   86.109180] ixgbe 0000:63:00.0: irq 1744 for MSI/MSI-X
[   86.109248] ixgbe 0000:63:00.0: irq 1745 for MSI/MSI-X
[   86.109307] ixgbe 0000:63:00.0: irq 1746 for MSI/MSI-X
[   86.109364] ixgbe 0000:63:00.0: irq 1747 for MSI/MSI-X
[   86.109421] ixgbe 0000:63:00.0: irq 1748 for MSI/MSI-X
[   86.109478] ixgbe 0000:63:00.0: irq 1749 for MSI/MSI-X
[   86.109539] ixgbe 0000:63:00.0: irq 1750 for MSI/MSI-X
[   86.109596] ixgbe 0000:63:00.0: irq 1751 for MSI/MSI-X
[   86.109654] ixgbe 0000:63:00.0: irq 1752 for MSI/MSI-X
[   86.109717] ixgbe 0000:63:00.0: irq 1753 for MSI/MSI-X
[   86.109777] ixgbe 0000:63:00.0: irq 1754 for MSI/MSI-X
[   86.109834] ixgbe 0000:63:00.0: irq 1755 for MSI/MSI-X
[   86.109900] ixgbe 0000:63:00.0: irq 1756 for MSI/MSI-X
[   86.109957] ixgbe 0000:63:00.0: irq 1757 for MSI/MSI-X
[   86.110020] ixgbe 0000:63:00.0: irq 1758 for MSI/MSI-X
[   86.110076] ixgbe 0000:63:00.0: irq 1759 for MSI/MSI-X
[   86.110132] ixgbe 0000:63:00.0: irq 1760 for MSI/MSI-X
[   86.110188] ixgbe 0000:63:00.0: irq 1761 for MSI/MSI-X
[   86.110253] ixgbe 0000:63:00.0: irq 1762 for MSI/MSI-X
[   86.110311] ixgbe 0000:63:00.0: irq 1763 for MSI/MSI-X
[   86.110369] ixgbe 0000:63:00.0: irq 1764 for MSI/MSI-X
[   86.110425] ixgbe 0000:63:00.0: irq 1765 for MSI/MSI-X
[   86.110489] ixgbe 0000:63:00.0: irq 1766 for MSI/MSI-X
[   86.110545] ixgbe 0000:63:00.0: irq 1767 for MSI/MSI-X
[   86.110600] ixgbe 0000:63:00.0: irq 1768 for MSI/MSI-X
[   86.110826] ixgbe 0000:63:00.0: irq 1769 for MSI/MSI-X
[   86.110882] ixgbe 0000:63:00.0: irq 1770 for MSI/MSI-X
[   86.110938] ixgbe 0000:63:00.0: irq 1771 for MSI/MSI-X
[   86.110993] ixgbe 0000:63:00.0: irq 1772 for MSI/MSI-X
[   86.111049] ixgbe 0000:63:00.0: irq 1773 for MSI/MSI-X
[   86.111111] ixgbe 0000:63:00.0: irq 1774 for MSI/MSI-X
[   86.111170] ixgbe 0000:63:00.0: irq 1775 for MSI/MSI-X
[   86.111228] ixgbe 0000:63:00.0: irq 1776 for MSI/MSI-X
[   86.111284] ixgbe 0000:63:00.0: irq 1777 for MSI/MSI-X
[   86.111340] ixgbe 0000:63:00.0: irq 1778 for MSI/MSI-X
[   86.111408] ixgbe 0000:63:00.0: irq 1779 for MSI/MSI-X
[   86.111478] ixgbe 0000:63:00.0: irq 1780 for MSI/MSI-X
[   86.111535] ixgbe 0000:63:00.0: irq 1781 for MSI/MSI-X
[   86.111596] ixgbe 0000:63:00.0: irq 1782 for MSI/MSI-X
[   86.111652] ixgbe 0000:63:00.0: irq 1783 for MSI/MSI-X
[   86.111726] ixgbe 0000:63:00.0: irq 1784 for MSI/MSI-X
[   86.111968] ixgbe 0000:63:00.0: irq 1785 for MSI/MSI-X
[   86.112024] ixgbe 0000:63:00.0: irq 1786 for MSI/MSI-X
[   86.112082] ixgbe 0000:63:00.0: irq 1787 for MSI/MSI-X
[   86.112139] ixgbe 0000:63:00.0: irq 1788 for MSI/MSI-X
[   86.112197] ixgbe 0000:63:00.0: irq 1789 for MSI/MSI-X
[   86.112274] ixgbe 0000:63:00.0: irq 1790 for MSI/MSI-X
[   86.112331] ixgbe 0000:63:00.0: irq 1791 for MSI/MSI-X
[   86.112758] ixgbe 0000:63:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   86.112890] ixgbe 0000:63:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8c:df:c4
[   86.113263] ixgbe 0000:63:00.0: MAC: 2, PHY: 1, PBA No: G43498-007
[   86.113268] ixgbe 0000:63:00.0: PCI Express bandwidth of 32GT/s available
[   86.113270] ixgbe 0000:63:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   86.149814] ixgbe 0000:63:00.0: Intel(R) 10 Gigabit Network Connection
[   86.256690] ixgbe 0000:63:00.1: irq 1792 for MSI/MSI-X
[   86.256752] ixgbe 0000:63:00.1: irq 1793 for MSI/MSI-X
[   86.256810] ixgbe 0000:63:00.1: irq 1794 for MSI/MSI-X
[   86.256867] ixgbe 0000:63:00.1: irq 1795 for MSI/MSI-X
[   86.256951] ixgbe 0000:63:00.1: irq 1796 for MSI/MSI-X
[   86.257011] ixgbe 0000:63:00.1: irq 1797 for MSI/MSI-X
[   86.257091] ixgbe 0000:63:00.1: irq 1798 for MSI/MSI-X
[   86.257296] ixgbe 0000:63:00.1: irq 1799 for MSI/MSI-X
[   86.257356] ixgbe 0000:63:00.1: irq 1800 for MSI/MSI-X
[   86.257424] ixgbe 0000:63:00.1: irq 1801 for MSI/MSI-X
[   86.257484] ixgbe 0000:63:00.1: irq 1802 for MSI/MSI-X
[   86.257572] ixgbe 0000:63:00.1: irq 1803 for MSI/MSI-X
[   86.257636] ixgbe 0000:63:00.1: irq 1804 for MSI/MSI-X
[   86.257694] ixgbe 0000:63:00.1: irq 1805 for MSI/MSI-X
[   86.257752] ixgbe 0000:63:00.1: irq 1806 for MSI/MSI-X
[   86.257810] ixgbe 0000:63:00.1: irq 1807 for MSI/MSI-X
[   86.257868] ixgbe 0000:63:00.1: irq 1808 for MSI/MSI-X
[   86.258068] ixgbe 0000:63:00.1: irq 1809 for MSI/MSI-X
[   86.258126] ixgbe 0000:63:00.1: irq 1810 for MSI/MSI-X
[   86.258185] ixgbe 0000:63:00.1: irq 1811 for MSI/MSI-X
[   86.258248] ixgbe 0000:63:00.1: irq 1812 for MSI/MSI-X
[   86.258306] ixgbe 0000:63:00.1: irq 1813 for MSI/MSI-X
[   86.258365] ixgbe 0000:63:00.1: irq 1814 for MSI/MSI-X
[   86.258580] ixgbe 0000:63:00.1: irq 1815 for MSI/MSI-X
[   86.258652] ixgbe 0000:63:00.1: irq 1816 for MSI/MSI-X
[   86.258711] ixgbe 0000:63:00.1: irq 1817 for MSI/MSI-X
[   86.258768] ixgbe 0000:63:00.1: irq 1818 for MSI/MSI-X
[   86.258826] ixgbe 0000:63:00.1: irq 1819 for MSI/MSI-X
[   86.258897] ixgbe 0000:63:00.1: irq 1820 for MSI/MSI-X
[   86.258957] ixgbe 0000:63:00.1: irq 1821 for MSI/MSI-X
[   86.259015] ixgbe 0000:63:00.1: irq 1822 for MSI/MSI-X
[   86.259072] ixgbe 0000:63:00.1: irq 1823 for MSI/MSI-X
[   86.259130] ixgbe 0000:63:00.1: irq 1824 for MSI/MSI-X
[   86.259188] ixgbe 0000:63:00.1: irq 1825 for MSI/MSI-X
[   86.259246] ixgbe 0000:63:00.1: irq 1826 for MSI/MSI-X
[   86.259305] ixgbe 0000:63:00.1: irq 1827 for MSI/MSI-X
[   86.259368] ixgbe 0000:63:00.1: irq 1828 for MSI/MSI-X
[   86.259426] ixgbe 0000:63:00.1: irq 1829 for MSI/MSI-X
[   86.259484] ixgbe 0000:63:00.1: irq 1830 for MSI/MSI-X
[   86.259710] ixgbe 0000:63:00.1: irq 1831 for MSI/MSI-X
[   86.259769] ixgbe 0000:63:00.1: irq 1832 for MSI/MSI-X
[   86.259827] ixgbe 0000:63:00.1: irq 1833 for MSI/MSI-X
[   86.259885] ixgbe 0000:63:00.1: irq 1834 for MSI/MSI-X
[   86.259951] ixgbe 0000:63:00.1: irq 1835 for MSI/MSI-X
[   86.260013] ixgbe 0000:63:00.1: irq 1836 for MSI/MSI-X
[   86.260072] ixgbe 0000:63:00.1: irq 1837 for MSI/MSI-X
[   86.260129] ixgbe 0000:63:00.1: irq 1838 for MSI/MSI-X
[   86.260188] ixgbe 0000:63:00.1: irq 1839 for MSI/MSI-X
[   86.260245] ixgbe 0000:63:00.1: irq 1840 for MSI/MSI-X
[   86.260303] ixgbe 0000:63:00.1: irq 1841 for MSI/MSI-X
[   86.260362] ixgbe 0000:63:00.1: irq 1842 for MSI/MSI-X
[   86.260424] ixgbe 0000:63:00.1: irq 1843 for MSI/MSI-X
[   86.260490] ixgbe 0000:63:00.1: irq 1844 for MSI/MSI-X
[   86.260548] ixgbe 0000:63:00.1: irq 1845 for MSI/MSI-X
[   86.260606] ixgbe 0000:63:00.1: irq 1846 for MSI/MSI-X
[   86.260847] ixgbe 0000:63:00.1: irq 1847 for MSI/MSI-X
[   86.260973] ixgbe 0000:63:00.1: irq 1848 for MSI/MSI-X
[   86.261032] ixgbe 0000:63:00.1: irq 1849 for MSI/MSI-X
[   86.261089] ixgbe 0000:63:00.1: irq 1850 for MSI/MSI-X
[   86.261148] ixgbe 0000:63:00.1: irq 1851 for MSI/MSI-X
[   86.261211] ixgbe 0000:63:00.1: irq 1852 for MSI/MSI-X
[   86.261270] ixgbe 0000:63:00.1: irq 1853 for MSI/MSI-X
[   86.261329] ixgbe 0000:63:00.1: irq 1854 for MSI/MSI-X
[   86.261397] ixgbe 0000:63:00.1: irq 1855 for MSI/MSI-X
[   86.261761] ixgbe 0000:63:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   86.261905] ixgbe 0000:63:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8c:df:c5
[   86.262252] ixgbe 0000:63:00.1: MAC: 2, PHY: 1, PBA No: G43498-007
[   86.262256] ixgbe 0000:63:00.1: PCI Express bandwidth of 32GT/s available
[   86.262258] ixgbe 0000:63:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   86.298813] ixgbe 0000:63:00.1: Intel(R) 10 Gigabit Network Connection
[   86.391678] ixgbe 0000:85:00.0: irq 1856 for MSI/MSI-X
[   86.391738] ixgbe 0000:85:00.0: irq 1857 for MSI/MSI-X
[   86.391792] ixgbe 0000:85:00.0: irq 1858 for MSI/MSI-X
[   86.391845] ixgbe 0000:85:00.0: irq 1859 for MSI/MSI-X
[   86.391898] ixgbe 0000:85:00.0: irq 1860 for MSI/MSI-X
[   86.391951] ixgbe 0000:85:00.0: irq 1861 for MSI/MSI-X
[   86.392003] ixgbe 0000:85:00.0: irq 1862 for MSI/MSI-X
[   86.392070] ixgbe 0000:85:00.0: irq 1863 for MSI/MSI-X
[   86.392128] ixgbe 0000:85:00.0: irq 1864 for MSI/MSI-X
[   86.392201] ixgbe 0000:85:00.0: irq 1865 for MSI/MSI-X
[   86.392288] ixgbe 0000:85:00.0: irq 1866 for MSI/MSI-X
[   86.392354] ixgbe 0000:85:00.0: irq 1867 for MSI/MSI-X
[   86.392418] ixgbe 0000:85:00.0: irq 1868 for MSI/MSI-X
[   86.392477] ixgbe 0000:85:00.0: irq 1869 for MSI/MSI-X
[   86.392536] ixgbe 0000:85:00.0: irq 1870 for MSI/MSI-X
[   86.392596] ixgbe 0000:85:00.0: irq 1871 for MSI/MSI-X
[   86.392655] ixgbe 0000:85:00.0: irq 1872 for MSI/MSI-X
[   86.392735] ixgbe 0000:85:00.0: irq 1873 for MSI/MSI-X
[   86.392792] ixgbe 0000:85:00.0: irq 1874 for MSI/MSI-X
[   86.392848] ixgbe 0000:85:00.0: irq 1875 for MSI/MSI-X
[   86.392904] ixgbe 0000:85:00.0: irq 1876 for MSI/MSI-X
[   86.392966] ixgbe 0000:85:00.0: irq 1877 for MSI/MSI-X
[   86.393022] ixgbe 0000:85:00.0: irq 1878 for MSI/MSI-X
[   86.393112] ixgbe 0000:85:00.0: irq 1879 for MSI/MSI-X
[   86.393168] ixgbe 0000:85:00.0: irq 1880 for MSI/MSI-X
[   86.393224] ixgbe 0000:85:00.0: irq 1881 for MSI/MSI-X
[   86.393280] ixgbe 0000:85:00.0: irq 1882 for MSI/MSI-X
[   86.393336] ixgbe 0000:85:00.0: irq 1883 for MSI/MSI-X
[   86.393392] ixgbe 0000:85:00.0: irq 1884 for MSI/MSI-X
[   86.393448] ixgbe 0000:85:00.0: irq 1885 for MSI/MSI-X
[   86.393504] ixgbe 0000:85:00.0: irq 1886 for MSI/MSI-X
[   86.393564] ixgbe 0000:85:00.0: irq 1887 for MSI/MSI-X
[   86.393620] ixgbe 0000:85:00.0: irq 1888 for MSI/MSI-X
[   86.393678] ixgbe 0000:85:00.0: irq 1889 for MSI/MSI-X
[   86.393739] ixgbe 0000:85:00.0: irq 1890 for MSI/MSI-X
[   86.393797] ixgbe 0000:85:00.0: irq 1891 for MSI/MSI-X
[   86.393853] ixgbe 0000:85:00.0: irq 1892 for MSI/MSI-X
[   86.394074] ixgbe 0000:85:00.0: irq 1893 for MSI/MSI-X
[   86.394130] ixgbe 0000:85:00.0: irq 1894 for MSI/MSI-X
[   86.394191] ixgbe 0000:85:00.0: irq 1895 for MSI/MSI-X
[   86.394246] ixgbe 0000:85:00.0: irq 1896 for MSI/MSI-X
[   86.394302] ixgbe 0000:85:00.0: irq 1897 for MSI/MSI-X
[   86.394359] ixgbe 0000:85:00.0: irq 1898 for MSI/MSI-X
[   86.394417] ixgbe 0000:85:00.0: irq 1899 for MSI/MSI-X
[   86.394473] ixgbe 0000:85:00.0: irq 1900 for MSI/MSI-X
[   86.394531] ixgbe 0000:85:00.0: irq 1901 for MSI/MSI-X
[   86.394588] ixgbe 0000:85:00.0: irq 1902 for MSI/MSI-X
[   86.394651] ixgbe 0000:85:00.0: irq 1903 for MSI/MSI-X
[   86.394707] ixgbe 0000:85:00.0: irq 1904 for MSI/MSI-X
[   86.394763] ixgbe 0000:85:00.0: irq 1905 for MSI/MSI-X
[   86.394819] ixgbe 0000:85:00.0: irq 1906 for MSI/MSI-X
[   86.394883] ixgbe 0000:85:00.0: irq 1907 for MSI/MSI-X
[   86.394953] ixgbe 0000:85:00.0: irq 1908 for MSI/MSI-X
[   86.395809] ixgbe 0000:85:00.0: irq 1909 for MSI/MSI-X
[   86.395868] ixgbe 0000:85:00.0: irq 1910 for MSI/MSI-X
[   86.395930] ixgbe 0000:85:00.0: irq 1911 for MSI/MSI-X
[   86.395992] ixgbe 0000:85:00.0: irq 1912 for MSI/MSI-X
[   86.396054] ixgbe 0000:85:00.0: irq 1913 for MSI/MSI-X
[   86.396130] ixgbe 0000:85:00.0: irq 1914 for MSI/MSI-X
[   86.396193] ixgbe 0000:85:00.0: irq 1915 for MSI/MSI-X
[   86.396257] ixgbe 0000:85:00.0: irq 1916 for MSI/MSI-X
[   86.396319] ixgbe 0000:85:00.0: irq 1917 for MSI/MSI-X
[   86.396381] ixgbe 0000:85:00.0: irq 1918 for MSI/MSI-X
[   86.396447] ixgbe 0000:85:00.0: irq 1919 for MSI/MSI-X
[   86.396856] ixgbe 0000:85:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   86.396996] ixgbe 0000:85:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:31:7a:30
[   86.397339] ixgbe 0000:85:00.0: MAC: 2, PHY: 1, PBA No: G33590-000
[   86.397362] ixgbe 0000:85:00.0: PCI Express bandwidth of 32GT/s available
[   86.397364] ixgbe 0000:85:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   86.438279] ixgbe 0000:85:00.0: Intel(R) 10 Gigabit Network Connection
[   86.532117] ixgbe 0000:85:00.1: irq 1920 for MSI/MSI-X
[   86.532182] ixgbe 0000:85:00.1: irq 1921 for MSI/MSI-X
[   86.532267] ixgbe 0000:85:00.1: irq 1922 for MSI/MSI-X
[   86.532513] ixgbe 0000:85:00.1: irq 1923 for MSI/MSI-X
[   86.532576] ixgbe 0000:85:00.1: irq 1924 for MSI/MSI-X
[   86.532641] ixgbe 0000:85:00.1: irq 1925 for MSI/MSI-X
[   86.532705] ixgbe 0000:85:00.1: irq 1926 for MSI/MSI-X
[   86.532769] ixgbe 0000:85:00.1: irq 1927 for MSI/MSI-X
[   86.532839] ixgbe 0000:85:00.1: irq 1928 for MSI/MSI-X
[   86.532912] ixgbe 0000:85:00.1: irq 1929 for MSI/MSI-X
[   86.532977] ixgbe 0000:85:00.1: irq 1930 for MSI/MSI-X
[   86.533041] ixgbe 0000:85:00.1: irq 1931 for MSI/MSI-X
[   86.533112] ixgbe 0000:85:00.1: irq 1932 for MSI/MSI-X
[   86.533173] ixgbe 0000:85:00.1: irq 1933 for MSI/MSI-X
[   86.533275] ixgbe 0000:85:00.1: irq 1934 for MSI/MSI-X
[   86.533359] ixgbe 0000:85:00.1: irq 1935 for MSI/MSI-X
[   86.533421] ixgbe 0000:85:00.1: irq 1936 for MSI/MSI-X
[   86.533484] ixgbe 0000:85:00.1: irq 1937 for MSI/MSI-X
[   86.533546] ixgbe 0000:85:00.1: irq 1938 for MSI/MSI-X
[   86.533775] ixgbe 0000:85:00.1: irq 1939 for MSI/MSI-X
[   86.533846] ixgbe 0000:85:00.1: irq 1940 for MSI/MSI-X
[   86.533907] ixgbe 0000:85:00.1: irq 1941 for MSI/MSI-X
[   86.533982] ixgbe 0000:85:00.1: irq 1942 for MSI/MSI-X
[   86.534050] ixgbe 0000:85:00.1: irq 1943 for MSI/MSI-X
[   86.534112] ixgbe 0000:85:00.1: irq 1944 for MSI/MSI-X
[   86.534174] ixgbe 0000:85:00.1: irq 1945 for MSI/MSI-X
[   86.534241] ixgbe 0000:85:00.1: irq 1946 for MSI/MSI-X
[   86.534324] ixgbe 0000:85:00.1: irq 1947 for MSI/MSI-X
[   86.534395] ixgbe 0000:85:00.1: irq 1948 for MSI/MSI-X
[   86.534459] ixgbe 0000:85:00.1: irq 1949 for MSI/MSI-X
[   86.534522] ixgbe 0000:85:00.1: irq 1950 for MSI/MSI-X
[   86.534586] ixgbe 0000:85:00.1: irq 1951 for MSI/MSI-X
[   86.534649] ixgbe 0000:85:00.1: irq 1952 for MSI/MSI-X
[   86.534720] ixgbe 0000:85:00.1: irq 1953 for MSI/MSI-X
[   86.534794] ixgbe 0000:85:00.1: irq 1954 for MSI/MSI-X
[   86.535006] ixgbe 0000:85:00.1: irq 1955 for MSI/MSI-X
[   86.535077] ixgbe 0000:85:00.1: irq 1956 for MSI/MSI-X
[   86.535143] ixgbe 0000:85:00.1: irq 1957 for MSI/MSI-X
[   86.535207] ixgbe 0000:85:00.1: irq 1958 for MSI/MSI-X
[   86.535278] ixgbe 0000:85:00.1: irq 1959 for MSI/MSI-X
[   86.535341] ixgbe 0000:85:00.1: irq 1960 for MSI/MSI-X
[   86.535408] ixgbe 0000:85:00.1: irq 1961 for MSI/MSI-X
[   86.535471] ixgbe 0000:85:00.1: irq 1962 for MSI/MSI-X
[   86.535535] ixgbe 0000:85:00.1: irq 1963 for MSI/MSI-X
[   86.535608] ixgbe 0000:85:00.1: irq 1964 for MSI/MSI-X
[   86.535671] ixgbe 0000:85:00.1: irq 1965 for MSI/MSI-X
[   86.535745] ixgbe 0000:85:00.1: irq 1966 for MSI/MSI-X
[   86.535809] ixgbe 0000:85:00.1: irq 1967 for MSI/MSI-X
[   86.535873] ixgbe 0000:85:00.1: irq 1968 for MSI/MSI-X
[   86.535936] ixgbe 0000:85:00.1: irq 1969 for MSI/MSI-X
[   86.536002] ixgbe 0000:85:00.1: irq 1970 for MSI/MSI-X
[   86.536230] ixgbe 0000:85:00.1: irq 1971 for MSI/MSI-X
[   86.536360] ixgbe 0000:85:00.1: irq 1972 for MSI/MSI-X
[   86.536422] ixgbe 0000:85:00.1: irq 1973 for MSI/MSI-X
[   86.536488] ixgbe 0000:85:00.1: irq 1974 for MSI/MSI-X
[   86.536549] ixgbe 0000:85:00.1: irq 1975 for MSI/MSI-X
[   86.536610] ixgbe 0000:85:00.1: irq 1976 for MSI/MSI-X
[   86.536671] ixgbe 0000:85:00.1: irq 1977 for MSI/MSI-X
[   86.536733] ixgbe 0000:85:00.1: irq 1978 for MSI/MSI-X
[   86.536796] ixgbe 0000:85:00.1: irq 1979 for MSI/MSI-X
[   86.536865] ixgbe 0000:85:00.1: irq 1980 for MSI/MSI-X
[   86.536927] ixgbe 0000:85:00.1: irq 1981 for MSI/MSI-X
[   86.536989] ixgbe 0000:85:00.1: irq 1982 for MSI/MSI-X
[   86.537050] ixgbe 0000:85:00.1: irq 1983 for MSI/MSI-X
[   86.537420] ixgbe 0000:85:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   86.537551] ixgbe 0000:85:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:31:7a:31
[   86.537890] ixgbe 0000:85:00.1: MAC: 2, PHY: 1, PBA No: G33590-000
[   86.537893] ixgbe 0000:85:00.1: PCI Express bandwidth of 32GT/s available
[   86.537895] ixgbe 0000:85:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   86.579615] ixgbe 0000:85:00.1: Intel(R) 10 Gigabit Network Connection
[   86.671216] ixgbe 0000:87:00.0: irq 1984 for MSI/MSI-X
[   86.671461] ixgbe 0000:87:00.0: irq 1985 for MSI/MSI-X
[   86.671526] ixgbe 0000:87:00.0: irq 1986 for MSI/MSI-X
[   86.671610] ixgbe 0000:87:00.0: irq 1987 for MSI/MSI-X
[   86.671675] ixgbe 0000:87:00.0: irq 1988 for MSI/MSI-X
[   86.671741] ixgbe 0000:87:00.0: irq 1989 for MSI/MSI-X
[   86.671806] ixgbe 0000:87:00.0: irq 1990 for MSI/MSI-X
[   86.671872] ixgbe 0000:87:00.0: irq 1991 for MSI/MSI-X
[   86.671948] ixgbe 0000:87:00.0: irq 1992 for MSI/MSI-X
[   86.672022] ixgbe 0000:87:00.0: irq 1993 for MSI/MSI-X
[   86.672105] ixgbe 0000:87:00.0: irq 1994 for MSI/MSI-X
[   86.672169] ixgbe 0000:87:00.0: irq 1995 for MSI/MSI-X
[   86.672232] ixgbe 0000:87:00.0: irq 1996 for MSI/MSI-X
[   86.672295] ixgbe 0000:87:00.0: irq 1997 for MSI/MSI-X
[   86.672362] ixgbe 0000:87:00.0: irq 1998 for MSI/MSI-X
[   86.672431] ixgbe 0000:87:00.0: irq 1999 for MSI/MSI-X
[   86.672495] ixgbe 0000:87:00.0: irq 2000 for MSI/MSI-X
[   86.672724] ixgbe 0000:87:00.0: irq 2001 for MSI/MSI-X
[   86.672796] ixgbe 0000:87:00.0: irq 2002 for MSI/MSI-X
[   86.672859] ixgbe 0000:87:00.0: irq 2003 for MSI/MSI-X
[   86.672923] ixgbe 0000:87:00.0: irq 2004 for MSI/MSI-X
[   86.672987] ixgbe 0000:87:00.0: irq 2005 for MSI/MSI-X
[   86.673051] ixgbe 0000:87:00.0: irq 2006 for MSI/MSI-X
[   86.673115] ixgbe 0000:87:00.0: irq 2007 for MSI/MSI-X
[   86.673181] ixgbe 0000:87:00.0: irq 2008 for MSI/MSI-X
[   86.673243] ixgbe 0000:87:00.0: irq 2009 for MSI/MSI-X
[   86.673315] ixgbe 0000:87:00.0: irq 2010 for MSI/MSI-X
[   86.673380] ixgbe 0000:87:00.0: irq 2011 for MSI/MSI-X
[   86.673462] ixgbe 0000:87:00.0: irq 2012 for MSI/MSI-X
[   86.673529] ixgbe 0000:87:00.0: irq 2013 for MSI/MSI-X
[   86.673593] ixgbe 0000:87:00.0: irq 2014 for MSI/MSI-X
[   86.673657] ixgbe 0000:87:00.0: irq 2015 for MSI/MSI-X
[   86.673722] ixgbe 0000:87:00.0: irq 2016 for MSI/MSI-X
[   86.673969] ixgbe 0000:87:00.0: irq 2017 for MSI/MSI-X
[   86.674063] ixgbe 0000:87:00.0: irq 2018 for MSI/MSI-X
[   86.674135] ixgbe 0000:87:00.0: irq 2019 for MSI/MSI-X
[   86.674201] ixgbe 0000:87:00.0: irq 2020 for MSI/MSI-X
[   86.674262] ixgbe 0000:87:00.0: irq 2021 for MSI/MSI-X
[   86.674324] ixgbe 0000:87:00.0: irq 2022 for MSI/MSI-X
[   86.674385] ixgbe 0000:87:00.0: irq 2023 for MSI/MSI-X
[   86.674476] ixgbe 0000:87:00.0: irq 2024 for MSI/MSI-X
[   86.674539] ixgbe 0000:87:00.0: irq 2025 for MSI/MSI-X
[   86.674611] ixgbe 0000:87:00.0: irq 2026 for MSI/MSI-X
[   86.674674] ixgbe 0000:87:00.0: irq 2027 for MSI/MSI-X
[   86.674739] ixgbe 0000:87:00.0: irq 2028 for MSI/MSI-X
[   86.674807] ixgbe 0000:87:00.0: irq 2029 for MSI/MSI-X
[   86.674871] ixgbe 0000:87:00.0: irq 2030 for MSI/MSI-X
[   86.674936] ixgbe 0000:87:00.0: irq 2031 for MSI/MSI-X
[   86.675003] ixgbe 0000:87:00.0: irq 2032 for MSI/MSI-X
[   86.675233] ixgbe 0000:87:00.0: irq 2033 for MSI/MSI-X
[   86.675304] ixgbe 0000:87:00.0: irq 2034 for MSI/MSI-X
[   86.675367] ixgbe 0000:87:00.0: irq 2035 for MSI/MSI-X
[   86.675438] ixgbe 0000:87:00.0: irq 2036 for MSI/MSI-X
[   86.675502] ixgbe 0000:87:00.0: irq 2037 for MSI/MSI-X
[   86.675565] ixgbe 0000:87:00.0: irq 2038 for MSI/MSI-X
[   86.675632] ixgbe 0000:87:00.0: irq 2039 for MSI/MSI-X
[   86.675695] ixgbe 0000:87:00.0: irq 2040 for MSI/MSI-X
[   86.675760] ixgbe 0000:87:00.0: irq 2041 for MSI/MSI-X
[   86.675830] ixgbe 0000:87:00.0: irq 2042 for MSI/MSI-X
[   86.675895] ixgbe 0000:87:00.0: irq 2043 for MSI/MSI-X
[   86.675958] ixgbe 0000:87:00.0: irq 2044 for MSI/MSI-X
[   86.676022] ixgbe 0000:87:00.0: irq 2045 for MSI/MSI-X
[   86.676086] ixgbe 0000:87:00.0: irq 2046 for MSI/MSI-X
[   86.676159] ixgbe 0000:87:00.0: irq 2047 for MSI/MSI-X
[   86.676563] ixgbe 0000:87:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   86.676695] ixgbe 0000:87:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8b:22:00
[   86.677029] ixgbe 0000:87:00.0: MAC: 2, PHY: 1, PBA No: G43498-000
[   86.677034] ixgbe 0000:87:00.0: PCI Express bandwidth of 32GT/s available
[   86.677035] ixgbe 0000:87:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   86.713692] ixgbe 0000:87:00.0: Intel(R) 10 Gigabit Network Connection
[   86.818523] ixgbe 0000:87:00.1: irq 2048 for MSI/MSI-X
[   86.818615] ixgbe 0000:87:00.1: irq 2049 for MSI/MSI-X
[   86.818684] ixgbe 0000:87:00.1: irq 2050 for MSI/MSI-X
[   86.818749] ixgbe 0000:87:00.1: irq 2051 for MSI/MSI-X
[   86.818815] ixgbe 0000:87:00.1: irq 2052 for MSI/MSI-X
[   86.818881] ixgbe 0000:87:00.1: irq 2053 for MSI/MSI-X
[   86.818946] ixgbe 0000:87:00.1: irq 2054 for MSI/MSI-X
[   86.819012] ixgbe 0000:87:00.1: irq 2055 for MSI/MSI-X
[   86.819083] ixgbe 0000:87:00.1: irq 2056 for MSI/MSI-X
[   86.819146] ixgbe 0000:87:00.1: irq 2057 for MSI/MSI-X
[   86.819212] ixgbe 0000:87:00.1: irq 2058 for MSI/MSI-X
[   86.819276] ixgbe 0000:87:00.1: irq 2059 for MSI/MSI-X
[   86.819339] ixgbe 0000:87:00.1: irq 2060 for MSI/MSI-X
[   86.819404] ixgbe 0000:87:00.1: irq 2061 for MSI/MSI-X
[   86.819471] ixgbe 0000:87:00.1: irq 2062 for MSI/MSI-X
[   86.819534] ixgbe 0000:87:00.1: irq 2063 for MSI/MSI-X
[   86.819766] ixgbe 0000:87:00.1: irq 2064 for MSI/MSI-X
[   86.819830] ixgbe 0000:87:00.1: irq 2065 for MSI/MSI-X
[   86.819897] ixgbe 0000:87:00.1: irq 2066 for MSI/MSI-X
[   86.819960] ixgbe 0000:87:00.1: irq 2067 for MSI/MSI-X
[   86.820036] ixgbe 0000:87:00.1: irq 2068 for MSI/MSI-X
[   86.820100] ixgbe 0000:87:00.1: irq 2069 for MSI/MSI-X
[   86.820164] ixgbe 0000:87:00.1: irq 2070 for MSI/MSI-X
[   86.820247] ixgbe 0000:87:00.1: irq 2071 for MSI/MSI-X
[   86.820314] ixgbe 0000:87:00.1: irq 2072 for MSI/MSI-X
[   86.820375] ixgbe 0000:87:00.1: irq 2073 for MSI/MSI-X
[   86.820437] ixgbe 0000:87:00.1: irq 2074 for MSI/MSI-X
[   86.820500] ixgbe 0000:87:00.1: irq 2075 for MSI/MSI-X
[   86.820561] ixgbe 0000:87:00.1: irq 2076 for MSI/MSI-X
[   86.820642] ixgbe 0000:87:00.1: irq 2077 for MSI/MSI-X
[   86.820711] ixgbe 0000:87:00.1: irq 2078 for MSI/MSI-X
[   86.820935] ixgbe 0000:87:00.1: irq 2079 for MSI/MSI-X
[   86.821004] ixgbe 0000:87:00.1: irq 2080 for MSI/MSI-X
[   86.821068] ixgbe 0000:87:00.1: irq 2081 for MSI/MSI-X
[   86.821132] ixgbe 0000:87:00.1: irq 2082 for MSI/MSI-X
[   86.821196] ixgbe 0000:87:00.1: irq 2083 for MSI/MSI-X
[   86.821263] ixgbe 0000:87:00.1: irq 2084 for MSI/MSI-X
[   86.821328] ixgbe 0000:87:00.1: irq 2085 for MSI/MSI-X
[   86.821391] ixgbe 0000:87:00.1: irq 2086 for MSI/MSI-X
[   86.821455] ixgbe 0000:87:00.1: irq 2087 for MSI/MSI-X
[   86.821523] ixgbe 0000:87:00.1: irq 2088 for MSI/MSI-X
[   86.821586] ixgbe 0000:87:00.1: irq 2089 for MSI/MSI-X
[   86.821661] ixgbe 0000:87:00.1: irq 2090 for MSI/MSI-X
[   86.821723] ixgbe 0000:87:00.1: irq 2091 for MSI/MSI-X
[   86.821786] ixgbe 0000:87:00.1: irq 2092 for MSI/MSI-X
[   86.821849] ixgbe 0000:87:00.1: irq 2093 for MSI/MSI-X
[   86.821912] ixgbe 0000:87:00.1: irq 2094 for MSI/MSI-X
[   86.822141] ixgbe 0000:87:00.1: irq 2095 for MSI/MSI-X
[   86.822212] ixgbe 0000:87:00.1: irq 2096 for MSI/MSI-X
[   86.822276] ixgbe 0000:87:00.1: irq 2097 for MSI/MSI-X
[   86.822341] ixgbe 0000:87:00.1: irq 2098 for MSI/MSI-X
[   86.822404] ixgbe 0000:87:00.1: irq 2099 for MSI/MSI-X
[   86.822468] ixgbe 0000:87:00.1: irq 2100 for MSI/MSI-X
[   86.822532] ixgbe 0000:87:00.1: irq 2101 for MSI/MSI-X
[   86.822601] ixgbe 0000:87:00.1: irq 2102 for MSI/MSI-X
[   86.822665] ixgbe 0000:87:00.1: irq 2103 for MSI/MSI-X
[   86.822737] ixgbe 0000:87:00.1: irq 2104 for MSI/MSI-X
[   86.822802] ixgbe 0000:87:00.1: irq 2105 for MSI/MSI-X
[   86.822865] ixgbe 0000:87:00.1: irq 2106 for MSI/MSI-X
[   86.822930] ixgbe 0000:87:00.1: irq 2107 for MSI/MSI-X
[   86.822994] ixgbe 0000:87:00.1: irq 2108 for MSI/MSI-X
[   86.823058] ixgbe 0000:87:00.1: irq 2109 for MSI/MSI-X
[   86.823124] ixgbe 0000:87:00.1: irq 2110 for MSI/MSI-X
[   86.823371] ixgbe 0000:87:00.1: irq 2111 for MSI/MSI-X
[   86.823750] ixgbe 0000:87:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   86.823882] ixgbe 0000:87:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8b:22:01
[   86.824216] ixgbe 0000:87:00.1: MAC: 2, PHY: 1, PBA No: G43498-000
[   86.824221] ixgbe 0000:87:00.1: PCI Express bandwidth of 32GT/s available
[   86.824223] ixgbe 0000:87:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   86.862866] ixgbe 0000:87:00.1: Intel(R) 10 Gigabit Network Connection
[   86.959187] ixgbe 0000:a1:00.0: irq 2112 for MSI/MSI-X
[   86.959303] ixgbe 0000:a1:00.0: irq 2113 for MSI/MSI-X
[   86.959372] ixgbe 0000:a1:00.0: irq 2114 for MSI/MSI-X
[   86.959441] ixgbe 0000:a1:00.0: irq 2115 for MSI/MSI-X
[   86.959700] ixgbe 0000:a1:00.0: irq 2116 for MSI/MSI-X
[   86.959786] ixgbe 0000:a1:00.0: irq 2117 for MSI/MSI-X
[   86.959858] ixgbe 0000:a1:00.0: irq 2118 for MSI/MSI-X
[   86.959928] ixgbe 0000:a1:00.0: irq 2119 for MSI/MSI-X
[   86.960005] ixgbe 0000:a1:00.0: irq 2120 for MSI/MSI-X
[   86.960134] ixgbe 0000:a1:00.0: irq 2121 for MSI/MSI-X
[   86.960208] ixgbe 0000:a1:00.0: irq 2122 for MSI/MSI-X
[   86.960278] ixgbe 0000:a1:00.0: irq 2123 for MSI/MSI-X
[   86.960348] ixgbe 0000:a1:00.0: irq 2124 for MSI/MSI-X
[   86.960421] ixgbe 0000:a1:00.0: irq 2125 for MSI/MSI-X
[   86.960526] ixgbe 0000:a1:00.0: irq 2126 for MSI/MSI-X
[   86.960599] ixgbe 0000:a1:00.0: irq 2127 for MSI/MSI-X
[   86.960690] ixgbe 0000:a1:00.0: irq 2128 for MSI/MSI-X
[   86.960890] ixgbe 0000:a1:00.0: irq 2129 for MSI/MSI-X
[   86.961123] ixgbe 0000:a1:00.0: irq 2130 for MSI/MSI-X
[   86.961221] ixgbe 0000:a1:00.0: irq 2131 for MSI/MSI-X
[   86.961304] ixgbe 0000:a1:00.0: irq 2132 for MSI/MSI-X
[   86.961376] ixgbe 0000:a1:00.0: irq 2133 for MSI/MSI-X
[   86.961480] ixgbe 0000:a1:00.0: irq 2134 for MSI/MSI-X
[   86.961552] ixgbe 0000:a1:00.0: irq 2135 for MSI/MSI-X
[   86.961628] ixgbe 0000:a1:00.0: irq 2136 for MSI/MSI-X
[   86.961700] ixgbe 0000:a1:00.0: irq 2137 for MSI/MSI-X
[   86.961938] ixgbe 0000:a1:00.0: irq 2138 for MSI/MSI-X
[   86.962011] ixgbe 0000:a1:00.0: irq 2139 for MSI/MSI-X
[   86.962081] ixgbe 0000:a1:00.0: irq 2140 for MSI/MSI-X
[   86.962153] ixgbe 0000:a1:00.0: irq 2141 for MSI/MSI-X
[   86.962223] ixgbe 0000:a1:00.0: irq 2142 for MSI/MSI-X
[   86.962320] ixgbe 0000:a1:00.0: irq 2143 for MSI/MSI-X
[   86.962400] ixgbe 0000:a1:00.0: irq 2144 for MSI/MSI-X
[   86.962736] ixgbe 0000:a1:00.0: irq 2145 for MSI/MSI-X
[   86.962822] ixgbe 0000:a1:00.0: irq 2146 for MSI/MSI-X
[   86.962892] ixgbe 0000:a1:00.0: irq 2147 for MSI/MSI-X
[   86.962969] ixgbe 0000:a1:00.0: irq 2148 for MSI/MSI-X
[   86.963066] ixgbe 0000:a1:00.0: irq 2149 for MSI/MSI-X
[   86.963136] ixgbe 0000:a1:00.0: irq 2150 for MSI/MSI-X
[   86.963205] ixgbe 0000:a1:00.0: irq 2151 for MSI/MSI-X
[   86.963280] ixgbe 0000:a1:00.0: irq 2152 for MSI/MSI-X
[   86.963368] ixgbe 0000:a1:00.0: irq 2153 for MSI/MSI-X
[   86.963449] ixgbe 0000:a1:00.0: irq 2154 for MSI/MSI-X
[   86.963613] ixgbe 0000:a1:00.0: irq 2155 for MSI/MSI-X
[   86.963684] ixgbe 0000:a1:00.0: irq 2156 for MSI/MSI-X
[   86.963754] ixgbe 0000:a1:00.0: irq 2157 for MSI/MSI-X
[   86.963833] ixgbe 0000:a1:00.0: irq 2158 for MSI/MSI-X
[   86.963908] ixgbe 0000:a1:00.0: irq 2159 for MSI/MSI-X
[   86.964035] ixgbe 0000:a1:00.0: irq 2160 for MSI/MSI-X
[   86.964357] ixgbe 0000:a1:00.0: irq 2161 for MSI/MSI-X
[   86.964430] ixgbe 0000:a1:00.0: irq 2162 for MSI/MSI-X
[   86.964500] ixgbe 0000:a1:00.0: irq 2163 for MSI/MSI-X
[   86.964585] ixgbe 0000:a1:00.0: irq 2164 for MSI/MSI-X
[   86.964688] ixgbe 0000:a1:00.0: irq 2165 for MSI/MSI-X
[   86.964758] ixgbe 0000:a1:00.0: irq 2166 for MSI/MSI-X
[   86.964840] ixgbe 0000:a1:00.0: irq 2167 for MSI/MSI-X
[   86.964917] ixgbe 0000:a1:00.0: irq 2168 for MSI/MSI-X
[   86.964986] ixgbe 0000:a1:00.0: irq 2169 for MSI/MSI-X
[   86.965059] ixgbe 0000:a1:00.0: irq 2170 for MSI/MSI-X
[   86.965127] ixgbe 0000:a1:00.0: irq 2171 for MSI/MSI-X
[   86.965268] ixgbe 0000:a1:00.0: irq 2172 for MSI/MSI-X
[   86.965338] ixgbe 0000:a1:00.0: irq 2173 for MSI/MSI-X
[   86.965407] ixgbe 0000:a1:00.0: irq 2174 for MSI/MSI-X
[   86.965476] ixgbe 0000:a1:00.0: irq 2175 for MSI/MSI-X
[   86.966182] ixgbe 0000:a1:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   86.966354] ixgbe 0000:a1:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:91:65:d8
[   86.966801] ixgbe 0000:a1:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[   86.966819] ixgbe 0000:a1:00.0: PCI Express bandwidth of 32GT/s available
[   86.966821] ixgbe 0000:a1:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   87.003597] ixgbe 0000:a1:00.0: Intel(R) 10 Gigabit Network Connection
[   87.098036] ixgbe 0000:a1:00.1: irq 2176 for MSI/MSI-X
[   87.098111] ixgbe 0000:a1:00.1: irq 2177 for MSI/MSI-X
[   87.098183] ixgbe 0000:a1:00.1: irq 2178 for MSI/MSI-X
[   87.098254] ixgbe 0000:a1:00.1: irq 2179 for MSI/MSI-X
[   87.098326] ixgbe 0000:a1:00.1: irq 2180 for MSI/MSI-X
[   87.098406] ixgbe 0000:a1:00.1: irq 2181 for MSI/MSI-X
[   87.098477] ixgbe 0000:a1:00.1: irq 2182 for MSI/MSI-X
[   87.098548] ixgbe 0000:a1:00.1: irq 2183 for MSI/MSI-X
[   87.098618] ixgbe 0000:a1:00.1: irq 2184 for MSI/MSI-X
[   87.098689] ixgbe 0000:a1:00.1: irq 2185 for MSI/MSI-X
[   87.098760] ixgbe 0000:a1:00.1: irq 2186 for MSI/MSI-X
[   87.099016] ixgbe 0000:a1:00.1: irq 2187 for MSI/MSI-X
[   87.099087] ixgbe 0000:a1:00.1: irq 2188 for MSI/MSI-X
[   87.099170] ixgbe 0000:a1:00.1: irq 2189 for MSI/MSI-X
[   87.099240] ixgbe 0000:a1:00.1: irq 2190 for MSI/MSI-X
[   87.099311] ixgbe 0000:a1:00.1: irq 2191 for MSI/MSI-X
[   87.099380] ixgbe 0000:a1:00.1: irq 2192 for MSI/MSI-X
[   87.099450] ixgbe 0000:a1:00.1: irq 2193 for MSI/MSI-X
[   87.099518] ixgbe 0000:a1:00.1: irq 2194 for MSI/MSI-X
[   87.099586] ixgbe 0000:a1:00.1: irq 2195 for MSI/MSI-X
[   87.099655] ixgbe 0000:a1:00.1: irq 2196 for MSI/MSI-X
[   87.099734] ixgbe 0000:a1:00.1: irq 2197 for MSI/MSI-X
[   87.099803] ixgbe 0000:a1:00.1: irq 2198 for MSI/MSI-X
[   87.099873] ixgbe 0000:a1:00.1: irq 2199 for MSI/MSI-X
[   87.099966] ixgbe 0000:a1:00.1: irq 2200 for MSI/MSI-X
[   87.100034] ixgbe 0000:a1:00.1: irq 2201 for MSI/MSI-X
[   87.100102] ixgbe 0000:a1:00.1: irq 2202 for MSI/MSI-X
[   87.100313] ixgbe 0000:a1:00.1: irq 2203 for MSI/MSI-X
[   87.100382] ixgbe 0000:a1:00.1: irq 2204 for MSI/MSI-X
[   87.100457] ixgbe 0000:a1:00.1: irq 2205 for MSI/MSI-X
[   87.100526] ixgbe 0000:a1:00.1: irq 2206 for MSI/MSI-X
[   87.100594] ixgbe 0000:a1:00.1: irq 2207 for MSI/MSI-X
[   87.100663] ixgbe 0000:a1:00.1: irq 2208 for MSI/MSI-X
[   87.100732] ixgbe 0000:a1:00.1: irq 2209 for MSI/MSI-X
[   87.100800] ixgbe 0000:a1:00.1: irq 2210 for MSI/MSI-X
[   87.100868] ixgbe 0000:a1:00.1: irq 2211 for MSI/MSI-X
[   87.100976] ixgbe 0000:a1:00.1: irq 2212 for MSI/MSI-X
[   87.101052] ixgbe 0000:a1:00.1: irq 2213 for MSI/MSI-X
[   87.101120] ixgbe 0000:a1:00.1: irq 2214 for MSI/MSI-X
[   87.101188] ixgbe 0000:a1:00.1: irq 2215 for MSI/MSI-X
[   87.101256] ixgbe 0000:a1:00.1: irq 2216 for MSI/MSI-X
[   87.101325] ixgbe 0000:a1:00.1: irq 2217 for MSI/MSI-X
[   87.101394] ixgbe 0000:a1:00.1: irq 2218 for MSI/MSI-X
[   87.101622] ixgbe 0000:a1:00.1: irq 2219 for MSI/MSI-X
[   87.101690] ixgbe 0000:a1:00.1: irq 2220 for MSI/MSI-X
[   87.101771] ixgbe 0000:a1:00.1: irq 2221 for MSI/MSI-X
[   87.101839] ixgbe 0000:a1:00.1: irq 2222 for MSI/MSI-X
[   87.101908] ixgbe 0000:a1:00.1: irq 2223 for MSI/MSI-X
[   87.102011] ixgbe 0000:a1:00.1: irq 2224 for MSI/MSI-X
[   87.102080] ixgbe 0000:a1:00.1: irq 2225 for MSI/MSI-X
[   87.102156] ixgbe 0000:a1:00.1: irq 2226 for MSI/MSI-X
[   87.102228] ixgbe 0000:a1:00.1: irq 2227 for MSI/MSI-X
[   87.102296] ixgbe 0000:a1:00.1: irq 2228 for MSI/MSI-X
[   87.102375] ixgbe 0000:a1:00.1: irq 2229 for MSI/MSI-X
[   87.102453] ixgbe 0000:a1:00.1: irq 2230 for MSI/MSI-X
[   87.102521] ixgbe 0000:a1:00.1: irq 2231 for MSI/MSI-X
[   87.102591] ixgbe 0000:a1:00.1: irq 2232 for MSI/MSI-X
[   87.102663] ixgbe 0000:a1:00.1: irq 2233 for MSI/MSI-X
[   87.102731] ixgbe 0000:a1:00.1: irq 2234 for MSI/MSI-X
[   87.102973] ixgbe 0000:a1:00.1: irq 2235 for MSI/MSI-X
[   87.103042] ixgbe 0000:a1:00.1: irq 2236 for MSI/MSI-X
[   87.103117] ixgbe 0000:a1:00.1: irq 2237 for MSI/MSI-X
[   87.103186] ixgbe 0000:a1:00.1: irq 2238 for MSI/MSI-X
[   87.103270] ixgbe 0000:a1:00.1: irq 2239 for MSI/MSI-X
[   87.103669] ixgbe 0000:a1:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   87.103801] ixgbe 0000:a1:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:91:65:d9
[   87.104284] ixgbe 0000:a1:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[   87.104288] ixgbe 0000:a1:00.1: PCI Express bandwidth of 32GT/s available
[   87.104290] ixgbe 0000:a1:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   87.140730] ixgbe 0000:a1:00.1: Intel(R) 10 Gigabit Network Connection
[   87.231761] ixgbe 0000:a3:00.0: irq 2240 for MSI/MSI-X
[   87.231833] ixgbe 0000:a3:00.0: irq 2241 for MSI/MSI-X
[   87.231902] ixgbe 0000:a3:00.0: irq 2242 for MSI/MSI-X
[   87.231977] ixgbe 0000:a3:00.0: irq 2243 for MSI/MSI-X
[   87.232046] ixgbe 0000:a3:00.0: irq 2244 for MSI/MSI-X
[   87.232123] ixgbe 0000:a3:00.0: irq 2245 for MSI/MSI-X
[   87.232199] ixgbe 0000:a3:00.0: irq 2246 for MSI/MSI-X
[   87.232268] ixgbe 0000:a3:00.0: irq 2247 for MSI/MSI-X
[   87.232337] ixgbe 0000:a3:00.0: irq 2248 for MSI/MSI-X
[   87.232563] ixgbe 0000:a3:00.0: irq 2249 for MSI/MSI-X
[   87.232634] ixgbe 0000:a3:00.0: irq 2250 for MSI/MSI-X
[   87.232709] ixgbe 0000:a3:00.0: irq 2251 for MSI/MSI-X
[   87.232778] ixgbe 0000:a3:00.0: irq 2252 for MSI/MSI-X
[   87.232848] ixgbe 0000:a3:00.0: irq 2253 for MSI/MSI-X
[   87.232917] ixgbe 0000:a3:00.0: irq 2254 for MSI/MSI-X
[   87.232986] ixgbe 0000:a3:00.0: irq 2255 for MSI/MSI-X
[   87.233054] ixgbe 0000:a3:00.0: irq 2256 for MSI/MSI-X
[   87.233157] ixgbe 0000:a3:00.0: irq 2257 for MSI/MSI-X
[   87.233227] ixgbe 0000:a3:00.0: irq 2258 for MSI/MSI-X
[   87.233301] ixgbe 0000:a3:00.0: irq 2259 for MSI/MSI-X
[   87.233369] ixgbe 0000:a3:00.0: irq 2260 for MSI/MSI-X
[   87.233437] ixgbe 0000:a3:00.0: irq 2261 for MSI/MSI-X
[   87.233507] ixgbe 0000:a3:00.0: irq 2262 for MSI/MSI-X
[   87.233575] ixgbe 0000:a3:00.0: irq 2263 for MSI/MSI-X
[   87.233645] ixgbe 0000:a3:00.0: irq 2264 for MSI/MSI-X
[   87.233881] ixgbe 0000:a3:00.0: irq 2265 for MSI/MSI-X
[   87.233950] ixgbe 0000:a3:00.0: irq 2266 for MSI/MSI-X
[   87.234025] ixgbe 0000:a3:00.0: irq 2267 for MSI/MSI-X
[   87.234094] ixgbe 0000:a3:00.0: irq 2268 for MSI/MSI-X
[   87.234201] ixgbe 0000:a3:00.0: irq 2269 for MSI/MSI-X
[   87.234270] ixgbe 0000:a3:00.0: irq 2270 for MSI/MSI-X
[   87.234338] ixgbe 0000:a3:00.0: irq 2271 for MSI/MSI-X
[   87.234407] ixgbe 0000:a3:00.0: irq 2272 for MSI/MSI-X
[   87.234475] ixgbe 0000:a3:00.0: irq 2273 for MSI/MSI-X
[   87.234544] ixgbe 0000:a3:00.0: irq 2274 for MSI/MSI-X
[   87.234621] ixgbe 0000:a3:00.0: irq 2275 for MSI/MSI-X
[   87.234690] ixgbe 0000:a3:00.0: irq 2276 for MSI/MSI-X
[   87.234758] ixgbe 0000:a3:00.0: irq 2277 for MSI/MSI-X
[   87.234827] ixgbe 0000:a3:00.0: irq 2278 for MSI/MSI-X
[   87.234895] ixgbe 0000:a3:00.0: irq 2279 for MSI/MSI-X
[   87.234964] ixgbe 0000:a3:00.0: irq 2280 for MSI/MSI-X
[   87.235208] ixgbe 0000:a3:00.0: irq 2281 for MSI/MSI-X
[   87.235277] ixgbe 0000:a3:00.0: irq 2282 for MSI/MSI-X
[   87.235351] ixgbe 0000:a3:00.0: irq 2283 for MSI/MSI-X
[   87.235422] ixgbe 0000:a3:00.0: irq 2284 for MSI/MSI-X
[   87.235490] ixgbe 0000:a3:00.0: irq 2285 for MSI/MSI-X
[   87.235558] ixgbe 0000:a3:00.0: irq 2286 for MSI/MSI-X
[   87.235641] ixgbe 0000:a3:00.0: irq 2287 for MSI/MSI-X
[   87.235710] ixgbe 0000:a3:00.0: irq 2288 for MSI/MSI-X
[   87.235781] ixgbe 0000:a3:00.0: irq 2289 for MSI/MSI-X
[   87.235852] ixgbe 0000:a3:00.0: irq 2290 for MSI/MSI-X
[   87.235929] ixgbe 0000:a3:00.0: irq 2291 for MSI/MSI-X
[   87.235998] ixgbe 0000:a3:00.0: irq 2292 for MSI/MSI-X
[   87.236068] ixgbe 0000:a3:00.0: irq 2293 for MSI/MSI-X
[   87.236150] ixgbe 0000:a3:00.0: irq 2294 for MSI/MSI-X
[   87.236219] ixgbe 0000:a3:00.0: irq 2295 for MSI/MSI-X
[   87.236287] ixgbe 0000:a3:00.0: irq 2296 for MSI/MSI-X
[   87.236506] ixgbe 0000:a3:00.0: irq 2297 for MSI/MSI-X
[   87.236578] ixgbe 0000:a3:00.0: irq 2298 for MSI/MSI-X
[   87.236655] ixgbe 0000:a3:00.0: irq 2299 for MSI/MSI-X
[   87.236726] ixgbe 0000:a3:00.0: irq 2300 for MSI/MSI-X
[   87.236797] ixgbe 0000:a3:00.0: irq 2301 for MSI/MSI-X
[   87.236867] ixgbe 0000:a3:00.0: irq 2302 for MSI/MSI-X
[   87.236947] ixgbe 0000:a3:00.0: irq 2303 for MSI/MSI-X
[   87.237351] ixgbe 0000:a3:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   87.237483] ixgbe 0000:a3:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8b:30:fc
[   87.237822] ixgbe 0000:a3:00.0: MAC: 2, PHY: 1, PBA No: G43498-000
[   87.237827] ixgbe 0000:a3:00.0: PCI Express bandwidth of 32GT/s available
[   87.237828] ixgbe 0000:a3:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   87.274298] ixgbe 0000:a3:00.0: Intel(R) 10 Gigabit Network Connection
[   87.380530] ixgbe 0000:a3:00.1: irq 2304 for MSI/MSI-X
[   87.380607] ixgbe 0000:a3:00.1: irq 2305 for MSI/MSI-X
[   87.380675] ixgbe 0000:a3:00.1: irq 2306 for MSI/MSI-X
[   87.380743] ixgbe 0000:a3:00.1: irq 2307 for MSI/MSI-X
[   87.380810] ixgbe 0000:a3:00.1: irq 2308 for MSI/MSI-X
[   87.380878] ixgbe 0000:a3:00.1: irq 2309 for MSI/MSI-X
[   87.380947] ixgbe 0000:a3:00.1: irq 2310 for MSI/MSI-X
[   87.381173] ixgbe 0000:a3:00.1: irq 2311 for MSI/MSI-X
[   87.381242] ixgbe 0000:a3:00.1: irq 2312 for MSI/MSI-X
[   87.381344] ixgbe 0000:a3:00.1: irq 2313 for MSI/MSI-X
[   87.381418] ixgbe 0000:a3:00.1: irq 2314 for MSI/MSI-X
[   87.381491] ixgbe 0000:a3:00.1: irq 2315 for MSI/MSI-X
[   87.381569] ixgbe 0000:a3:00.1: irq 2316 for MSI/MSI-X
[   87.381643] ixgbe 0000:a3:00.1: irq 2317 for MSI/MSI-X
[   87.381717] ixgbe 0000:a3:00.1: irq 2318 for MSI/MSI-X
[   87.381791] ixgbe 0000:a3:00.1: irq 2319 for MSI/MSI-X
[   87.381866] ixgbe 0000:a3:00.1: irq 2320 for MSI/MSI-X
[   87.381945] ixgbe 0000:a3:00.1: irq 2321 for MSI/MSI-X
[   87.382019] ixgbe 0000:a3:00.1: irq 2322 for MSI/MSI-X
[   87.382093] ixgbe 0000:a3:00.1: irq 2323 for MSI/MSI-X
[   87.382167] ixgbe 0000:a3:00.1: irq 2324 for MSI/MSI-X
[   87.382240] ixgbe 0000:a3:00.1: irq 2325 for MSI/MSI-X
[   87.382324] ixgbe 0000:a3:00.1: irq 2326 for MSI/MSI-X
[   87.382547] ixgbe 0000:a3:00.1: irq 2327 for MSI/MSI-X
[   87.382621] ixgbe 0000:a3:00.1: irq 2328 for MSI/MSI-X
[   87.382701] ixgbe 0000:a3:00.1: irq 2329 for MSI/MSI-X
[   87.382777] ixgbe 0000:a3:00.1: irq 2330 for MSI/MSI-X
[   87.382853] ixgbe 0000:a3:00.1: irq 2331 for MSI/MSI-X
[   87.382931] ixgbe 0000:a3:00.1: irq 2332 for MSI/MSI-X
[   87.383007] ixgbe 0000:a3:00.1: irq 2333 for MSI/MSI-X
[   87.383083] ixgbe 0000:a3:00.1: irq 2334 for MSI/MSI-X
[   87.383160] ixgbe 0000:a3:00.1: irq 2335 for MSI/MSI-X
[   87.383236] ixgbe 0000:a3:00.1: irq 2336 for MSI/MSI-X
[   87.383346] ixgbe 0000:a3:00.1: irq 2337 for MSI/MSI-X
[   87.383420] ixgbe 0000:a3:00.1: irq 2338 for MSI/MSI-X
[   87.383494] ixgbe 0000:a3:00.1: irq 2339 for MSI/MSI-X
[   87.383568] ixgbe 0000:a3:00.1: irq 2340 for MSI/MSI-X
[   87.383641] ixgbe 0000:a3:00.1: irq 2341 for MSI/MSI-X
[   87.383717] ixgbe 0000:a3:00.1: irq 2342 for MSI/MSI-X
[   87.383955] ixgbe 0000:a3:00.1: irq 2343 for MSI/MSI-X
[   87.384030] ixgbe 0000:a3:00.1: irq 2344 for MSI/MSI-X
[   87.384111] ixgbe 0000:a3:00.1: irq 2345 for MSI/MSI-X
[   87.384189] ixgbe 0000:a3:00.1: irq 2346 for MSI/MSI-X
[   87.384262] ixgbe 0000:a3:00.1: irq 2347 for MSI/MSI-X
[   87.384349] ixgbe 0000:a3:00.1: irq 2348 for MSI/MSI-X
[   87.384426] ixgbe 0000:a3:00.1: irq 2349 for MSI/MSI-X
[   87.384500] ixgbe 0000:a3:00.1: irq 2350 for MSI/MSI-X
[   87.384573] ixgbe 0000:a3:00.1: irq 2351 for MSI/MSI-X
[   87.384650] ixgbe 0000:a3:00.1: irq 2352 for MSI/MSI-X
[   87.384729] ixgbe 0000:a3:00.1: irq 2353 for MSI/MSI-X
[   87.384806] ixgbe 0000:a3:00.1: irq 2354 for MSI/MSI-X
[   87.384880] ixgbe 0000:a3:00.1: irq 2355 for MSI/MSI-X
[   87.384954] ixgbe 0000:a3:00.1: irq 2356 for MSI/MSI-X
[   87.385028] ixgbe 0000:a3:00.1: irq 2357 for MSI/MSI-X
[   87.385107] ixgbe 0000:a3:00.1: irq 2358 for MSI/MSI-X
[   87.385336] ixgbe 0000:a3:00.1: irq 2359 for MSI/MSI-X
[   87.385409] ixgbe 0000:a3:00.1: irq 2360 for MSI/MSI-X
[   87.385488] ixgbe 0000:a3:00.1: irq 2361 for MSI/MSI-X
[   87.385563] ixgbe 0000:a3:00.1: irq 2362 for MSI/MSI-X
[   87.385639] ixgbe 0000:a3:00.1: irq 2363 for MSI/MSI-X
[   87.385713] ixgbe 0000:a3:00.1: irq 2364 for MSI/MSI-X
[   87.385787] ixgbe 0000:a3:00.1: irq 2365 for MSI/MSI-X
[   87.385876] ixgbe 0000:a3:00.1: irq 2366 for MSI/MSI-X
[   87.385960] ixgbe 0000:a3:00.1: irq 2367 for MSI/MSI-X
[   87.386363] ixgbe 0000:a3:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   87.386496] ixgbe 0000:a3:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8b:30:fd
[   87.386866] ixgbe 0000:a3:00.1: MAC: 2, PHY: 1, PBA No: G43498-000
[   87.386870] ixgbe 0000:a3:00.1: PCI Express bandwidth of 32GT/s available
[   87.386871] ixgbe 0000:a3:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   87.423479] ixgbe 0000:a3:00.1: Intel(R) 10 Gigabit Network Connection
[   87.515086] ixgbe 0000:c1:00.0: irq 2368 for MSI/MSI-X
[   87.515168] ixgbe 0000:c1:00.0: irq 2369 for MSI/MSI-X
[   87.515271] ixgbe 0000:c1:00.0: irq 2370 for MSI/MSI-X
[   87.515346] ixgbe 0000:c1:00.0: irq 2371 for MSI/MSI-X
[   87.515421] ixgbe 0000:c1:00.0: irq 2372 for MSI/MSI-X
[   87.515684] ixgbe 0000:c1:00.0: irq 2373 for MSI/MSI-X
[   87.515761] ixgbe 0000:c1:00.0: irq 2374 for MSI/MSI-X
[   87.515844] ixgbe 0000:c1:00.0: irq 2375 for MSI/MSI-X
[   87.515920] ixgbe 0000:c1:00.0: irq 2376 for MSI/MSI-X
[   87.515997] ixgbe 0000:c1:00.0: irq 2377 for MSI/MSI-X
[   87.516072] ixgbe 0000:c1:00.0: irq 2378 for MSI/MSI-X
[   87.516149] ixgbe 0000:c1:00.0: irq 2379 for MSI/MSI-X
[   87.516223] ixgbe 0000:c1:00.0: irq 2380 for MSI/MSI-X
[   87.516297] ixgbe 0000:c1:00.0: irq 2381 for MSI/MSI-X
[   87.516370] ixgbe 0000:c1:00.0: irq 2382 for MSI/MSI-X
[   87.516444] ixgbe 0000:c1:00.0: irq 2383 for MSI/MSI-X
[   87.516536] ixgbe 0000:c1:00.0: irq 2384 for MSI/MSI-X
[   87.516617] ixgbe 0000:c1:00.0: irq 2385 for MSI/MSI-X
[   87.516695] ixgbe 0000:c1:00.0: irq 2386 for MSI/MSI-X
[   87.516771] ixgbe 0000:c1:00.0: irq 2387 for MSI/MSI-X
[   87.516845] ixgbe 0000:c1:00.0: irq 2388 for MSI/MSI-X
[   87.517084] ixgbe 0000:c1:00.0: irq 2389 for MSI/MSI-X
[   87.517158] ixgbe 0000:c1:00.0: irq 2390 for MSI/MSI-X
[   87.517235] ixgbe 0000:c1:00.0: irq 2391 for MSI/MSI-X
[   87.517310] ixgbe 0000:c1:00.0: irq 2392 for MSI/MSI-X
[   87.517388] ixgbe 0000:c1:00.0: irq 2393 for MSI/MSI-X
[   87.517476] ixgbe 0000:c1:00.0: irq 2394 for MSI/MSI-X
[   87.517554] ixgbe 0000:c1:00.0: irq 2395 for MSI/MSI-X
[   87.517631] ixgbe 0000:c1:00.0: irq 2396 for MSI/MSI-X
[   87.517705] ixgbe 0000:c1:00.0: irq 2397 for MSI/MSI-X
[   87.517791] ixgbe 0000:c1:00.0: irq 2398 for MSI/MSI-X
[   87.517865] ixgbe 0000:c1:00.0: irq 2399 for MSI/MSI-X
[   87.517941] ixgbe 0000:c1:00.0: irq 2400 for MSI/MSI-X
[   87.518023] ixgbe 0000:c1:00.0: irq 2401 for MSI/MSI-X
[   87.518099] ixgbe 0000:c1:00.0: irq 2402 for MSI/MSI-X
[   87.518174] ixgbe 0000:c1:00.0: irq 2403 for MSI/MSI-X
[   87.518248] ixgbe 0000:c1:00.0: irq 2404 for MSI/MSI-X
[   87.519172] ixgbe 0000:c1:00.0: irq 2405 for MSI/MSI-X
[   87.519252] ixgbe 0000:c1:00.0: irq 2406 for MSI/MSI-X
[   87.519328] ixgbe 0000:c1:00.0: irq 2407 for MSI/MSI-X
[   87.519408] ixgbe 0000:c1:00.0: irq 2408 for MSI/MSI-X
[   87.519507] ixgbe 0000:c1:00.0: irq 2409 for MSI/MSI-X
[   87.519587] ixgbe 0000:c1:00.0: irq 2410 for MSI/MSI-X
[   87.519667] ixgbe 0000:c1:00.0: irq 2411 for MSI/MSI-X
[   87.519741] ixgbe 0000:c1:00.0: irq 2412 for MSI/MSI-X
[   87.519819] ixgbe 0000:c1:00.0: irq 2413 for MSI/MSI-X
[   87.519895] ixgbe 0000:c1:00.0: irq 2414 for MSI/MSI-X
[   87.519974] ixgbe 0000:c1:00.0: irq 2415 for MSI/MSI-X
[   87.520053] ixgbe 0000:c1:00.0: irq 2416 for MSI/MSI-X
[   87.520136] ixgbe 0000:c1:00.0: irq 2417 for MSI/MSI-X
[   87.520213] ixgbe 0000:c1:00.0: irq 2418 for MSI/MSI-X
[   87.520288] ixgbe 0000:c1:00.0: irq 2419 for MSI/MSI-X
[   87.520365] ixgbe 0000:c1:00.0: irq 2420 for MSI/MSI-X
[   87.520734] ixgbe 0000:c1:00.0: irq 2421 for MSI/MSI-X
[   87.520808] ixgbe 0000:c1:00.0: irq 2422 for MSI/MSI-X
[   87.520883] ixgbe 0000:c1:00.0: irq 2423 for MSI/MSI-X
[   87.520966] ixgbe 0000:c1:00.0: irq 2424 for MSI/MSI-X
[   87.521043] ixgbe 0000:c1:00.0: irq 2425 for MSI/MSI-X
[   87.521117] ixgbe 0000:c1:00.0: irq 2426 for MSI/MSI-X
[   87.521190] ixgbe 0000:c1:00.0: irq 2427 for MSI/MSI-X
[   87.521263] ixgbe 0000:c1:00.0: irq 2428 for MSI/MSI-X
[   87.521336] ixgbe 0000:c1:00.0: irq 2429 for MSI/MSI-X
[   87.521409] ixgbe 0000:c1:00.0: irq 2430 for MSI/MSI-X
[   87.521503] ixgbe 0000:c1:00.0: irq 2431 for MSI/MSI-X
[   87.521958] ixgbe 0000:c1:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   87.522096] ixgbe 0000:c1:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:91:1a:54
[   87.522438] ixgbe 0000:c1:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[   87.522444] ixgbe 0000:c1:00.0: PCI Express bandwidth of 32GT/s available
[   87.522446] ixgbe 0000:c1:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   87.559094] ixgbe 0000:c1:00.0: Intel(R) 10 Gigabit Network Connection
[   87.652931] ixgbe 0000:c1:00.1: irq 2432 for MSI/MSI-X
[   87.653016] ixgbe 0000:c1:00.1: irq 2433 for MSI/MSI-X
[   87.653100] ixgbe 0000:c1:00.1: irq 2434 for MSI/MSI-X
[   87.653220] ixgbe 0000:c1:00.1: irq 2435 for MSI/MSI-X
[   87.653292] ixgbe 0000:c1:00.1: irq 2436 for MSI/MSI-X
[   87.653363] ixgbe 0000:c1:00.1: irq 2437 for MSI/MSI-X
[   87.653435] ixgbe 0000:c1:00.1: irq 2438 for MSI/MSI-X
[   87.653765] ixgbe 0000:c1:00.1: irq 2439 for MSI/MSI-X
[   87.653845] ixgbe 0000:c1:00.1: irq 2440 for MSI/MSI-X
[   87.653945] ixgbe 0000:c1:00.1: irq 2441 for MSI/MSI-X
[   87.654019] ixgbe 0000:c1:00.1: irq 2442 for MSI/MSI-X
[   87.654099] ixgbe 0000:c1:00.1: irq 2443 for MSI/MSI-X
[   87.654173] ixgbe 0000:c1:00.1: irq 2444 for MSI/MSI-X
[   87.654320] ixgbe 0000:c1:00.1: irq 2445 for MSI/MSI-X
[   87.654398] ixgbe 0000:c1:00.1: irq 2446 for MSI/MSI-X
[   87.654479] ixgbe 0000:c1:00.1: irq 2447 for MSI/MSI-X
[   87.654555] ixgbe 0000:c1:00.1: irq 2448 for MSI/MSI-X
[   87.654710] ixgbe 0000:c1:00.1: irq 2449 for MSI/MSI-X
[   87.654787] ixgbe 0000:c1:00.1: irq 2450 for MSI/MSI-X
[   87.654867] ixgbe 0000:c1:00.1: irq 2451 for MSI/MSI-X
[   87.654959] ixgbe 0000:c1:00.1: irq 2452 for MSI/MSI-X
[   87.655077] ixgbe 0000:c1:00.1: irq 2453 for MSI/MSI-X
[   87.655156] ixgbe 0000:c1:00.1: irq 2454 for MSI/MSI-X
[   87.655679] ixgbe 0000:c1:00.1: irq 2455 for MSI/MSI-X
[   87.655758] ixgbe 0000:c1:00.1: irq 2456 for MSI/MSI-X
[   87.655832] ixgbe 0000:c1:00.1: irq 2457 for MSI/MSI-X
[   87.655912] ixgbe 0000:c1:00.1: irq 2458 for MSI/MSI-X
[   87.656035] ixgbe 0000:c1:00.1: irq 2459 for MSI/MSI-X
[   87.656109] ixgbe 0000:c1:00.1: irq 2460 for MSI/MSI-X
[   87.656181] ixgbe 0000:c1:00.1: irq 2461 for MSI/MSI-X
[   87.656322] ixgbe 0000:c1:00.1: irq 2462 for MSI/MSI-X
[   87.656415] ixgbe 0000:c1:00.1: irq 2463 for MSI/MSI-X
[   87.656488] ixgbe 0000:c1:00.1: irq 2464 for MSI/MSI-X
[   87.656566] ixgbe 0000:c1:00.1: irq 2465 for MSI/MSI-X
[   87.656736] ixgbe 0000:c1:00.1: irq 2466 for MSI/MSI-X
[   87.656805] ixgbe 0000:c1:00.1: irq 2467 for MSI/MSI-X
[   87.656876] ixgbe 0000:c1:00.1: irq 2468 for MSI/MSI-X
[   87.656949] ixgbe 0000:c1:00.1: irq 2469 for MSI/MSI-X
[   87.657023] ixgbe 0000:c1:00.1: irq 2470 for MSI/MSI-X
[   87.657380] ixgbe 0000:c1:00.1: irq 2471 for MSI/MSI-X
[   87.657458] ixgbe 0000:c1:00.1: irq 2472 for MSI/MSI-X
[   87.657539] ixgbe 0000:c1:00.1: irq 2473 for MSI/MSI-X
[   87.657701] ixgbe 0000:c1:00.1: irq 2474 for MSI/MSI-X
[   87.657775] ixgbe 0000:c1:00.1: irq 2475 for MSI/MSI-X
[   87.657852] ixgbe 0000:c1:00.1: irq 2476 for MSI/MSI-X
[   87.657942] ixgbe 0000:c1:00.1: irq 2477 for MSI/MSI-X
[   87.658066] ixgbe 0000:c1:00.1: irq 2478 for MSI/MSI-X
[   87.658155] ixgbe 0000:c1:00.1: irq 2479 for MSI/MSI-X
[   87.658230] ixgbe 0000:c1:00.1: irq 2480 for MSI/MSI-X
[   87.658308] ixgbe 0000:c1:00.1: irq 2481 for MSI/MSI-X
[   87.658412] ixgbe 0000:c1:00.1: irq 2482 for MSI/MSI-X
[   87.658486] ixgbe 0000:c1:00.1: irq 2483 for MSI/MSI-X
[   87.658560] ixgbe 0000:c1:00.1: irq 2484 for MSI/MSI-X
[   87.658631] ixgbe 0000:c1:00.1: irq 2485 for MSI/MSI-X
[   87.658709] ixgbe 0000:c1:00.1: irq 2486 for MSI/MSI-X
[   87.659073] ixgbe 0000:c1:00.1: irq 2487 for MSI/MSI-X
[   87.659147] ixgbe 0000:c1:00.1: irq 2488 for MSI/MSI-X
[   87.659220] ixgbe 0000:c1:00.1: irq 2489 for MSI/MSI-X
[   87.659306] ixgbe 0000:c1:00.1: irq 2490 for MSI/MSI-X
[   87.659389] ixgbe 0000:c1:00.1: irq 2491 for MSI/MSI-X
[   87.659461] ixgbe 0000:c1:00.1: irq 2492 for MSI/MSI-X
[   87.659533] ixgbe 0000:c1:00.1: irq 2493 for MSI/MSI-X
[   87.659605] ixgbe 0000:c1:00.1: irq 2494 for MSI/MSI-X
[   87.659852] ixgbe 0000:c1:00.1: irq 2495 for MSI/MSI-X
[   87.660693] ixgbe 0000:c1:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   87.660846] ixgbe 0000:c1:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:91:1a:55
[   87.661189] ixgbe 0000:c1:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[   87.661194] ixgbe 0000:c1:00.1: PCI Express bandwidth of 32GT/s available
[   87.661195] ixgbe 0000:c1:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   87.698078] ixgbe 0000:c1:00.1: Intel(R) 10 Gigabit Network Connection
[   87.790624] ixgbe 0000:c3:00.0: irq 2496 for MSI/MSI-X
[   87.790875] ixgbe 0000:c3:00.0: irq 2497 for MSI/MSI-X
[   87.790949] ixgbe 0000:c3:00.0: irq 2498 for MSI/MSI-X
[   87.791022] ixgbe 0000:c3:00.0: irq 2499 for MSI/MSI-X
[   87.791096] ixgbe 0000:c3:00.0: irq 2500 for MSI/MSI-X
[   87.791173] ixgbe 0000:c3:00.0: irq 2501 for MSI/MSI-X
[   87.791249] ixgbe 0000:c3:00.0: irq 2502 for MSI/MSI-X
[   87.791325] ixgbe 0000:c3:00.0: irq 2503 for MSI/MSI-X
[   87.791402] ixgbe 0000:c3:00.0: irq 2504 for MSI/MSI-X
[   87.791478] ixgbe 0000:c3:00.0: irq 2505 for MSI/MSI-X
[   87.791554] ixgbe 0000:c3:00.0: irq 2506 for MSI/MSI-X
[   87.791630] ixgbe 0000:c3:00.0: irq 2507 for MSI/MSI-X
[   87.791705] ixgbe 0000:c3:00.0: irq 2508 for MSI/MSI-X
[   87.791784] ixgbe 0000:c3:00.0: irq 2509 for MSI/MSI-X
[   87.791895] ixgbe 0000:c3:00.0: irq 2510 for MSI/MSI-X
[   87.791968] ixgbe 0000:c3:00.0: irq 2511 for MSI/MSI-X
[   87.792042] ixgbe 0000:c3:00.0: irq 2512 for MSI/MSI-X
[   87.792253] ixgbe 0000:c3:00.0: irq 2513 for MSI/MSI-X
[   87.792344] ixgbe 0000:c3:00.0: irq 2514 for MSI/MSI-X
[   87.792423] ixgbe 0000:c3:00.0: irq 2515 for MSI/MSI-X
[   87.792502] ixgbe 0000:c3:00.0: irq 2516 for MSI/MSI-X
[   87.792588] ixgbe 0000:c3:00.0: irq 2517 for MSI/MSI-X
[   87.792667] ixgbe 0000:c3:00.0: irq 2518 for MSI/MSI-X
[   87.792746] ixgbe 0000:c3:00.0: irq 2519 for MSI/MSI-X
[   87.792832] ixgbe 0000:c3:00.0: irq 2520 for MSI/MSI-X
[   87.792911] ixgbe 0000:c3:00.0: irq 2521 for MSI/MSI-X
[   87.792989] ixgbe 0000:c3:00.0: irq 2522 for MSI/MSI-X
[   87.793067] ixgbe 0000:c3:00.0: irq 2523 for MSI/MSI-X
[   87.793145] ixgbe 0000:c3:00.0: irq 2524 for MSI/MSI-X
[   87.793232] ixgbe 0000:c3:00.0: irq 2525 for MSI/MSI-X
[   87.793310] ixgbe 0000:c3:00.0: irq 2526 for MSI/MSI-X
[   87.793390] ixgbe 0000:c3:00.0: irq 2527 for MSI/MSI-X
[   87.793468] ixgbe 0000:c3:00.0: irq 2528 for MSI/MSI-X
[   87.793750] ixgbe 0000:c3:00.0: irq 2529 for MSI/MSI-X
[   87.793841] ixgbe 0000:c3:00.0: irq 2530 for MSI/MSI-X
[   87.793924] ixgbe 0000:c3:00.0: irq 2531 for MSI/MSI-X
[   87.794003] ixgbe 0000:c3:00.0: irq 2532 for MSI/MSI-X
[   87.794086] ixgbe 0000:c3:00.0: irq 2533 for MSI/MSI-X
[   87.794178] ixgbe 0000:c3:00.0: irq 2534 for MSI/MSI-X
[   87.794254] ixgbe 0000:c3:00.0: irq 2535 for MSI/MSI-X
[   87.794330] ixgbe 0000:c3:00.0: irq 2536 for MSI/MSI-X
[   87.794408] ixgbe 0000:c3:00.0: irq 2537 for MSI/MSI-X
[   87.794496] ixgbe 0000:c3:00.0: irq 2538 for MSI/MSI-X
[   87.794573] ixgbe 0000:c3:00.0: irq 2539 for MSI/MSI-X
[   87.794649] ixgbe 0000:c3:00.0: irq 2540 for MSI/MSI-X
[   87.794732] ixgbe 0000:c3:00.0: irq 2541 for MSI/MSI-X
[   87.794817] ixgbe 0000:c3:00.0: irq 2542 for MSI/MSI-X
[   87.794908] ixgbe 0000:c3:00.0: irq 2543 for MSI/MSI-X
[   87.794987] ixgbe 0000:c3:00.0: irq 2544 for MSI/MSI-X
[   87.795240] ixgbe 0000:c3:00.0: irq 2545 for MSI/MSI-X
[   87.795316] ixgbe 0000:c3:00.0: irq 2546 for MSI/MSI-X
[   87.795395] ixgbe 0000:c3:00.0: irq 2547 for MSI/MSI-X
[   87.795471] ixgbe 0000:c3:00.0: irq 2548 for MSI/MSI-X
[   87.795553] ixgbe 0000:c3:00.0: irq 2549 for MSI/MSI-X
[   87.795632] ixgbe 0000:c3:00.0: irq 2550 for MSI/MSI-X
[   87.795711] ixgbe 0000:c3:00.0: irq 2551 for MSI/MSI-X
[   87.795787] ixgbe 0000:c3:00.0: irq 2552 for MSI/MSI-X
[   87.795879] ixgbe 0000:c3:00.0: irq 2553 for MSI/MSI-X
[   87.795955] ixgbe 0000:c3:00.0: irq 2554 for MSI/MSI-X
[   87.796034] ixgbe 0000:c3:00.0: irq 2555 for MSI/MSI-X
[   87.796111] ixgbe 0000:c3:00.0: irq 2556 for MSI/MSI-X
[   87.796194] ixgbe 0000:c3:00.0: irq 2557 for MSI/MSI-X
[   87.796272] ixgbe 0000:c3:00.0: irq 2558 for MSI/MSI-X
[   87.796360] ixgbe 0000:c3:00.0: irq 2559 for MSI/MSI-X
[   87.796779] ixgbe 0000:c3:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   87.796909] ixgbe 0000:c3:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8c:e6:64
[   87.797248] ixgbe 0000:c3:00.0: MAC: 2, PHY: 1, PBA No: G43498-007
[   87.797252] ixgbe 0000:c3:00.0: PCI Express bandwidth of 32GT/s available
[   87.797254] ixgbe 0000:c3:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   87.838122] ixgbe 0000:c3:00.0: Intel(R) 10 Gigabit Network Connection
[   87.947707] ixgbe 0000:c3:00.1: irq 2560 for MSI/MSI-X
[   87.947794] ixgbe 0000:c3:00.1: irq 2561 for MSI/MSI-X
[   87.947879] ixgbe 0000:c3:00.1: irq 2562 for MSI/MSI-X
[   87.947963] ixgbe 0000:c3:00.1: irq 2563 for MSI/MSI-X
[   87.948083] ixgbe 0000:c3:00.1: irq 2564 for MSI/MSI-X
[   87.948167] ixgbe 0000:c3:00.1: irq 2565 for MSI/MSI-X
[   87.948261] ixgbe 0000:c3:00.1: irq 2566 for MSI/MSI-X
[   87.948343] ixgbe 0000:c3:00.1: irq 2567 for MSI/MSI-X
[   87.948425] ixgbe 0000:c3:00.1: irq 2568 for MSI/MSI-X
[   87.948510] ixgbe 0000:c3:00.1: irq 2569 for MSI/MSI-X
[   87.948600] ixgbe 0000:c3:00.1: irq 2570 for MSI/MSI-X
[   87.948687] ixgbe 0000:c3:00.1: irq 2571 for MSI/MSI-X
[   87.948769] ixgbe 0000:c3:00.1: irq 2572 for MSI/MSI-X
[   87.948850] ixgbe 0000:c3:00.1: irq 2573 for MSI/MSI-X
[   87.948934] ixgbe 0000:c3:00.1: irq 2574 for MSI/MSI-X
[   87.949199] ixgbe 0000:c3:00.1: irq 2575 for MSI/MSI-X
[   87.949284] ixgbe 0000:c3:00.1: irq 2576 for MSI/MSI-X
[   87.949364] ixgbe 0000:c3:00.1: irq 2577 for MSI/MSI-X
[   87.949456] ixgbe 0000:c3:00.1: irq 2578 for MSI/MSI-X
[   87.949542] ixgbe 0000:c3:00.1: irq 2579 for MSI/MSI-X
[   87.949624] ixgbe 0000:c3:00.1: irq 2580 for MSI/MSI-X
[   87.949704] ixgbe 0000:c3:00.1: irq 2581 for MSI/MSI-X
[   87.949783] ixgbe 0000:c3:00.1: irq 2582 for MSI/MSI-X
[   87.949872] ixgbe 0000:c3:00.1: irq 2583 for MSI/MSI-X
[   87.949951] ixgbe 0000:c3:00.1: irq 2584 for MSI/MSI-X
[   87.950078] ixgbe 0000:c3:00.1: irq 2585 for MSI/MSI-X
[   87.950164] ixgbe 0000:c3:00.1: irq 2586 for MSI/MSI-X
[   87.950243] ixgbe 0000:c3:00.1: irq 2587 for MSI/MSI-X
[   87.950325] ixgbe 0000:c3:00.1: irq 2588 for MSI/MSI-X
[   87.950407] ixgbe 0000:c3:00.1: irq 2589 for MSI/MSI-X
[   87.950492] ixgbe 0000:c3:00.1: irq 2590 for MSI/MSI-X
[   87.950733] ixgbe 0000:c3:00.1: irq 2591 for MSI/MSI-X
[   87.950838] ixgbe 0000:c3:00.1: irq 2592 for MSI/MSI-X
[   87.950921] ixgbe 0000:c3:00.1: irq 2593 for MSI/MSI-X
[   87.951078] ixgbe 0000:c3:00.1: irq 2594 for MSI/MSI-X
[   87.951159] ixgbe 0000:c3:00.1: irq 2595 for MSI/MSI-X
[   87.951240] ixgbe 0000:c3:00.1: irq 2596 for MSI/MSI-X
[   87.951322] ixgbe 0000:c3:00.1: irq 2597 for MSI/MSI-X
[   87.951406] ixgbe 0000:c3:00.1: irq 2598 for MSI/MSI-X
[   87.951498] ixgbe 0000:c3:00.1: irq 2599 for MSI/MSI-X
[   87.951582] ixgbe 0000:c3:00.1: irq 2600 for MSI/MSI-X
[   87.951663] ixgbe 0000:c3:00.1: irq 2601 for MSI/MSI-X
[   87.951752] ixgbe 0000:c3:00.1: irq 2602 for MSI/MSI-X
[   87.951835] ixgbe 0000:c3:00.1: irq 2603 for MSI/MSI-X
[   87.951919] ixgbe 0000:c3:00.1: irq 2604 for MSI/MSI-X
[   87.952062] ixgbe 0000:c3:00.1: irq 2605 for MSI/MSI-X
[   87.952144] ixgbe 0000:c3:00.1: irq 2606 for MSI/MSI-X
[   87.952370] ixgbe 0000:c3:00.1: irq 2607 for MSI/MSI-X
[   87.952452] ixgbe 0000:c3:00.1: irq 2608 for MSI/MSI-X
[   87.952535] ixgbe 0000:c3:00.1: irq 2609 for MSI/MSI-X
[   87.952624] ixgbe 0000:c3:00.1: irq 2610 for MSI/MSI-X
[   87.952705] ixgbe 0000:c3:00.1: irq 2611 for MSI/MSI-X
[   87.952786] ixgbe 0000:c3:00.1: irq 2612 for MSI/MSI-X
[   87.952869] ixgbe 0000:c3:00.1: irq 2613 for MSI/MSI-X
[   87.952951] ixgbe 0000:c3:00.1: irq 2614 for MSI/MSI-X
[   87.953072] ixgbe 0000:c3:00.1: irq 2615 for MSI/MSI-X
[   87.953153] ixgbe 0000:c3:00.1: irq 2616 for MSI/MSI-X
[   87.953235] ixgbe 0000:c3:00.1: irq 2617 for MSI/MSI-X
[   87.953323] ixgbe 0000:c3:00.1: irq 2618 for MSI/MSI-X
[   87.953401] ixgbe 0000:c3:00.1: irq 2619 for MSI/MSI-X
[   87.953481] ixgbe 0000:c3:00.1: irq 2620 for MSI/MSI-X
[   87.953566] ixgbe 0000:c3:00.1: irq 2621 for MSI/MSI-X
[   87.953660] ixgbe 0000:c3:00.1: irq 2622 for MSI/MSI-X
[   87.953919] ixgbe 0000:c3:00.1: irq 2623 for MSI/MSI-X
[   87.954421] ixgbe 0000:c3:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   87.954555] ixgbe 0000:c3:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8c:e6:65
[   87.954896] ixgbe 0000:c3:00.1: MAC: 2, PHY: 1, PBA No: G43498-007
[   87.954901] ixgbe 0000:c3:00.1: PCI Express bandwidth of 32GT/s available
[   87.954902] ixgbe 0000:c3:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   87.992167] ixgbe 0000:c3:00.1: Intel(R) 10 Gigabit Network Connection
[   88.085162] ixgbe 0000:e1:00.0: irq 2624 for MSI/MSI-X
[   88.085289] ixgbe 0000:e1:00.0: irq 2625 for MSI/MSI-X
[   88.085371] ixgbe 0000:e1:00.0: irq 2626 for MSI/MSI-X
[   88.085452] ixgbe 0000:e1:00.0: irq 2627 for MSI/MSI-X
[   88.085533] ixgbe 0000:e1:00.0: irq 2628 for MSI/MSI-X
[   88.085615] ixgbe 0000:e1:00.0: irq 2629 for MSI/MSI-X
[   88.085699] ixgbe 0000:e1:00.0: irq 2630 for MSI/MSI-X
[   88.085786] ixgbe 0000:e1:00.0: irq 2631 for MSI/MSI-X
[   88.085869] ixgbe 0000:e1:00.0: irq 2632 for MSI/MSI-X
[   88.085953] ixgbe 0000:e1:00.0: irq 2633 for MSI/MSI-X
[   88.086038] ixgbe 0000:e1:00.0: irq 2634 for MSI/MSI-X
[   88.086123] ixgbe 0000:e1:00.0: irq 2635 for MSI/MSI-X
[   88.086226] ixgbe 0000:e1:00.0: irq 2636 for MSI/MSI-X
[   88.086449] ixgbe 0000:e1:00.0: irq 2637 for MSI/MSI-X
[   88.086548] ixgbe 0000:e1:00.0: irq 2638 for MSI/MSI-X
[   88.086659] ixgbe 0000:e1:00.0: irq 2639 for MSI/MSI-X
[   88.086745] ixgbe 0000:e1:00.0: irq 2640 for MSI/MSI-X
[   88.086824] ixgbe 0000:e1:00.0: irq 2641 for MSI/MSI-X
[   88.086905] ixgbe 0000:e1:00.0: irq 2642 for MSI/MSI-X
[   88.086985] ixgbe 0000:e1:00.0: irq 2643 for MSI/MSI-X
[   88.087064] ixgbe 0000:e1:00.0: irq 2644 for MSI/MSI-X
[   88.087150] ixgbe 0000:e1:00.0: irq 2645 for MSI/MSI-X
[   88.087261] ixgbe 0000:e1:00.0: irq 2646 for MSI/MSI-X
[   88.087344] ixgbe 0000:e1:00.0: irq 2647 for MSI/MSI-X
[   88.087425] ixgbe 0000:e1:00.0: irq 2648 for MSI/MSI-X
[   88.087506] ixgbe 0000:e1:00.0: irq 2649 for MSI/MSI-X
[   88.087587] ixgbe 0000:e1:00.0: irq 2650 for MSI/MSI-X
[   88.087669] ixgbe 0000:e1:00.0: irq 2651 for MSI/MSI-X
[   88.087749] ixgbe 0000:e1:00.0: irq 2652 for MSI/MSI-X
[   88.088006] ixgbe 0000:e1:00.0: irq 2653 for MSI/MSI-X
[   88.088087] ixgbe 0000:e1:00.0: irq 2654 for MSI/MSI-X
[   88.088168] ixgbe 0000:e1:00.0: irq 2655 for MSI/MSI-X
[   88.088266] ixgbe 0000:e1:00.0: irq 2656 for MSI/MSI-X
[   88.088345] ixgbe 0000:e1:00.0: irq 2657 for MSI/MSI-X
[   88.088425] ixgbe 0000:e1:00.0: irq 2658 for MSI/MSI-X
[   88.088511] ixgbe 0000:e1:00.0: irq 2659 for MSI/MSI-X
[   88.088597] ixgbe 0000:e1:00.0: irq 2660 for MSI/MSI-X
[   88.088684] ixgbe 0000:e1:00.0: irq 2661 for MSI/MSI-X
[   88.088766] ixgbe 0000:e1:00.0: irq 2662 for MSI/MSI-X
[   88.088847] ixgbe 0000:e1:00.0: irq 2663 for MSI/MSI-X
[   88.088926] ixgbe 0000:e1:00.0: irq 2664 for MSI/MSI-X
[   88.089007] ixgbe 0000:e1:00.0: irq 2665 for MSI/MSI-X
[   88.089087] ixgbe 0000:e1:00.0: irq 2666 for MSI/MSI-X
[   88.089167] ixgbe 0000:e1:00.0: irq 2667 for MSI/MSI-X
[   88.089277] ixgbe 0000:e1:00.0: irq 2668 for MSI/MSI-X
[   88.089513] ixgbe 0000:e1:00.0: irq 2669 for MSI/MSI-X
[   88.089596] ixgbe 0000:e1:00.0: irq 2670 for MSI/MSI-X
[   88.089679] ixgbe 0000:e1:00.0: irq 2671 for MSI/MSI-X
[   88.089761] ixgbe 0000:e1:00.0: irq 2672 for MSI/MSI-X
[   88.089844] ixgbe 0000:e1:00.0: irq 2673 for MSI/MSI-X
[   88.089927] ixgbe 0000:e1:00.0: irq 2674 for MSI/MSI-X
[   88.090009] ixgbe 0000:e1:00.0: irq 2675 for MSI/MSI-X
[   88.090095] ixgbe 0000:e1:00.0: irq 2676 for MSI/MSI-X
[   88.090213] ixgbe 0000:e1:00.0: irq 2677 for MSI/MSI-X
[   88.090293] ixgbe 0000:e1:00.0: irq 2678 for MSI/MSI-X
[   88.090374] ixgbe 0000:e1:00.0: irq 2679 for MSI/MSI-X
[   88.090453] ixgbe 0000:e1:00.0: irq 2680 for MSI/MSI-X
[   88.090533] ixgbe 0000:e1:00.0: irq 2681 for MSI/MSI-X
[   88.090613] ixgbe 0000:e1:00.0: irq 2682 for MSI/MSI-X
[   88.090693] ixgbe 0000:e1:00.0: irq 2683 for MSI/MSI-X
[   88.090775] ixgbe 0000:e1:00.0: irq 2684 for MSI/MSI-X
[   88.091053] ixgbe 0000:e1:00.0: irq 2685 for MSI/MSI-X
[   88.091134] ixgbe 0000:e1:00.0: irq 2686 for MSI/MSI-X
[   88.091232] ixgbe 0000:e1:00.0: irq 2687 for MSI/MSI-X
[   88.091775] ixgbe 0000:e1:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   88.091915] ixgbe 0000:e1:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:31:7e:f8
[   88.092261] ixgbe 0000:e1:00.0: MAC: 2, PHY: 1, PBA No: G33590-000
[   88.092268] ixgbe 0000:e1:00.0: PCI Express bandwidth of 32GT/s available
[   88.092269] ixgbe 0000:e1:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   88.129969] ixgbe 0000:e1:00.0: Intel(R) 10 Gigabit Network Connection
[   88.224308] ixgbe 0000:e1:00.1: irq 2688 for MSI/MSI-X
[   88.224442] ixgbe 0000:e1:00.1: irq 2689 for MSI/MSI-X
[   88.224524] ixgbe 0000:e1:00.1: irq 2690 for MSI/MSI-X
[   88.224608] ixgbe 0000:e1:00.1: irq 2691 for MSI/MSI-X
[   88.224692] ixgbe 0000:e1:00.1: irq 2692 for MSI/MSI-X
[   88.224775] ixgbe 0000:e1:00.1: irq 2693 for MSI/MSI-X
[   88.224857] ixgbe 0000:e1:00.1: irq 2694 for MSI/MSI-X
[   88.224940] ixgbe 0000:e1:00.1: irq 2695 for MSI/MSI-X
[   88.225024] ixgbe 0000:e1:00.1: irq 2696 for MSI/MSI-X
[   88.225108] ixgbe 0000:e1:00.1: irq 2697 for MSI/MSI-X
[   88.225206] ixgbe 0000:e1:00.1: irq 2698 for MSI/MSI-X
[   88.225461] ixgbe 0000:e1:00.1: irq 2699 for MSI/MSI-X
[   88.225542] ixgbe 0000:e1:00.1: irq 2700 for MSI/MSI-X
[   88.225620] ixgbe 0000:e1:00.1: irq 2701 for MSI/MSI-X
[   88.225700] ixgbe 0000:e1:00.1: irq 2702 for MSI/MSI-X
[   88.225783] ixgbe 0000:e1:00.1: irq 2703 for MSI/MSI-X
[   88.225864] ixgbe 0000:e1:00.1: irq 2704 for MSI/MSI-X
[   88.225944] ixgbe 0000:e1:00.1: irq 2705 for MSI/MSI-X
[   88.226032] ixgbe 0000:e1:00.1: irq 2706 for MSI/MSI-X
[   88.226112] ixgbe 0000:e1:00.1: irq 2707 for MSI/MSI-X
[   88.226192] ixgbe 0000:e1:00.1: irq 2708 for MSI/MSI-X
[   88.226272] ixgbe 0000:e1:00.1: irq 2709 for MSI/MSI-X
[   88.226384] ixgbe 0000:e1:00.1: irq 2710 for MSI/MSI-X
[   88.226464] ixgbe 0000:e1:00.1: irq 2711 for MSI/MSI-X
[   88.226543] ixgbe 0000:e1:00.1: irq 2712 for MSI/MSI-X
[   88.226622] ixgbe 0000:e1:00.1: irq 2713 for MSI/MSI-X
[   88.226710] ixgbe 0000:e1:00.1: irq 2714 for MSI/MSI-X
[   88.226957] ixgbe 0000:e1:00.1: irq 2715 for MSI/MSI-X
[   88.227042] ixgbe 0000:e1:00.1: irq 2716 for MSI/MSI-X
[   88.227130] ixgbe 0000:e1:00.1: irq 2717 for MSI/MSI-X
[   88.227215] ixgbe 0000:e1:00.1: irq 2718 for MSI/MSI-X
[   88.227299] ixgbe 0000:e1:00.1: irq 2719 for MSI/MSI-X
[   88.227415] ixgbe 0000:e1:00.1: irq 2720 for MSI/MSI-X
[   88.227501] ixgbe 0000:e1:00.1: irq 2721 for MSI/MSI-X
[   88.227592] ixgbe 0000:e1:00.1: irq 2722 for MSI/MSI-X
[   88.227676] ixgbe 0000:e1:00.1: irq 2723 for MSI/MSI-X
[   88.227760] ixgbe 0000:e1:00.1: irq 2724 for MSI/MSI-X
[   88.227844] ixgbe 0000:e1:00.1: irq 2725 for MSI/MSI-X
[   88.227928] ixgbe 0000:e1:00.1: irq 2726 for MSI/MSI-X
[   88.228013] ixgbe 0000:e1:00.1: irq 2727 for MSI/MSI-X
[   88.228099] ixgbe 0000:e1:00.1: irq 2728 for MSI/MSI-X
[   88.228184] ixgbe 0000:e1:00.1: irq 2729 for MSI/MSI-X
[   88.228280] ixgbe 0000:e1:00.1: irq 2730 for MSI/MSI-X
[   88.228543] ixgbe 0000:e1:00.1: irq 2731 for MSI/MSI-X
[   88.228629] ixgbe 0000:e1:00.1: irq 2732 for MSI/MSI-X
[   88.228715] ixgbe 0000:e1:00.1: irq 2733 for MSI/MSI-X
[   88.228802] ixgbe 0000:e1:00.1: irq 2734 for MSI/MSI-X
[   88.228888] ixgbe 0000:e1:00.1: irq 2735 for MSI/MSI-X
[   88.228976] ixgbe 0000:e1:00.1: irq 2736 for MSI/MSI-X
[   88.229063] ixgbe 0000:e1:00.1: irq 2737 for MSI/MSI-X
[   88.229160] ixgbe 0000:e1:00.1: irq 2738 for MSI/MSI-X
[   88.229247] ixgbe 0000:e1:00.1: irq 2739 for MSI/MSI-X
[   88.229336] ixgbe 0000:e1:00.1: irq 2740 for MSI/MSI-X
[   88.229451] ixgbe 0000:e1:00.1: irq 2741 for MSI/MSI-X
[   88.229538] ixgbe 0000:e1:00.1: irq 2742 for MSI/MSI-X
[   88.229624] ixgbe 0000:e1:00.1: irq 2743 for MSI/MSI-X
[   88.229712] ixgbe 0000:e1:00.1: irq 2744 for MSI/MSI-X
[   88.229797] ixgbe 0000:e1:00.1: irq 2745 for MSI/MSI-X
[   88.229889] ixgbe 0000:e1:00.1: irq 2746 for MSI/MSI-X
[   88.230149] ixgbe 0000:e1:00.1: irq 2747 for MSI/MSI-X
[   88.230235] ixgbe 0000:e1:00.1: irq 2748 for MSI/MSI-X
[   88.230321] ixgbe 0000:e1:00.1: irq 2749 for MSI/MSI-X
[   88.230454] ixgbe 0000:e1:00.1: irq 2750 for MSI/MSI-X
[   88.230538] ixgbe 0000:e1:00.1: irq 2751 for MSI/MSI-X
[   88.231043] ixgbe 0000:e1:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   88.231176] ixgbe 0000:e1:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:31:7e:f9
[   88.231511] ixgbe 0000:e1:00.1: MAC: 2, PHY: 1, PBA No: G33590-000
[   88.231517] ixgbe 0000:e1:00.1: PCI Express bandwidth of 32GT/s available
[   88.231519] ixgbe 0000:e1:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   88.268243] ixgbe 0000:e1:00.1: Intel(R) 10 Gigabit Network Connection
[   88.360279] ixgbe 0000:e3:00.0: irq 2752 for MSI/MSI-X
[   88.360373] ixgbe 0000:e3:00.0: irq 2753 for MSI/MSI-X
[   88.360465] ixgbe 0000:e3:00.0: irq 2754 for MSI/MSI-X
[   88.360570] ixgbe 0000:e3:00.0: irq 2755 for MSI/MSI-X
[   88.360660] ixgbe 0000:e3:00.0: irq 2756 for MSI/MSI-X
[   88.360761] ixgbe 0000:e3:00.0: irq 2757 for MSI/MSI-X
[   88.360848] ixgbe 0000:e3:00.0: irq 2758 for MSI/MSI-X
[   88.360935] ixgbe 0000:e3:00.0: irq 2759 for MSI/MSI-X
[   88.361027] ixgbe 0000:e3:00.0: irq 2760 for MSI/MSI-X
[   88.361251] ixgbe 0000:e3:00.0: irq 2761 for MSI/MSI-X
[   88.361337] ixgbe 0000:e3:00.0: irq 2762 for MSI/MSI-X
[   88.361421] ixgbe 0000:e3:00.0: irq 2763 for MSI/MSI-X
[   88.361505] ixgbe 0000:e3:00.0: irq 2764 for MSI/MSI-X
[   88.361612] ixgbe 0000:e3:00.0: irq 2765 for MSI/MSI-X
[   88.361696] ixgbe 0000:e3:00.0: irq 2766 for MSI/MSI-X
[   88.361781] ixgbe 0000:e3:00.0: irq 2767 for MSI/MSI-X
[   88.361881] ixgbe 0000:e3:00.0: irq 2768 for MSI/MSI-X
[   88.361967] ixgbe 0000:e3:00.0: irq 2769 for MSI/MSI-X
[   88.362052] ixgbe 0000:e3:00.0: irq 2770 for MSI/MSI-X
[   88.362137] ixgbe 0000:e3:00.0: irq 2771 for MSI/MSI-X
[   88.362230] ixgbe 0000:e3:00.0: irq 2772 for MSI/MSI-X
[   88.362315] ixgbe 0000:e3:00.0: irq 2773 for MSI/MSI-X
[   88.362399] ixgbe 0000:e3:00.0: irq 2774 for MSI/MSI-X
[   88.362487] ixgbe 0000:e3:00.0: irq 2775 for MSI/MSI-X
[   88.362614] ixgbe 0000:e3:00.0: irq 2776 for MSI/MSI-X
[   88.362860] ixgbe 0000:e3:00.0: irq 2777 for MSI/MSI-X
[   88.362944] ixgbe 0000:e3:00.0: irq 2778 for MSI/MSI-X
[   88.363028] ixgbe 0000:e3:00.0: irq 2779 for MSI/MSI-X
[   88.363112] ixgbe 0000:e3:00.0: irq 2780 for MSI/MSI-X
[   88.363201] ixgbe 0000:e3:00.0: irq 2781 for MSI/MSI-X
[   88.363291] ixgbe 0000:e3:00.0: irq 2782 for MSI/MSI-X
[   88.363386] ixgbe 0000:e3:00.0: irq 2783 for MSI/MSI-X
[   88.363477] ixgbe 0000:e3:00.0: irq 2784 for MSI/MSI-X
[   88.363574] ixgbe 0000:e3:00.0: irq 2785 for MSI/MSI-X
[   88.363660] ixgbe 0000:e3:00.0: irq 2786 for MSI/MSI-X
[   88.363750] ixgbe 0000:e3:00.0: irq 2787 for MSI/MSI-X
[   88.363839] ixgbe 0000:e3:00.0: irq 2788 for MSI/MSI-X
[   88.363929] ixgbe 0000:e3:00.0: irq 2789 for MSI/MSI-X
[   88.364015] ixgbe 0000:e3:00.0: irq 2790 for MSI/MSI-X
[   88.364105] ixgbe 0000:e3:00.0: irq 2791 for MSI/MSI-X
[   88.364200] ixgbe 0000:e3:00.0: irq 2792 for MSI/MSI-X
[   88.364464] ixgbe 0000:e3:00.0: irq 2793 for MSI/MSI-X
[   88.364569] ixgbe 0000:e3:00.0: irq 2794 for MSI/MSI-X
[   88.364657] ixgbe 0000:e3:00.0: irq 2795 for MSI/MSI-X
[   88.364752] ixgbe 0000:e3:00.0: irq 2796 for MSI/MSI-X
[   88.364837] ixgbe 0000:e3:00.0: irq 2797 for MSI/MSI-X
[   88.364924] ixgbe 0000:e3:00.0: irq 2798 for MSI/MSI-X
[   88.365009] ixgbe 0000:e3:00.0: irq 2799 for MSI/MSI-X
[   88.365102] ixgbe 0000:e3:00.0: irq 2800 for MSI/MSI-X
[   88.365205] ixgbe 0000:e3:00.0: irq 2801 for MSI/MSI-X
[   88.365289] ixgbe 0000:e3:00.0: irq 2802 for MSI/MSI-X
[   88.365376] ixgbe 0000:e3:00.0: irq 2803 for MSI/MSI-X
[   88.365460] ixgbe 0000:e3:00.0: irq 2804 for MSI/MSI-X
[   88.365565] ixgbe 0000:e3:00.0: irq 2805 for MSI/MSI-X
[   88.365663] ixgbe 0000:e3:00.0: irq 2806 for MSI/MSI-X
[   88.365771] ixgbe 0000:e3:00.0: irq 2807 for MSI/MSI-X
[   88.365864] ixgbe 0000:e3:00.0: irq 2808 for MSI/MSI-X
[   88.366120] ixgbe 0000:e3:00.0: irq 2809 for MSI/MSI-X
[   88.366210] ixgbe 0000:e3:00.0: irq 2810 for MSI/MSI-X
[   88.366298] ixgbe 0000:e3:00.0: irq 2811 for MSI/MSI-X
[   88.366400] ixgbe 0000:e3:00.0: irq 2812 for MSI/MSI-X
[   88.366488] ixgbe 0000:e3:00.0: irq 2813 for MSI/MSI-X
[   88.366643] ixgbe 0000:e3:00.0: irq 2814 for MSI/MSI-X
[   88.366737] ixgbe 0000:e3:00.0: irq 2815 for MSI/MSI-X
[   88.367279] ixgbe 0000:e3:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   88.367413] ixgbe 0000:e3:00.0: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8b:27:f4
[   88.367760] ixgbe 0000:e3:00.0: MAC: 2, PHY: 1, PBA No: G43498-000
[   88.367765] ixgbe 0000:e3:00.0: PCI Express bandwidth of 32GT/s available
[   88.367766] ixgbe 0000:e3:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   88.404926] ixgbe 0000:e3:00.0: Intel(R) 10 Gigabit Network Connection
[   88.509668] ixgbe 0000:e3:00.1: irq 2816 for MSI/MSI-X
[   88.509819] ixgbe 0000:e3:00.1: irq 2817 for MSI/MSI-X
[   88.509944] ixgbe 0000:e3:00.1: irq 2818 for MSI/MSI-X
[   88.510075] ixgbe 0000:e3:00.1: irq 2819 for MSI/MSI-X
[   88.510204] ixgbe 0000:e3:00.1: irq 2820 for MSI/MSI-X
[   88.510344] ixgbe 0000:e3:00.1: irq 2821 for MSI/MSI-X
[   88.510451] ixgbe 0000:e3:00.1: irq 2822 for MSI/MSI-X
[   88.510680] ixgbe 0000:e3:00.1: irq 2823 for MSI/MSI-X
[   88.510828] ixgbe 0000:e3:00.1: irq 2824 for MSI/MSI-X
[   88.510970] ixgbe 0000:e3:00.1: irq 2825 for MSI/MSI-X
[   88.511099] ixgbe 0000:e3:00.1: irq 2826 for MSI/MSI-X
[   88.511231] ixgbe 0000:e3:00.1: irq 2827 for MSI/MSI-X
[   88.511362] ixgbe 0000:e3:00.1: irq 2828 for MSI/MSI-X
[   88.511500] ixgbe 0000:e3:00.1: irq 2829 for MSI/MSI-X
[   88.511637] ixgbe 0000:e3:00.1: irq 2830 for MSI/MSI-X
[   88.511795] ixgbe 0000:e3:00.1: irq 2831 for MSI/MSI-X
[   88.511926] ixgbe 0000:e3:00.1: irq 2832 for MSI/MSI-X
[   88.512031] ixgbe 0000:e3:00.1: irq 2833 for MSI/MSI-X
[   88.512131] ixgbe 0000:e3:00.1: irq 2834 for MSI/MSI-X
[   88.512229] ixgbe 0000:e3:00.1: irq 2835 for MSI/MSI-X
[   88.512317] ixgbe 0000:e3:00.1: irq 2836 for MSI/MSI-X
[   88.512407] ixgbe 0000:e3:00.1: irq 2837 for MSI/MSI-X
[   88.512492] ixgbe 0000:e3:00.1: irq 2838 for MSI/MSI-X
[   88.512783] ixgbe 0000:e3:00.1: irq 2839 for MSI/MSI-X
[   88.512919] ixgbe 0000:e3:00.1: irq 2840 for MSI/MSI-X
[   88.513050] ixgbe 0000:e3:00.1: irq 2841 for MSI/MSI-X
[   88.513188] ixgbe 0000:e3:00.1: irq 2842 for MSI/MSI-X
[   88.513319] ixgbe 0000:e3:00.1: irq 2843 for MSI/MSI-X
[   88.513456] ixgbe 0000:e3:00.1: irq 2844 for MSI/MSI-X
[   88.513593] ixgbe 0000:e3:00.1: irq 2845 for MSI/MSI-X
[   88.513739] ixgbe 0000:e3:00.1: irq 2846 for MSI/MSI-X
[   88.513875] ixgbe 0000:e3:00.1: irq 2847 for MSI/MSI-X
[   88.514011] ixgbe 0000:e3:00.1: irq 2848 for MSI/MSI-X
[   88.514146] ixgbe 0000:e3:00.1: irq 2849 for MSI/MSI-X
[   88.514274] ixgbe 0000:e3:00.1: irq 2850 for MSI/MSI-X
[   88.514402] ixgbe 0000:e3:00.1: irq 2851 for MSI/MSI-X
[   88.514533] ixgbe 0000:e3:00.1: irq 2852 for MSI/MSI-X
[   88.514670] ixgbe 0000:e3:00.1: irq 2853 for MSI/MSI-X
[   88.514808] ixgbe 0000:e3:00.1: irq 2854 for MSI/MSI-X
[   88.515087] ixgbe 0000:e3:00.1: irq 2855 for MSI/MSI-X
[   88.515221] ixgbe 0000:e3:00.1: irq 2856 for MSI/MSI-X
[   88.515328] ixgbe 0000:e3:00.1: irq 2857 for MSI/MSI-X
[   88.515430] ixgbe 0000:e3:00.1: irq 2858 for MSI/MSI-X
[   88.515522] ixgbe 0000:e3:00.1: irq 2859 for MSI/MSI-X
[   88.515608] ixgbe 0000:e3:00.1: irq 2860 for MSI/MSI-X
[   88.515700] ixgbe 0000:e3:00.1: irq 2861 for MSI/MSI-X
[   88.515831] ixgbe 0000:e3:00.1: irq 2862 for MSI/MSI-X
[   88.515961] ixgbe 0000:e3:00.1: irq 2863 for MSI/MSI-X
[   88.516093] ixgbe 0000:e3:00.1: irq 2864 for MSI/MSI-X
[   88.516226] ixgbe 0000:e3:00.1: irq 2865 for MSI/MSI-X
[   88.516362] ixgbe 0000:e3:00.1: irq 2866 for MSI/MSI-X
[   88.516492] ixgbe 0000:e3:00.1: irq 2867 for MSI/MSI-X
[   88.516623] ixgbe 0000:e3:00.1: irq 2868 for MSI/MSI-X
[   88.516792] ixgbe 0000:e3:00.1: irq 2869 for MSI/MSI-X
[   88.516924] ixgbe 0000:e3:00.1: irq 2870 for MSI/MSI-X
[   88.517235] ixgbe 0000:e3:00.1: irq 2871 for MSI/MSI-X
[   88.517366] ixgbe 0000:e3:00.1: irq 2872 for MSI/MSI-X
[   88.517476] ixgbe 0000:e3:00.1: irq 2873 for MSI/MSI-X
[   88.517580] ixgbe 0000:e3:00.1: irq 2874 for MSI/MSI-X
[   88.517670] ixgbe 0000:e3:00.1: irq 2875 for MSI/MSI-X
[   88.517784] ixgbe 0000:e3:00.1: irq 2876 for MSI/MSI-X
[   88.517920] ixgbe 0000:e3:00.1: irq 2877 for MSI/MSI-X
[   88.518051] ixgbe 0000:e3:00.1: irq 2878 for MSI/MSI-X
[   88.518194] ixgbe 0000:e3:00.1: irq 2879 for MSI/MSI-X
[   88.518981] ixgbe 0000:e3:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[   88.519112] ixgbe 0000:e3:00.1: (PCI Express:5.0GT/s:Width x8) 38:ea:a7:8b:27:f5
[   88.519452] ixgbe 0000:e3:00.1: MAC: 2, PHY: 1, PBA No: G43498-000
[   88.519457] ixgbe 0000:e3:00.1: PCI Express bandwidth of 32GT/s available
[   88.519459] ixgbe 0000:e3:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[   88.556648] ixgbe 0000:e3:00.1: Intel(R) 10 Gigabit Network Connection
[   88.579999] iTCO_vendor_support: vendor-support=0
[   88.591596] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[   88.592052] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by hardware/BIOS
[   88.966180] systemd-udevd[7380]: renamed network interface eth0 to eno32
[   89.055276] systemd-udevd[6588]: renamed network interface eth1 to eno33
[   93.358551] systemd-udevd[6045]: renamed network interface eth2 to eno1456
[   93.977970] systemd-udevd[6097]: renamed network interface eth3 to eno1457
[   94.010425] systemd-udevd[6127]: renamed network interface eth4 to eno208
[   97.583264] systemd-udevd[6067]: renamed network interface eth5 to eno209
[  101.187440] systemd-udevd[8056]: renamed network interface eth6 to eno1632
[  111.629322] systemd-udevd[8188]: renamed network interface eth7 to eno1633
[  117.570169] systemd-udevd[7912]: renamed network interface eth8 to eno384
[  132.916266] systemd-udevd[6672]: renamed network interface eth9 to eno385
[  135.566542] systemd-udevd[5999]: renamed network interface eth10 to eno1808
[  137.194465] systemd-udevd[7456]: renamed network interface eth11 to eno1809
[  144.310328] systemd-udevd[6060]: renamed network interface eth12 to eno560
[  145.753361] systemd-udevd[6553]: renamed network interface eth13 to eno561
[  145.886395] btrfs: device fsid e15e7b18-bed6-4fad-ba82-c7a2cf0d6f3b devid 1 transid 9906 /dev/dm-22
[  145.984956] Adding 4194300k swap on /dev/mapper/rhel-swap.  Priority:-1 extents:1 across:4194300k FS
[  146.473361] sd 0:0:0:0: Attached scsi generic sg0 type 0
[  146.473661] sd 0:0:0:1: Attached scsi generic sg1 type 0
[  146.473896] sd 0:0:0:2: Attached scsi generic sg2 type 0
[  146.474224] sd 0:0:0:3: Attached scsi generic sg3 type 0
[  146.474470] sd 0:0:1:0: Attached scsi generic sg4 type 0
[  146.474775] sd 0:0:1:1: Attached scsi generic sg5 type 0
[  146.475008] sd 0:0:1:2: Attached scsi generic sg6 type 0
[  146.475360] sd 0:0:1:3: Attached scsi generic sg7 type 0
[  146.475643] ses 1:0:0:0: Attached scsi generic sg8 type 13
[  146.475922] sd 2:0:0:0: Attached scsi generic sg9 type 0
[  146.476184] sd 2:0:0:100: Attached scsi generic sg10 type 0
[  146.476455] sd 2:0:0:101: Attached scsi generic sg11 type 0
[  146.476734] sd 2:0:0:102: Attached scsi generic sg12 type 0
[  146.476988] sd 2:0:0:103: Attached scsi generic sg13 type 0
[  146.477250] sd 2:0:0:104: Attached scsi generic sg14 type 0
[  146.477480] sd 2:0:0:105: Attached scsi generic sg15 type 0
[  146.477783] sd 2:0:0:106: Attached scsi generic sg16 type 0
[  146.478031] sd 2:0:0:107: Attached scsi generic sg17 type 0
[  146.478297] sd 2:0:0:108: Attached scsi generic sg18 type 0
[  146.478538] sd 2:0:0:109: Attached scsi generic sg19 type 0
[  146.478839] sd 2:0:0:110: Attached scsi generic sg20 type 0
[  146.479239] sd 2:0:0:111: Attached scsi generic sg21 type 0
[  146.479522] sd 2:0:0:112: Attached scsi generic sg22 type 0
[  146.479902] sd 2:0:0:113: Attached scsi generic sg23 type 0
[  146.480179] sd 2:0:0:114: Attached scsi generic sg24 type 0
[  146.480420] sd 2:0:0:115: Attached scsi generic sg25 type 0
[  146.480709] sd 2:0:0:116: Attached scsi generic sg26 type 0
[  146.480957] sd 2:0:0:117: Attached scsi generic sg27 type 0
[  146.481244] sd 2:0:0:118: Attached scsi generic sg28 type 0
[  146.481485] sd 2:0:0:119: Attached scsi generic sg29 type 0
[  146.481800] ses 1:0:1:0: Attached scsi generic sg30 type 13
[  146.482151] ses 3:0:0:0: Attached scsi generic sg31 type 13
[  146.482441] sd 2:0:1:0: Attached scsi generic sg32 type 0
[  146.482706] sd 2:0:1:100: Attached scsi generic sg33 type 0
[  146.482952] sd 2:0:1:101: Attached scsi generic sg34 type 0
[  146.483231] sd 2:0:1:102: Attached scsi generic sg35 type 0
[  146.483475] sd 2:0:1:103: Attached scsi generic sg36 type 0
[  146.483788] sd 2:0:1:104: Attached scsi generic sg37 type 0
[  146.484043] sd 2:0:1:105: Attached scsi generic sg38 type 0
[  146.484330] sd 2:0:1:106: Attached scsi generic sg39 type 0
[  146.484606] sd 2:0:1:107: Attached scsi generic sg40 type 0
[  146.484882] sd 2:0:1:108: Attached scsi generic sg41 type 0
[  146.485184] sd 2:0:1:109: Attached scsi generic sg42 type 0
[  146.485469] sd 2:0:1:110: Attached scsi generic sg43 type 0
[  146.485705] sd 2:0:1:111: Attached scsi generic sg44 type 0
[  146.485974] sd 2:0:1:112: Attached scsi generic sg45 type 0
[  146.486245] sd 2:0:1:113: Attached scsi generic sg46 type 0
[  146.486559] sd 2:0:1:114: Attached scsi generic sg47 type 0
[  146.486823] sd 2:0:1:115: Attached scsi generic sg48 type 0
[  146.487183] sd 2:0:1:116: Attached scsi generic sg49 type 0
[  146.487825] sd 2:0:1:117: Attached scsi generic sg50 type 0
[  146.488917] sd 2:0:1:118: Attached scsi generic sg51 type 0
[  146.489263] sd 2:0:1:119: Attached scsi generic sg52 type 0
[  146.489525] ses 3:0:1:0: Attached scsi generic sg53 type 13
[  146.489820] ses 4:0:0:0: Attached scsi generic sg54 type 13
[  146.490043] ses 4:0:1:0: Attached scsi generic sg55 type 13
[  146.490357] ses 5:0:0:0: Attached scsi generic sg56 type 13
[  146.490643] ses 5:0:1:0: Attached scsi generic sg57 type 13
[  146.490903] ses 6:0:0:0: Attached scsi generic sg58 type 13
[  146.491222] ses 7:0:0:0: Attached scsi generic sg59 type 13
[  146.491461] ses 6:0:1:0: Attached scsi generic sg60 type 13
[  146.491755] ses 7:0:1:0: Attached scsi generic sg61 type 13
[  146.492024] ses 8:0:0:0: Attached scsi generic sg62 type 13
[  146.492342] ses 8:0:1:0: Attached scsi generic sg63 type 13
[  146.492628] ses 9:0:0:0: Attached scsi generic sg64 type 13
[  146.492875] ses 9:0:1:0: Attached scsi generic sg65 type 13
[  146.493213] ses 10:0:0:0: Attached scsi generic sg66 type 13
[  146.493488] ses 11:0:0:0: Attached scsi generic sg67 type 13
[  146.493764] ses 10:0:1:0: Attached scsi generic sg68 type 13
[  146.494008] ses 11:0:1:0: Attached scsi generic sg69 type 13
[  146.494299] ses 12:0:0:0: Attached scsi generic sg70 type 13
[  146.494546] ses 13:0:0:0: Attached scsi generic sg71 type 13
[  146.494832] ses 12:0:1:0: Attached scsi generic sg72 type 13
[  146.495134] ses 13:0:1:0: Attached scsi generic sg73 type 13
[  146.495397] ses 14:0:0:0: Attached scsi generic sg74 type 13
[  146.495677] ses 14:0:1:0: Attached scsi generic sg75 type 13
[  146.495922] ses 15:0:0:0: Attached scsi generic sg76 type 13
[  146.496317] ses 15:0:1:0: Attached scsi generic sg77 type 13
[  146.520367] systemd-udevd[5682]: renamed network interface eth14 to eno1984
[  146.556546] systemd-udevd[5661]: renamed network interface eth15 to eno1985
[  147.029919] ip_tables: (C) 2000-2006 Netfilter Core Team
[  147.218366] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[  147.290467] systemd-udevd[5663]: renamed network interface eth16 to eno736
[  147.332074] systemd-udevd[5657]: renamed network interface eth21 to eno913
[  147.381203] systemd-udevd[5656]: renamed network interface eth20 to eno912
[  147.402422] ip6_tables: (C) 2000-2006 Netfilter Core Team
[  147.413770] systemd-udevd[5668]: renamed network interface eth17 to eno737
[  147.449908] systemd-udevd[5659]: renamed network interface eth19 to eno2161
[  147.471481] systemd-udevd[5654]: renamed network interface eth22 to eno2336
[  147.521342] systemd-udevd[5660]: renamed network interface eth18 to eno2160
[  147.664873] Ebtables v2.0 registered
[  147.798467] Bridge firewalling registered
[  148.202171] systemd-udevd[5656]: renamed network interface eth24 to eno1088
[  148.228135] systemd-udevd[5658]: renamed network interface eth25 to eno1089
[  148.269216] systemd-udevd[5657]: renamed network interface eth26 to eno2512
[  148.338510] systemd-udevd[5655]: renamed network interface eth23 to eno2337
[  148.662752] ixgbe 0000:01:00.0: registered PHC device on eno32
[  148.671497] IPv6: ADDRCONF(NETDEV_UP): eno32: link is not ready
[  148.678175] ixgbe 0000:01:00.0 eno32: NIC Link is Up 10 Gbps, Flow Control: None
[  148.701809] systemd-udevd[5665]: renamed network interface eth27 to eno2513
[  148.725626] systemd-udevd[5657]: renamed network interface eth29 to eno1265
[  148.725676] IPv6: ADDRCONF(NETDEV_CHANGE): eno32: link becomes ready
[  148.756838] systemd-udevd[5656]: renamed network interface eth30 to eno2688
[  149.042152] ixgbe 0000:01:00.1: registered PHC device on eno33
[  149.050832] IPv6: ADDRCONF(NETDEV_UP): eno33: link is not ready
[  149.057490] ixgbe 0000:01:00.1 eno33: NIC Link is Up 10 Gbps, Flow Control: None
[  149.077238] systemd-udevd[5655]: renamed network interface eth28 to eno1264
[  149.149312] systemd-udevd[5663]: renamed network interface eth31 to eno2689
[  149.149318] IPv6: ADDRCONF(NETDEV_CHANGE): eno33: link becomes ready
[  149.441719] ixgbe 0000:03:00.0: registered PHC device on eno1456
[  149.450603] IPv6: ADDRCONF(NETDEV_UP): eno1456: link is not ready
[  149.457459] ixgbe 0000:03:00.0 eno1456: NIC Link is Up 10 Gbps, Flow Control: None
[  149.466015] IPv6: ADDRCONF(NETDEV_CHANGE): eno1456: link becomes ready
[  149.751651] ixgbe 0000:03:00.1: registered PHC device on eno1457
[  149.760824] IPv6: ADDRCONF(NETDEV_UP): eno1457: link is not ready
[  150.049411] ixgbe 0000:21:00.0: registered PHC device on eno208
[  150.058237] IPv6: ADDRCONF(NETDEV_UP): eno208: link is not ready
[  150.064999] ixgbe 0000:21:00.0 eno208: NIC Link is Up 10 Gbps, Flow Control: None
[  150.073759] IPv6: ADDRCONF(NETDEV_CHANGE): eno208: link becomes ready
[  150.356381] ixgbe 0000:21:00.1: registered PHC device on eno209
[  150.365193] IPv6: ADDRCONF(NETDEV_UP): eno209: link is not ready
[  150.372034] ixgbe 0000:21:00.1 eno209: NIC Link is Up 10 Gbps, Flow Control: None
[  150.380659] IPv6: ADDRCONF(NETDEV_CHANGE): eno209: link becomes ready
[  150.663330] ixgbe 0000:23:00.0: registered PHC device on eno1632
[  150.672333] IPv6: ADDRCONF(NETDEV_UP): eno1632: link is not ready
[  150.679512] ixgbe 0000:23:00.0 eno1632: NIC Link is Up 10 Gbps, Flow Control: None
[  150.688052] IPv6: ADDRCONF(NETDEV_CHANGE): eno1632: link becomes ready
[  150.974521] ixgbe 0000:23:00.1: registered PHC device on eno1633
[  150.984417] IPv6: ADDRCONF(NETDEV_UP): eno1633: link is not ready
[  151.272870] ixgbe 0000:41:00.0: registered PHC device on eno384
[  151.281766] IPv6: ADDRCONF(NETDEV_UP): eno384: link is not ready
[  151.288525] ixgbe 0000:41:00.0 eno384: NIC Link is Up 10 Gbps, Flow Control: None
[  151.297275] IPv6: ADDRCONF(NETDEV_CHANGE): eno384: link becomes ready
[  151.582458] ixgbe 0000:41:00.1: registered PHC device on eno385
[  151.591481] IPv6: ADDRCONF(NETDEV_UP): eno385: link is not ready
[  151.598263] ixgbe 0000:41:00.1 eno385: NIC Link is Up 10 Gbps, Flow Control: None
[  151.607030] IPv6: ADDRCONF(NETDEV_CHANGE): eno385: link becomes ready
[  151.886203] ixgbe 0000:43:00.0: registered PHC device on eno1808
[  151.895164] IPv6: ADDRCONF(NETDEV_UP): eno1808: link is not ready
[  151.902046] ixgbe 0000:43:00.0 eno1808: NIC Link is Up 10 Gbps, Flow Control: None
[  151.910653] IPv6: ADDRCONF(NETDEV_CHANGE): eno1808: link becomes ready
[  152.192216] ixgbe 0000:43:00.1: registered PHC device on eno1809
[  152.202155] IPv6: ADDRCONF(NETDEV_UP): eno1809: link is not ready
[  152.485539] ixgbe 0000:61:00.0: registered PHC device on eno560
[  152.494517] IPv6: ADDRCONF(NETDEV_UP): eno560: link is not ready
[  152.501296] ixgbe 0000:61:00.0 eno560: NIC Link is Up 10 Gbps, Flow Control: None
[  152.510117] IPv6: ADDRCONF(NETDEV_CHANGE): eno560: link becomes ready
[  152.789346] ixgbe 0000:61:00.1: registered PHC device on eno561
[  152.798278] IPv6: ADDRCONF(NETDEV_UP): eno561: link is not ready
[  152.805077] ixgbe 0000:61:00.1 eno561: NIC Link is Up 10 Gbps, Flow Control: None
[  152.813685] IPv6: ADDRCONF(NETDEV_CHANGE): eno561: link becomes ready
[  153.090664] ixgbe 0000:63:00.0: registered PHC device on eno1984
[  153.099753] IPv6: ADDRCONF(NETDEV_UP): eno1984: link is not ready
[  153.106644] ixgbe 0000:63:00.0 eno1984: NIC Link is Up 10 Gbps, Flow Control: None
[  153.115285] IPv6: ADDRCONF(NETDEV_CHANGE): eno1984: link becomes ready
[  153.400138] ixgbe 0000:63:00.1: registered PHC device on eno1985
[  153.409265] IPv6: ADDRCONF(NETDEV_UP): eno1985: link is not ready
[  153.696010] ixgbe 0000:85:00.0: registered PHC device on eno736
[  153.704987] IPv6: ADDRCONF(NETDEV_UP): eno736: link is not ready
[  153.711776] ixgbe 0000:85:00.0 eno736: NIC Link is Up 10 Gbps, Flow Control: None
[  153.720517] IPv6: ADDRCONF(NETDEV_CHANGE): eno736: link becomes ready
[  154.004235] ixgbe 0000:85:00.1: registered PHC device on eno737
[  154.013213] IPv6: ADDRCONF(NETDEV_UP): eno737: link is not ready
[  154.020020] ixgbe 0000:85:00.1 eno737: NIC Link is Up 10 Gbps, Flow Control: None
[  154.028610] IPv6: ADDRCONF(NETDEV_CHANGE): eno737: link becomes ready
[  154.313190] ixgbe 0000:87:00.0: registered PHC device on eno2160
[  154.322202] IPv6: ADDRCONF(NETDEV_UP): eno2160: link is not ready
[  154.329101] ixgbe 0000:87:00.0 eno2160: NIC Link is Up 10 Gbps, Flow Control: None
[  154.337751] IPv6: ADDRCONF(NETDEV_CHANGE): eno2160: link becomes ready
[  154.624399] ixgbe 0000:87:00.1: registered PHC device on eno2161
[  154.633384] IPv6: ADDRCONF(NETDEV_UP): eno2161: link is not ready
[  154.918907] ixgbe 0000:a1:00.0: registered PHC device on eno912
[  154.927560] IPv6: ADDRCONF(NETDEV_UP): eno912: link is not ready
[  154.934364] ixgbe 0000:a1:00.0 eno912: NIC Link is Up 10 Gbps, Flow Control: None
[  154.943767] IPv6: ADDRCONF(NETDEV_CHANGE): eno912: link becomes ready
[  155.236440] ixgbe 0000:a1:00.1: registered PHC device on eno913
[  155.245386] IPv6: ADDRCONF(NETDEV_UP): eno913: link is not ready
[  155.252176] ixgbe 0000:a1:00.1 eno913: NIC Link is Up 10 Gbps, Flow Control: None
[  155.260749] IPv6: ADDRCONF(NETDEV_CHANGE): eno913: link becomes ready
[  155.551647] ixgbe 0000:a3:00.0: registered PHC device on eno2336
[  155.560699] IPv6: ADDRCONF(NETDEV_UP): eno2336: link is not ready
[  155.567577] ixgbe 0000:a3:00.0 eno2336: NIC Link is Up 10 Gbps, Flow Control: None
[  155.576206] IPv6: ADDRCONF(NETDEV_CHANGE): eno2336: link becomes ready
[  155.914712] ixgbe 0000:c1:00.0: registered PHC device on eno1088
[  155.923518] IPv6: ADDRCONF(NETDEV_UP): eno1088: link is not ready
[  155.930399] ixgbe 0000:c1:00.0 eno1088: NIC Link is Up 10 Gbps, Flow Control: None
[  155.939035] IPv6: ADDRCONF(NETDEV_CHANGE): eno1088: link becomes ready
[  156.232693] ixgbe 0000:c1:00.1: registered PHC device on eno1089
[  156.241460] IPv6: ADDRCONF(NETDEV_UP): eno1089: link is not ready
[  156.248361] ixgbe 0000:c1:00.1 eno1089: NIC Link is Up 10 Gbps, Flow Control: None
[  156.256993] IPv6: ADDRCONF(NETDEV_CHANGE): eno1089: link becomes ready
[  156.543166] ixgbe 0000:c3:00.0: registered PHC device on eno2512
[  156.551936] IPv6: ADDRCONF(NETDEV_UP): eno2512: link is not ready
[  156.558794] ixgbe 0000:c3:00.0 eno2512: NIC Link is Up 10 Gbps, Flow Control: None
[  156.567405] IPv6: ADDRCONF(NETDEV_CHANGE): eno2512: link becomes ready
[  156.862250] ixgbe 0000:a3:00.1: registered PHC device on eno2337
[  156.871586] IPv6: ADDRCONF(NETDEV_UP): eno2337: link is not ready
[  157.163122] ixgbe 0000:c3:00.1: registered PHC device on eno2513
[  157.172262] IPv6: ADDRCONF(NETDEV_UP): eno2513: link is not ready
[  157.466403] ixgbe 0000:e1:00.1: registered PHC device on eno1265
[  157.475504] IPv6: ADDRCONF(NETDEV_UP): eno1265: link is not ready
[  157.482403] ixgbe 0000:e1:00.1 eno1265: NIC Link is Up 10 Gbps, Flow Control: None
[  157.491065] IPv6: ADDRCONF(NETDEV_CHANGE): eno1265: link becomes ready
[  157.784540] ixgbe 0000:e3:00.0: registered PHC device on eno2688
[  157.793748] IPv6: ADDRCONF(NETDEV_UP): eno2688: link is not ready
[  157.800631] ixgbe 0000:e3:00.0 eno2688: NIC Link is Up 10 Gbps, Flow Control: None
[  157.809731] IPv6: ADDRCONF(NETDEV_CHANGE): eno2688: link becomes ready
[  158.105176] ixgbe 0000:e1:00.0: registered PHC device on eno1264
[  158.114331] IPv6: ADDRCONF(NETDEV_UP): eno1264: link is not ready
[  158.121216] ixgbe 0000:e1:00.0 eno1264: NIC Link is Up 10 Gbps, Flow Control: None
[  158.129853] IPv6: ADDRCONF(NETDEV_CHANGE): eno1264: link becomes ready
[  158.445487] ixgbe 0000:e3:00.1: registered PHC device on eno2689
[  158.454500] IPv6: ADDRCONF(NETDEV_UP): eno2689: link is not ready
[  272.609418] EXT4-fs (dm-2): mounted filesystem with ordered data mode. Opts: (null)
[  717.221860] perf samples too long (2583 > 2500), lowering kernel.perf_event_max_sample_rate to 50000
[ 2186.204000] loop: module loaded
[ 2186.324348] bio: create slab <bio-3> at 3
[ 2186.397115] bio: create slab <bio-4> at 4
[ 2188.014354] IPv6: ADDRCONF(NETDEV_UP): docker0: link is not ready
[ 2188.553923] ixgbe 0000:01:00.0 eno32: NIC Link is Up 10 Gbps, Flow Control: None
[ 2188.935871] ixgbe 0000:01:00.1 eno33: NIC Link is Up 10 Gbps, Flow Control: None
[ 2189.319036] ixgbe 0000:03:00.0 eno1456: NIC Link is Up 10 Gbps, Flow Control: None
[ 2190.084131] ixgbe 0000:21:00.0 eno208: NIC Link is Up 10 Gbps, Flow Control: None
[ 2190.464620] ixgbe 0000:21:00.1 eno209: NIC Link is Up 10 Gbps, Flow Control: None
[ 2190.846676] ixgbe 0000:23:00.0 eno1632: NIC Link is Up 10 Gbps, Flow Control: None
[ 2191.611838] ixgbe 0000:41:00.0 eno384: NIC Link is Up 10 Gbps, Flow Control: None
[ 2192.000556] ixgbe 0000:41:00.1 eno385: NIC Link is Up 10 Gbps, Flow Control: None
[ 2192.383760] ixgbe 0000:43:00.0 eno1808: NIC Link is Up 10 Gbps, Flow Control: None
[ 2193.149273] ixgbe 0000:61:00.0 eno560: NIC Link is Up 10 Gbps, Flow Control: None
[ 2193.529499] ixgbe 0000:61:00.1 eno561: NIC Link is Up 10 Gbps, Flow Control: None
[ 2193.911027] ixgbe 0000:63:00.0 eno1984: NIC Link is Up 10 Gbps, Flow Control: None
[ 2194.681507] ixgbe 0000:85:00.0 eno736: NIC Link is Up 10 Gbps, Flow Control: None
[ 2195.061848] ixgbe 0000:85:00.1 eno737: NIC Link is Up 10 Gbps, Flow Control: None
[ 2195.443527] ixgbe 0000:87:00.0 eno2160: NIC Link is Up 10 Gbps, Flow Control: None
[ 2196.203878] ixgbe 0000:a1:00.0 eno912: NIC Link is Up 10 Gbps, Flow Control: None
[ 2196.593774] ixgbe 0000:a1:00.1 eno913: NIC Link is Up 10 Gbps, Flow Control: None
[ 2196.976422] ixgbe 0000:a3:00.0 eno2336: NIC Link is Up 10 Gbps, Flow Control: None
[ 2197.742300] ixgbe 0000:c1:00.0 eno1088: NIC Link is Up 10 Gbps, Flow Control: None
[ 2198.123353] ixgbe 0000:c1:00.1 eno1089: NIC Link is Up 10 Gbps, Flow Control: None
[ 2198.505317] ixgbe 0000:c3:00.0 eno2512: NIC Link is Up 10 Gbps, Flow Control: None
[ 2199.270987] ixgbe 0000:e1:00.0 eno1264: NIC Link is Up 10 Gbps, Flow Control: None
[ 2199.652045] ixgbe 0000:e1:00.1 eno1265: NIC Link is Up 10 Gbps, Flow Control: None
[ 2200.032174] ixgbe 0000:e3:00.0 eno2688: NIC Link is Up 10 Gbps, Flow Control: None
[ 2410.231164] device-mapper: thin: Creation of new snapshot 0 of device 0 failed.
[ 2410.296150] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2411.933475] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2411.987860] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2413.767978] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2432.791972] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2433.763013] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2433.891398] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2433.945378] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2435.050940] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2435.105400] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2437.336386] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2437.469802] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2437.854051] IPv6: ADDRCONF(NETDEV_UP): veth68f7: link is not ready
[ 2437.871706] IPv6: ADDRCONF(NETDEV_CHANGE): veth68f7: link becomes ready
[ 2437.885646] device veth1546 entered promiscuous mode
[ 2438.160040] docker0: port 1(veth1546) entered disabled state
[ 2438.174111] device veth1546 left promiscuous mode
[ 2438.179371] docker0: port 1(veth1546) entered disabled state
[ 2438.248194] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2439.029329] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2439.081919] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2440.974626] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2441.102919] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2441.155531] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2442.046637] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2442.097812] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2444.081154] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2444.210262] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2444.262920] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2445.124555] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2445.177770] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2447.139394] device-mapper: ioctl: unable to remove open device docker-253:37-51124480-372a7358356f273174dd87ca3678a73e6d073c3f2d5e525c3faf88a78b3c732d-init
[ 2447.235973] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2447.367664] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2447.420338] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2448.360656] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2448.412947] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2450.367806] device-mapper: ioctl: unable to remove open device docker-253:37-51124480-351db7bd206b629920c03414f4f2251b6594875f689334401a268505e65b78c1-init
[ 2450.461946] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2450.590702] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2450.640917] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2451.666425] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2451.719922] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2453.738854] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2453.870514] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2453.969637] IPv6: ADDRCONF(NETDEV_UP): veth721e: link is not ready
[ 2453.986841] IPv6: ADDRCONF(NETDEV_CHANGE): veth721e: link becomes ready
[ 2454.016171] device vethf0bd entered promiscuous mode
[ 2454.962844] docker0: port 1(vethf0bd) entered forwarding state
[ 2454.969463] docker0: port 1(vethf0bd) entered forwarding state
[ 2454.976927] IPv6: ADDRCONF(NETDEV_CHANGE): docker0: link becomes ready
[ 2470.041660] docker0: port 1(vethf0bd) entered forwarding state
[ 2549.888230] docker0: port 1(vethf0bd) entered disabled state
[ 2549.903048] device vethf0bd left promiscuous mode
[ 2549.908324] docker0: port 1(vethf0bd) entered disabled state
[ 2550.067528] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2551.452144] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2553.366428] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2559.439267] device-mapper: ioctl: unable to remove open device docker-253:37-51124480-7fdc0d53b5910754e429b284e44d068171b15bf273835dcd431ec9fee8ee83c3-init
[ 2576.641073] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2576.779464] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2576.892073] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2578.829245] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2578.927346] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2582.178084] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2582.311111] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2582.409611] IPv6: ADDRCONF(NETDEV_UP): veth6229: link is not ready
[ 2582.427458] IPv6: ADDRCONF(NETDEV_CHANGE): veth6229: link becomes ready
[ 2582.441818] device veth4eac entered promiscuous mode
[ 2583.401180] docker0: port 1(veth4eac) entered forwarding state
[ 2583.407805] docker0: port 1(veth4eac) entered forwarding state
[ 2584.268598] docker0: port 1(veth4eac) entered disabled state
[ 2584.282596] device veth4eac left promiscuous mode
[ 2584.287862] docker0: port 1(veth4eac) entered disabled state
[ 2584.372848] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2586.529686] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2586.818584] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2591.003430] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2591.135126] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2591.231955] IPv6: ADDRCONF(NETDEV_UP): veth58bc: link is not ready
[ 2591.251128] IPv6: ADDRCONF(NETDEV_CHANGE): veth58bc: link becomes ready
[ 2591.266606] device veth805d entered promiscuous mode
[ 2591.590595] docker0: port 1(veth805d) entered disabled state
[ 2591.605236] device veth805d left promiscuous mode
[ 2591.610483] docker0: port 1(veth805d) entered disabled state
[ 2591.678189] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2593.222016] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2593.274783] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2596.131119] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2596.268128] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2596.364865] IPv6: ADDRCONF(NETDEV_UP): veth9543: link is not ready
[ 2596.387560] IPv6: ADDRCONF(NETDEV_CHANGE): veth9543: link becomes ready
[ 2596.396592] device veth36a7 entered promiscuous mode
[ 2596.613413] docker0: port 1(veth36a7) entered disabled state
[ 2596.627243] device veth36a7 left promiscuous mode
[ 2596.632512] docker0: port 1(veth36a7) entered disabled state
[ 2596.694554] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2598.419597] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2598.475715] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2600.983430] device-mapper: ioctl: unable to remove open device docker-253:37-51124480-7b2f1a9d493234839c7fd48441009cb4f680ed0bd9fc7cbbf2b6995fc694b0bb
[ 2601.732824] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2601.861088] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2601.955253] IPv6: ADDRCONF(NETDEV_UP): vethdfd1: link is not ready
[ 2601.972708] IPv6: ADDRCONF(NETDEV_CHANGE): vethdfd1: link becomes ready
[ 2601.986704] device veth124f entered promiscuous mode
[ 2602.213175] docker0: port 1(veth124f) entered disabled state
[ 2602.227144] device veth124f left promiscuous mode
[ 2602.232390] docker0: port 1(veth124f) entered disabled state
[ 2602.277818] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2604.072111] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2604.123676] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2607.321618] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2607.453610] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2607.548715] IPv6: ADDRCONF(NETDEV_UP): veth9e98: link is not ready
[ 2607.566614] IPv6: ADDRCONF(NETDEV_CHANGE): veth9e98: link becomes ready
[ 2607.580497] device veth177c entered promiscuous mode
[ 2607.850501] docker0: port 1(veth177c) entered disabled state
[ 2607.864144] device veth177c left promiscuous mode
[ 2607.869399] docker0: port 1(veth177c) entered disabled state
[ 2607.922218] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2609.736768] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2609.790494] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2612.874988] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2613.004191] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2613.055676] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2614.578154] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2614.629849] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2616.894872] device-mapper: ioctl: unable to remove open device docker-253:37-51124480-405ae40581196b1c9fada48b99403123d8f808d08130eef446623da7fda68bb6-init
[ 2616.992162] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2617.117823] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2617.167004] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2618.531123] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2618.582057] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2621.161509] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2621.288618] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2621.338961] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2622.701835] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2622.750700] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2625.204657] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2625.332777] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2625.383571] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2626.714701] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2626.765374] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2629.068667] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2629.197513] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2629.245594] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2630.573497] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2630.623092] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2632.882089] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2633.011114] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2633.059933] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2634.393463] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2634.442504] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2636.790445] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2636.916689] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2636.966805] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2638.296531] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2638.347585] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2640.627921] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2640.757651] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2640.809796] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2642.149005] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2642.197946] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2658.218449] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2658.352756] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2658.454313] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2660.040868] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2660.146646] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2663.198150] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2663.333356] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2663.430175] IPv6: ADDRCONF(NETDEV_UP): veth904a: link is not ready
[ 2663.453024] IPv6: ADDRCONF(NETDEV_CHANGE): veth904a: link becomes ready
[ 2663.464302] device veth0a0e entered promiscuous mode
[ 2664.089727] docker0: port 1(veth0a0e) entered disabled state
[ 2664.103738] device veth0a0e left promiscuous mode
[ 2664.108978] docker0: port 1(veth0a0e) entered disabled state
[ 2664.187191] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2665.935207] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2666.050090] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2668.912184] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2669.034488] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2669.127892] IPv6: ADDRCONF(NETDEV_UP): veth0542: link is not ready
[ 2669.150709] IPv6: ADDRCONF(NETDEV_CHANGE): veth0542: link becomes ready
[ 2669.161693] device veth28ac entered promiscuous mode
[ 2669.414323] docker0: port 1(veth28ac) entered disabled state
[ 2669.427854] device veth28ac left promiscuous mode
[ 2669.433118] docker0: port 1(veth28ac) entered disabled state
[ 2669.498060] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2671.102945] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2671.155028] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2732.571917] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2732.706393] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2733.046714] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2734.803515] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2735.147711] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2738.878804] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2739.004445] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2739.097548] IPv6: ADDRCONF(NETDEV_UP): vethf115: link is not ready
[ 2739.123468] IPv6: ADDRCONF(NETDEV_CHANGE): vethf115: link becomes ready
[ 2739.131280] device veth7b05 entered promiscuous mode
[ 2740.090790] docker0: port 1(veth7b05) entered forwarding state
[ 2740.097373] docker0: port 1(veth7b05) entered forwarding state
[ 2741.304239] docker0: port 1(veth7b05) entered disabled state
[ 2741.318165] device veth7b05 left promiscuous mode
[ 2741.323448] docker0: port 1(veth7b05) entered disabled state
[ 2741.421725] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2742.971667] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2743.382077] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2747.527445] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2747.668017] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2747.765566] IPv6: ADDRCONF(NETDEV_UP): vethb4c1: link is not ready
[ 2747.783650] IPv6: ADDRCONF(NETDEV_CHANGE): vethb4c1: link becomes ready
[ 2747.797094] device veth808b entered promiscuous mode
[ 2748.169567] docker0: port 1(veth808b) entered disabled state
[ 2748.183598] device veth808b left promiscuous mode
[ 2748.188876] docker0: port 1(veth808b) entered disabled state
[ 2748.248794] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2749.857872] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2749.909856] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2751.945385] device-mapper: ioctl: unable to remove open device docker-253:37-51124480-dfbc1c5b71d0c7e75b1baf2a1c34aa2bdb896a68f1a027828b4fc0e0315d4fa7
[ 2752.560821] device-mapper: ioctl: unable to remove open device docker-253:37-51124480-dfbc1c5b71d0c7e75b1baf2a1c34aa2bdb896a68f1a027828b4fc0e0315d4fa7-init
[ 2752.662600] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2752.788126] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2752.839461] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2754.363716] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2754.415296] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2757.101811] device-mapper: ioctl: unable to remove open device docker-253:37-51124480-76b2b14788e5145327147922c95325d587b8383f681ac22a14ee9d8d65c00249-init
[ 2757.308197] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2757.434705] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2757.484314] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2759.045408] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2759.094195] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2761.616707] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2761.743528] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2761.793551] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2763.181370] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2763.231125] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2765.721752] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2765.848267] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2765.901750] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2767.278116] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2767.328609] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2769.900677] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2770.027826] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2770.078191] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2771.474915] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2771.524669] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2774.291321] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2774.424298] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2774.476323] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2775.854616] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2775.906213] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2778.390364] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2778.515017] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2778.564965] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2779.925550] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2779.975814] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2782.501959] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2782.632742] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2782.683900] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2784.081245] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2784.132962] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2786.672432] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2786.799445] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2786.850241] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2788.241680] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2788.294838] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2790.771824] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2790.898326] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2790.952518] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2792.331767] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2792.383926] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2794.922641] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2795.049224] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2795.100645] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2796.496786] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2796.547819] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2799.166080] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2799.296894] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2799.350308] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2800.822218] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2800.874726] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2803.271227] device-mapper: ioctl: unable to remove open device docker-253:37-51124480-b1d0c027e13dabfd2a5af02b04a4d6617957c4c02ecda1ed3a9da5ea662ce50f-init
[ 2803.478764] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2803.615750] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2803.673135] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2805.406073] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2805.460785] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2808.799211] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2808.937060] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2808.990957] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2810.629777] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2810.680192] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2813.957018] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2814.097437] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2814.150769] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2815.664134] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2815.720080] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2819.335761] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2819.466219] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2819.517623] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2821.153632] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2821.205494] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2828.140054] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2846.123230] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2848.521392] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2848.642884] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2850.881399] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2850.934801] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2854.129551] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2854.181759] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2854.839580] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2854.963415] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2855.060305] IPv6: ADDRCONF(NETDEV_UP): veth6782: link is not ready
[ 2855.077709] IPv6: ADDRCONF(NETDEV_CHANGE): veth6782: link becomes ready
[ 2855.090983] device veth5520 entered promiscuous mode
[ 2855.278961] docker0: port 1(veth5520) entered disabled state
[ 2855.292729] device veth5520 left promiscuous mode
[ 2855.298016] docker0: port 1(veth5520) entered disabled state
[ 2855.359632] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2856.022375] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2856.075100] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2857.711616] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2857.833896] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2857.927888] IPv6: ADDRCONF(NETDEV_UP): veth29db: link is not ready
[ 2857.953193] device veth735d entered promiscuous mode
[ 2857.967054] IPv6: ADDRCONF(NETDEV_CHANGE): veth29db: link becomes ready
[ 2858.150756] docker0: port 1(veth735d) entered disabled state
[ 2858.164123] device veth735d left promiscuous mode
[ 2858.169381] docker0: port 1(veth735d) entered disabled state
[ 2858.230570] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2858.879137] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2858.929495] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2860.575393] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2860.694233] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2860.823319] IPv6: ADDRCONF(NETDEV_UP): veth2bf5: link is not ready
[ 2860.847891] IPv6: ADDRCONF(NETDEV_CHANGE): veth2bf5: link becomes ready
[ 2860.857133] device vethb259 entered promiscuous mode
[ 2861.050466] docker0: port 1(vethb259) entered disabled state
[ 2861.064061] device vethb259 left promiscuous mode
[ 2861.069309] docker0: port 1(vethb259) entered disabled state
[ 2861.141759] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2861.704016] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2861.785462] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2863.426379] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2863.545744] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2863.647417] IPv6: ADDRCONF(NETDEV_UP): vethf470: link is not ready
[ 2863.662205] IPv6: ADDRCONF(NETDEV_CHANGE): vethf470: link becomes ready
[ 2863.671208] device veth6dcb entered promiscuous mode
[ 2864.642258] docker0: port 1(veth6dcb) entered forwarding state
[ 2864.648823] docker0: port 1(veth6dcb) entered forwarding state
[ 2879.705048] docker0: port 1(veth6dcb) entered forwarding state
[ 2955.025389] docker0: port 1(veth6dcb) entered disabled state
[ 2955.040300] device veth6dcb left promiscuous mode
[ 2955.045551] docker0: port 1(veth6dcb) entered disabled state
[ 2955.173913] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2956.018781] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2957.471514] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2960.846880] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2960.989698] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2961.047600] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2962.350181] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2962.404130] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 2964.708035] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2964.840526] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 2964.892560] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2966.165213] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 2966.216709] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 3013.305143] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 3013.447478] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: discard
[ 3013.545447] IPv6: ADDRCONF(NETDEV_UP): veth6017: link is not ready
[ 3013.568989] device vetha5c3 entered promiscuous mode
[ 3013.578054] IPv6: ADDRCONF(NETDEV_CHANGE): veth6017: link becomes ready
[ 3014.543405] docker0: port 1(vetha5c3) entered forwarding state
[ 3014.549986] docker0: port 1(vetha5c3) entered forwarding state
[ 3029.588102] docker0: port 1(vetha5c3) entered forwarding state
[ 3032.252258] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 3032.391940] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: discard
[ 3032.516019] IPv6: ADDRCONF(NETDEV_UP): vethda3e: link is not ready
[ 3032.534195] IPv6: ADDRCONF(NETDEV_CHANGE): vethda3e: link becomes ready
[ 3032.548325] device veth80a5 entered promiscuous mode
[ 3033.509023] docker0: port 2(veth80a5) entered forwarding state
[ 3033.515651] docker0: port 2(veth80a5) entered forwarding state
[ 3036.213015] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 3036.345346] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: discard
[ 3036.470357] IPv6: ADDRCONF(NETDEV_UP): veth790f: link is not ready
[ 3036.488078] IPv6: ADDRCONF(NETDEV_CHANGE): veth790f: link becomes ready
[ 3036.502827] device veth2001 entered promiscuous mode
[ 3037.468045] docker0: port 3(veth2001) entered forwarding state
[ 3037.474610] docker0: port 3(veth2001) entered forwarding state
[ 3040.161241] EXT4-fs (dm-47): mounted filesystem with ordered data mode. Opts: discard
[ 3040.344719] EXT4-fs (dm-47): mounted filesystem with ordered data mode. Opts: discard
[ 3040.479557] IPv6: ADDRCONF(NETDEV_UP): veth08d8: link is not ready
[ 3040.502460] IPv6: ADDRCONF(NETDEV_CHANGE): veth08d8: link becomes ready
[ 3040.521972] device vethd0a8 entered promiscuous mode
[ 3041.474993] docker0: port 4(vethd0a8) entered forwarding state
[ 3041.481621] docker0: port 4(vethd0a8) entered forwarding state
[ 3044.264558] EXT4-fs (dm-48): mounted filesystem with ordered data mode. Opts: discard
[ 3044.408989] EXT4-fs (dm-48): mounted filesystem with ordered data mode. Opts: discard
[ 3044.525572] IPv6: ADDRCONF(NETDEV_UP): veth8b7d: link is not ready
[ 3044.551108] IPv6: ADDRCONF(NETDEV_CHANGE): veth8b7d: link becomes ready
[ 3044.570121] device veth3f65 entered promiscuous mode
[ 3045.524073] docker0: port 5(veth3f65) entered forwarding state
[ 3045.530666] docker0: port 5(veth3f65) entered forwarding state
[ 3048.290774] EXT4-fs (dm-49): mounted filesystem with ordered data mode. Opts: discard
[ 3048.469344] EXT4-fs (dm-49): mounted filesystem with ordered data mode. Opts: discard
[ 3048.555798] docker0: port 2(veth80a5) entered forwarding state
[ 3048.608525] IPv6: ADDRCONF(NETDEV_UP): vethe3ad: link is not ready
[ 3048.640738] IPv6: ADDRCONF(NETDEV_CHANGE): vethe3ad: link becomes ready
[ 3048.655740] device veth73c5 entered promiscuous mode
[ 3049.605133] docker0: port 6(veth73c5) entered forwarding state
[ 3049.611709] docker0: port 6(veth73c5) entered forwarding state
[ 3052.528743] docker0: port 3(veth2001) entered forwarding state
[ 3052.583626] EXT4-fs (dm-50): mounted filesystem with ordered data mode. Opts: discard
[ 3052.728634] EXT4-fs (dm-50): mounted filesystem with ordered data mode. Opts: discard
[ 3052.868160] IPv6: ADDRCONF(NETDEV_UP): veth30bb: link is not ready
[ 3052.889944] IPv6: ADDRCONF(NETDEV_CHANGE): veth30bb: link becomes ready
[ 3052.920756] device vethc7e2 entered promiscuous mode
[ 3052.983776] hrtimer: interrupt took 3192065 ns
[ 3053.866446] docker0: port 7(vethc7e2) entered forwarding state
[ 3053.873036] docker0: port 7(vethc7e2) entered forwarding state
[ 3056.501724] docker0: port 4(vethd0a8) entered forwarding state
[ 3056.801587] EXT4-fs (dm-51): mounted filesystem with ordered data mode. Opts: discard
[ 3056.989568] EXT4-fs (dm-51): mounted filesystem with ordered data mode. Opts: discard
[ 3057.151145] IPv6: ADDRCONF(NETDEV_UP): vethd9c6: link is not ready
[ 3057.172091] IPv6: ADDRCONF(NETDEV_CHANGE): vethd9c6: link becomes ready
[ 3057.189887] device vethe3e4 entered promiscuous mode
[ 3058.143800] docker0: port 8(vethe3e4) entered forwarding state
[ 3058.150346] docker0: port 8(vethe3e4) entered forwarding state
[ 3060.602842] docker0: port 5(veth3f65) entered forwarding state
[ 3060.928181] EXT4-fs (dm-52): mounted filesystem with ordered data mode. Opts: discard
[ 3061.110035] EXT4-fs (dm-52): mounted filesystem with ordered data mode. Opts: discard
[ 3061.253971] IPv6: ADDRCONF(NETDEV_UP): vethf85c: link is not ready
[ 3061.279043] IPv6: ADDRCONF(NETDEV_CHANGE): vethf85c: link becomes ready
[ 3061.315470] device veth9273 entered promiscuous mode
[ 3062.252976] docker0: port 9(veth9273) entered forwarding state
[ 3062.259597] docker0: port 9(veth9273) entered forwarding state
[ 3064.639904] docker0: port 6(veth73c5) entered forwarding state
[ 3065.040276] EXT4-fs (dm-53): mounted filesystem with ordered data mode. Opts: discard
[ 3065.174638] EXT4-fs (dm-53): mounted filesystem with ordered data mode. Opts: discard
[ 3065.318158] IPv6: ADDRCONF(NETDEV_UP): vethef9a: link is not ready
[ 3065.347062] IPv6: ADDRCONF(NETDEV_CHANGE): vethef9a: link becomes ready
[ 3065.358143] device vethc013 entered promiscuous mode
[ 3066.310021] docker0: port 10(vethc013) entered forwarding state
[ 3066.316671] docker0: port 10(vethc013) entered forwarding state
[ 3068.933268] docker0: port 7(vethc7e2) entered forwarding state
[ 3069.128917] EXT4-fs (dm-54): mounted filesystem with ordered data mode. Opts: discard
[ 3069.273229] EXT4-fs (dm-54): mounted filesystem with ordered data mode. Opts: discard
[ 3069.417881] IPv6: ADDRCONF(NETDEV_UP): vethb21a: link is not ready
[ 3069.437286] IPv6: ADDRCONF(NETDEV_CHANGE): vethb21a: link becomes ready
[ 3069.459015] device veth3054 entered promiscuous mode
[ 3070.419130] docker0: port 11(veth3054) entered forwarding state
[ 3070.425788] docker0: port 11(veth3054) entered forwarding state
[ 3073.223160] EXT4-fs (dm-55): mounted filesystem with ordered data mode. Opts: discard
[ 3073.226577] docker0: port 8(vethe3e4) entered forwarding state
[ 3073.388713] EXT4-fs (dm-55): mounted filesystem with ordered data mode. Opts: discard
[ 3073.532072] IPv6: ADDRCONF(NETDEV_UP): vethb0c9: link is not ready
[ 3073.557877] IPv6: ADDRCONF(NETDEV_CHANGE): vethb0c9: link becomes ready
[ 3073.570059] device veth5444 entered promiscuous mode
[ 3074.528281] docker0: port 12(veth5444) entered forwarding state
[ 3074.534941] docker0: port 12(veth5444) entered forwarding state
[ 3077.275468] EXT4-fs (dm-56): mounted filesystem with ordered data mode. Opts: discard
[ 3077.327690] docker0: port 9(veth9273) entered forwarding state
[ 3077.399563] EXT4-fs (dm-56): mounted filesystem with ordered data mode. Opts: discard
[ 3077.550675] IPv6: ADDRCONF(NETDEV_UP): vethd75a: link is not ready
[ 3077.578887] IPv6: ADDRCONF(NETDEV_CHANGE): vethd75a: link becomes ready
[ 3077.599376] device veth3d0b entered promiscuous mode
[ 3078.545323] docker0: port 13(veth3d0b) entered forwarding state
[ 3078.552018] docker0: port 13(veth3d0b) entered forwarding state
[ 3081.311387] EXT4-fs (dm-57): mounted filesystem with ordered data mode. Opts: discard
[ 3081.364782] docker0: port 10(vethc013) entered forwarding state
[ 3081.452353] EXT4-fs (dm-57): mounted filesystem with ordered data mode. Opts: discard
[ 3081.599923] IPv6: ADDRCONF(NETDEV_UP): veth10e0: link is not ready
[ 3081.616549] IPv6: ADDRCONF(NETDEV_CHANGE): veth10e0: link becomes ready
[ 3081.635852] device vethd00b entered promiscuous mode
[ 3082.598334] docker0: port 14(vethd00b) entered forwarding state
[ 3082.604998] docker0: port 14(vethd00b) entered forwarding state
[ 3085.390407] EXT4-fs (dm-58): mounted filesystem with ordered data mode. Opts: discard
[ 3085.465920] docker0: port 11(veth3054) entered forwarding state
[ 3085.530419] EXT4-fs (dm-58): mounted filesystem with ordered data mode. Opts: discard
[ 3085.710793] IPv6: ADDRCONF(NETDEV_UP): veth7c9f: link is not ready
[ 3085.734906] IPv6: ADDRCONF(NETDEV_CHANGE): veth7c9f: link becomes ready
[ 3085.754154] device vethce7b entered promiscuous mode
[ 3086.707462] docker0: port 15(vethce7b) entered forwarding state
[ 3086.714172] docker0: port 15(vethce7b) entered forwarding state
[ 3089.515823] EXT4-fs (dm-59): mounted filesystem with ordered data mode. Opts: discard
[ 3089.567032] docker0: port 12(veth5444) entered forwarding state
[ 3089.680669] EXT4-fs (dm-59): mounted filesystem with ordered data mode. Opts: discard
[ 3089.828825] IPv6: ADDRCONF(NETDEV_UP): veth6fea: link is not ready
[ 3089.860331] IPv6: ADDRCONF(NETDEV_CHANGE): veth6fea: link becomes ready
[ 3089.881251] device veth1f8c entered promiscuous mode
[ 3090.824638] docker0: port 16(veth1f8c) entered forwarding state
[ 3090.831332] docker0: port 16(veth1f8c) entered forwarding state
[ 3093.604053] docker0: port 13(veth3d0b) entered forwarding state
[ 3093.649577] EXT4-fs (dm-60): mounted filesystem with ordered data mode. Opts: discard
[ 3093.798163] EXT4-fs (dm-60): mounted filesystem with ordered data mode. Opts: discard
[ 3093.988533] IPv6: ADDRCONF(NETDEV_UP): veth00ad: link is not ready
[ 3094.022050] IPv6: ADDRCONF(NETDEV_CHANGE): veth00ad: link becomes ready
[ 3094.032701] device veth797a entered promiscuous mode
[ 3094.981800] docker0: port 17(veth797a) entered forwarding state
[ 3094.988455] docker0: port 17(veth797a) entered forwarding state
[ 3097.642068] docker0: port 14(vethd00b) entered forwarding state
[ 3097.842301] EXT4-fs (dm-61): mounted filesystem with ordered data mode. Opts: discard
[ 3097.989584] EXT4-fs (dm-61): mounted filesystem with ordered data mode. Opts: discard
[ 3098.165442] IPv6: ADDRCONF(NETDEV_UP): veth0acb: link is not ready
[ 3098.190271] IPv6: ADDRCONF(NETDEV_CHANGE): veth0acb: link becomes ready
[ 3098.206985] device veth7a6e entered promiscuous mode
[ 3099.154974] docker0: port 18(veth7a6e) entered forwarding state
[ 3099.161661] docker0: port 18(veth7a6e) entered forwarding state
[ 3101.742223] docker0: port 15(vethce7b) entered forwarding state
[ 3102.064830] EXT4-fs (dm-62): mounted filesystem with ordered data mode. Opts: discard
[ 3102.204824] EXT4-fs (dm-62): mounted filesystem with ordered data mode. Opts: discard
[ 3102.370049] IPv6: ADDRCONF(NETDEV_UP): veth9666: link is not ready
[ 3102.392917] IPv6: ADDRCONF(NETDEV_CHANGE): veth9666: link becomes ready
[ 3102.430419] device veth96cc entered promiscuous mode
[ 3103.364268] docker0: port 19(veth96cc) entered forwarding state
[ 3103.370959] docker0: port 19(veth96cc) entered forwarding state
[ 3105.907395] docker0: port 16(veth1f8c) entered forwarding state
[ 3106.274202] EXT4-fs (dm-63): mounted filesystem with ordered data mode. Opts: discard
[ 3106.449107] EXT4-fs (dm-63): mounted filesystem with ordered data mode. Opts: discard
[ 3106.621214] IPv6: ADDRCONF(NETDEV_UP): vethee89: link is not ready
[ 3106.653144] IPv6: ADDRCONF(NETDEV_CHANGE): vethee89: link becomes ready
[ 3106.670182] device vethdc8c entered promiscuous mode
[ 3107.617589] docker0: port 20(vethdc8c) entered forwarding state
[ 3107.624343] docker0: port 20(vethdc8c) entered forwarding state
[ 3110.008501] docker0: port 17(veth797a) entered forwarding state
[ 3110.483798] EXT4-fs (dm-64): mounted filesystem with ordered data mode. Opts: discard
[ 3110.710041] EXT4-fs (dm-64): mounted filesystem with ordered data mode. Opts: discard
[ 3110.867273] IPv6: ADDRCONF(NETDEV_UP): veth239c: link is not ready
[ 3110.899034] IPv6: ADDRCONF(NETDEV_CHANGE): veth239c: link becomes ready
[ 3110.915036] device veth2cd6 entered promiscuous mode
[ 3111.866943] docker0: port 21(veth2cd6) entered forwarding state
[ 3111.873708] docker0: port 21(veth2cd6) entered forwarding state
[ 3114.237768] docker0: port 18(veth7a6e) entered forwarding state
[ 3114.888934] EXT4-fs (dm-65): mounted filesystem with ordered data mode. Opts: discard
[ 3115.074084] EXT4-fs (dm-65): mounted filesystem with ordered data mode. Opts: discard
[ 3115.270717] IPv6: ADDRCONF(NETDEV_UP): veth4a53: link is not ready
[ 3115.307539] IPv6: ADDRCONF(NETDEV_CHANGE): veth4a53: link becomes ready
[ 3115.339567] device veth31cd entered promiscuous mode
[ 3116.258330] docker0: port 22(veth31cd) entered forwarding state
[ 3116.265006] docker0: port 22(veth31cd) entered forwarding state
[ 3118.402991] docker0: port 19(veth96cc) entered forwarding state
[ 3119.314381] EXT4-fs (dm-66): mounted filesystem with ordered data mode. Opts: discard
[ 3119.464265] EXT4-fs (dm-66): mounted filesystem with ordered data mode. Opts: discard
[ 3119.638784] IPv6: ADDRCONF(NETDEV_UP): veth0855: link is not ready
[ 3119.665942] IPv6: ADDRCONF(NETDEV_CHANGE): veth0855: link becomes ready
[ 3119.696876] device vethb822 entered promiscuous mode
[ 3120.633789] docker0: port 23(vethb822) entered forwarding state
[ 3120.640488] docker0: port 23(vethb822) entered forwarding state
[ 3122.696357] docker0: port 20(vethdc8c) entered forwarding state
[ 3123.615148] EXT4-fs (dm-67): mounted filesystem with ordered data mode. Opts: discard
[ 3123.814276] EXT4-fs (dm-67): mounted filesystem with ordered data mode. Opts: discard
[ 3124.040508] IPv6: ADDRCONF(NETDEV_UP): vethc809: link is not ready
[ 3124.072388] IPv6: ADDRCONF(NETDEV_CHANGE): vethc809: link becomes ready
[ 3124.084484] device veth4f38 entered promiscuous mode
[ 3125.031339] docker0: port 24(veth4f38) entered forwarding state
[ 3125.038031] docker0: port 24(veth4f38) entered forwarding state
[ 3126.925647] docker0: port 21(veth2cd6) entered forwarding state
[ 3128.017376] EXT4-fs (dm-68): mounted filesystem with ordered data mode. Opts: discard
[ 3128.206306] EXT4-fs (dm-68): mounted filesystem with ordered data mode. Opts: discard
[ 3128.403979] IPv6: ADDRCONF(NETDEV_UP): veth8861: link is not ready
[ 3128.445342] IPv6: ADDRCONF(NETDEV_CHANGE): veth8861: link becomes ready
[ 3128.467314] device veth22d4 entered promiscuous mode
[ 3129.392782] docker0: port 25(veth22d4) entered forwarding state
[ 3129.399428] docker0: port 25(veth22d4) entered forwarding state
[ 3131.315153] docker0: port 22(veth31cd) entered forwarding state
[ 3132.419496] EXT4-fs (dm-69): mounted filesystem with ordered data mode. Opts: discard
[ 3132.554577] EXT4-fs (dm-69): mounted filesystem with ordered data mode. Opts: discard
[ 3132.729750] IPv6: ADDRCONF(NETDEV_UP): veth98ad: link is not ready
[ 3132.751553] IPv6: ADDRCONF(NETDEV_CHANGE): veth98ad: link becomes ready
[ 3132.774042] device veth1321 entered promiscuous mode
[ 3133.726177] docker0: port 26(veth1321) entered forwarding state
[ 3133.732847] docker0: port 26(veth1321) entered forwarding state
[ 3135.704595] docker0: port 23(vethb822) entered forwarding state
[ 3136.680286] EXT4-fs (dm-70): mounted filesystem with ordered data mode. Opts: discard
[ 3136.900790] EXT4-fs (dm-70): mounted filesystem with ordered data mode. Opts: discard
[ 3137.102195] IPv6: ADDRCONF(NETDEV_UP): vetha9bd: link is not ready
[ 3137.136307] IPv6: ADDRCONF(NETDEV_CHANGE): vetha9bd: link becomes ready
[ 3137.185290] device veth8f1e entered promiscuous mode
[ 3138.095643] docker0: port 27(veth8f1e) entered forwarding state
[ 3138.102330] docker0: port 27(veth8f1e) entered forwarding state
[ 3140.062046] docker0: port 24(veth4f38) entered forwarding state
[ 3141.151546] EXT4-fs (dm-71): mounted filesystem with ordered data mode. Opts: discard
[ 3141.399764] EXT4-fs (dm-71): mounted filesystem with ordered data mode. Opts: discard
[ 3141.595008] IPv6: ADDRCONF(NETDEV_UP): veth1e20: link is not ready
[ 3141.622355] IPv6: ADDRCONF(NETDEV_CHANGE): veth1e20: link becomes ready
[ 3141.654462] device veth9680 entered promiscuous mode
[ 3142.589217] docker0: port 28(veth9680) entered forwarding state
[ 3142.595898] docker0: port 28(veth9680) entered forwarding state
[ 3144.419491] docker0: port 25(veth22d4) entered forwarding state
[ 3145.561175] EXT4-fs (dm-72): mounted filesystem with ordered data mode. Opts: discard
[ 3145.745621] EXT4-fs (dm-72): mounted filesystem with ordered data mode. Opts: discard
[ 3145.960752] IPv6: ADDRCONF(NETDEV_UP): veth6efb: link is not ready
[ 3145.990768] IPv6: ADDRCONF(NETDEV_CHANGE): veth6efb: link becomes ready
[ 3146.017599] device vethf1d5 entered promiscuous mode
[ 3146.950653] docker0: port 29(vethf1d5) entered forwarding state
[ 3146.957335] docker0: port 29(vethf1d5) entered forwarding state
[ 3148.776933] docker0: port 26(veth1321) entered forwarding state
[ 3149.949677] EXT4-fs (dm-73): mounted filesystem with ordered data mode. Opts: discard
[ 3150.100725] EXT4-fs (dm-73): mounted filesystem with ordered data mode. Opts: discard
[ 3150.312227] IPv6: ADDRCONF(NETDEV_UP): veth6915: link is not ready
[ 3150.359140] IPv6: ADDRCONF(NETDEV_CHANGE): veth6915: link becomes ready
[ 3150.366931] device veth5b14 entered promiscuous mode
[ 3151.294153] docker0: port 30(veth5b14) entered forwarding state
[ 3151.300872] docker0: port 30(veth5b14) entered forwarding state
[ 3153.134385] docker0: port 27(veth8f1e) entered forwarding state
[ 3154.312945] EXT4-fs (dm-74): mounted filesystem with ordered data mode. Opts: discard
[ 3154.490233] EXT4-fs (dm-74): mounted filesystem with ordered data mode. Opts: discard
[ 3154.689691] IPv6: ADDRCONF(NETDEV_UP): veth2941: link is not ready
[ 3154.719452] IPv6: ADDRCONF(NETDEV_CHANGE): veth2941: link becomes ready
[ 3154.760054] device vethe037 entered promiscuous mode
[ 3155.677553] docker0: port 31(vethe037) entered forwarding state
[ 3155.684288] docker0: port 31(vethe037) entered forwarding state
[ 3157.619988] docker0: port 28(veth9680) entered forwarding state
[ 3158.802804] EXT4-fs (dm-75): mounted filesystem with ordered data mode. Opts: discard
[ 3159.000745] EXT4-fs (dm-75): mounted filesystem with ordered data mode. Opts: discard
[ 3159.222418] IPv6: ADDRCONF(NETDEV_UP): veth608b: link is not ready
[ 3159.249976] IPv6: ADDRCONF(NETDEV_CHANGE): veth608b: link becomes ready
[ 3159.266917] device vethabee entered promiscuous mode
[ 3160.213215] docker0: port 32(vethabee) entered forwarding state
[ 3160.219959] docker0: port 32(vethabee) entered forwarding state
[ 3161.977426] docker0: port 29(vethf1d5) entered forwarding state
[ 3163.332603] EXT4-fs (dm-76): mounted filesystem with ordered data mode. Opts: discard
[ 3163.564856] EXT4-fs (dm-76): mounted filesystem with ordered data mode. Opts: discard
[ 3163.788969] IPv6: ADDRCONF(NETDEV_UP): veth9cce: link is not ready
[ 3163.826840] IPv6: ADDRCONF(NETDEV_CHANGE): veth9cce: link becomes ready
[ 3163.848444] device veth7d87 entered promiscuous mode
[ 3164.778920] docker0: port 33(veth7d87) entered forwarding state
[ 3164.785609] docker0: port 33(veth7d87) entered forwarding state
[ 3166.334831] docker0: port 30(veth5b14) entered forwarding state
[ 3167.711782] EXT4-fs (dm-77): mounted filesystem with ordered data mode. Opts: discard
[ 3168.082775] EXT4-fs (dm-77): mounted filesystem with ordered data mode. Opts: discard
[ 3168.279043] IPv6: ADDRCONF(NETDEV_UP): veth03ea: link is not ready
[ 3168.304392] IPv6: ADDRCONF(NETDEV_CHANGE): veth03ea: link becomes ready
[ 3168.361444] device vethb676 entered promiscuous mode
[ 3169.270560] docker0: port 34(vethb676) entered forwarding state
[ 3169.277256] docker0: port 34(vethb676) entered forwarding state
[ 3170.756381] docker0: port 31(vethe037) entered forwarding state
[ 3175.241970] docker0: port 32(vethabee) entered forwarding state
[ 3179.855687] docker0: port 33(veth7d87) entered forwarding state
[ 3184.341327] docker0: port 34(vethb676) entered forwarding state
[ 3331.620687] perf samples too long (5015 > 5000), lowering kernel.perf_event_max_sample_rate to 25000
[ 5889.003933] EXT4-fs (dm-78): mounted filesystem with ordered data mode. Opts: discard
[ 5889.157504] EXT4-fs (dm-78): mounted filesystem with ordered data mode. Opts: discard
[ 5889.335373] IPv6: ADDRCONF(NETDEV_UP): veth0ae6: link is not ready
[ 5889.362241] IPv6: ADDRCONF(NETDEV_CHANGE): veth0ae6: link becomes ready
[ 5889.395408] device vethc880 entered promiscuous mode
[ 5890.331258] docker0: port 35(vethc880) entered forwarding state
[ 5890.337930] docker0: port 35(vethc880) entered forwarding state
[ 5905.369965] docker0: port 35(vethc880) entered forwarding state
[ 5959.021364] net_ratelimit: 2687 callbacks suppressed
[ 5965.493278] net_ratelimit: 378 callbacks suppressed
[ 6000.596811] net_ratelimit: 366 callbacks suppressed
[ 6006.669020] net_ratelimit: 3150 callbacks suppressed
[ 6013.128852] net_ratelimit: 235 callbacks suppressed
[ 6041.679389] net_ratelimit: 230 callbacks suppressed
[ 6047.195333] net_ratelimit: 3518 callbacks suppressed
[ 6054.236323] net_ratelimit: 241 callbacks suppressed
[ 6087.651029] net_ratelimit: 219 callbacks suppressed
[ 6092.876465] net_ratelimit: 5599 callbacks suppressed
[ 6098.651577] net_ratelimit: 347 callbacks suppressed
[ 6128.155561] net_ratelimit: 319 callbacks suppressed
[ 6134.248209] net_ratelimit: 3866 callbacks suppressed
[ 6140.720209] net_ratelimit: 252 callbacks suppressed
[ 6168.913735] net_ratelimit: 235 callbacks suppressed
[ 6169.148712] BUG: unable to handle kernel NULL pointer dereference at           (null)
[ 6169.157531] IP: [<ffffffff8151829d>] tcp_sendpage+0x44d/0x6d0
[ 6169.163995] PGD 49bcfb83067 PUD 49bcfb82067 PMD 0 
[ 6169.169520] Oops: 0002 [#1] SMP 
[ 6169.173230] Modules linked in: veth xt_addrtype ipt_MASQUERADE dm_thin_pool dm_persistent_data dm_bio_prison dm_bufio loop ext4 mbcache jbd2 ip6t_rpfilter ip6t_REJECT ipt_REJECT xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw iptable_filter ip_tables sg iTCO_wdt iTCO_vendor_support coretemp kvm_intel kvm crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel lrw gf128mul glue_helper ablk_helper cryptd pcspkr ses enclosure ixgbe ptp hpilo hpwdt pps_core mdio sb_edac ioatdma lpc_ich edac_co
 re mfd_core
[ 6169.255799]  dca shpchp ipmi_si ipmi_msghandler mperf vfat fat btrfs zlib_deflate raid6_pq xor xfs libcrc32c dm_service_time sd_mod crc_t10dif crct10dif_common mgag200 syscopyarea sysfillrect sysimgblt i2c_algo_bit qla2xxx drm_kms_helper ttm scsi_transport_fc drm scsi_tgt i2c_core dm_mirror dm_region_hash dm_log dm_multipath dm_mod
[ 6169.289059] CPU: 87 PID: 205310 Comm: java Not tainted 3.10.0-123.el7.x86_64 #1
[ 6169.297161] Hardware name: HP Superdome2 16s x86, BIOS Bundle: 005.073.000 SFW: 015.082.000 08/08/2014
[ 6169.307538] task: ffff8c9bccf38000 ti: ffff8c94c506c000 task.ti: ffff8c94c506c000
[ 6169.315890] RIP: 0010:[<ffffffff8151829d>]  [<ffffffff8151829d>] tcp_sendpage+0x44d/0x6d0
[ 6169.325229] RSP: 0018:ffff8c94c506dbe0  EFLAGS: 00010202
[ 6169.331182] RAX: 0000000000000000 RBX: ffff918a6dfda800 RCX: ffff918a6dfda938
[ 6169.339149] RDX: 0000000000000110 RSI: ffff918a6dfda938 RDI: 0000000000000000
[ 6169.347141] RBP: ffff8c94c506dc58 R08: 00000000000002c0 R09: 0000000000000500
[ 6169.355100] R10: ffff88bd7f406e80 R11: 0000000000000000 R12: 0000000000020040
[ 6169.363074] R13: 0000000000000000 R14: 0000000000000219 R15: ffffea1253a1c800
[ 6169.371045] FS:  00007f648fefe700(0000) GS:ffff8c9cffb80000(0000) knlGS:0000000000000000
[ 6169.380075] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 6169.386507] CR2: 0000000000000000 CR3: 0000049bd848c000 CR4: 00000000001407e0
[ 6169.394540] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 6169.402612] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 6169.410621] Stack:
[ 6169.412984]  0000000100000000 ffff8ed00a267c00 ffffffff00000de7 0000000000000de7
[ 6169.422080]  0000000000000001 ffff918a6dfda938 00000de7000005a8 000010f853ab6ec0
[ 6169.431181]  0000000000000000 00000000a54958f0 ffff918a6dfda800 ffff8c9bd5e4fd00
[ 6169.440262] Call Trace:
[ 6169.443190]  [<ffffffff811dc940>] ? splice_from_pipe_feed+0x120/0x120
[ 6169.450512]  [<ffffffff81542ade>] inet_sendpage+0x6e/0xe0
[ 6169.456766]  [<ffffffff814b668b>] kernel_sendpage+0x1b/0x30
[ 6169.463193]  [<ffffffff814b66c7>] sock_sendpage+0x27/0x30
[ 6169.469387]  [<ffffffff811dc9a3>] pipe_to_sendpage+0x63/0xa0
[ 6169.475864]  [<ffffffff811dc89e>] splice_from_pipe_feed+0x7e/0x120
[ 6169.482900]  [<ffffffff811dc940>] ? splice_from_pipe_feed+0x120/0x120
[ 6169.490215]  [<ffffffff811dcc1e>] __splice_from_pipe+0x6e/0x90
[ 6169.496881]  [<ffffffff811dc940>] ? splice_from_pipe_feed+0x120/0x120
[ 6169.504198]  [<ffffffff811de82e>] splice_from_pipe+0x5e/0x90
[ 6169.510659]  [<ffffffff811de860>] ? splice_from_pipe+0x90/0x90
[ 6169.517342]  [<ffffffff811de875>] generic_splice_sendpage+0x15/0x20
[ 6169.524464]  [<ffffffff811dd361>] do_splice_from+0x91/0x100
[ 6169.530900]  [<ffffffff811dd3f0>] direct_splice_actor+0x20/0x30
[ 6169.537686]  [<ffffffff811dd114>] splice_direct_to_actor+0xd4/0x200
[ 6169.544915]  [<ffffffff811dd3d0>] ? do_splice_from+0x100/0x100
[ 6169.551594]  [<ffffffff811de912>] do_splice_direct+0x62/0x90
[ 6169.558070]  [<ffffffff811b0193>] do_sendfile+0x1c3/0x340
[ 6169.564248]  [<ffffffff811b130e>] SyS_sendfile64+0x5e/0xb0
[ 6169.570521]  [<ffffffff815f2119>] system_call_fastpath+0x16/0x1b
[ 6169.577273] Code: 10 88 41 7c 8b 81 dc 00 00 00 48 03 81 e0 00 00 00 f0 81 40 24 00 00 01 00 48 8b 83 40 01 00 00 48 8b 75 b0 48 89 41 08 48 89 31 <48> 89 08 83 83 48 01 00 00 01 48 83 bb 68 02 00 00 00 48 89 8b 
[ 6169.606298] RIP  [<ffffffff8151829d>] tcp_sendpage+0x44d/0x6d0
[ 6169.612956]  RSP <ffff8c94c506dbe0>
[ 6169.616925] CR2: 0000000000000000

--=-AKoF5emHwQaUwEW4zyBt--

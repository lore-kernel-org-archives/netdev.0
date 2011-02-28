From: Jean-Philippe Menil <jean-philippe.menil@univ-nantes.fr>
Subject: Re: Bug inkvm_set_irq
Date: Mon, 28 Feb 2011 23:34:16 +0100
Message-ID: <4D6C22E8.2020007@univ-nantes.fr>
References: <4D67714A.2050100@univ-nantes.fr>	<20110227170031.GC17973@redhat.com>	<4D6B634E.9090801@univ-nantes.fr>	<20110228101139.GD28006@redhat.com>	<4D6B7BAB.9070907@univ-nantes.fr>	<20110228113939.GH28006@redhat.com> <4D6BBB88.5060709@univ-nantes.fr>
Reply-To: jean-philippe.menil@univ-nantes.fr
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050607060509010903000509"
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-tls1.univ-nantes.fr ([193.52.101.145]:45371 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450Ab1B1Wb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 17:31:58 -0500
In-Reply-To: <4D6BBB88.5060709@univ-nantes.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050607060509010903000509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

here is another trace with kvm.ko compiled with debug flags.

the bug:
[12099.503414] BUG: unable to handle kernel paging request at 
000000000b6635e9
[12099.503462] IP: [<ffffffffa03ee877>] kvm_set_irq+0x37/0x140 [kvm]
[12099.503521] PGD 45d8d2067 PUD 45d58e067 PMD 0
[12099.503560] Oops: 0000 [#1] SMP
[12099.503591] last sysfs file: 
/sys/devices/system/cpu/cpu11/cache/index2/shared_cpu_map
[12099.503641] CPU 0
[12099.503648] Modules linked in: netconsole configfs vhost_net macvtap 
macvlan tun veth powernow_k8 mperf cpufreq_userspace cpufreq_stats 
cpufreq_powersave cpufreq_ondemand freq_table cpufreq_conservative fuse 
xt_physdev ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport 
xt_limit xt_tcpudp xt_state iptable_filter ip_tables x_tables 
nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 
8021q bridge stp ext2 mbcache dm_round_robin dm_multipath 
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 kvm_amd kvm ipv6 snd_pcm 
snd_timer snd soundcore snd_page_alloc shpchp pci_hotplug tpm_tis 
i2c_nforce2 tpm i2c_core pcspkr evdev psmouse joydev tpm_bios processor 
ghes dcdbas hed button serio_raw thermal_sys xfs exportfs dm_mod sg 
sr_mod cdrom usbhid hid usb_storage ses sd_mod enclosure megaraid_sas 
ohci_hcd lpfc scsi_transport_fc bnx2 scsi_tgt scsi_mod ehci_hcd [last 
unloaded: scsi_wait_scan]
[12099.504277]
[12099.504302] Pid: 1742, comm: kworker/0:2 Not tainted 
2.6.37.2-dsiun-110105+ #2 Dell Inc. PowerEdge M605/0K543T
[12099.504373] RIP: 0010:[<ffffffffa03ee877>]  [<ffffffffa03ee877>] 
kvm_set_irq+0x37/0x140 [kvm]
[12099.504444] RSP: 0018:ffff88045e013d00  EFLAGS: 00010246
[12099.504474] RAX: 000000000b6634c1 RBX: 0000000000000018 RCX: 
0000000000000001
[12099.504508] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
ffff880419b600c0
[12099.504541] RBP: ffff88045e013dd0 R08: ffff88045e012000 R09: 
0000000000000000
[12099.504575] R10: 0000000000000000 R11: 00000000ffffffff R12: 
ffff880419b600c0
[12099.504609] R13: ffff880419b600c0 R14: ffffffffa03efaa0 R15: 
0000000000000001
[12099.504643] FS:  00007f3abaa05710(0000) GS:ffff88007f800000(0000) 
knlGS:0000000000000000
[12099.504693] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[12099.504724] CR2: 000000000b6635e9 CR3: 000000045e2bc000 CR4: 
00000000000006f0
[12099.504757] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[12099.504791] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[12099.504825] Process kworker/0:2 (pid: 1742, threadinfo 
ffkvm_set_irqff88045e012000, task ffff88045ffb0d60)
[12099.504874] Stack:
[12099.504897]  00000000000119c0 00000000000119c0 00000000000119c0 
ffff88045ffb0d60
[12099.504953]  ffff88045ffb1010 ffff88045e013fd8 ffff88045ffb1018 
ffff88045e012010
[12099.505009]  00000000000119c0 ffff88045e013fd8 00000000000119c0 
00000000000119c0
[12099.505065] Call Trace:
[12099.505099]  [<ffffffff813818ce>] ? common_interrupt+0xe/0x13
[12099.505145]  [<ffffffffa03efaa0>] ? irqfd_inject+0x0/0x50 [kvm]
[12099.505145]  [<ffffffffa03efaca>] irqfd_inject+0x2a/0x50 [kvm]
[12099.505145]  [<ffffffff8106b7bb>] process_one_work+0x11b/0x450
[12099.505145]  [<ffffffff8106bf37>] worker_thread+0x157/0x410
[12099.505145]  [<ffffffff8103a569>] ? __wake_up_common+0x59/0x90
[12099.505145]  [<ffffffff8106bde0>] ? worker_thread+0x0/0x410
[12099.505145]  [<ffffffff8106f996>] kthread+0x96/0xa0
[12099.505145]  [<ffffffff81003c64>] kernel_thread_helper+0x4/0x10
[12099.505145]  [<ffffffff8106f900>] ? kthread+0x0/0xa0
[12099.505145]  [<ffffffff81003c60>] ? kernel_thread_helper+0x0/0x10
[12099.505145] Code: 55 49 89 fd 41 54 53 89 d3 48 81 ec a8 00 00 00 8b 
15 a6 75 03 00 89 b5 3c ff ff ff 85 d2 0f 85 d5 00 00 00 49 8b 85 58 24 
00 00 <3b> 98 28 01 00 00 73 61 89 db 48 8b 84 d8 30 01 00 00 48 85 c0
[12099.505145] RIP  [<ffffffffa03ee877>] kvm_set_irq+0x37/0x140 [kvm]
[12099.505145]  RSP <ffff88045e013d00>
[12099.505145] CR2: 000000000b6635e9


markup_oops result:

root@ayrshire:~# cat bug.txt | perl markup_oops.pl -m 
/lib/modules/2.6.37.2-dsiun-110105+/kernel/arch/x86/kvm/kvm.ko 
/boot/vmlinuz-2.6.37.2-dsiun-110105+
vmaoffset = 18446744072103034880 ffffffffa03ee841:	48 89 e5 
   	mov    %rsp,%rbp
  ffffffffa03ee844:	41 57                	push   %r15
  ffffffffa03ee846:	41 89 cf             	mov    %ecx,%r15d  |  %r15 => 
1  %ecx = 1
  ffffffffa03ee849:	41 56                	push   %r14        |  %r14 => 
ffffffffa03efaa0
  ffffffffa03ee84b:	41 55                	push   %r13
  ffffffffa03ee84d:	49 89 fd             	mov    %rdi,%r13   |  %edi = 
ffff880419b600c0  %r13 => ffff880419b600c0
  ffffffffa03ee850:	41 54                	push   %r12        |  %r12 => 
ffff880419b600c0
  ffffffffa03ee852:	53                   	push   %rbx
  ffffffffa03ee853:	89 d3                	mov    %edx,%ebx   |  %ebx => 18
  ffffffffa03ee855:	48 81 ec a8 00 00 00 	sub    $0xa8,%rsp
  ffffffffa03ee85c:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 
ffffffffa03ee862 <kvm_set_irq+0x22>
  ffffffffa03ee862:	89 b5 3c ff ff ff    	mov    %esi,-0xc4(%rbp) | 
%esi = 0
  ffffffffa03ee868:	85 d2                	test   %edx,%edx   |  %edx => 0
  ffffffffa03ee86a:	0f 85 d5 00 00 00    	jne    ffffffffa03ee945 
<kvm_set_irq+0x105>
  ffffffffa03ee870:	49 8b 85 58 24 00 00 	mov    0x2458(%r13),%rax | 
%eax => b6634c1  %r13 = ffff880419b600c0
*ffffffffa03ee877:	3b 98 28 01 00 00    	cmp    0x128(%rax),%ebx |  %eax 
= b6634c1  %ebx = 18 <--- faulting instruction
  ffffffffa03ee87d:	73 61                	jae    ffffffffa03ee8e0 
<kvm_set_irq+0xa0>
  ffffffffa03ee87f:	89 db                	mov    %ebx,%ebx
  ffffffffa03ee881:	48 8b 84 d8 30 01 00 	mov    0x130(%rax,%rbx,8),%rax
  ffffffffa03ee888:	00
  ffffffffa03ee889:	48 85 c0             	test   %rax,%rax
  ffffffffa03ee88c:	74 52                	je     ffffffffa03ee8e0 
<kvm_set_irq+0xa0>
  ffffffffa03ee88e:	48 8d 95 40 ff ff ff 	lea    -0xc0(%rbp),%rdx
  ffffffffa03ee895:	31 db                	xor    %ebx,%ebx
  ffffffffa03ee897:	48 8b 08             	mov    (%rax),%rcx
  ffffffffa03ee89a:	83 c3 01             	add    $0x1,%ebx
  ffffffffa03ee89d:	0f 18 09             	prefetcht0 (%rcx)
  ffffffffa03ee8a0:	48 8b 48 e0          	mov    -0x20(%rax),%rcx
  ffffffffa03ee8a4:	48 89 0a             	mov    %rcx,(%rdx)
  ffffffffa03ee8a7:	48 8b 48 e8          	mov    -0x18(%rax),%rcx
  ffffffffa03ee8ab:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  ffffffffa03ee8af:	48 8b 48 f0          	mov    -0x10(%rax),%rcx
  ffffffffa03ee8b3:	48 89 4a 10          	mov    %rcx,0x10(%rdx)
  ffffffffa03ee8b7:	48 8b 48 f8          	mov    -0x8(%rax),%rcx
  ffffffffa03ee8bb:	48 89 4a 18          	mov    %rcx,0x18(%rdx)
  ffffffffa03ee8bf:	48 8b 08             	mov    (%rax),%rcx

The relvant part of objdump for kvm_set_irq:
root@ayrshire:~# objdump -ldS 
/lib/modules/2.6.37.2-dsiun-110105+/kernel/arch/x86/kvm/kvm.ko > dump.txt

0000000000006840 <kvm_set_irq>:
kvm_set_irq():
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:148
     6840:       55                      push   %rbp
     6841:       48 89 e5                mov    %rsp,%rbp
     6844:       41 57                   push   %r15
     6846:       41 89 cf                mov    %ecx,%r15d
     6849:       41 56                   push   %r14
     684b:       41 55                   push   %r13
     684d:       49 89 fd                mov    %rdi,%r13
     6850:       41 54                   push   %r12
     6852:       53                      push   %rbx
     6853:       89 d3                   mov    %edx,%ebx
     6855:       48 81 ec a8 00 00 00    sub    $0xa8,%rsp
trace_kvm_set_irq():
/usr/src/GIT/linux-2.6-stable/include/trace/events/kvm.h:10
     685c:       8b 15 00 00 00 00       mov    0x0(%rip),%edx        # 
6862 <kvm_set_irq+0x22>
kvm_set_irq():
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:148
     6862:       89 b5 3c ff ff ff       mov    %esi,-0xc4(%rbp)
trace_kvm_set_irq():
/usr/src/GIT/linux-2.6-stable/include/trace/events/kvm.h:10
     6868:       85 d2                   test   %edx,%edx
     686a:       0f 85 d5 00 00 00       jne    6945 <kvm_set_irq+0x105>
kvm_set_irq():
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:161
     6870:       49 8b 85 58 24 00 00    mov    0x2458(%r13),%rax
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:162
     6877:       3b 98 28 01 00 00       cmp    0x128(%rax),%ebx
     687d:       73 61                   jae    68e0 <kvm_set_irq+0xa0>
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:163
     687f:       89 db                   mov    %ebx,%ebx
     6881:       48 8b 84 d8 30 01 00    mov    0x130(%rax,%rbx,8),%rax
     6888:       00
     6889:       48 85 c0                test   %rax,%rax
     688c:       74 52                   je     68e0 <kvm_set_irq+0xa0>
     688e:       48 8d 95 40 ff ff ff    lea    -0xc0(%rbp),%rdx
     6895:       31 db                   xor    %ebx,%ebx
     6897:       48 8b 08                mov    (%rax),%rcx
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:164
     689a:       83 c3 01                add    $0x1,%ebx
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:163
     689d:       0f 18 09                prefetcht0 (%rcx)
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:164
     68a0:       48 8b 48 e0             mov    -0x20(%rax),%rcx
     68a4:       48 89 0a                mov    %rcx,(%rdx)
     68a7:       48 8b 48 e8             mov    -0x18(%rax),%rcx
     68ab:       48 89 4a 08             mov    %rcx,0x8(%rdx)
     68af:       48 8b 48 f0             mov    -0x10(%rax),%rcx
     68b3:       48 89 4a 10             mov    %rcx,0x10(%rdx)
     68b7:       48 8b 48 f8             mov    -0x8(%rax),%rcx
     68bb:       48 89 4a 18             mov    %rcx,0x18(%rdx)
     68bf:       48 8b 08                mov    (%rax),%rcx
     68c2:       48 89 4a 20             mov    %rcx,0x20(%rdx)
     68c6:       48 8b 48 08             mov    0x8(%rax),%rcx
     68ca:       48 89 4a 28             mov    %rcx,0x28(%rdx)
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:163
     68ce:       48 8b 00                mov    (%rax),%rax
     68d1:       48 83 c2 30             add    $0x30,%rdx
     68d5:       48 85 c0                test   %rax,%rax
     68d8:       75 bd                   jne    6897 <kvm_set_irq+0x57>
     68da:       eb 06                   jmp    68e2 <kvm_set_irq+0xa2>
     68dc:       0f 1f 40 00             nopl   0x0(%rax)
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:162
     68e0:       31 db                   xor    %ebx,%ebx
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:169
     68e2:       4c 8d b5 40 ff ff ff    lea    -0xc0(%rbp),%r14
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:162
     68e9:       41 bc ff ff ff ff       mov    $0xffffffff,%r12d
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:167
     68ef:       85 db                   test   %ebx,%ebx
     68f1:       74 3d                   je     6930 <kvm_set_irq+0xf0>
     68f3:       83 eb 01                sub    $0x1,%ebx
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:169
     68f6:       44 89 f9                mov    %r15d,%ecx
     68f9:       8b 95 3c ff ff ff       mov    -0xc4(%rbp),%edx
     68ff:       48 63 c3                movslq %ebx,%rax
     6902:       4c 89 ee                mov    %r13,%rsi
     6905:       48 8d 04 40             lea    (%rax,%rax,2),%rax
     6909:       48 c1 e0 04             shl    $0x4,%rax
     690d:       49 8d 3c 06             lea    (%r14,%rax,1),%rdi
     6911:       ff 94 05 48 ff ff ff    callq  *-0xb8(%rbp,%rax,1)
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:170
     6918:       85 c0                   test   %eax,%eax
     691a:       78 d3                   js     68ef <kvm_set_irq+0xaf>
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:173
     691c:       45 85 e4                test   %r12d,%r12d
     691f:       ba 00 00 00 00          mov    $0x0,%edx
     6924:       44 0f 48 e2             cmovs  %edx,%r12d
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:167
     6928:       85 db                   test   %ebx,%ebx
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:173
     692a:       46 8d 24 20             lea    (%rax,%r12,1),%r12d
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:167
     692e:       75 c3                   jne    68f3 <kvm_set_irq+0xb3>
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:177
     6930:       48 81 c4 a8 00 00 00    add    $0xa8,%rsp
     6937:       44 89 e0                mov    %r12d,%eax
     693a:       5b                      pop    %rbx
     693b:       41 5c                   pop    %r12
     693d:       41 5d                   pop    %r13
     693f:       41 5e                   pop    %r14
     6941:       41 5f                   pop    %r15
     6943:       c9                      leaveq
     6944:       c3                      retq
trace_kvm_set_irq():
/usr/src/GIT/linux-2.6-stable/include/trace/events/kvm.h:10
     6945:       4c 8b 25 00 00 00 00    mov    0x0(%rip),%r12        # 
694c <kvm_set_irq+0x10c>
     694c:       4d 85 e4                test   %r12,%r12
     694f:       0f 84 1b ff ff ff       je     6870 <kvm_set_irq+0x30>
     6955:       49 8b 04 24             mov    (%r12),%rax
     6959:       49 8b 7c 24 08          mov    0x8(%r12),%rdi
     695e:       49 83 c4 10             add    $0x10,%r12
     6962:       8b 8d 3c ff ff ff       mov    -0xc4(%rbp),%ecx
     6968:       44 89 fa                mov    %r15d,%edx
     696b:       89 de                   mov    %ebx,%esi
     696d:       ff d0                   callq  *%rax
     696f:       49 8b 04 24             mov    (%r12),%rax
     6973:       48 85 c0                test   %rax,%rax
     6976:       75 e1                   jne    6959 <kvm_set_irq+0x119>
     6978:       e9 f3 fe ff ff          jmpq   6870 <kvm_set_irq+0x30>
kvm_set_irq():
     697d:       0f 1f 00                nopl   (%rax)

So, if i've read correctly, the offset is 0x6877 ?

root@ayrshire:~# addr2line -e 
/lib/modules/2.6.37.2-dsiun-110105+/kernel/arch/x86/kvm/kvm.ko 0x6877
/usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:162


Is it the correct way to analyse this?

Regards.

--------------050607060509010903000509
Content-Type: text/x-vcard; charset=utf-8;
 name="jean-philippe_menil.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="jean-philippe_menil.vcf"

begin:vcard
fn:Jean-Philippe Menil
n:Menil;Jean-Philippe
org;quoted-printable:Universit=C3=A9 de Nantes;IRTS - DSI
adr;quoted-printable:;;2 rue de la Houssini=C3=A8re;Nantes;Loire-Atlantique;44382;France
email;internet:jean-philippe.menil@univ-nantes.fr
title;quoted-printable:Administrateur R=C3=A9seau
url:http://www.cri.univ-nantes.fr
version:2.1
end:vcard


--------------050607060509010903000509--

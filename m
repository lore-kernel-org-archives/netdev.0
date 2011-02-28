From: Jean-Philippe Menil <jean-philippe.menil@univ-nantes.fr>
Subject: Re: Bug inkvm_set_irq
Date: Mon, 28 Feb 2011 11:40:43 +0100
Message-ID: <4D6B7BAB.9070907@univ-nantes.fr>
References: <4D67714A.2050100@univ-nantes.fr> <20110227170031.GC17973@redhat.com> <4D6B634E.9090801@univ-nantes.fr> <20110228101139.GD28006@redhat.com>
Reply-To: jean-philippe.menil@univ-nantes.fr
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-tls1.univ-nantes.fr ([193.52.101.145]:36660 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155Ab1B1Kkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 05:40:45 -0500
In-Reply-To: <20110228101139.GD28006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/02/2011 11:11, Michael S. Tsirkin a =E9crit :
> On Mon, Feb 28, 2011 at 09:56:46AM +0100, Jean-Philippe Menil wrote:
>> Le 27/02/2011 18:00, Michael S. Tsirkin a =E9crit :
>>> On Fri, Feb 25, 2011 at 10:07:22AM +0100, Jean-Philippe Menil wrote=
:
>>>> Hi,
>>>>
>>>> Each time i try tou use vhost_net, i'm facing a kernel bug.
>>>> I do a "modprobe vhost_net", and start guest whith vhost=3Don.
>>>>
>>>> Following is a trace with a kernel 2.6.37, but  i had the same
>>>> problem with 2.6.36 (cf https://lkml.org/lkml/2010/11/30/29).
>>> 2.6.36 had a theorectical race that could explain this,
>>> but it should be ok in 2.6.37.
>>>
>>>> The bug only occurs whith vhost_net charged, so i don't know if th=
is
>>>> is a bug in kvm module code or in the vhost_net code.
>>> It could be a bug in eventfd which is the interface
>>> used by both kvm and vhost_net.
>>> Just for fun, you can try 3.6.38 - eventfd code has been changed
>>> a lot in 2.6.38 and if it does not trigger there
>>> it's a hint that irqfd is the reason.
>>>
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.243100] BUG: unable to handle kernel paging request at
>>>> 0000000000002458
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.243250] IP: [<ffffffffa041aa8a>] kvm_set_irq+0x2a/0x130 [kvm]
>>> Could you run markup_oops/ ksymoops on this please?
>>> As far as I can see kvm_set_irq can only get a wrong
>>> kvm pointer. Unless there's some general memory corruption,
>>> I'd guess
>>>
>>> You can also try comparing the irqfd->kvm pointer in
>>> kvm_irqfd_assign irqfd_wakeup and kvm_set_irq in
>>> virt/kvm/eventfd.c.
>>>
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.243378] PGD 45d363067 PUD 45e77a067 PMD 0
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.243556] Oops: 0000 [#1] SMP
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.243692] last sysfs file:
>>>> /sys/devices/pci0000:00/0000:00:0d.0/0000:05:00.0/0000:06:00.0/irq
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [  685.2437=
77] CPU 0
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.243820] Modules linked in: vhost_net macvtap macvlan tun
>>>> powernow_k8 mperf cpufreq_userspace cpufreq_stats cpufreq_powersav=
e
>>>> cpufreq_ondemand fre
>>>> q_table cpufreq_conservative fuse xt_physdev ip6t_LOG
>>>> ip6table_filter ip6_tables ipt_LOG xt_multiport xt_limit xt_tcpudp
>>>> xt_state iptable_filter ip_tables x_tables nf_conntrack_tftp
>>>> nf_conntrack_ftp nf_connt
>>>> rack_ipv4 nf_defrag_ipv4 8021q bridge stp ext2 mbcache
>>>> dm_round_robin dm_multipath nf_conntrack_ipv6 nf_conntrack
>>>> nf_defrag_ipv6 kvm_amd kvm ipv6 snd_pcm snd_timer snd soundcore
>>>> snd_page_alloc tpm_tis tpm ps
>>>> mouse dcdbas tpm_bios processor i2c_nforce2 shpchp pcspkr ghes
>>>> serio_raw joydev evdev pci_hotplug i2c_core hed button thermal_sys
>>>> xfs exportfs dm_mod sg sr_mod cdrom usbhid hid usb_storage ses
>>>> sd_mod enclosu
>>>> re megaraid_sas ohci_hcd lpfc scsi_transport_fc scsi_tgt bnx2
>>>> scsi_mod ehci_hcd [last unloaded: scsi_wait_scan]
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [  685.2461=
23]
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] Pid: 10, comm: kworker/0:1 Not tainted
>>>> 2.6.37-dsiun-110105 #17 0K543T/PowerEdge M605
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] RIP: 0010:[<ffffffffa041aa8a>]  [<ffffffffa041aa8a>]
>>>> kvm_set_irq+0x2a/0x130 [kvm]
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] RSP: 0018:ffff88045fc89d30  EFLAGS: 00010246
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] RAX: 0000000000000000 RBX: 000000000000001a RCX:
>>>> 0000000000000001
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
>>>> 0000000000000000
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] RBP: 0000000000000000 R08: 0000000000000001 R09:
>>>> ffff880856a91e48
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] R10: 0000000000000000 R11: 00000000ffffffff R12:
>>>> 0000000000000000
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] R13: 0000000000000001 R14: 0000000000000000 R15:
>>>> 0000000000000000
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] FS:  00007f617986c710(0000) GS:ffff88007f800000(0000)
>>>> knlGS:0000000000000000
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] CR2: 0000000000002458 CR3: 000000045d197000 CR4:
>>>> 00000000000006f0
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>>>> 0000000000000000
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>>>> 0000000000000400
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] Process kworker/0:1 (pid: 10, threadinfo
>>>> ffff88045fc88000, task ffff88085fc53c30)
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [  685.2461=
23] Stack:
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  ffff88045fc89fd8 00000000000119c0 ffff88045fc88010
>>>> ffff88085fc53ee8
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  ffff88045fc89fd8 ffff88085fc53ee0 ffff88085fc53c30
>>>> 00000000000119c0
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  00000000000119c0 ffffffff8137f7ce ffff88007f80df40
>>>> 00000000ffffffff
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] Call Trace:
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  [<ffffffff8137f7ce>] ? common_interrupt+0xe/0x13
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  [<ffffffffa041bc30>] ? irqfd_inject+0x0/0x50 [kvm]
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  [<ffffffffa041bc57>] ? irqfd_inject+0x27/0x50 [kvm]
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  [<ffffffffa041bc30>] ? irqfd_inject+0x0/0x50 [kvm]
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  [<ffffffff8106b6f2>] ? process_one_work+0x112/0x460
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  [<ffffffff8106be25>] ? worker_thread+0x145/0x410
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  [<ffffffff8103a3d0>] ? __wake_up_common+0x50/0x80
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  [<ffffffff8106bce0>] ? worker_thread+0x0/0x410
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  [<ffffffff8106bce0>] ? worker_thread+0x0/0x410
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  [<ffffffff8106f786>] ? kthread+0x96/0xa0
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  [<ffffffff81003ce4>] ? kernel_thread_helper+0x4/0x10
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  [<ffffffff8106f6f0>] ? kthread+0x0/0xa0
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  [<ffffffff81003ce0>] ? kernel_thread_helper+0x0/0x10
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] Code: ff 41 57 41 89 f7 41 56 41 55 41 89 cd 41 54 49 =
89
>>>> fc 55 53 89 d3 48 81 ec 98 00 00 00 8b 15 c6 79 03 00 85 d2 0f 85 =
c4
>>>> 00 00 00<4
>>>> 9>   8b 84 24 58 24 00 00 3b 98 28 01 00 00 73 5e 89 db 48 8b 84
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] RIP  [<ffffffffa041aa8a>] kvm_set_irq+0x2a/0x130 [kvm]
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123]  RSP<ffff88045fc89d30>
>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>> 685.246123] CR2: 0000000000002458
>>>>
>>>>
>>>> If someone can help me, on how to solve this.
>>>>
>>>> Regards.
>>>> _______________________________________________
>>>> Virtualization mailing list
>>>> Virtualization@lists.linux-foundation.org
>>>> https://lists.linux-foundation.org/mailman/listinfo/virtualization
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Hi,
>>
>> thanks for your response.
>>
>> This is what markup_oops.pl return me:
>> "No matching code found"
> Well, let's try to understand what's there.
>
> Do objdumop -ldS kvm.ko
> look for<kvm_set_irq>
>
> and paste the content from start of that function
> to offset 0x2a and a bit beyond.
>
> You can also upload your kvm.ko somewhere, I'll try to take a look.
>
>
>> So this is not a vhost_net bug, or my oops is incomplete and
>> markup_oops can't find the good vma offset.
>>
>> I will try to compare the pointers you indicate me, even it could be
>> a little difficult for me.
> Hmm you know how to add printk to code and rebuild, right?
>
>> Maybe i will try a 2.6.38, will wait a response from the kvm team.
>>
>> Regards.
>>
>> --=20
>> Jean-Philippe Menil - P=F4le r=E9seau Service IRTS
>> DSI Universit=E9 de Nantes
>> jean-philippe.menil@univ-nantes.fr
>> Tel : 02.53.48.49.27 - Fax : 02.53.48.49.09
So, here is the result for the objdump against the kvm.ko (the=20
kvm_set_irq part) :

0000000000006a60 <kvm_set_irq>:
kvm_set_irq():
     6a60:       41 57                   push   %r15
     6a62:       41 89 f7                mov    %esi,%r15d
     6a65:       41 56                   push   %r14
     6a67:       41 55                   push   %r13
     6a69:       41 89 cd                mov    %ecx,%r13d
     6a6c:       41 54                   push   %r12
     6a6e:       49 89 fc                mov    %rdi,%r12
     6a71:       55                      push   %rbp
     6a72:       53                      push   %rbx
     6a73:       89 d3                   mov    %edx,%ebx
     6a75:       48 81 ec 98 00 00 00    sub    $0x98,%rsp
     6a7c:       8b 15 00 00 00 00       mov    0x0(%rip),%edx        #=
=20
6a82 <kvm_set_irq+0x22>
     6a82:       85 d2                   test   %edx,%edx
     6a84:       0f 85 c4 00 00 00       jne    6b4e <kvm_set_irq+0xee>
     6a8a:       49 8b 84 24 58 24 00    mov    0x2458(%r12),%rax
     6a91:       00
     6a92:       3b 98 28 01 00 00       cmp    0x128(%rax),%ebx
     6a98:       73 5e                   jae    6af8 <kvm_set_irq+0x98>
     6a9a:       89 db                   mov    %ebx,%ebx
     6a9c:       48 8b 84 d8 30 01 00    mov    0x130(%rax,%rbx,8),%rax
     6aa3:       00
     6aa4:       48 85 c0                test   %rax,%rax
     6aa7:       74 4f                   je     6af8 <kvm_set_irq+0x98>
     6aa9:       48 89 e2                mov    %rsp,%rdx
     6aac:       31 db                   xor    %ebx,%ebx
     6aae:       48 8b 08                mov    (%rax),%rcx
     6ab1:       83 c3 01                add    $0x1,%ebx
     6ab4:       0f 18 09                prefetcht0 (%rcx)
     6ab7:       48 8b 48 e0             mov    -0x20(%rax),%rcx
     6abb:       48 89 0a                mov    %rcx,(%rdx)
     6abe:       48 8b 48 e8             mov    -0x18(%rax),%rcx
     6ac2:       48 89 4a 08             mov    %rcx,0x8(%rdx)
     6ac6:       48 8b 48 f0             mov    -0x10(%rax),%rcx
     6aca:       48 89 4a 10             mov    %rcx,0x10(%rdx)
     6ace:       48 8b 48 f8             mov    -0x8(%rax),%rcx
     6ad2:       48 89 4a 18             mov    %rcx,0x18(%rdx)
     6ad6:       48 8b 08                mov    (%rax),%rcx
     6ad9:       48 89 4a 20             mov    %rcx,0x20(%rdx)
     6add:       48 8b 48 08             mov    0x8(%rax),%rcx
     6ae1:       48 89 4a 28             mov    %rcx,0x28(%rdx)
     6ae5:       48 8b 00                mov    (%rax),%rax
     6ae8:       48 83 c2 30             add    $0x30,%rdx
     6aec:       48 85 c0                test   %rax,%rax
     6aef:       75 bd                   jne    6aae <kvm_set_irq+0x4e>
     6af1:       eb 07                   jmp    6afa <kvm_set_irq+0x9a>
     6af3:       0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
     6af8:       31 db                   xor    %ebx,%ebx
     6afa:       bd ff ff ff ff          mov    $0xffffffff,%ebp
     6aff:       49 89 e6                mov    %rsp,%r14
     6b02:       85 db                   test   %ebx,%ebx
     6b04:       74 34                   je     6b3a <kvm_set_irq+0xda>
     6b06:       83 eb 01                sub    $0x1,%ebx
     6b09:       44 89 e9                mov    %r13d,%ecx
     6b0c:       44 89 fa                mov    %r15d,%edx
     6b0f:       48 63 c3                movslq %ebx,%rax
     6b12:       4c 89 e6                mov    %r12,%rsi
     6b15:       48 8d 04 40             lea    (%rax,%rax,2),%rax
     6b19:       48 c1 e0 04             shl    $0x4,%rax
     6b1d:       49 8d 3c 06             lea    (%r14,%rax,1),%rdi
     6b21:       ff 54 04 08             callq  *0x8(%rsp,%rax,1)
     6b25:       85 c0                   test   %eax,%eax
     6b27:       78 d9                   js     6b02 <kvm_set_irq+0xa2>
     6b29:       85 ed                   test   %ebp,%ebp
     6b2b:       ba 00 00 00 00          mov    $0x0,%edx
     6b30:       0f 48 ea                cmovs  %edx,%ebp
     6b33:       85 db                   test   %ebx,%ebx
     6b35:       8d 2c 28                lea    (%rax,%rbp,1),%ebp
     6b38:       75 cc                   jne    6b06 <kvm_set_irq+0xa6>
     6b3a:       48 81 c4 98 00 00 00    add    $0x98,%rsp
     6b41:       89 e8                   mov    %ebp,%eax
     6b43:       5b                      pop    %rbx
     6b44:       5d                      pop    %rbp
     6b45:       41 5c                   pop    %r12
     6b47:       41 5d                   pop    %r13
     6b49:       41 5e                   pop    %r14
     6b4b:       41 5f                   pop    %r15
     6b4d:       c3                      retq
     6b4e:       48 8b 2d 00 00 00 00    mov    0x0(%rip),%rbp        #=
=20
6b55 <kvm_set_irq+0xf5>
     6b55:       48 85 ed                test   %rbp,%rbp
     6b58:       0f 84 2c ff ff ff       je     6a8a <kvm_set_irq+0x2a>
     6b5e:       48 8b 45 00             mov    0x0(%rbp),%rax
     6b62:       48 8b 7d 08             mov    0x8(%rbp),%rdi
     6b66:       48 83 c5 10             add    $0x10,%rbp
     6b6a:       44 89 f9                mov    %r15d,%ecx
     6b6d:       44 89 ea                mov    %r13d,%edx
     6b70:       89 de                   mov    %ebx,%esi
     6b72:       ff d0                   callq  *%rax
     6b74:       48 8b 45 00             mov    0x0(%rbp),%rax
     6b78:       48 85 c0                test   %rax,%rax
     6b7b:       75 e5                   jne    6b62 <kvm_set_irq+0x102=
>
     6b7d:       e9 08 ff ff ff          jmpq   6a8a <kvm_set_irq+0x2a>
     6b82:       66 66 66 66 66 2e 0f    nopw   %cs:0x0(%rax,%rax,1)
     6b89:       1f 84 00 00 00 00 00

I admit that this analysis is too complicated for me.
I, effectively, can rebuild a kernel with more printk, and program a re=
boot.

The kvm.ko is available through the following address:
http://filex.univ-nantes.fr/get?k=3Dk1jKhQghdcHLz12Z50H

Regards.

--=20
Jean-Philippe Menil - P=F4le r=E9seau Service IRTS
DSI Universit=E9 de Nantes
jean-philippe.menil@univ-nantes.fr
Tel : 02.53.48.49.27 - Fax : 02.53.48.49.09


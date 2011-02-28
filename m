From: Jean-Philippe Menil <jean-philippe.menil@univ-nantes.fr>
Subject: Re: Bug inkvm_set_irq
Date: Mon, 28 Feb 2011 16:13:12 +0100
Message-ID: <4D6BBB88.5060709@univ-nantes.fr>
References: <4D67714A.2050100@univ-nantes.fr> <20110227170031.GC17973@redhat.com> <4D6B634E.9090801@univ-nantes.fr> <20110228101139.GD28006@redhat.com> <4D6B7BAB.9070907@univ-nantes.fr> <20110228113939.GH28006@redhat.com>
Reply-To: jean-philippe.menil@univ-nantes.fr
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-tls2.univ-nantes.fr ([193.52.101.146]:60973 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754245Ab1B1PNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 10:13:13 -0500
In-Reply-To: <20110228113939.GH28006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/02/2011 12:39, Michael S. Tsirkin a =E9crit :
> On Mon, Feb 28, 2011 at 11:40:43AM +0100, Jean-Philippe Menil wrote:
>> Le 28/02/2011 11:11, Michael S. Tsirkin a =E9crit :
>>> On Mon, Feb 28, 2011 at 09:56:46AM +0100, Jean-Philippe Menil wrote=
:
>>>> Le 27/02/2011 18:00, Michael S. Tsirkin a =E9crit :
>>>>> On Fri, Feb 25, 2011 at 10:07:22AM +0100, Jean-Philippe Menil wro=
te:
>>>>>> Hi,
>>>>>>
>>>>>> Each time i try tou use vhost_net, i'm facing a kernel bug.
>>>>>> I do a "modprobe vhost_net", and start guest whith vhost=3Don.
>>>>>>
>>>>>> Following is a trace with a kernel 2.6.37, but  i had the same
>>>>>> problem with 2.6.36 (cf https://lkml.org/lkml/2010/11/30/29).
>>>>> 2.6.36 had a theorectical race that could explain this,
>>>>> but it should be ok in 2.6.37.
>>>>>
>>>>>> The bug only occurs whith vhost_net charged, so i don't know if =
this
>>>>>> is a bug in kvm module code or in the vhost_net code.
>>>>> It could be a bug in eventfd which is the interface
>>>>> used by both kvm and vhost_net.
>>>>> Just for fun, you can try 3.6.38 - eventfd code has been changed
>>>>> a lot in 2.6.38 and if it does not trigger there
>>>>> it's a hint that irqfd is the reason.
>>>>>
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.243100] BUG: unable to handle kernel paging request at
>>>>>> 0000000000002458
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.243250] IP: [<ffffffffa041aa8a>] kvm_set_irq+0x2a/0x130 [kvm=
]
>>>>> Could you run markup_oops/ ksymoops on this please?
>>>>> As far as I can see kvm_set_irq can only get a wrong
>>>>> kvm pointer. Unless there's some general memory corruption,
>>>>> I'd guess
>>>>>
>>>>> You can also try comparing the irqfd->kvm pointer in
>>>>> kvm_irqfd_assign irqfd_wakeup and kvm_set_irq in
>>>>> virt/kvm/eventfd.c.
>>>>>
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.243378] PGD 45d363067 PUD 45e77a067 PMD 0
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.243556] Oops: 0000 [#1] SMP
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.243692] last sysfs file:
>>>>>> /sys/devices/pci0000:00/0000:00:0d.0/0000:05:00.0/0000:06:00.0/i=
rq
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [  685.24=
3777] CPU 0
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.243820] Modules linked in: vhost_net macvtap macvlan tun
>>>>>> powernow_k8 mperf cpufreq_userspace cpufreq_stats cpufreq_powers=
ave
>>>>>> cpufreq_ondemand fre
>>>>>> q_table cpufreq_conservative fuse xt_physdev ip6t_LOG
>>>>>> ip6table_filter ip6_tables ipt_LOG xt_multiport xt_limit xt_tcpu=
dp
>>>>>> xt_state iptable_filter ip_tables x_tables nf_conntrack_tftp
>>>>>> nf_conntrack_ftp nf_connt
>>>>>> rack_ipv4 nf_defrag_ipv4 8021q bridge stp ext2 mbcache
>>>>>> dm_round_robin dm_multipath nf_conntrack_ipv6 nf_conntrack
>>>>>> nf_defrag_ipv6 kvm_amd kvm ipv6 snd_pcm snd_timer snd soundcore
>>>>>> snd_page_alloc tpm_tis tpm ps
>>>>>> mouse dcdbas tpm_bios processor i2c_nforce2 shpchp pcspkr ghes
>>>>>> serio_raw joydev evdev pci_hotplug i2c_core hed button thermal_s=
ys
>>>>>> xfs exportfs dm_mod sg sr_mod cdrom usbhid hid usb_storage ses
>>>>>> sd_mod enclosu
>>>>>> re megaraid_sas ohci_hcd lpfc scsi_transport_fc scsi_tgt bnx2
>>>>>> scsi_mod ehci_hcd [last unloaded: scsi_wait_scan]
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [  685.24=
6123]
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] Pid: 10, comm: kworker/0:1 Not tainted
>>>>>> 2.6.37-dsiun-110105 #17 0K543T/PowerEdge M605
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] RIP: 0010:[<ffffffffa041aa8a>]  [<ffffffffa041aa8a>]
>>>>>> kvm_set_irq+0x2a/0x130 [kvm]
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] RSP: 0018:ffff88045fc89d30  EFLAGS: 00010246
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] RAX: 0000000000000000 RBX: 000000000000001a RCX:
>>>>>> 0000000000000001
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
>>>>>> 0000000000000000
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] RBP: 0000000000000000 R08: 0000000000000001 R09:
>>>>>> ffff880856a91e48
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] R10: 0000000000000000 R11: 00000000ffffffff R12:
>>>>>> 0000000000000000
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] R13: 0000000000000001 R14: 0000000000000000 R15:
>>>>>> 0000000000000000
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] FS:  00007f617986c710(0000) GS:ffff88007f800000(0000=
)
>>>>>> knlGS:0000000000000000
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] CR2: 0000000000002458 CR3: 000000045d197000 CR4:
>>>>>> 00000000000006f0
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>>>>>> 0000000000000000
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>>>>>> 0000000000000400
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] Process kworker/0:1 (pid: 10, threadinfo
>>>>>> ffff88045fc88000, task ffff88085fc53c30)
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [  685.24=
6123] Stack:
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  ffff88045fc89fd8 00000000000119c0 ffff88045fc88010
>>>>>> ffff88085fc53ee8
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  ffff88045fc89fd8 ffff88085fc53ee0 ffff88085fc53c30
>>>>>> 00000000000119c0
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  00000000000119c0 ffffffff8137f7ce ffff88007f80df40
>>>>>> 00000000ffffffff
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] Call Trace:
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  [<ffffffff8137f7ce>] ? common_interrupt+0xe/0x13
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  [<ffffffffa041bc30>] ? irqfd_inject+0x0/0x50 [kvm]
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  [<ffffffffa041bc57>] ? irqfd_inject+0x27/0x50 [kvm]
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  [<ffffffffa041bc30>] ? irqfd_inject+0x0/0x50 [kvm]
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  [<ffffffff8106b6f2>] ? process_one_work+0x112/0x460
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  [<ffffffff8106be25>] ? worker_thread+0x145/0x410
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  [<ffffffff8103a3d0>] ? __wake_up_common+0x50/0x80
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  [<ffffffff8106bce0>] ? worker_thread+0x0/0x410
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  [<ffffffff8106bce0>] ? worker_thread+0x0/0x410
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  [<ffffffff8106f786>] ? kthread+0x96/0xa0
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  [<ffffffff81003ce4>] ? kernel_thread_helper+0x4/0x1=
0
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  [<ffffffff8106f6f0>] ? kthread+0x0/0xa0
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  [<ffffffff81003ce0>] ? kernel_thread_helper+0x0/0x1=
0
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] Code: ff 41 57 41 89 f7 41 56 41 55 41 89 cd 41 54 4=
9 89
>>>>>> fc 55 53 89 d3 48 81 ec 98 00 00 00 8b 15 c6 79 03 00 85 d2 0f 8=
5 c4
>>>>>> 00 00 00<4
>>>>>> 9>    8b 84 24 58 24 00 00 3b 98 28 01 00 00 73 5e 89 db 48 8b 8=
4
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] RIP  [<ffffffffa041aa8a>] kvm_set_irq+0x2a/0x130 [kv=
m]
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123]  RSP<ffff88045fc89d30>
>>>>>> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
>>>>>> 685.246123] CR2: 0000000000002458
>>>>>>
>>>>>>
>>>>>> If someone can help me, on how to solve this.
>>>>>>
>>>>>> Regards.
>>>>>> _______________________________________________
>>>>>> Virtualization mailing list
>>>>>> Virtualization@lists.linux-foundation.org
>>>>>> https://lists.linux-foundation.org/mailman/listinfo/virtualizati=
on
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe netdev"=
 in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.htm=
l
>>>> Hi,
>>>>
>>>> thanks for your response.
>>>>
>>>> This is what markup_oops.pl return me:
>>>> "No matching code found"
>>> Well, let's try to understand what's there.
>>>
>>> Do objdumop -ldS kvm.ko
>>> look for<kvm_set_irq>
>>>
>>> and paste the content from start of that function
>>> to offset 0x2a and a bit beyond.
>>>
>>> You can also upload your kvm.ko somewhere, I'll try to take a look.
>>>
>>>
>>>> So this is not a vhost_net bug, or my oops is incomplete and
>>>> markup_oops can't find the good vma offset.
>>>>
>>>> I will try to compare the pointers you indicate me, even it could =
be
>>>> a little difficult for me.
>>> Hmm you know how to add printk to code and rebuild, right?
>>>
>>>> Maybe i will try a 2.6.38, will wait a response from the kvm team.
>>>>
>>>> Regards.
>>>>
>>>> --=20
>>>> Jean-Philippe Menil - P=F4le r=E9seau Service IRTS
>>>> DSI Universit=E9 de Nantes
>>>> jean-philippe.menil@univ-nantes.fr
>>>> Tel : 02.53.48.49.27 - Fax : 02.53.48.49.09
>> So, here is the result for the objdump against the kvm.ko (the
>> kvm_set_irq part) :
> Can you try building with -g and adding -l and -S to objdump
> please? I'd rather make the tool do the legwork than
> do it manually.
>
>> 0000000000006a60<kvm_set_irq>:
>> kvm_set_irq():
>>      6a60:       41 57                   push   %r15
>>      6a62:       41 89 f7                mov    %esi,%r15d
>>      6a65:       41 56                   push   %r14
>>      6a67:       41 55                   push   %r13
>>      6a69:       41 89 cd                mov    %ecx,%r13d
>>      6a6c:       41 54                   push   %r12
>>      6a6e:       49 89 fc                mov    %rdi,%r12
>>      6a71:       55                      push   %rbp
>>      6a72:       53                      push   %rbx
>>      6a73:       89 d3                   mov    %edx,%ebx
>>      6a75:       48 81 ec 98 00 00 00    sub    $0x98,%rsp
>>      6a7c:       8b 15 00 00 00 00       mov    0x0(%rip),%edx
>> # 6a82<kvm_set_irq+0x22>
>>      6a82:       85 d2                   test   %edx,%edx
>>      6a84:       0f 85 c4 00 00 00       jne    6b4e<kvm_set_irq+0xe=
e>
>>      6a8a:       49 8b 84 24 58 24 00    mov    0x2458(%r12),%rax
> OK, 0x6a8a is the offset.
> After you build with -g, try
>
> addr2line kvm.ko 0x6a8a
>
> and see which line this points to.
>
>
>>      6a91:       00
>>      6a92:       3b 98 28 01 00 00       cmp    0x128(%rax),%ebx
>>      6a98:       73 5e                   jae    6af8<kvm_set_irq+0x9=
8>
>>      6a9a:       89 db                   mov    %ebx,%ebx
>>      6a9c:       48 8b 84 d8 30 01 00    mov    0x130(%rax,%rbx,8),%=
rax
>>      6aa3:       00
>>      6aa4:       48 85 c0                test   %rax,%rax
>>      6aa7:       74 4f                   je     6af8<kvm_set_irq+0x9=
8>
>>      6aa9:       48 89 e2                mov    %rsp,%rdx
>>      6aac:       31 db                   xor    %ebx,%ebx
>>      6aae:       48 8b 08                mov    (%rax),%rcx
>>      6ab1:       83 c3 01                add    $0x1,%ebx
>>      6ab4:       0f 18 09                prefetcht0 (%rcx)
>>      6ab7:       48 8b 48 e0             mov    -0x20(%rax),%rcx
>>      6abb:       48 89 0a                mov    %rcx,(%rdx)
>>      6abe:       48 8b 48 e8             mov    -0x18(%rax),%rcx
>>      6ac2:       48 89 4a 08             mov    %rcx,0x8(%rdx)
>>      6ac6:       48 8b 48 f0             mov    -0x10(%rax),%rcx
>>      6aca:       48 89 4a 10             mov    %rcx,0x10(%rdx)
>>      6ace:       48 8b 48 f8             mov    -0x8(%rax),%rcx
>>      6ad2:       48 89 4a 18             mov    %rcx,0x18(%rdx)
>>      6ad6:       48 8b 08                mov    (%rax),%rcx
>>      6ad9:       48 89 4a 20             mov    %rcx,0x20(%rdx)
>>      6add:       48 8b 48 08             mov    0x8(%rax),%rcx
>>      6ae1:       48 89 4a 28             mov    %rcx,0x28(%rdx)
>>      6ae5:       48 8b 00                mov    (%rax),%rax
>>      6ae8:       48 83 c2 30             add    $0x30,%rdx
>>      6aec:       48 85 c0                test   %rax,%rax
>>      6aef:       75 bd                   jne    6aae<kvm_set_irq+0x4=
e>
>>      6af1:       eb 07                   jmp    6afa<kvm_set_irq+0x9=
a>
>>      6af3:       0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
>>      6af8:       31 db                   xor    %ebx,%ebx
>>      6afa:       bd ff ff ff ff          mov    $0xffffffff,%ebp
>>      6aff:       49 89 e6                mov    %rsp,%r14
>>      6b02:       85 db                   test   %ebx,%ebx
>>      6b04:       74 34                   je     6b3a<kvm_set_irq+0xd=
a>
>>      6b06:       83 eb 01                sub    $0x1,%ebx
>>      6b09:       44 89 e9                mov    %r13d,%ecx
>>      6b0c:       44 89 fa                mov    %r15d,%edx
>>      6b0f:       48 63 c3                movslq %ebx,%rax
>>      6b12:       4c 89 e6                mov    %r12,%rsi
>>      6b15:       48 8d 04 40             lea    (%rax,%rax,2),%rax
>>      6b19:       48 c1 e0 04             shl    $0x4,%rax
>>      6b1d:       49 8d 3c 06             lea    (%r14,%rax,1),%rdi
>>      6b21:       ff 54 04 08             callq  *0x8(%rsp,%rax,1)
>>      6b25:       85 c0                   test   %eax,%eax
>>      6b27:       78 d9                   js     6b02<kvm_set_irq+0xa=
2>
>>      6b29:       85 ed                   test   %ebp,%ebp
>>      6b2b:       ba 00 00 00 00          mov    $0x0,%edx
>>      6b30:       0f 48 ea                cmovs  %edx,%ebp
>>      6b33:       85 db                   test   %ebx,%ebx
>>      6b35:       8d 2c 28                lea    (%rax,%rbp,1),%ebp
>>      6b38:       75 cc                   jne    6b06<kvm_set_irq+0xa=
6>
>>      6b3a:       48 81 c4 98 00 00 00    add    $0x98,%rsp
>>      6b41:       89 e8                   mov    %ebp,%eax
>>      6b43:       5b                      pop    %rbx
>>      6b44:       5d                      pop    %rbp
>>      6b45:       41 5c                   pop    %r12
>>      6b47:       41 5d                   pop    %r13
>>      6b49:       41 5e                   pop    %r14
>>      6b4b:       41 5f                   pop    %r15
>>      6b4d:       c3                      retq
>>      6b4e:       48 8b 2d 00 00 00 00    mov    0x0(%rip),%rbp
>> # 6b55<kvm_set_irq+0xf5>
>>      6b55:       48 85 ed                test   %rbp,%rbp
>>      6b58:       0f 84 2c ff ff ff       je     6a8a<kvm_set_irq+0x2=
a>
>>      6b5e:       48 8b 45 00             mov    0x0(%rbp),%rax
>>      6b62:       48 8b 7d 08             mov    0x8(%rbp),%rdi
>>      6b66:       48 83 c5 10             add    $0x10,%rbp
>>      6b6a:       44 89 f9                mov    %r15d,%ecx
>>      6b6d:       44 89 ea                mov    %r13d,%edx
>>      6b70:       89 de                   mov    %ebx,%esi
>>      6b72:       ff d0                   callq  *%rax
>>      6b74:       48 8b 45 00             mov    0x0(%rbp),%rax
>>      6b78:       48 85 c0                test   %rax,%rax
>>      6b7b:       75 e5                   jne    6b62<kvm_set_irq+0x1=
02>
>>      6b7d:       e9 08 ff ff ff          jmpq   6a8a<kvm_set_irq+0x2=
a>
>>      6b82:       66 66 66 66 66 2e 0f    nopw   %cs:0x0(%rax,%rax,1)
>>      6b89:       1f 84 00 00 00 00 00
>>
>> I admit that this analysis is too complicated for me.
>> I, effectively, can rebuild a kernel with more printk, and program a=
 reboot.
>>
>> The kvm.ko is available through the following address:
>> http://filex.univ-nantes.fr/get?k=3Dk1jKhQghdcHLz12Z50H
>>
>> Regards.
> This has no debug data. Can you rebuild with -g please?
>
> BTW if you want to rerun and get more reliable backtrace,
> tyr enabling frame pointers (do you know how to?). But this will chan=
ge code
> so backtrace will no longer be val we will need
> a new one.
>
>> --=20
>> Jean-Philippe Menil - P=F4le r=E9seau Service IRTS
>> DSI Universit=E9 de Nantes
>> jean-philippe.menil@univ-nantes.fr
>> Tel : 02.53.48.49.27 - Fax : 02.53.48.49.09
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Host reboot with his new kernel (2.6.37.2), i modprobe vhost_net, start=
=20
three kvm guests.
Host hang in a half an hour.

This time i get a general protection fault:

[ 2380.381225] general protection fault: 0000 [#1] SMP
[ 2380.381261] last sysfs file:=20
/sys/devices/system/cpu/cpu11/cache/index2/shared_cpu_map
[ 2380.381309] CPU 0
[ 2380.381316] Modules linked in: vhost_net macvtap macvlan tun veth=20
powernow_k8 mperf cpufreq_userspace cpufreq_stats cpufreq_powersave=20
cpufreq_ondemand freq_table cpufreq_conservative fuse xt_physdev=20
ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport xt_limit=20
xt_tcpudp xt_state iptable_filter ip_tables x_tables nf_conntrack_tftp=20
nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 8021q bridge stp ext2=
=20
mbcache dm_round_robin dm_multipath nf_conntrack_ipv6 nf_conntrack=20
nf_defrag_ipv6 kvm_amd kvm ipv6 snd_pcm snd_timer snd soundcore=20
snd_page_alloc shpchp i2c_nforce2 pci_hotplug psmouse tpm_tis joydev=20
pcspkr tpm evdev i2c_core dcdbas tpm_bios serio_raw processor ghes=20
button hed thermal_sys xfs exportfs dm_mod sg sr_mod cdrom usbhid hid=20
usb_storage sd_mod ses enclosure megaraid_sas lpfc ohci_hcd=20
scsi_transport_fc scsi_tgt scsi_mod bnx2 ehci_hcd [last unloaded:=20
scsi_wait_scan]
=46eb 28 15:28:09 ayrshire.u06.univ-nantes.prive kernel: Feb 28 15:28:0=
9=20
ayrshire.u06.univ-nantes.prive kernel: [ 2380.381839] Pid: 10, comm:=20
kworker/0:1 Not tainted 2.6.37.2-dsiun-110105+ #2 Dell Inc. PowerEdge=20
M605/0K543T
[ 2380.381902] RIP: 0010:[<ffffffffa037e877>]  [<ffffffffa037e877>]=20
kvm_set_irq+0x37/0x140 [kvm]
[ 2380.381973] RSP: 0018:ffff88045fc85d00  EFLAGS: 00010246
[ 2380.382002] RAX: 000200740000029c RBX: 000000000000001a RCX:=20
0000000000000001
[ 2380.382035] RDX: 0000000000000000 RSI: 0000000000000000 RDI:=20
ffff88045dbb7440
[ 2380.382068] RBP: ffff88045fc85dd0 R08: ffff88045fc84000 R09:=20
000000000000000c
[ 2380.382101] R10: 0000000000000036 R11: 00000000ffffffff R12:=20
ffff88045dbb7440
[ 2380.382134] R13: ffff88045dbb7440 R14: ffffffffa037faa0 R15:=20
0000000000000001
[ 2380.382168] FS:  00007f0c97165720(0000) GS:ffff88007f800000(0000)=20
knlGS:0000000000000000
[ 2380.382216] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2380.382246] CR2: 00007f13bcc80b40 CR3: 000000045e96c000 CR4:=20
00000000000006f0
[ 2380.382279] DR0: 0000000000000000 DR1: 0000000000000000 DR2:=20
0000000000000000
[ 2380.382312] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:=20
0000000000000400
[ 2380.382347] Process kworker/0:1 (pid: 10, threadinfo=20
ffff88045fc84000, task ffff88085fc53c30)
[ 2380.382395] Stack:
[ 2380.382416]  00000000000119c0 00000000000119c0 00000000000119c0=20
ffff88085fc53c30
[ 2380.382466]  ffff88085fc53ee0 ffff88045fc85fd8 ffff88085fc53ee8=20
ffff88045fc84010
[ 2380.382516]  00000000000119c0 ffff88045fc85fd8 00000000000119c0=20
00000000000119c0
[ 2380.382566] Call Trace:
[ 2380.382600]  [<ffffffff813818ce>] ? common_interrupt+0xe/0x13
[ 2380.382648]  [<ffffffffa037faa0>] ? irqfd_inject+0x0/0x50 [kvm]
[ 2380.382694]  [<ffffffffa037faca>] irqfd_inject+0x2a/0x50 [kvm]
[ 2380.382729]  [<ffffffff8106b7bb>] process_one_work+0x11b/0x450
[ 2380.382762]  [<ffffffff8106bf37>] worker_thread+0x157/0x410
[ 2380.382796]  [<ffffffff8103a569>] ? __wake_up_common+0x59/0x90
[ 2380.382828]  [<ffffffff8106bde0>] ? worker_thread+0x0/0x410
[ 2380.382861]  [<ffffffff8106f996>] kthread+0x96/0xa0
[ 2380.382894]  [<ffffffff81003c64>] kernel_thread_helper+0x4/0x10
[ 2380.382927]  [<ffffffff8106f900>] ? kthread+0x0/0xa0
[ 2380.382958]  [<ffffffff81003c60>] ? kernel_thread_helper+0x0/0x10
[ 2380.382987] Code: 55 49 89 fd 41 54 53 89 d3 48 81 ec a8 00 00 00 8b=
=20
15 a6 75 03 00 89 b5 3c ff ff ff 85 d2 0f 85 d5 00 00 00 49 8b 85 58 24=
=20
00 00 <3b> 98 28 01 00 00 73 61 89 db 48 8b 84 d8 30 01 00 00 48 85 c0
[ 2380.383185] RIP  [<ffffffffa037e877>] kvm_set_irq+0x37/0x140 [kvm]
[ 2380.383231]  RSP <ffff88045fc85d00>

Running markup_oops.pl give me the following:

vmaoffset =3D 18446744072102576128 ffffffffa037e841:    48 89=20
e5                 mov    %rsp,%rbp
  ffffffffa037e844:    41 57                    push   %r15
  ffffffffa037e846:    41 89 cf                 mov    %ecx,%r15d  | =20
%r15 =3D> 1  %ecx =3D 1
  ffffffffa037e849:    41 56                    push   %r14        | =20
%r14 =3D> ffffffffa037faa0
  ffffffffa037e84b:    41 55                    push   %r13
  ffffffffa037e84d:    49 89 fd                 mov    %rdi,%r13   | =20
%edi =3D ffff88045dbb7440  %r13 =3D> ffff88045dbb7440
  ffffffffa037e850:    41 54                    push   %r12        | =20
%r12 =3D> ffff88045dbb7440
  ffffffffa037e852:    53                       push   %rbx
  ffffffffa037e853:    89 d3                    mov    %edx,%ebx   | =20
%ebx =3D> 1a
  ffffffffa037e855:    48 81 ec a8 00 00 00     sub    $0xa8,%rsp
  ffffffffa037e85c:    8b 15 00 00 00 00        mov   =20
0x0(%rip),%edx        # ffffffffa037e862 <kvm_set_irq+0x22>
  ffffffffa037e862:    89 b5 3c ff ff ff        mov    %esi,-0xc4(%rbp)=
=20
|  %esi =3D 0
  ffffffffa037e868:    85 d2                    test   %edx,%edx   | =20
%edx =3D> 0
  ffffffffa037e86a:    0f 85 d5 00 00 00        jne    ffffffffa037e945=
=20
<kvm_set_irq+0x105>
  ffffffffa037e870:    49 8b 85 58 24 00 00     mov    0x2458(%r13),%ra=
x=20
|  %eax =3D> 200740000029c  %r13 =3D ffff88045dbb7440
*ffffffffa037e877:    3b 98 28 01 00 00        cmp    0x128(%rax),%ebx=20
|  %eax =3D 200740000029c  %ebx =3D 1a <--- faulting instruction
  ffffffffa037e87d:    73 61                    jae    ffffffffa037e8e0=
=20
<kvm_set_irq+0xa0>
  ffffffffa037e87f:    89 db                    mov    %ebx,%ebx
  ffffffffa037e881:    48 8b 84 d8 30 01 00     mov   =20
0x130(%rax,%rbx,8),%rax
  ffffffffa037e888:    00
  ffffffffa037e889:    48 85 c0                 test   %rax,%rax
  ffffffffa037e88c:    74 52                    je     ffffffffa037e8e0=
=20
<kvm_set_irq+0xa0>
  ffffffffa037e88e:    48 8d 95 40 ff ff ff     lea    -0xc0(%rbp),%rdx
  ffffffffa037e895:    31 db                    xor    %ebx,%ebx
  ffffffffa037e897:    48 8b 08                 mov    (%rax),%rcx
  ffffffffa037e89a:    83 c3 01                 add    $0x1,%ebx
  ffffffffa037e89d:    0f 18 09                 prefetcht0 (%rcx)
  ffffffffa037e8a0:    48 8b 48 e0              mov    -0x20(%rax),%rcx
  ffffffffa037e8a4:    48 89 0a                 mov    %rcx,(%rdx)
  ffffffffa037e8a7:    48 8b 48 e8              mov    -0x18(%rax),%rcx
  ffffffffa037e8ab:    48 89 4a 08              mov    %rcx,0x8(%rdx)
  ffffffffa037e8af:    48 8b 48 f0              mov    -0x10(%rax),%rcx
  ffffffffa037e8b3:    48 89 4a 10              mov    %rcx,0x10(%rdx)
  ffffffffa037e8b7:    48 8b 48 f8              mov    -0x8(%rax),%rcx
  ffffffffa037e8bb:    48 89 4a 18              mov    %rcx,0x18(%rdx)
  ffffffffa037e8bf:    48 8b 08                 mov    (%rax),%rcx

I've re-run markup_oops on the first oops (2.6.37.1) (on the right=20
module this time, sorry for that), it give me the following:

vmaoffset =3D 18446744072103215104 ffffffffa041aa62:    41 89=20
f7                 mov    %esi,%r15d  |  %r15 =3D> 0  %esi =3D 0
  ffffffffa041aa65:    41 56                    push   %r14        | =20
%r14 =3D> 0
  ffffffffa041aa67:    41 55                    push   %r13
  ffffffffa041aa69:    41 89 cd                 mov    %ecx,%r13d  | =20
%ecx =3D 1  %r13 =3D> 1
  ffffffffa041aa6c:    41 54                    push   %r12
  ffffffffa041aa6e:    49 89 fc                 mov    %rdi,%r12   | =20
%edi =3D 0  %r12 =3D> 0
  ffffffffa041aa71:    55                       push   %rbp
  ffffffffa041aa72:    53                       push   %rbx
  ffffffffa041aa73:    89 d3                    mov    %edx,%ebx   | =20
%ebx =3D> 1a
  ffffffffa041aa75:    48 81 ec 98 00 00 00     sub    $0x98,%rsp
  ffffffffa041aa7c:    8b 15 00 00 00 00        mov   =20
0x0(%rip),%edx        # ffffffffa041aa82 <kvm_set_irq+0x22>
  ffffffffa041aa82:    85 d2                    test   %edx,%edx   | =20
%edx =3D> 0
  ffffffffa041aa84:    0f 85 c4 00 00 00        jne    ffffffffa041ab4e=
=20
<kvm_set_irq+0xee>
*ffffffffa041aa8a:    49 8b 84 24 58 24 00     mov    0x2458(%r12),%rax=
=20
|  %eax =3D 0  %r12 =3D 0 <--- faulting instruction
  ffffffffa041aa91:    00
  ffffffffa041aa92:    3b 98 28 01 00 00        cmp    0x128(%rax),%ebx
  ffffffffa041aa98:    73 5e                    jae    ffffffffa041aaf8=
=20
<kvm_set_irq+0x98>
  ffffffffa041aa9a:    89 db                    mov    %ebx,%ebx
  ffffffffa041aa9c:    48 8b 84 d8 30 01 00     mov   =20
0x130(%rax,%rbx,8),%rax
  ffffffffa041aaa3:    00
  ffffffffa041aaa4:    48 85 c0                 test   %rax,%rax
  ffffffffa041aaa7:    74 4f                    je     ffffffffa041aaf8=
=20
<kvm_set_irq+0x98>
  ffffffffa041aaa9:    48 89 e2                 mov    %rsp,%rdx
  ffffffffa041aaac:    31 db                    xor    %ebx,%ebx
  ffffffffa041aaae:    48 8b 08                 mov    (%rax),%rcx
  ffffffffa041aab1:    83 c3 01                 add    $0x1,%ebx
  ffffffffa041aab4:    0f 18 09                 prefetcht0 (%rcx)
  ffffffffa041aab7:    48 8b 48 e0              mov    -0x20(%rax),%rcx
  ffffffffa041aabb:    48 89 0a                 mov    %rcx,(%rdx)
  ffffffffa041aabe:    48 8b 48 e8              mov    -0x18(%rax),%rcx
  ffffffffa041aac2:    48 89 4a 08              mov    %rcx,0x8(%rdx)
  ffffffffa041aac6:    48 8b 48 f0              mov    -0x10(%rax),%rcx
  ffffffffa041aaca:    48 89 4a 10              mov    %rcx,0x10(%rdx)
  ffffffffa041aace:    48 8b 48 f8              mov    -0x8(%rax),%rcx

It's appear that the kernel i recompiled (make-pkg) with the debug=20
options for kvm module, doesn't have the debug!
addr2line give me an "??:0"

I will retent with the good options.

Regards.

--=20
Jean-Philippe Menil - P=F4le r=E9seau Service IRTS
DSI Universit=E9 de Nantes
jean-philippe.menil@univ-nantes.fr
Tel : 02.53.48.49.27 - Fax : 02.53.48.49.09


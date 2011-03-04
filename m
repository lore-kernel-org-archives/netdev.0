From: Jean-Philippe Menil <jean-philippe.menil@univ-nantes.fr>
Subject: Re: Bug inkvm_set_irq
Date: Fri, 04 Mar 2011 10:39:05 +0100
Message-ID: <4D70B339.3080001@univ-nantes.fr>
References: <4D6B7BAB.9070907@univ-nantes.fr> <20110228113939.GH28006@redhat.com> <4D6BBB88.5060709@univ-nantes.fr> <4D6C22E8.2020007@univ-nantes.fr> <20110301070333.GA5972@redhat.com> <4D6D0510.4060300@univ-nantes.fr> <20110303144715.GA12400@redhat.com> <4D6FB313.1010400@univ-nantes.fr> <20110303155533.GA13310@redhat.com> <4D70AF3B.5080007@univ-nantes.fr> <20110304093500.GA31844@redhat.com>
Reply-To: jean-philippe.menil@univ-nantes.fr
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-tls2.univ-nantes.fr ([193.52.101.146]:57137 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759297Ab1CDJjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 04:39:06 -0500
In-Reply-To: <20110304093500.GA31844@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/03/2011 10:35, Michael S. Tsirkin a =E9crit :
> On Fri, Mar 04, 2011 at 10:22:03AM +0100, Jean-Philippe Menil wrote:
>> Le 03/03/2011 16:55, Michael S. Tsirkin a =E9crit :
>>> On Thu, Mar 03, 2011 at 04:26:11PM +0100, Jean-Philippe Menil wrote=
:
>>>> Le 03/03/2011 15:47, Michael S. Tsirkin a =E9crit :
>>>>> On Tue, Mar 01, 2011 at 03:39:12PM +0100, Jean-Philippe Menil wro=
te:
>>>>>> so this time the bug is:
>>>>>>
>>>>>> [17882.612303] BUG: unable to handle kernel paging request at
>>>>>> 0000000000002458
>>>>>> [17882.612342] IP: [<ffffffffa03898a0>] kvm_set_irq+0x30/0x140 [=
kvm]
>>>>>>
>>>>>> markup_oops give me this:
>>>>>>
>>>>>> root@ayrshire:~# cat bug-0103.txt | perl markup_oops.pl -m
>>>>>> /lib/modules/2.6.37.2-dsiun-110105+/kernel/arch/x86/kvm/kvm.ko
>>>>>> /boot/vmlinuz-2.6.37.2-dsiun-110105+
>>>>>> vmaoffset =3D 18446744072102621184 ffffffffa0389871:	48 89 e5   =
	mov
>>>>>> %rsp,%rbp
>>>>>>   ffffffffa0389874:	41 57                	push   %r15
>>>>>>   ffffffffa0389876:	41 89 cf             	mov    %ecx,%r15d  |  =
%r15
>>>>>> =3D>    1  %ecx =3D 1
>>>>>>   ffffffffa0389879:	41 56                	push   %r14        |  =
%r14
>>>>>> =3D>    ffffffffa038aad0
>>>>>>   ffffffffa038987b:	41 55                	push   %r13
>>>>>>   ffffffffa038987d:	49 89 fd             	mov    %rdi,%r13   |  =
%edi
>>>>>> =3D 0  %r13 =3D>    0
>>>>>>   ffffffffa0389880:	41 54                	push   %r12        |  =
%r12 =3D>    0
>>>>>>   ffffffffa0389882:	53                   	push   %rbx
>>>>>>   ffffffffa0389883:	89 d3                	mov    %edx,%ebx   |  =
%ebx =3D>    1a
>>>>>>   ffffffffa0389885:	48 81 ec a8 00 00 00 	sub    $0xa8,%rsp
>>>>>>   ffffffffa038988c:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx
>>>>>> # ffffffffa0389892<kvm_set_irq+0x22>
>>>>>>   ffffffffa0389892:	89 b5 3c ff ff ff    	mov    %esi,-0xc4(%rbp=
) |
>>>>>> %esi =3D 0
>>>>>>   ffffffffa0389898:	85 d2                	test   %edx,%edx   |  =
%edx =3D>    0
>>>>>>   ffffffffa038989a:	0f 85 d5 00 00 00    	jne    ffffffffa038997=
5
>>>>>> <kvm_set_irq+0x105>
>>>>>> *ffffffffa03898a0:	49 8b 85 58 24 00 00 	mov    0x2458(%r13),%ra=
x |
>>>>>> %eax =3D 0  %r13 =3D 0<--- faulting instruction
>>>>>>   ffffffffa03898a7:	3b 98 28 01 00 00    	cmp    0x128(%rax),%eb=
x
>>>>>>   ffffffffa03898ad:	73 61                	jae    ffffffffa038991=
0
>>>>>> <kvm_set_irq+0xa0>
>>>>>>   ffffffffa03898af:	89 db                	mov    %ebx,%ebx
>>>>>>   ffffffffa03898b1:	48 8b 84 d8 30 01 00 	mov    0x130(%rax,%rbx=
,8),%rax
>>>>>>   ffffffffa03898b8:	00
>>>>>>   ffffffffa03898b9:	48 85 c0             	test   %rax,%rax
>>>>>>   ffffffffa03898bc:	74 52                	je     ffffffffa038991=
0
>>>>>> <kvm_set_irq+0xa0>
>>>>>>   ffffffffa03898be:	48 8d 95 40 ff ff ff 	lea    -0xc0(%rbp),%rd=
x
>>>>>>   ffffffffa03898c5:	31 db                	xor    %ebx,%ebx
>>>>>>   ffffffffa03898c7:	48 8b 08             	mov    (%rax),%rcx
>>>>>>   ffffffffa03898ca:	83 c3 01             	add    $0x1,%ebx
>>>>>>   ffffffffa03898cd:	0f 18 09             	prefetcht0 (%rcx)
>>>>>>   ffffffffa03898d0:	48 8b 48 e0          	mov    -0x20(%rax),%rc=
x
>>>>>>   ffffffffa03898d4:	48 89 0a             	mov    %rcx,(%rdx)
>>>>>>   ffffffffa03898d7:	48 8b 48 e8          	mov    -0x18(%rax),%rc=
x
>>>>>>   ffffffffa03898db:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
>>>>>>   ffffffffa03898df:	48 8b 48 f0          	mov    -0x10(%rax),%rc=
x
>>>>>>   ffffffffa03898e3:	48 89 4a 10          	mov    %rcx,0x10(%rdx)
>>>>>>   ffffffffa03898e7:	48 8b 48 f8          	mov    -0x8(%rax),%rcx
>>>>>>   ffffffffa03898eb:	48 89 4a 18          	mov    %rcx,0x18(%rdx)
>>>>>>
>>>>>> wich correspond to offset 68a0 (from objdump):
>>>>>>
>>>>>> kvm_set_irq():
>>>>>> /usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq=
_comm.c:161
>>>>>>      68a0:       49 8b 85 58 24 00 00    mov    0x2458(%r13),%ra=
x
>>>>>> /usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq=
_comm.c:162
>>>>>>      68a7:       3b 98 28 01 00 00       cmp    0x128(%rax),%ebx
>>>>>>
>>>>>> root@ayrshire:~# addr2line -e
>>>>>> /lib/modules/2.6.37.2-dsiun-110105+/kernel/arch/x86/kvm/kvm.ko
>>>>>> 0x68a0
>>>>>> /usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq=
_comm.c:161
>>>>>>
>>>>>> So here kvm->irq_routing is null.
>>>>>>
>>>>>> How can it be?
>>>>>>
>>>>>> Regards.
>>>>> Not null, this seems to be invalid.
>>>>> I suspect use after free where the kvm pointer is
>>>>> pointing at some random memory. Use after free?
>>>>> Could you please try enabling a slab debugger,
>>>>> recompile and rerun the test?
>>>>>
>>>> Hi,
>>>>
>>>> I'm not sure to activate the right thing.
>>>> Is that what you want?
>>>>
>>>> CONFIG_SLAB=3Dy
>>>> CONFIG_SLABINFO=3Dy
>>>> CONFIG_DEBUG_SLAB=3Dy
>>>> CONFIG_DEBUG_SLAB_LEAK=3Dy
>>>>
>>>> Regards.
>>> Yes, maybe disable SLAB_LEAK.
>>>
>>>> --=20
>>>> Jean-Philippe Menil - P=F4le r=E9seau Service IRTS
>>>> DSI Universit=E9 de Nantes
>>>> jean-philippe.menil@univ-nantes.fr
>>>> Tel : 02.53.48.49.27 - Fax : 02.53.48.49.09
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe kvm" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Hi,
>>
>> so this time, here is what markup_oops says:
>>
>> root@ayrshire:~# cat oops-0403.txt | perl markup_oops.pl -m
>> /lib/modules/2.6.37.2.999-dsiun-110105+/kernel/arch/x86/kvm/kvm.ko
>> /boot/vmlinuz-2.6.37.2.999-dsiun-110105+
>> vmaoffset =3D 18446744072102948864 ffffffffa03d9811:    48 89 e5
>> mov    %rsp,%rbp
>>   ffffffffa03d9814:    41 57                    push   %r15
>>   ffffffffa03d9816:    41 89 cf                 mov    %ecx,%r15d  |
>> %r15 =3D>  1  %ecx =3D 1
>>   ffffffffa03d9819:    41 56                    push   %r14        |
>> %r14 =3D>  ffffffffa03daa50
>>   ffffffffa03d981b:    41 55                    push   %r13
>>   ffffffffa03d981d:    49 89 fd                 mov    %rdi,%r13   |
>> %edi =3D 6b6b6b6b6b6b6b6b  %r13 =3D>  6b6b6b6b6b6b6b6b
>>   ffffffffa03d9820:    41 54                    push   %r12        |
>> %r12 =3D>  6b6b6b6b6b6b6b6b
>>   ffffffffa03d9822:    53                       push   %rbx
>>   ffffffffa03d9823:    89 d3                    mov    %edx,%ebx   |
>> %ebx =3D>  6b6b6b6b
>>   ffffffffa03d9825:    48 81 ec a8 00 00 00     sub    $0xa8,%rsp
>>   ffffffffa03d982c:    8b 15 00 00 00 00        mov    0x0(%rip),%ed=
x
>> # ffffffffa03d9832<kvm_set_irq+0x22>
>>   ffffffffa03d9832:    89 b5 3c ff ff ff        mov
>> %esi,-0xc4(%rbp) |  %esi =3D 0
>>   ffffffffa03d9838:    85 d2                    test   %edx,%edx   |
>> %edx =3D>  0
>>   ffffffffa03d983a:    0f 85 d5 00 00 00        jne
>> ffffffffa03d9915<kvm_set_irq+0x105>
>> *ffffffffa03d9840:    49 8b 85 58 24 00 00     mov
>> 0x2458(%r13),%rax |  %eax =3D 0  %r13 =3D 6b6b6b6b6b6b6b6b<--- fault=
ing
>> instruction
>>   ffffffffa03d9847:    3b 98 28 01 00 00        cmp    0x128(%rax),%=
ebx
>>   ffffffffa03d984d:    73 61                    jae
>> ffffffffa03d98b0<kvm_set_irq+0xa0>
>>   ffffffffa03d984f:    89 db                    mov    %ebx,%ebx
>>   ffffffffa03d9851:    48 8b 84 d8 30 01 00     mov
>> 0x130(%rax,%rbx,8),%rax
>>   ffffffffa03d9858:    00
>>   ffffffffa03d9859:    48 85 c0                 test   %rax,%rax
>>   ffffffffa03d985c:    74 52                    je
>> ffffffffa03d98b0<kvm_set_irq+0xa0>
>>   ffffffffa03d985e:    48 8d 95 40 ff ff ff     lea    -0xc0(%rbp),%=
rdx
>>   ffffffffa03d9865:    31 db                    xor    %ebx,%ebx
>>   ffffffffa03d9867:    48 8b 08                 mov    (%rax),%rcx
>>   ffffffffa03d986a:    83 c3 01                 add    $0x1,%ebx
>>   ffffffffa03d986d:    0f 18 09                 prefetcht0 (%rcx)
>>   ffffffffa03d9870:    48 8b 48 e0              mov    -0x20(%rax),%=
rcx
>>   ffffffffa03d9874:    48 89 0a                 mov    %rcx,(%rdx)
>>   ffffffffa03d9877:    48 8b 48 e8              mov    -0x18(%rax),%=
rcx
>>   ffffffffa03d987b:    48 89 4a 08              mov    %rcx,0x8(%rdx=
)
>>   ffffffffa03d987f:    48 8b 48 f0              mov    -0x10(%rax),%=
rcx
>>   ffffffffa03d9883:    48 89 4a 10              mov    %rcx,0x10(%rd=
x)
>>   ffffffffa03d9887:    48 8b 48 f8              mov    -0x8(%rax),%r=
cx
>>   ffffffffa03d988b:    48 89 4a 18              mov    %rcx,0x18(%rd=
x)
>>
>>
>> Is that you wanted, the "6b6b6b6b6b6b6b6b" ?
>>
>> Regards.
> Yes, excellent. So now we can detect the problem by comparing
> kvm with 6b6b6b6b6b6b6b6b, and print out stuff to understand where
> this comes from.
> I will prepare such a debugging patch.
>
> For that, could you please tell me which kernel version, exactly, are
> you using?
>
>
Yes, it's a 2.6.37.2 kernel.

Thanks a lot.


--=20
Jean-Philippe Menil - P=F4le r=E9seau Service IRTS
DSI Universit=E9 de Nantes
jean-philippe.menil@univ-nantes.fr
Tel : 02.53.48.49.27 - Fax : 02.53.48.49.09


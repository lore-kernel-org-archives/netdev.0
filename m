From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Use after free in e100
Date: 29 May 2003 14:30:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1054211442.761.32.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-vauby9rcL3iM4q8NTpnC"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux.nics@intel.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-vauby9rcL3iM4q8NTpnC
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi

When using 2.5.69-mm9 which includes Manfred's unmap-after-free patch I
ran into a use-after-free bug in e100 that just might be real.

I ran the two oopses through ksymoops to get some more detail but since
ksyms doesn't exist in 2.5 anymore it failed to resolve the EIP (e100 as
module). But fear not, the EIP is in the original report by kksymoops
and I've included it below.

(identical in both oopses)
EIP is at e100_rx_srv+0x4ac/0x514 [e100]

The two ksymoopsed oopses are attached.


Driver output at init:
(no module options)

Intel(R) PRO/100 Network Driver - version 2.2.21-k1
Copyright (c) 2003 Intel Corporation

e100: selftest OK.
e100: eth0: Intel(R) PRO/100 Network Connection

e100: selftest OK.
e100: eth1: Intel(R) PRO/100 Network Connection


lspci:

00:11.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 04)
00:12.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 05)

-- 
/Martin

--=-vauby9rcL3iM4q8NTpnC
Content-Disposition: attachment; filename=e100-decoded
Content-Type: text/plain; name=e100-decoded; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

ksymoops 2.4.8 on i686 2.5.69-mm9.  Options used
     -v /usr/src/2.5/linux-2.5.69-mm9/vmlinux (specified)
     -K (specified)
     -L (specified)
     -O (specified)
     -m /boot/System.map-2.5.69-mm9 (specified)

Unable to handle kernel paging request at virtual address c2f0a064
ec9056e4
*pde =3D 0000a067
Oops: 0000 [#1]
CPU:    0
EIP:    0060:[<ec9056e4>]    Not tainted VLI
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010286
eax: 03c495c9   ebx: e6df0004   ecx: e6df0260   edx: c2f0a004
esi: cd843004   edi: 0000003c   ebp: c0375eb4   esp: c0375e84
ds: 007b   es: 007b   ss: 0068
Stack: 00004050 e6df0260 00004050 e6df0288 e6df0280 0000002e 0000002e 00000=
02d=20
       e6df0004 c2f0a004 c037a022 e9106016 c0375ed4 ec9050bc e6df0260 e6ce3=
a48=20
       04000001 00000001 40000000 e6df0004 c0375ef4 c010ae1a 0000000b e6df0=
004=20
Call Trace:
 [<c037a022>] cpu_init+0xbe/0x28c
 [<ec9050bc>] e100intr+0x25c/0x2b8 [e100]
 [<c010ae1a>] handle_IRQ_event+0x2a/0x54
 [<c010b36b>] do_IRQ+0x187/0x2cc
 [<c0109980>] common_interrupt+0x18/0x20
 [<c0120aa7>] do_softirq+0x47/0xb0
 [<c010b49a>] do_IRQ+0x2b6/0x2cc
 [<c0106f24>] default_idle+0x0/0x34
 [<c0106f24>] default_idle+0x0/0x34
 [<c0109980>] common_interrupt+0x18/0x20
 [<c0106f24>] default_idle+0x0/0x34
 [<c0106f24>] default_idle+0x0/0x34
 [<c0106f4a>] default_idle+0x26/0x34
 [<c0106fd9>] cpu_idle+0x35/0x44
 [<c0105000>] _stext+0x0/0x20
 [<c010501c>] _stext+0x1c/0x20
 [<c0376614>] start_kernel+0x11c/0x120
Code: f3 a6 75 04 c6 40 6e 00 8b 55 f4 52 eb 04 8b 4d f4 51 e8 ac c5 92 d3 =
83 c4 04 a1 20 3b 33 c0 8b 5d f0 89 43 4c 8b 55 f4 8b 4d 08 <8b> 42 60 01 8=
1 84 00 00 00 8b 5d e4 89 5d ec 8b 45 08 8b 75 e8=20


>>EIP; ec9056e4 <_end+2c51eb24/3fc17440>   <=3D=3D=3D=3D=3D

>>ebx; e6df0004 <_end+26a09444/3fc17440>
>>ecx; e6df0260 <_end+26a096a0/3fc17440>
>>edx; c2f0a004 <_end+2b23444/3fc17440>
>>esi; cd843004 <_end+d45c444/3fc17440>
>>ebp; c0375eb4 <init_thread_union+1eb4/2000>
>>esp; c0375e84 <init_thread_union+1e84/2000>

Trace; c037a022 <cpu_init+be/28c>
Trace; ec9050bc <_end+2c51e4fc/3fc17440>
Trace; c010ae1a <handle_IRQ_event+2a/54>
Trace; c010b36b <do_IRQ+187/2cc>
Trace; c0109980 <common_interrupt+18/20>
Trace; c0120aa7 <do_softirq+47/b0>
Trace; c010b49a <do_IRQ+2b6/2cc>
Trace; c0106f24 <default_idle+0/34>
Trace; c0106f24 <default_idle+0/34>
Trace; c0109980 <common_interrupt+18/20>
Trace; c0106f24 <default_idle+0/34>
Trace; c0106f24 <default_idle+0/34>
Trace; c0106f4a <default_idle+26/34>
Trace; c0106fd9 <cpu_idle+35/44>
Trace; c0105000 <_stext+0/0>
Trace; c010501c <rest_init+1c/20>
Trace; c0376614 <start_kernel+11c/120>

Code;  ec9056b9 <_end+2c51eaf9/3fc17440>
00000000 <_EIP>:
Code;  ec9056b9 <_end+2c51eaf9/3fc17440>
   0:   f3 a6                     repz cmpsb %es:(%edi),%ds:(%esi)
Code;  ec9056bb <_end+2c51eafb/3fc17440>
   2:   75 04                     jne    8 <_EIP+0x8>
Code;  ec9056bd <_end+2c51eafd/3fc17440>
   4:   c6 40 6e 00               movb   $0x0,0x6e(%eax)
Code;  ec9056c1 <_end+2c51eb01/3fc17440>
   8:   8b 55 f4                  mov    0xfffffff4(%ebp),%edx
Code;  ec9056c4 <_end+2c51eb04/3fc17440>
   b:   52                        push   %edx
Code;  ec9056c5 <_end+2c51eb05/3fc17440>
   c:   eb 04                     jmp    12 <_EIP+0x12>
Code;  ec9056c7 <_end+2c51eb07/3fc17440>
   e:   8b 4d f4                  mov    0xfffffff4(%ebp),%ecx
Code;  ec9056ca <_end+2c51eb0a/3fc17440>
  11:   51                        push   %ecx
Code;  ec9056cb <_end+2c51eb0b/3fc17440>
  12:   e8 ac c5 92 d3            call   d392c5c3 <_EIP+0xd392c5c3>
Code;  ec9056d0 <_end+2c51eb10/3fc17440>
  17:   83 c4 04                  add    $0x4,%esp
Code;  ec9056d3 <_end+2c51eb13/3fc17440>
  1a:   a1 20 3b 33 c0            mov    0xc0333b20,%eax
Code;  ec9056d8 <_end+2c51eb18/3fc17440>
  1f:   8b 5d f0                  mov    0xfffffff0(%ebp),%ebx
Code;  ec9056db <_end+2c51eb1b/3fc17440>
  22:   89 43 4c                  mov    %eax,0x4c(%ebx)
Code;  ec9056de <_end+2c51eb1e/3fc17440>
  25:   8b 55 f4                  mov    0xfffffff4(%ebp),%edx
Code;  ec9056e1 <_end+2c51eb21/3fc17440>
  28:   8b 4d 08                  mov    0x8(%ebp),%ecx
Code;  ec9056e4 <_end+2c51eb24/3fc17440>   <=3D=3D=3D=3D=3D
  2b:   8b 42 60                  mov    0x60(%edx),%eax   <=3D=3D=3D=3D=3D
Code;  ec9056e7 <_end+2c51eb27/3fc17440>
  2e:   01 81 84 00 00 00         add    %eax,0x84(%ecx)
Code;  ec9056ed <_end+2c51eb2d/3fc17440>
  34:   8b 5d e4                  mov    0xffffffe4(%ebp),%ebx
Code;  ec9056f0 <_end+2c51eb30/3fc17440>
  37:   89 5d ec                  mov    %ebx,0xffffffec(%ebp)
Code;  ec9056f3 <_end+2c51eb33/3fc17440>
  3a:   8b 45 08                  mov    0x8(%ebp),%eax
Code;  ec9056f6 <_end+2c51eb36/3fc17440>
  3d:   8b 75 e8                  mov    0xffffffe8(%ebp),%esi

 <0>Kernel panic: Fatal exception in interrupt

--=-vauby9rcL3iM4q8NTpnC
Content-Disposition: attachment; filename=e100_2-decoded
Content-Type: text/plain; name=e100_2-decoded; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

ksymoops 2.4.8 on i686 2.5.69-mm9.  Options used
     -v /usr/src/2.5/linux-2.5.69-mm9/vmlinux (specified)
     -K (specified)
     -L (specified)
     -O (specified)
     -m /boot/System.map-2.5.69-mm9 (specified)

Unable to handle kernel paging request at virtual address dd896064
ec9056e4
*pde =3D 00075067
Oops: 0000 [#1]
CPU:    0
EIP:    0060:[<ec9056e4>]    Not tainted VLI
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010282
eax: 089b89ea   ebx: e8550004   ecx: e8550260   edx: dd896004
esi: cff0e004   edi: 0000003c   ebp: c0375d84   esp: c0375d54
ds: 007b   es: 007b   ss: 0068
Stack: 00004050 e8550260 00004050 e8550288 e8550280 0000002e 0000002e 00000=
02d=20
       e8550004 dd896004 c037a022 e9a13016 c0375da4 ec9050bc e8550260 e83a6=
e68=20
       04000001 00000001 40000000 e8550004 c0375dc4 c010ae1a 0000000b e8550=
004=20
Call Trace:
 [<c037a022>] cpu_init+0xbe/0x28c
 [<ec9050bc>] e100intr+0x25c/0x2b8 [e100]
 [<c010ae1a>] handle_IRQ_event+0x2a/0x54
 [<c010b36b>] do_IRQ+0x187/0x2cc
 [<c0109980>] common_interrupt+0x18/0x20
 [<c0140087>] kfree+0x267/0x274
 [<c022d8fa>] skb_release_data+0x92/0x9c
 [<c022d8fa>] skb_release_data+0x92/0x9c
 [<c022d911>] kfree_skbmem+0xd/0x20
 [<c022da10>] __kfree_skb+0xec/0xf4
 [<c026d54f>] arp_process+0x42f/0x43c
 [<c026d60b>] arp_rcv+0xaf/0x100
 [<c023223b>] netif_receive_skb+0x1df/0x218
 [<c0232308>] process_backlog+0x94/0x168
 [<c023244b>] net_rx_action+0x6f/0x110
 [<c0120ab1>] do_softirq+0x51/0xb0
 [<c010b49a>] do_IRQ+0x2b6/0x2cc
 [<c0106f24>] default_idle+0x0/0x34
 [<c0106f24>] default_idle+0x0/0x34
 [<c0109980>] common_interrupt+0x18/0x20
 [<c0106f24>] default_idle+0x0/0x34
 [<c0106f24>] default_idle+0x0/0x34
 [<c0106f4a>] default_idle+0x26/0x34
 [<c0106fd9>] cpu_idle+0x35/0x44
 [<c0105000>] _stext+0x0/0x20
 [<c010501c>] _stext+0x1c/0x20
 [<c0376614>] start_kernel+0x11c/0x120
Code: f3 a6 75 04 c6 40 6e 00 8b 55 f4 52 eb 04 8b 4d f4 51 e8 ac c5 92 d3 =
83 c4 04 a1 20 3b 33 c0 8b 5d f0 89 43 4c 8b 55 f4 8b 4d 08 <8b> 42 60 01 8=
1 84 00 00 00 8b 5d e4 89 5d ec 8b 45 08 8b 75 e8=20


>>EIP; ec9056e4 <_end+2c51eb24/3fc17440>   <=3D=3D=3D=3D=3D

>>ebx; e8550004 <_end+28169444/3fc17440>
>>ecx; e8550260 <_end+281696a0/3fc17440>
>>edx; dd896004 <_end+1d4af444/3fc17440>
>>esi; cff0e004 <_end+fb27444/3fc17440>
>>ebp; c0375d84 <init_thread_union+1d84/2000>
>>esp; c0375d54 <init_thread_union+1d54/2000>

Trace; c037a022 <cpu_init+be/28c>
Trace; ec9050bc <_end+2c51e4fc/3fc17440>
Trace; c010ae1a <handle_IRQ_event+2a/54>
Trace; c010b36b <do_IRQ+187/2cc>
Trace; c0109980 <common_interrupt+18/20>
Trace; c0140087 <kfree+267/274>
Trace; c022d8fa <skb_release_data+92/9c>
Trace; c022d8fa <skb_release_data+92/9c>
Trace; c022d911 <kfree_skbmem+d/20>
Trace; c022da10 <__kfree_skb+ec/f4>
Trace; c026d54f <arp_process+42f/43c>
Trace; c026d60b <arp_rcv+af/100>
Trace; c023223b <netif_receive_skb+1df/218>
Trace; c0232308 <process_backlog+94/168>
Trace; c023244b <net_rx_action+6f/110>
Trace; c0120ab1 <do_softirq+51/b0>
Trace; c010b49a <do_IRQ+2b6/2cc>
Trace; c0106f24 <default_idle+0/34>
Trace; c0106f24 <default_idle+0/34>
Trace; c0109980 <common_interrupt+18/20>
Trace; c0106f24 <default_idle+0/34>
Trace; c0106f24 <default_idle+0/34>
Trace; c0106f4a <default_idle+26/34>
Trace; c0106fd9 <cpu_idle+35/44>
Trace; c0105000 <_stext+0/0>
Trace; c010501c <rest_init+1c/20>
Trace; c0376614 <start_kernel+11c/120>

Code;  ec9056b9 <_end+2c51eaf9/3fc17440>
00000000 <_EIP>:
Code;  ec9056b9 <_end+2c51eaf9/3fc17440>
   0:   f3 a6                     repz cmpsb %es:(%edi),%ds:(%esi)
Code;  ec9056bb <_end+2c51eafb/3fc17440>
   2:   75 04                     jne    8 <_EIP+0x8>
Code;  ec9056bd <_end+2c51eafd/3fc17440>
   4:   c6 40 6e 00               movb   $0x0,0x6e(%eax)
Code;  ec9056c1 <_end+2c51eb01/3fc17440>
   8:   8b 55 f4                  mov    0xfffffff4(%ebp),%edx
Code;  ec9056c4 <_end+2c51eb04/3fc17440>
   b:   52                        push   %edx
Code;  ec9056c5 <_end+2c51eb05/3fc17440>
   c:   eb 04                     jmp    12 <_EIP+0x12>
Code;  ec9056c7 <_end+2c51eb07/3fc17440>
   e:   8b 4d f4                  mov    0xfffffff4(%ebp),%ecx
Code;  ec9056ca <_end+2c51eb0a/3fc17440>
  11:   51                        push   %ecx
Code;  ec9056cb <_end+2c51eb0b/3fc17440>
  12:   e8 ac c5 92 d3            call   d392c5c3 <_EIP+0xd392c5c3>
Code;  ec9056d0 <_end+2c51eb10/3fc17440>
  17:   83 c4 04                  add    $0x4,%esp
Code;  ec9056d3 <_end+2c51eb13/3fc17440>
  1a:   a1 20 3b 33 c0            mov    0xc0333b20,%eax
Code;  ec9056d8 <_end+2c51eb18/3fc17440>
  1f:   8b 5d f0                  mov    0xfffffff0(%ebp),%ebx
Code;  ec9056db <_end+2c51eb1b/3fc17440>
  22:   89 43 4c                  mov    %eax,0x4c(%ebx)
Code;  ec9056de <_end+2c51eb1e/3fc17440>
  25:   8b 55 f4                  mov    0xfffffff4(%ebp),%edx
Code;  ec9056e1 <_end+2c51eb21/3fc17440>
  28:   8b 4d 08                  mov    0x8(%ebp),%ecx
Code;  ec9056e4 <_end+2c51eb24/3fc17440>   <=3D=3D=3D=3D=3D
  2b:   8b 42 60                  mov    0x60(%edx),%eax   <=3D=3D=3D=3D=3D
Code;  ec9056e7 <_end+2c51eb27/3fc17440>
  2e:   01 81 84 00 00 00         add    %eax,0x84(%ecx)
Code;  ec9056ed <_end+2c51eb2d/3fc17440>
  34:   8b 5d e4                  mov    0xffffffe4(%ebp),%ebx
Code;  ec9056f0 <_end+2c51eb30/3fc17440>
  37:   89 5d ec                  mov    %ebx,0xffffffec(%ebp)
Code;  ec9056f3 <_end+2c51eb33/3fc17440>
  3a:   8b 45 08                  mov    0x8(%ebp),%eax
Code;  ec9056f6 <_end+2c51eb36/3fc17440>
  3d:   8b 75 e8                  mov    0xffffffe8(%ebp),%esi

 <0>Kernel panic: Fatal exception in interrupt

--=-vauby9rcL3iM4q8NTpnC--

From: Ron Yorgason <yorgasor@gmail.com>
Subject: Re: Kernel Oops in UDP w/ ARM architecture
Date: Mon, 9 Mar 2009 12:46:31 -0500
Message-ID: <93d1fdd10903091046w2d426226sfcb2a0d52c94a114@mail.gmail.com>
References: <93d1fdd10903090852g268b4141h31dc39a5848fcf32@mail.gmail.com>
	 <49B54F00.5090706@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:7367 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbZCIRqs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 13:46:48 -0400
Received: by qw-out-2122.google.com with SMTP id 5so1697514qwi.37
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2009 10:46:46 -0700 (PDT)
In-Reply-To: <49B54F00.5090706@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're using the fec driver, found in drivers/net/fec.c.  I modified
this driver slightly to get the MAC address from the redboot
configuration stored in flash memory, but it's otherwise untouched.  I
can send my version of the file if that would help.

--Ron



On Mon, Mar 9, 2009 at 12:16 PM, Eric Dumazet <dada1@cosmosbay.com> wro=
te:
> Ron Yorgason a =E9crit :
> - Show quoted text -
>> I'm working on an embedded video streaming application using gstream=
er
>> over RTP/UDP on a Freescale iMX27 ARM platform. =A0I have one board
>> doing the video capture and compression, and streaming it across the
>> network to another board which does the decoding and display. =A0I'm
>> stuck right now with a kernel oops we're getting. =A0It usually occu=
rs
>> within 2-6 hours, but sometimes it takes longer for it to happen. =A0=
I
>> believe it always dies with the same address in the failure.
>>
>> I'm using a 2.6.19.2 kernel release. =A0I don't know if this problem=
 has
>> already been found and fixed in a future release (I didn't see any
>> mention of it in the changelogs of the next few releases), but this =
is
>> a customized kernel and I don't know how feasible it would be to por=
t
>> all the changes to a newer kernel. =A0We haven't touched the network=
ing
>> stack, so it's most likely this bug is in the stock release.
>>
>> Unable to handle kernel paging request at virtual address c6f9202a
>> pgd =3D c6d7c000
>> [c6f9202a] *pgd=3Da6e0041e(bad)
>> Internal error: Oops: 1 [#3]
>> Modules linked in:
>> CPU: 0
>> PC is at udp_recvmsg+0x184/0x21c
>> LR is at 0xf2799669
>> pc : [<c024a3e0>] =A0 =A0lr : [<f2799669>] =A0 =A0Not tainted
>> sp : c6f9fd48 =A0ip : 00000000 =A0fp : c6f9fd80
>> r10: c6f9fea0 =A0r9 : 00000000 =A0r8 : 00000400
>> r7 : 00000400 =A0r6 : c7a52200 =A0r5 : c6f9ff20 =A0r4 : c6291780
>> r3 : c6f9201e =A0r2 : 00000000 =A0r1 : 00000008 =A0r0 : c6f9fea8
>> Flags: NzCv =A0IRQs on =A0FIQs on =A0Mode SVC_32 =A0Segment user
>> Control: 5317F
>> Table: A6D7C000 =A0DAC: 00000015
>> Process gst-launch-0.10 (pid: 18165, stack limit =3D 0xc6f9e250)
>> Stack: (0xc6f9fd48 to 0xc6fa0000)
>> fd40: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 00000001 00000000 00000000=
 00000000 c02fbb80 c6f9ff20
>> fd60: c6f9ff20 00000400 00000000 00000000 00000000 c6f9fda8 c6f9fd84=
 c0207468
>> fd80: c024a26c 00000000 00000000 c6f9fd90 00000010 c6f9fdb0 c7c4fac0=
 c6f9fe9c
>> fda0: c6f9fdac c0205ae0 c020742c 00000000 c02e06c8 00000001 00000000=
 00000001
>> fdc0: ffffffff 00000000 00000000 00000000 00000000 00000000 c7c4fac0=
 00000000
>> fde0: 00000000 c6c5d720 c7c4fac0 c006a3a4 c6f9fdf0 c6f9fdf0 c6f9e000=
 ffffffff
>> fe00: c6f9fe34 c7176b60 c7176b90 8511a8c0 c6f9fea8 00000408 c6f9fe44=
 c6f9fe28
>> fe20: c0209ff8 00000001 00000004 40ee9e04 40ee9e04 00000000 00000000=
 00000000
>> fe40: 00000400 c759bba0 00000000 00000000 c6f9ff20 00000500 00000000=
 00000000
>> fe60: 00000400 00000000 00000000 c03714a4 c6f9fef8 00000000 00000400=
 00093800
>> fe80: c6f9fea0 c76d45a0 c6f9e000 40ee9e84 c6f9ff70 c6f9fea0 c0206990=
 c0205a30
>> fea0: 03080002 c005d660 a0000093 00043887 c7d6a000 000002c0 c7d6a2c0=
 60000013
>> fec0: c6f9fedc c6f9fed0 c005dbc0 c005da94 c6f9ff34 c6f9fee0 c018455c=
 c005db90
>> fee0: 485a7d2d 00046731 00000400 c6f9ff10 c6f9fefc c024a130 c0059780=
 c76d45a0
>> ff00: 0000541b c6f9ff20 c6f9ff14 c024ff7c c024a0a8 c6f9ff3c c6f9ff24=
 c02052cc
>> ff20: c6f9fea0 00000080 c6f9ff3c 00000001 00000000 00000000 c00a8cf8=
 00093c00
>> ff40: 00000000 00000001 40ee9e9c 0000000c 00093800 00000400 00000066=
 c0038f84
>> ff60: 404fa2f0 c6f9ffa4 c6f9ff74 c0206e9c c0206908 40ee9e84 40ee9ea0=
 0000000a
>> ff80: 00093800 00000400 00000000 40ee9e84 40ee9ea0 000001c4 00000000=
 c6f9ffa8
>> ffa0: c0038de0 c0206d10 000001c4 00093800 0000000c 40ee9dd4 40eea56c=
 00000002
>> ffc0: 000001c4 00093800 00000400 0000000a 40ee9ea0 40ee9e84 404fa2f0=
 000350d0
>> ffe0: 00000000 40ee9dd0 4020fe74 40210808 80000010 0000000c 033a0000=
 8c020000
>> Backtrace:
>> [<c024a25c>] (udp_recvmsg+0x0/0x21c) from [<c0207468>] (sock_common_=
recvmsg+0x4)
>> [<c020741c>] (sock_common_recvmsg+0x0/0x60) from [<c0205ae0>] (sock_=
recvmsg+0xc)
>> =A0r5 =3D C7C4FAC0 =A0r4 =3D C6F9FDB0
>> [<c0205a20>] (sock_recvmsg+0x0/0xec) from [<c0206990>] (sys_recvfrom=
+0x98/0xf0)
>> [<c02068f8>] (sys_recvfrom+0x0/0xf0) from [<c0206e9c>] (sys_socketca=
ll+0x19c/0x)
>> [<c0206d00>] (sys_socketcall+0x0/0x1f0) from [<c0038de0>] (ret_fast_=
syscall+0x0)
>> =A0r4 =3D 000001C4
>> Code: e28a0008 e1d330b0 e3a01008 e1ca30b2 (e5943020)
>>
>>
>> I did the disassembly to find out exactly where the failure occurs. =
=A0I
>> put an asterisk by the address offset mentioned in the oops, but I
>> believe it's the next line down where it references the address wher=
e
>> it chokes.
>
> Yes I agree =A0(R3 + offset) chokes, not (r4 + offset)
> - Show quoted text -
>>
>> 00001ae4 <udp_recvmsg>:
>> =A0 =A0 1ae4: =A0 =A0 e1a0c00d =A0 =A0 =A0 =A0mov =A0 =A0 ip, sp
>> =A0 =A0 1ae8: =A0 =A0 e92ddff0 =A0 =A0 =A0 =A0stmdb =A0 sp!, {r4, r5=
, r6, r7, r8, r9, sl, fp, ip, lr, pc}
>> =A0 =A0 1aec: =A0 =A0 e24cb004 =A0 =A0 =A0 =A0sub =A0 =A0 fp, ip, #4=
 =A0 =A0 =A0; 0x4
>> =A0 =A0 1af0: =A0 =A0 e24dd010 =A0 =A0 =A0 =A0sub =A0 =A0 sp, sp, #1=
6 =A0 =A0 ; 0x10
>> =A0 =A0 1af4: =A0 =A0 e59b000c =A0 =A0 =A0 =A0ldr =A0 =A0 r0, [fp, #=
12]
>> =A0 =A0 1af8: =A0 =A0 e59b9008 =A0 =A0 =A0 =A0ldr =A0 =A0 r9, [fp, #=
8]
>> =A0 =A0 1afc: =A0 =A0 e3500000 =A0 =A0 =A0 =A0cmp =A0 =A0 r0, #0 =A0=
; 0x0
>> =A0 =A0 1b00: =A0 =A0 e1a08003 =A0 =A0 =A0 =A0mov =A0 =A0 r8, r3
>> =A0 =A0 1b04: =A0 =A0 13a03010 =A0 =A0 =A0 =A0movne =A0 r3, #16 ; 0x=
10
>> =A0 =A0 1b08: =A0 =A0 e592a000 =A0 =A0 =A0 =A0ldr =A0 =A0 sl, [r2]
>> =A0 =A0 1b0c: =A0 =A0 15803000 =A0 =A0 =A0 =A0strne =A0 r3, [r0]
>> =A0 =A0 1b10: =A0 =A0 e3190a02 =A0 =A0 =A0 =A0tst =A0 =A0 r9, #8192 =
=A0 =A0 =A0 ; 0x2000
>> =A0 =A0 1b14: =A0 =A0 e1a05002 =A0 =A0 =A0 =A0mov =A0 =A0 r5, r2
>> =A0 =A0 1b18: =A0 =A0 e1a06001 =A0 =A0 =A0 =A0mov =A0 =A0 r6, r1
>> =A0 =A0 1b1c: =A0 =A0 0a000004 =A0 =A0 =A0 =A0beq =A0 =A0 1b34 <udp_=
recvmsg+0x50>
>> =A0 =A0 1b20: =A0 =A0 e1a00001 =A0 =A0 =A0 =A0mov =A0 =A0 r0, r1
>> =A0 =A0 1b24: =A0 =A0 e1a01002 =A0 =A0 =A0 =A0mov =A0 =A0 r1, r2
>> =A0 =A0 1b28: =A0 =A0 e1a02008 =A0 =A0 =A0 =A0mov =A0 =A0 r2, r8
>> =A0 =A0 1b2c: =A0 =A0 ebfffffe =A0 =A0 =A0 =A0bl =A0 =A0 =A00 <ip_re=
cv_error>
>> =A0 =A0 1b30: =A0 =A0 ea00006e =A0 =A0 =A0 =A0b =A0 =A0 =A0 1cf0 <ud=
p_recvmsg+0x20c>
>> =A0 =A0 1b34: =A0 =A0 e1a01009 =A0 =A0 =A0 =A0mov =A0 =A0 r1, r9
>> =A0 =A0 1b38: =A0 =A0 e59b2004 =A0 =A0 =A0 =A0ldr =A0 =A0 r2, [fp, #=
4]
>> =A0 =A0 1b3c: =A0 =A0 e24b302c =A0 =A0 =A0 =A0sub =A0 =A0 r3, fp, #4=
4 =A0 =A0 ; 0x2c
>> =A0 =A0 1b40: =A0 =A0 e1a00006 =A0 =A0 =A0 =A0mov =A0 =A0 r0, r6
>> =A0 =A0 1b44: =A0 =A0 ebfffffe =A0 =A0 =A0 =A0bl =A0 =A0 =A00 <skb_r=
ecv_datagram>
>> =A0 =A0 1b48: =A0 =A0 e2504000 =A0 =A0 =A0 =A0subs =A0 =A0r4, r0, #0=
 =A0 =A0 =A0; 0x0
>> =A0 =A0 1b4c: =A0 =A0 e3a01008 =A0 =A0 =A0 =A0mov =A0 =A0 r1, #8 =A0=
; 0x8
>> =A0 =A0 1b50: =A0 =A0 0a000057 =A0 =A0 =A0 =A0beq =A0 =A0 1cb4 <udp_=
recvmsg+0x1d0>
>> =A0 =A0 1b54: =A0 =A0 e5943060 =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [r4, #=
96]
>> =A0 =A0 1b58: =A0 =A0 e2437008 =A0 =A0 =A0 =A0sub =A0 =A0 r7, r3, #8=
 =A0 =A0 =A0; 0x8
>> =A0 =A0 1b5c: =A0 =A0 e1570008 =A0 =A0 =A0 =A0cmp =A0 =A0 r7, r8
>> =A0 =A0 1b60: =A0 =A0 85953018 =A0 =A0 =A0 =A0ldrhi =A0 r3, [r5, #24=
]
>> =A0 =A0 1b64: =A0 =A0 81a07008 =A0 =A0 =A0 =A0movhi =A0 r7, r8
>> =A0 =A0 1b68: =A0 =A0 83833020 =A0 =A0 =A0 =A0orrhi =A0 r3, r3, #32 =
=A0 =A0 ; 0x20
>> =A0 =A0 1b6c: =A0 =A0 85853018 =A0 =A0 =A0 =A0strhi =A0 r3, [r5, #24=
]
>> =A0 =A0 1b70: =A0 =A0 e5d43074 =A0 =A0 =A0 =A0ldrb =A0 =A0r3, [r4, #=
116]
>> =A0 =A0 1b74: =A0 =A0 e203300c =A0 =A0 =A0 =A0and =A0 =A0 r3, r3, #1=
2 =A0 =A0 ; 0xc
>> =A0 =A0 1b78: =A0 =A0 e3530008 =A0 =A0 =A0 =A0cmp =A0 =A0 r3, #8 =A0=
; 0x8
>> =A0 =A0 1b7c: =A0 =A0 01a01003 =A0 =A0 =A0 =A0moveq =A0 r1, r3
>> =A0 =A0 1b80: =A0 =A0 0a000007 =A0 =A0 =A0 =A0beq =A0 =A0 1ba4 <udp_=
recvmsg+0xc0>
>> =A0 =A0 1b84: =A0 =A0 e5953018 =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [r5, #=
24]
>> =A0 =A0 1b88: =A0 =A0 e3130020 =A0 =A0 =A0 =A0tst =A0 =A0 r3, #32 ; =
0x20
>> =A0 =A0 1b8c: =A0 =A0 0a000009 =A0 =A0 =A0 =A0beq =A0 =A0 1bb8 <udp_=
recvmsg+0xd4>
>> =A0 =A0 1b90: =A0 =A0 ebfffffe =A0 =A0 =A0 =A0bl =A0 =A0 =A00 <__skb=
_checksum_complete>
>> =A0 =A0 1b94: =A0 =A0 e3500000 =A0 =A0 =A0 =A0cmp =A0 =A0 r0, #0 =A0=
; 0x0
>> =A0 =A0 1b98: =A0 =A0 1a000047 =A0 =A0 =A0 =A0bne =A0 =A0 1cbc <udp_=
recvmsg+0x1d8>
>> =A0 =A0 1b9c: =A0 =A0 e1a00004 =A0 =A0 =A0 =A0mov =A0 =A0 r0, r4
>> =A0 =A0 1ba0: =A0 =A0 e3a01008 =A0 =A0 =A0 =A0mov =A0 =A0 r1, #8 =A0=
; 0x8
>> =A0 =A0 1ba4: =A0 =A0 e5952008 =A0 =A0 =A0 =A0ldr =A0 =A0 r2, [r5, #=
8]
>> =A0 =A0 1ba8: =A0 =A0 e1a03007 =A0 =A0 =A0 =A0mov =A0 =A0 r3, r7
>> =A0 =A0 1bac: =A0 =A0 ebfffffe =A0 =A0 =A0 =A0bl =A0 =A0 =A00 <skb_c=
opy_datagram_iovec>
>> =A0 =A0 1bb0: =A0 =A0 e50b002c =A0 =A0 =A0 =A0str =A0 =A0 r0, [fp, #=
-44]
>> =A0 =A0 1bb4: =A0 =A0 ea000004 =A0 =A0 =A0 =A0b =A0 =A0 =A0 1bcc <ud=
p_recvmsg+0xe8>
>> =A0 =A0 1bb8: =A0 =A0 e5952008 =A0 =A0 =A0 =A0ldr =A0 =A0 r2, [r5, #=
8]
>> =A0 =A0 1bbc: =A0 =A0 ebfffffe =A0 =A0 =A0 =A0bl =A0 =A0 =A00 <skb_c=
opy_and_csum_datagram_iovec>
>> =A0 =A0 1bc0: =A0 =A0 e3700016 =A0 =A0 =A0 =A0cmn =A0 =A0 r0, #22 ; =
0x16
>> =A0 =A0 1bc4: =A0 =A0 e50b002c =A0 =A0 =A0 =A0str =A0 =A0 r0, [fp, #=
-44]
>> =A0 =A0 1bc8: =A0 =A0 0a00003b =A0 =A0 =A0 =A0beq =A0 =A0 1cbc <udp_=
recvmsg+0x1d8>
>> =A0 =A0 1bcc: =A0 =A0 e51b302c =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [fp, #=
-44]
>> =A0 =A0 1bd0: =A0 =A0 e3530000 =A0 =A0 =A0 =A0cmp =A0 =A0 r3, #0 =A0=
; 0x0
>> =A0 =A0 1bd4: =A0 =A0 1a000033 =A0 =A0 =A0 =A0bne =A0 =A0 1ca8 <udp_=
recvmsg+0x1c4>
>> =A0 =A0 1bd8: =A0 =A0 e594100c =A0 =A0 =A0 =A0ldr =A0 =A0 r1, [r4, #=
12]
>> =A0 =A0 1bdc: =A0 =A0 e5962094 =A0 =A0 =A0 =A0ldr =A0 =A0 r2, [r6, #=
148]
>> =A0 =A0 1be0: =A0 =A0 e50b1034 =A0 =A0 =A0 =A0str =A0 =A0 r1, [fp, #=
-52]
>> =A0 =A0 1be4: =A0 =A0 e5943010 =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [r4, #=
16]
>> =A0 =A0 1be8: =A0 =A0 e3120b02 =A0 =A0 =A0 =A0tst =A0 =A0 r2, #2048 =
=A0 =A0 =A0 ; 0x800
>> =A0 =A0 1bec: =A0 =A0 e50b3030 =A0 =A0 =A0 =A0str =A0 =A0 r3, [fp, #=
-48]
>> =A0 =A0 1bf0: =A0 =A0 0a00000f =A0 =A0 =A0 =A0beq =A0 =A0 1c34 <udp_=
recvmsg+0x150>
>> =A0 =A0 1bf4: =A0 =A0 e3510000 =A0 =A0 =A0 =A0cmp =A0 =A0 r1, #0 =A0=
; 0x0
>> =A0 =A0 1bf8: =A0 =A0 1a000001 =A0 =A0 =A0 =A0bne =A0 =A0 1c04 <udp_=
recvmsg+0x120>
>> =A0 =A0 1bfc: =A0 =A0 e24b0034 =A0 =A0 =A0 =A0sub =A0 =A0 r0, fp, #5=
2 =A0 =A0 ; 0x34
>> =A0 =A0 1c00: =A0 =A0 ebfffffe =A0 =A0 =A0 =A0bl =A0 =A0 =A00 <do_ge=
ttimeofday>
>> =A0 =A0 1c04: =A0 =A0 e51b3034 =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [fp, #=
-52]
>> =A0 =A0 1c08: =A0 =A0 e24bc034 =A0 =A0 =A0 =A0sub =A0 =A0 ip, fp, #5=
2 =A0 =A0 ; 0x34
>> =A0 =A0 1c0c: =A0 =A0 e584300c =A0 =A0 =A0 =A0str =A0 =A0 r3, [r4, #=
12]
>> =A0 =A0 1c10: =A0 =A0 e51b3030 =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [fp, #=
-48]
>> =A0 =A0 1c14: =A0 =A0 e1a00005 =A0 =A0 =A0 =A0mov =A0 =A0 r0, r5
>> =A0 =A0 1c18: =A0 =A0 e5843010 =A0 =A0 =A0 =A0str =A0 =A0 r3, [r4, #=
16]
>> =A0 =A0 1c1c: =A0 =A0 e3a01001 =A0 =A0 =A0 =A0mov =A0 =A0 r1, #1 =A0=
; 0x1
>> =A0 =A0 1c20: =A0 =A0 e3a0201d =A0 =A0 =A0 =A0mov =A0 =A0 r2, #29 ; =
0x1d
>> =A0 =A0 1c24: =A0 =A0 e3a03008 =A0 =A0 =A0 =A0mov =A0 =A0 r3, #8 =A0=
; 0x8
>> =A0 =A0 1c28: =A0 =A0 e58dc000 =A0 =A0 =A0 =A0str =A0 =A0 ip, [sp]
>> =A0 =A0 1c2c: =A0 =A0 ebfffffe =A0 =A0 =A0 =A0bl =A0 =A0 =A00 <put_c=
msg>
>> =A0 =A0 1c30: =A0 =A0 ea000003 =A0 =A0 =A0 =A0b =A0 =A0 =A0 1c44 <ud=
p_recvmsg+0x160>
>> =A0 =A0 1c34: =A0 =A0 e24b2034 =A0 =A0 =A0 =A0sub =A0 =A0 r2, fp, #5=
2 =A0 =A0 ; 0x34
>> =A0 =A0 1c38: =A0 =A0 e892000c =A0 =A0 =A0 =A0ldmia =A0 r2, {r2, r3}
>> =A0 =A0 1c3c: =A0 =A0 e58620f8 =A0 =A0 =A0 =A0str =A0 =A0 r2, [r6, #=
248]
>> =A0 =A0 1c40: =A0 =A0 e58630fc =A0 =A0 =A0 =A0str =A0 =A0 r3, [r6, #=
252]
>> =A0 =A0 1c44: =A0 =A0 e35a0000 =A0 =A0 =A0 =A0cmp =A0 =A0 sl, #0 =A0=
; 0x0
>>
>>
>> =A0 =A0 1c48: =A0 =A0 0a00000a =A0 =A0 =A0 =A0beq =A0 =A0 1c78 <udp_=
recvmsg+0x194>
>> =A0 =A0 1c4c: =A0 =A0 e3a03002 =A0 =A0 =A0 =A0mov =A0 =A0 r3, #2 =A0=
; 0x2
>> =A0 =A0 1c50: =A0 =A0 e1ca30b0 =A0 =A0 =A0 =A0strh =A0 =A0r3, [sl]
>> =A0 =A0 1c54: =A0 =A0 e594301c =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [r4, #=
28]
>> =A0 =A0 1c58: =A0 =A0 e28a0008 =A0 =A0 =A0 =A0add =A0 =A0 r0, sl, #8=
 =A0 =A0 =A0; 0x8
>> =A0 =A0 1c5c: =A0 =A0 e1d330b0 =A0 =A0 =A0 =A0ldrh =A0 =A0r3, [r3]
>> =A0 =A0 1c60: =A0 =A0 e3a01008 =A0 =A0 =A0 =A0mov =A0 =A0 r1, #8 =A0=
; 0x8
>> =A0 =A0 1c64: =A0 =A0 e1ca30b2 =A0 =A0 =A0 =A0strh =A0 =A0r3, [sl, #=
2]
>> * =A0 =A01c68: =A0 =A0e5943020 =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [r4, #=
32]
>> =A0 =A0 1c6c: =A0 =A0 e593300c =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [r3, #=
12]
>> =A0 =A0 1c70: =A0 =A0 e58a3004 =A0 =A0 =A0 =A0str =A0 =A0 r3, [sl, #=
4]
>> =A0 =A0 1c74: =A0 =A0 ebfffffe =A0 =A0 =A0 =A0bl =A0 =A0 =A00 <__mem=
zero>
>> =A0 =A0 1c78: =A0 =A0 e59f3078 =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [pc, #=
120] =A0; 1cf8 <.text+0x1cf8>
>> =A0 =A0 1c7c: =A0 =A0 e19630b3 =A0 =A0 =A0 =A0ldrh =A0 =A0r3, [r6, r=
3]
>>
>>
>> =A0 =A0 1c80: =A0 =A0 e3530000 =A0 =A0 =A0 =A0cmp =A0 =A0 r3, #0 =A0=
; 0x0
>> =A0 =A0 1c84: =A0 =A0 0a000002 =A0 =A0 =A0 =A0beq =A0 =A0 1c94 <udp_=
recvmsg+0x1b0>
>> =A0 =A0 1c88: =A0 =A0 e1a00005 =A0 =A0 =A0 =A0mov =A0 =A0 r0, r5
>> =A0 =A0 1c8c: =A0 =A0 e1a01004 =A0 =A0 =A0 =A0mov =A0 =A0 r1, r4
>> =A0 =A0 1c90: =A0 =A0 ebfffffe =A0 =A0 =A0 =A0bl =A0 =A0 =A00 <ip_cm=
sg_recv>
>> =A0 =A0 1c94: =A0 =A0 e3190020 =A0 =A0 =A0 =A0tst =A0 =A0 r9, #32 ; =
0x20
>> =A0 =A0 1c98: =A0 =A0 e50b702c =A0 =A0 =A0 =A0str =A0 =A0 r7, [fp, #=
-44]
>> =A0 =A0 1c9c: =A0 =A0 15943060 =A0 =A0 =A0 =A0ldrne =A0 r3, [r4, #96=
]
>> =A0 =A0 1ca0: =A0 =A0 12433008 =A0 =A0 =A0 =A0subne =A0 r3, r3, #8 =A0=
 =A0 =A0; 0x8
>> =A0 =A0 1ca4: =A0 =A0 150b302c =A0 =A0 =A0 =A0strne =A0 r3, [fp, #-4=
4]
>> =A0 =A0 1ca8: =A0 =A0 e1a00006 =A0 =A0 =A0 =A0mov =A0 =A0 r0, r6
>> =A0 =A0 1cac: =A0 =A0 e1a01004 =A0 =A0 =A0 =A0mov =A0 =A0 r1, r4
>> =A0 =A0 1cb0: =A0 =A0 ebfffffe =A0 =A0 =A0 =A0bl =A0 =A0 =A00 <skb_f=
ree_datagram>
>> =A0 =A0 1cb4: =A0 =A0 e51b002c =A0 =A0 =A0 =A0ldr =A0 =A0 r0, [fp, #=
-44]
>> =A0 =A0 1cb8: =A0 =A0 ea00000c =A0 =A0 =A0 =A0b =A0 =A0 =A0 1cf0 <ud=
p_recvmsg+0x20c>
>> =A0 =A0 1cbc: =A0 =A0 e59f3038 =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [pc, #=
56] =A0 ; 1cfc <.text+0x1cfc>
>> =A0 =A0 1cc0: =A0 =A0 e1a02009 =A0 =A0 =A0 =A0mov =A0 =A0 r2, r9
>> =A0 =A0 1cc4: =A0 =A0 e593c000 =A0 =A0 =A0 =A0ldr =A0 =A0 ip, [r3]
>> =A0 =A0 1cc8: =A0 =A0 e1a01004 =A0 =A0 =A0 =A0mov =A0 =A0 r1, r4
>> =A0 =A0 1ccc: =A0 =A0 e59c300c =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [ip, #=
12]
>> =A0 =A0 1cd0: =A0 =A0 e1a00006 =A0 =A0 =A0 =A0mov =A0 =A0 r0, r6
>> =A0 =A0 1cd4: =A0 =A0 e2833001 =A0 =A0 =A0 =A0add =A0 =A0 r3, r3, #1=
 =A0 =A0 =A0; 0x1
>> =A0 =A0 1cd8: =A0 =A0 e58c300c =A0 =A0 =A0 =A0str =A0 =A0 r3, [ip, #=
12]
>> =A0 =A0 1cdc: =A0 =A0 ebfffffe =A0 =A0 =A0 =A0bl =A0 =A0 =A00 <skb_k=
ill_datagram>
>> =A0 =A0 1ce0: =A0 =A0 e59b2004 =A0 =A0 =A0 =A0ldr =A0 =A0 r2, [fp, #=
4]
>> =A0 =A0 1ce4: =A0 =A0 e3520000 =A0 =A0 =A0 =A0cmp =A0 =A0 r2, #0 =A0=
; 0x0
>> =A0 =A0 1ce8: =A0 =A0 0affff91 =A0 =A0 =A0 =A0beq =A0 =A0 1b34 <udp_=
recvmsg+0x50>
>> =A0 =A0 1cec: =A0 =A0 e3e0000a =A0 =A0 =A0 =A0mvn =A0 =A0 r0, #10 ; =
0xa
>> =A0 =A0 1cf0: =A0 =A0 e24bd028 =A0 =A0 =A0 =A0sub =A0 =A0 sp, fp, #4=
0 =A0 =A0 ; 0x28
>> =A0 =A0 1cf4: =A0 =A0 e89daff0 =A0 =A0 =A0 =A0ldmia =A0 sp, {r4, r5,=
 r6, r7, r8, r9, sl, fp, sp, pc}
>> =A0 =A0 1cf8: =A0 =A0 00000146 =A0 =A0 =A0 =A0andeq =A0 r0, r0, r6, =
asr #2
>> =A0 =A0 1cfc: =A0 =A0 00000000 =A0 =A0 =A0 =A0andeq =A0 r0, r0, r0
>>
>>
>> In the udp_recvmsg() function, the fault occurs in this code:
>> =A0 =A0 =A0 /* Copy the address. */
>> =A0 =A0 =A0 if (sin)
>> =A0 =A0 =A0 {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sin->sin_family =3D AF_INET;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sin->sin_port =3D skb->h.uh->source;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sin->sin_addr.s_addr =3D skb->nh.iph->sa=
ddr; =A0// <- failure accessing
>> memory at saddr
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(sin->sin_zero, 0, sizeof(sin->sin=
_zero));
>> =A0 =A0 =A0 }
>>
>>
>> After reviewing the assembly and the source code, it looks like the
>> address "c6f9202a" is where it thinks saddr should be. =A0Ideally, I=
'd
>
> This address is not aligned to a word (multiple of 4), which seems st=
range...
>
> Maybe ARM doesnt handle unaligned accesses ?
>
>
> =A0 =A01c48: =A0 =A0 =A0 0a00000a =A0 =A0 =A0 =A0beq =A0 =A0 1c78 <ud=
p_recvmsg+0x194>
> =A0 =A01c4c: =A0 =A0 =A0 e3a03002 =A0 =A0 =A0 =A0mov =A0 =A0 r3, #2 =A0=
; 0x2
> =A0 =A01c50: =A0 =A0 =A0 e1ca30b0 =A0 =A0 =A0 =A0strh =A0 =A0r3, [sl]
> =A0 =A01c54: =A0 =A0 =A0 e594301c =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [r4,=
 #28] =A0 =A0 =A0 skb->h.uh (udp hdr) =A0OK
> =A0 =A01c58: =A0 =A0 =A0 e28a0008 =A0 =A0 =A0 =A0add =A0 =A0 r0, sl, =
#8 =A0 =A0 =A0; 0x8
> =A0 =A01c5c: =A0 =A0 =A0 e1d330b0 =A0 =A0 =A0 =A0ldrh =A0 =A0r3, [r3]
> =A0 =A01c60: =A0 =A0 =A0 e3a01008 =A0 =A0 =A0 =A0mov =A0 =A0 r1, #8 =A0=
; 0x8
> =A0 =A01c64: =A0 =A0 =A0 e1ca30b2 =A0 =A0 =A0 =A0strh =A0 =A0r3, [sl,=
 #2]
> * =A0 =A01c68: =A0 =A0 =A0e5943020 =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [r4=
, #32] =A0 skb->nh.iph =A0(IP header) OK
> =A0 =A01c6c: =A0 =A0 =A0 e593300c =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [r3,=
 #12] =A0 but (R+12) is unaligned
> =A0 =A01c70: =A0 =A0 =A0 e58a3004 =A0 =A0 =A0 =A0str =A0 =A0 r3, [sl,=
 #4]
> =A0 =A01c74: =A0 =A0 =A0 ebfffffe =A0 =A0 =A0 =A0bl =A0 =A0 =A00 <__m=
emzero>
> =A0 =A01c78: =A0 =A0 =A0 e59f3078 =A0 =A0 =A0 =A0ldr =A0 =A0 r3, [pc,=
 #120] =A0; 1cf8 <.text+0x1cf8>
> =A0 =A01c7c: =A0 =A0 =A0 e19630b3 =A0 =A0 =A0 =A0ldrh =A0 =A0r3, [r6,=
 r3]
>
> What is your NIC driver ?
> - Show quoted text -
>> like to figure out how to solve the problem. =A0From ifconfig, I'm
>> finding a few errors with overruns, so maybe the queue is wrapping
>> around and clobbering the sk_buffs.
>>
>> eth0 =A0 =A0 =A0Link encap:Ethernet =A0HWaddr 00:00:D0:D0:DA:D2
>> =A0 =A0 =A0 =A0 =A0 inet addr:192.168.17.133 =A0Bcast:192.168.17.255=
 =A0Mask:255.255.255.0
>> =A0 =A0 =A0 =A0 =A0 UP BROADCAST RUNNING MULTICAST =A0MTU:1500 =A0Me=
tric:1
>> =A0 =A0 =A0 =A0 =A0 RX packets:440979642 errors:8 dropped:0 overruns=
:8 frame:0
>> =A0 =A0 =A0 =A0 =A0 TX packets:601998 errors:0 dropped:0 overruns:0 =
carrier:0
>> =A0 =A0 =A0 =A0 =A0 collisions:0 txqueuelen:1000
>> =A0 =A0 =A0 =A0 =A0 RX bytes:2838009823 (2.6 GiB) =A0TX bytes:155320=
893 (148.1 MiB)
>> =A0 =A0 =A0 =A0 =A0 Base address:0xb000
>>
>> I'd also be willing to settle for a short term solution of finding a
>> way to test whether it's safe to dereference that pointer, and
>> skipping that sk_buff if it's bad.
>
>

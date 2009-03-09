From: Ron Yorgason <yorgasor@gmail.com>
Subject: Kernel Oops in UDP w/ ARM architecture
Date: Mon, 9 Mar 2009 10:52:20 -0500
Message-ID: <93d1fdd10903090852g268b4141h31dc39a5848fcf32@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f122.google.com ([209.85.221.122]:60401 "EHLO
	mail-qy0-f122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbZCIPwY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 11:52:24 -0400
Received: by qyk28 with SMTP id 28so1154998qyk.33
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2009 08:52:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm working on an embedded video streaming application using gstreamer
over RTP/UDP on a Freescale iMX27 ARM platform.=A0 I have one board
doing the video capture and compression, and streaming it across the
network to another board which does the decoding and display.=A0 I'm
stuck right now with a kernel oops we're getting.=A0 It usually occurs
within 2-6 hours, but sometimes it takes longer for it to happen.=A0 I
believe it always dies with the same address in the failure.

I'm using a 2.6.19.2 kernel release.  I don't know if this problem has
already been found and fixed in a future release (I didn't see any
mention of it in the changelogs of the next few releases), but this is
a customized kernel and I don't know how feasible it would be to port
all the changes to a newer kernel.  We haven't touched the networking
stack, so it's most likely this bug is in the stock release.

Unable to handle kernel paging request at virtual address c6f9202a
pgd =3D c6d7c000
[c6f9202a] *pgd=3Da6e0041e(bad)
Internal error: Oops: 1 [#3]
Modules linked in:
CPU: 0
PC is at udp_recvmsg+0x184/0x21c
LR is at 0xf2799669
pc : [<c024a3e0>]=A0=A0=A0 lr : [<f2799669>]=A0=A0=A0 Not tainted
sp : c6f9fd48=A0 ip : 00000000=A0 fp : c6f9fd80
r10: c6f9fea0=A0 r9 : 00000000=A0 r8 : 00000400
r7 : 00000400=A0 r6 : c7a52200=A0 r5 : c6f9ff20=A0 r4 : c6291780
r3 : c6f9201e=A0 r2 : 00000000=A0 r1 : 00000008=A0 r0 : c6f9fea8
=46lags: NzCv=A0 IRQs on=A0 FIQs on=A0 Mode SVC_32=A0 Segment user
Control: 5317F
Table: A6D7C000=A0 DAC: 00000015
Process gst-launch-0.10 (pid: 18165, stack limit =3D 0xc6f9e250)
Stack: (0xc6f9fd48 to 0xc6fa0000)
fd40:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 00000001 00=
000000 00000000 00000000 c02fbb80 c6f9ff20
fd60: c6f9ff20 00000400 00000000 00000000 00000000 c6f9fda8 c6f9fd84 c0=
207468
fd80: c024a26c 00000000 00000000 c6f9fd90 00000010 c6f9fdb0 c7c4fac0 c6=
f9fe9c
fda0: c6f9fdac c0205ae0 c020742c 00000000 c02e06c8 00000001 00000000 00=
000001
fdc0: ffffffff 00000000 00000000 00000000 00000000 00000000 c7c4fac0 00=
000000
fde0: 00000000 c6c5d720 c7c4fac0 c006a3a4 c6f9fdf0 c6f9fdf0 c6f9e000 ff=
ffffff
fe00: c6f9fe34 c7176b60 c7176b90 8511a8c0 c6f9fea8 00000408 c6f9fe44 c6=
f9fe28
fe20: c0209ff8 00000001 00000004 40ee9e04 40ee9e04 00000000 00000000 00=
000000
fe40: 00000400 c759bba0 00000000 00000000 c6f9ff20 00000500 00000000 00=
000000
fe60: 00000400 00000000 00000000 c03714a4 c6f9fef8 00000000 00000400 00=
093800
fe80: c6f9fea0 c76d45a0 c6f9e000 40ee9e84 c6f9ff70 c6f9fea0 c0206990 c0=
205a30
fea0: 03080002 c005d660 a0000093 00043887 c7d6a000 000002c0 c7d6a2c0 60=
000013
fec0: c6f9fedc c6f9fed0 c005dbc0 c005da94 c6f9ff34 c6f9fee0 c018455c c0=
05db90
fee0: 485a7d2d 00046731 00000400 c6f9ff10 c6f9fefc c024a130 c0059780 c7=
6d45a0
ff00: 0000541b c6f9ff20 c6f9ff14 c024ff7c c024a0a8 c6f9ff3c c6f9ff24 c0=
2052cc
ff20: c6f9fea0 00000080 c6f9ff3c 00000001 00000000 00000000 c00a8cf8 00=
093c00
ff40: 00000000 00000001 40ee9e9c 0000000c 00093800 00000400 00000066 c0=
038f84
ff60: 404fa2f0 c6f9ffa4 c6f9ff74 c0206e9c c0206908 40ee9e84 40ee9ea0 00=
00000a
ff80: 00093800 00000400 00000000 40ee9e84 40ee9ea0 000001c4 00000000 c6=
f9ffa8
ffa0: c0038de0 c0206d10 000001c4 00093800 0000000c 40ee9dd4 40eea56c 00=
000002
ffc0: 000001c4 00093800 00000400 0000000a 40ee9ea0 40ee9e84 404fa2f0 00=
0350d0
ffe0: 00000000 40ee9dd0 4020fe74 40210808 80000010 0000000c 033a0000 8c=
020000
Backtrace:
[<c024a25c>] (udp_recvmsg+0x0/0x21c) from [<c0207468>] (sock_common_rec=
vmsg+0x4)
[<c020741c>] (sock_common_recvmsg+0x0/0x60) from [<c0205ae0>] (sock_rec=
vmsg+0xc)
=A0r5 =3D C7C4FAC0=A0 r4 =3D C6F9FDB0
[<c0205a20>] (sock_recvmsg+0x0/0xec) from [<c0206990>] (sys_recvfrom+0x=
98/0xf0)
[<c02068f8>] (sys_recvfrom+0x0/0xf0) from [<c0206e9c>] (sys_socketcall+=
0x19c/0x)
[<c0206d00>] (sys_socketcall+0x0/0x1f0) from [<c0038de0>] (ret_fast_sys=
call+0x0)
=A0r4 =3D 000001C4
Code: e28a0008 e1d330b0 e3a01008 e1ca30b2 (e5943020)


I did the disassembly to find out exactly where the failure occurs.  I
put an asterisk by the address offset mentioned in the oops, but I
believe it's the next line down where it references the address where
it chokes.

00001ae4 <udp_recvmsg>:
    1ae4:	e1a0c00d 	mov	ip, sp
    1ae8:	e92ddff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, ip, lr,=
 pc}
    1aec:	e24cb004 	sub	fp, ip, #4	; 0x4
    1af0:	e24dd010 	sub	sp, sp, #16	; 0x10
    1af4:	e59b000c 	ldr	r0, [fp, #12]
    1af8:	e59b9008 	ldr	r9, [fp, #8]
    1afc:	e3500000 	cmp	r0, #0	; 0x0
    1b00:	e1a08003 	mov	r8, r3
    1b04:	13a03010 	movne	r3, #16	; 0x10
    1b08:	e592a000 	ldr	sl, [r2]
    1b0c:	15803000 	strne	r3, [r0]
    1b10:	e3190a02 	tst	r9, #8192	; 0x2000
    1b14:	e1a05002 	mov	r5, r2
    1b18:	e1a06001 	mov	r6, r1
    1b1c:	0a000004 	beq	1b34 <udp_recvmsg+0x50>
    1b20:	e1a00001 	mov	r0, r1
    1b24:	e1a01002 	mov	r1, r2
    1b28:	e1a02008 	mov	r2, r8
    1b2c:	ebfffffe 	bl	0 <ip_recv_error>
    1b30:	ea00006e 	b	1cf0 <udp_recvmsg+0x20c>
    1b34:	e1a01009 	mov	r1, r9
    1b38:	e59b2004 	ldr	r2, [fp, #4]
    1b3c:	e24b302c 	sub	r3, fp, #44	; 0x2c
    1b40:	e1a00006 	mov	r0, r6
    1b44:	ebfffffe 	bl	0 <skb_recv_datagram>
    1b48:	e2504000 	subs	r4, r0, #0	; 0x0
    1b4c:	e3a01008 	mov	r1, #8	; 0x8
    1b50:	0a000057 	beq	1cb4 <udp_recvmsg+0x1d0>
    1b54:	e5943060 	ldr	r3, [r4, #96]
    1b58:	e2437008 	sub	r7, r3, #8	; 0x8
    1b5c:	e1570008 	cmp	r7, r8
    1b60:	85953018 	ldrhi	r3, [r5, #24]
    1b64:	81a07008 	movhi	r7, r8
    1b68:	83833020 	orrhi	r3, r3, #32	; 0x20
    1b6c:	85853018 	strhi	r3, [r5, #24]
    1b70:	e5d43074 	ldrb	r3, [r4, #116]
    1b74:	e203300c 	and	r3, r3, #12	; 0xc
    1b78:	e3530008 	cmp	r3, #8	; 0x8
    1b7c:	01a01003 	moveq	r1, r3
    1b80:	0a000007 	beq	1ba4 <udp_recvmsg+0xc0>
    1b84:	e5953018 	ldr	r3, [r5, #24]
    1b88:	e3130020 	tst	r3, #32	; 0x20
    1b8c:	0a000009 	beq	1bb8 <udp_recvmsg+0xd4>
    1b90:	ebfffffe 	bl	0 <__skb_checksum_complete>
    1b94:	e3500000 	cmp	r0, #0	; 0x0
    1b98:	1a000047 	bne	1cbc <udp_recvmsg+0x1d8>
    1b9c:	e1a00004 	mov	r0, r4
    1ba0:	e3a01008 	mov	r1, #8	; 0x8
    1ba4:	e5952008 	ldr	r2, [r5, #8]
    1ba8:	e1a03007 	mov	r3, r7
    1bac:	ebfffffe 	bl	0 <skb_copy_datagram_iovec>
    1bb0:	e50b002c 	str	r0, [fp, #-44]
    1bb4:	ea000004 	b	1bcc <udp_recvmsg+0xe8>
    1bb8:	e5952008 	ldr	r2, [r5, #8]
    1bbc:	ebfffffe 	bl	0 <skb_copy_and_csum_datagram_iovec>
    1bc0:	e3700016 	cmn	r0, #22	; 0x16
    1bc4:	e50b002c 	str	r0, [fp, #-44]
    1bc8:	0a00003b 	beq	1cbc <udp_recvmsg+0x1d8>
    1bcc:	e51b302c 	ldr	r3, [fp, #-44]
    1bd0:	e3530000 	cmp	r3, #0	; 0x0
    1bd4:	1a000033 	bne	1ca8 <udp_recvmsg+0x1c4>
    1bd8:	e594100c 	ldr	r1, [r4, #12]
    1bdc:	e5962094 	ldr	r2, [r6, #148]
    1be0:	e50b1034 	str	r1, [fp, #-52]
    1be4:	e5943010 	ldr	r3, [r4, #16]
    1be8:	e3120b02 	tst	r2, #2048	; 0x800
    1bec:	e50b3030 	str	r3, [fp, #-48]
    1bf0:	0a00000f 	beq	1c34 <udp_recvmsg+0x150>
    1bf4:	e3510000 	cmp	r1, #0	; 0x0
    1bf8:	1a000001 	bne	1c04 <udp_recvmsg+0x120>
    1bfc:	e24b0034 	sub	r0, fp, #52	; 0x34
    1c00:	ebfffffe 	bl	0 <do_gettimeofday>
    1c04:	e51b3034 	ldr	r3, [fp, #-52]
    1c08:	e24bc034 	sub	ip, fp, #52	; 0x34
    1c0c:	e584300c 	str	r3, [r4, #12]
    1c10:	e51b3030 	ldr	r3, [fp, #-48]
    1c14:	e1a00005 	mov	r0, r5
    1c18:	e5843010 	str	r3, [r4, #16]
    1c1c:	e3a01001 	mov	r1, #1	; 0x1
    1c20:	e3a0201d 	mov	r2, #29	; 0x1d
    1c24:	e3a03008 	mov	r3, #8	; 0x8
    1c28:	e58dc000 	str	ip, [sp]
    1c2c:	ebfffffe 	bl	0 <put_cmsg>
    1c30:	ea000003 	b	1c44 <udp_recvmsg+0x160>
    1c34:	e24b2034 	sub	r2, fp, #52	; 0x34
    1c38:	e892000c 	ldmia	r2, {r2, r3}
    1c3c:	e58620f8 	str	r2, [r6, #248]
    1c40:	e58630fc 	str	r3, [r6, #252]
    1c44:	e35a0000 	cmp	sl, #0	; 0x0


    1c48:	0a00000a 	beq	1c78 <udp_recvmsg+0x194>
    1c4c:	e3a03002 	mov	r3, #2	; 0x2
    1c50:	e1ca30b0 	strh	r3, [sl]
    1c54:	e594301c 	ldr	r3, [r4, #28]
    1c58:	e28a0008 	add	r0, sl, #8	; 0x8
    1c5c:	e1d330b0 	ldrh	r3, [r3]
    1c60:	e3a01008 	mov	r1, #8	; 0x8
    1c64:	e1ca30b2 	strh	r3, [sl, #2]
*    1c68:	e5943020 	ldr	r3, [r4, #32]
    1c6c:	e593300c 	ldr	r3, [r3, #12]
    1c70:	e58a3004 	str	r3, [sl, #4]
    1c74:	ebfffffe 	bl	0 <__memzero>
    1c78:	e59f3078 	ldr	r3, [pc, #120]	; 1cf8 <.text+0x1cf8>
    1c7c:	e19630b3 	ldrh	r3, [r6, r3]


    1c80:	e3530000 	cmp	r3, #0	; 0x0
    1c84:	0a000002 	beq	1c94 <udp_recvmsg+0x1b0>
    1c88:	e1a00005 	mov	r0, r5
    1c8c:	e1a01004 	mov	r1, r4
    1c90:	ebfffffe 	bl	0 <ip_cmsg_recv>
    1c94:	e3190020 	tst	r9, #32	; 0x20
    1c98:	e50b702c 	str	r7, [fp, #-44]
    1c9c:	15943060 	ldrne	r3, [r4, #96]
    1ca0:	12433008 	subne	r3, r3, #8	; 0x8
    1ca4:	150b302c 	strne	r3, [fp, #-44]
    1ca8:	e1a00006 	mov	r0, r6
    1cac:	e1a01004 	mov	r1, r4
    1cb0:	ebfffffe 	bl	0 <skb_free_datagram>
    1cb4:	e51b002c 	ldr	r0, [fp, #-44]
    1cb8:	ea00000c 	b	1cf0 <udp_recvmsg+0x20c>
    1cbc:	e59f3038 	ldr	r3, [pc, #56]	; 1cfc <.text+0x1cfc>
    1cc0:	e1a02009 	mov	r2, r9
    1cc4:	e593c000 	ldr	ip, [r3]
    1cc8:	e1a01004 	mov	r1, r4
    1ccc:	e59c300c 	ldr	r3, [ip, #12]
    1cd0:	e1a00006 	mov	r0, r6
    1cd4:	e2833001 	add	r3, r3, #1	; 0x1
    1cd8:	e58c300c 	str	r3, [ip, #12]
    1cdc:	ebfffffe 	bl	0 <skb_kill_datagram>
    1ce0:	e59b2004 	ldr	r2, [fp, #4]
    1ce4:	e3520000 	cmp	r2, #0	; 0x0
    1ce8:	0affff91 	beq	1b34 <udp_recvmsg+0x50>
    1cec:	e3e0000a 	mvn	r0, #10	; 0xa
    1cf0:	e24bd028 	sub	sp, fp, #40	; 0x28
    1cf4:	e89daff0 	ldmia	sp, {r4, r5, r6, r7, r8, r9, sl, fp, sp, pc}
    1cf8:	00000146 	andeq	r0, r0, r6, asr #2
    1cfc:	00000000 	andeq	r0, r0, r0


In the udp_recvmsg() function, the fault occurs in this code:
	/* Copy the address. */
	if (sin)
	{
		sin->sin_family =3D AF_INET;
		sin->sin_port =3D skb->h.uh->source;
		sin->sin_addr.s_addr =3D skb->nh.iph->saddr;  // <- failure accessing
memory at saddr
		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
  	}


After reviewing the assembly and the source code, it looks like the
address "c6f9202a" is where it thinks saddr should be.  Ideally, I'd
like to figure out how to solve the problem.  From ifconfig, I'm
finding a few errors with overruns, so maybe the queue is wrapping
around and clobbering the sk_buffs.

eth0      Link encap:Ethernet  HWaddr 00:00:D0:D0:DA:D2
          inet addr:192.168.17.133  Bcast:192.168.17.255  Mask:255.255.=
255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:440979642 errors:8 dropped:0 overruns:8 frame:0
          TX packets:601998 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:2838009823 (2.6 GiB)  TX bytes:155320893 (148.1 MiB)
          Base address:0xb000

I'd also be willing to settle for a short term solution of finding a
way to test whether it's safe to dereference that pointer, and
skipping that sk_buff if it's bad.

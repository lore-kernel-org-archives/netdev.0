From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel Panic every 2 weeks on ISP server (NULL pointer
 dereference)
Date: Mon, 24 Oct 2011 20:21:04 +0200
Message-ID: <1319480464.3064.6.camel@edumazet-laptop>
References: <201110222218.12524.lruete@sequre.com.ar>
	 <1319346989.6180.71.camel@edumazet-laptop>
	 <201110241509.14027.lruete@sequre.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Luciano Ruete <lruete@sequre.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54948 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933052Ab1JXSVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 14:21:09 -0400
Received: by wyg36 with SMTP id 36so6485154wyg.19
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2011 11:21:08 -0700 (PDT)
In-Reply-To: <201110241509.14027.lruete@sequre.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 24 octobre 2011 =C3=A0 15:09 -0300, Luciano Ruete a =C3=A9crit=
 :

> Hi Eric!
>=20
> Thanks for your answer...
>=20
> >=20
> > [694250.472081] Code: f6
> > 49 c1 e6 07          shl    $0x7,%r14
> > 66 89 93 ac 00 00 00 mov    %dx,0xac(%rbx)
> >[...]
> > This looks like a dev_pick_tx() bug, using an out of bound
> > queue_index number and returning a txq pointing after
> > the device allocated array.
>=20
> Clear explanation, is there a tool to map the trace to kernel code, o=
r you did=20
> this by hand?=20
>=20

In kernek source, you can find scripts/decodecode

# cat CRASH | scripts/decodecode=20
[694250.472081] Code: f6 49 c1 e6 07 66 89 93 ac 00 00 00 4d 03 b5 40 0=
3 00 00 0f b7 83 a6 00 00 00 4d 8b 66 08 80 e4 cf 80 cc 20 66 89 83 a6 =
00 00 00 <49> 83 3c 24 00 0f 84 3b 02 00 00 49 8d 84 24 9c 00 00 00 48 =
89
All code
=3D=3D=3D=3D=3D=3D=3D=3D
   0:	f6                   	(bad) =20
   1:	49 c1 e6 07          	shl    $0x7,%r14
   5:	66 89 93 ac 00 00 00 	mov    %dx,0xac(%rbx)
   c:	4d 03 b5 40 03 00 00 	add    0x340(%r13),%r14
  13:	0f b7 83 a6 00 00 00 	movzwl 0xa6(%rbx),%eax
  1a:	4d 8b 66 08          	mov    0x8(%r14),%r12
  1e:	80 e4 cf             	and    $0xcf,%ah
  21:	80 cc 20             	or     $0x20,%ah
  24:	66 89 83 a6 00 00 00 	mov    %ax,0xa6(%rbx)
  2b:*	49 83 3c 24 00       	cmpq   $0x0,(%r12)     <-- trapping instru=
ction
  30:	0f 84 3b 02 00 00    	je     0x271
  36:	49 8d 84 24 9c 00 00 	lea    0x9c(%r12),%rax
  3d:	00=20
  3e:	48                   	rex.W
  3f:	89                   	.byte 0x89

Code starting with the faulting instruction
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
   0:	49 83 3c 24 00       	cmpq   $0x0,(%r12)
   5:	0f 84 3b 02 00 00    	je     0x246
   b:	49 8d 84 24 9c 00 00 	lea    0x9c(%r12),%rax
  12:	00=20
  13:	48                   	rex.W
  14:	89                   	.byte 0x89

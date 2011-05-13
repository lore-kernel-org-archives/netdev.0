From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel BUG at net/ipv4/tcp_output.c:1006!
Date: Fri, 13 May 2011 21:47:38 +0200
Message-ID: <1305316058.3120.6.camel@edumazet-laptop>
References: <4DCD6658.3020901@techboom.com>
	 <1305307633.3866.61.camel@edumazet-laptop>  <4DCD86C0.9030904@techboom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: TB <lkml@techboom.com>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DCD86C0.9030904@techboom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 13 mai 2011 =C3=A0 15:30 -0400, TB a =C3=A9crit :
> On 11-05-13 01:27 PM, Eric Dumazet wrote:
> > Le vendredi 13 mai 2011 =C3=A0 13:11 -0400, TB a =C3=A9crit :
> >> This is the 2.6.38.5 kernel with the patch in
> >> [PATCH] tcp_cubic: limit delayed_ack ratio to prevent divide error
> >>
> >=20
> > Please send us full disassembly of tcp_fragment (from vmlinux file)
>=20
>=20
> GCC is debian 4.3.2-1.1
> AS 2.18.0.20080103
>=20
> CPU is Intel Xeon E5620
> Kernel CPU is set to MCORE2 (Core 2/newer Xeon)
>=20
>=20
> ffffffff814e7eb0 <tcp_fragment>:
> ffffffff814e7eb0:       41 57                   push   %r15
> ffffffff814e7eb2:       49 89 ff                mov    %rdi,%r15
> ffffffff814e7eb5:       41 56                   push   %r14
> ffffffff814e7eb7:       41 55                   push   %r13
> ffffffff814e7eb9:       41 89 d5                mov    %edx,%r13d
> ffffffff814e7ebc:       41 54                   push   %r12
> ffffffff814e7ebe:       55                      push   %rbp
> ffffffff814e7ebf:       53                      push   %rbx
> ffffffff814e7ec0:       48 89 f3                mov    %rsi,%rbx
> ffffffff814e7ec3:       48 83 ec 18             sub    $0x18,%rsp
> ffffffff814e7ec7:       89 4c 24 0c             mov    %ecx,0xc(%rsp)
> ffffffff814e7ecb:       8b 6e 68                mov    0x68(%rsi),%eb=
p
> ffffffff814e7ece:       39 ea                   cmp    %ebp,%edx
> ffffffff814e7ed0:       76 04                   jbe    ffffffff814e7e=
d6
> <tcp_fragment+0x26>
> ffffffff814e7ed2:       0f 0b                   ud2a
> ffffffff814e7ed4:       eb fe                   jmp    ffffffff814e7e=
d4
> <tcp_fragment+0x24>



So skb->len =3D 0x1540 and len =3D 0x1708

I suspect we should push commit 2fceec13375e5d98 (tcp: len check is
unnecessarily devastating, change to WARN_ON) to stable if not already
done...

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3D2fceec13375e5d98

David, is this commit in your stable queue ?

Thanks !

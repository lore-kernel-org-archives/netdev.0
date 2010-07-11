From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Sun, 11 Jul 2010 10:02:12 +0200
Message-ID: <1278835332.2538.51.camel@edumazet-laptop>
References: <AANLkTimn8A0cYZmwNZYitRkBHKKFe4HQ5GU626DLugkk@mail.gmail.com>
	 <AANLkTil49m6Ul2bauiH4Pwn-6ykrYTFmSO6_SxqQgD_e@mail.gmail.com>
	 <1278626921.2435.73.camel@edumazet-laptop>
	 <AANLkTiliBClahTfb41M5BDi1etg5pgkqEz_VfGrn_mK4@mail.gmail.com>
	 <1278695580.2696.55.camel@edumazet-laptop>
	 <AANLkTil39xHOhcdAo4h_jWtx_UuYdFHGdQVAdwPMd7QJ@mail.gmail.com>
	 <1278742649.2538.17.camel@edumazet-laptop>  <4C395459.6080407@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Felipe W Damasio <felipewd@gmail.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Avi Kivity <avi@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C395459.6080407@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 11 juillet 2010 =C3=A0 08:19 +0300, Avi Kivity a =C3=A9crit=
 :
> On 07/10/2010 09:17 AM, Eric Dumazet wrote:
> >
> > Strange thing with your crash report is CR2 value, with unexpected =
value
> > of 000000000b388000 while RAX value is dce8dce85d415d41
> >
> > Faulting instruction is :
> >
> > 48 83 b8 b0 00 00 00 00   cmpq   $0x0,0xb0(%rax)
> >
> > So I would have expected CR2 being RAX+0xb0, but its not.
> >   =20
>=20
> Nothing strange about it.  You only get page faults and valid cr2 for=
=20
> canonical addresses (17 high order bits all equal).  In this case=20
> rax+0xb0 is not a canonical address, so you got a general protection=20
> fault instead, with cr2 unchanged.
>=20

OK, thanks Avi for this information, as I was not aware of this.

So something overwrote sk->sk_prot pointer (or skb->sk pointer) with
some data.

tcp sockets are allocated from a dedicated kmem_cache (because of
SLAB_DESTROY_RCU attribute). Their sk->sk_prot should never change in
normal operation, since underlying memory cannot be reused by another
object type in kernel. It should be NULL or &tcp_prot

=46elipe, please describe your configuration as much as possible.
It might be a driver bug with with special kind of network frames.

lsmod
lspci -v
ethtool -k eth0
ethtool -k eth1 (if applicable)

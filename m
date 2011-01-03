From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Mon, 03 Jan 2011 15:08:53 +0100
Message-ID: <1294063733.21229.12.camel@wall-e>
References: <1294007971-18878-1-git-send-email-stefani@seibold.net>
	 <1294008562.2535.263.camel@edumazet-laptop>
	 <1294008917.18963.3.camel@wall-e>
	 <alpine.LNX.2.00.1101022356550.11481@swampdragon.chaosbits.net>
	 <1294045732.19666.6.camel@wall-e>
	 <1294046867.2892.101.camel@edumazet-laptop>
	 <1294048469.20187.13.camel@wall-e>
	 <1294051199.2892.198.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Juhl <jj@chaosbits.net>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	daniel.baluta@gmail.com, jochen@jochen.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294051199.2892.198.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, den 03.01.2011, 11:39 +0100 schrieb Eric Dumazet:
> Le lundi 03 janvier 2011 =E0 10:54 +0100, Stefani Seibold a =E9crit :
>=20
> > How can you do a routing, how can you determinate the MTU of the ro=
ute.
> > This are basics. Look into other code how this things will be handl=
ed is
> > in my opinion the right way, since there a no function provide to d=
o
> > this.
> >=20
>=20
> Hmm, how user land can perform this task then ?
>=20

Userspace is much more complicate and more overhead than kernel space.
The UDPCP implementation in userspace is about the factor 10 slower.

> Is there an open source implementation of UDPCP ?
>=20

I don't know any. These is the first one.

> What are its problems ? You say its dog slow, I really wonder why.
> UDP stack is pretty scalable these days, yet some improvements are
> possible.
>=20

UDP is fast... but UDPCP depends extremely on latency due the missing o=
f
sliding windows.=20

> Why not adding generic helpers if you believe you miss some
> infrastructure ? This could benefit to other 'stacks' as well.
>=20

Maybe i don't have the knowledge, maybe i don't have the time. Getting
in new API functions into LINUX is much more complicate than getting ne=
w
driver into LINUX. I know what i am talk, it takes me one year to the
new kfifo API (kfifo.c, kfifo.h) into the kernel.

> > Otherwise you can say the same about all the filesystem or PCI
> > drvivers , which do also a lot in the same way. But since this is t=
he
> > way to do it, it is the right way.
> >=20
>=20
> These drivers are here because of high performance on top of high
> performance specs.
>=20
> While UDPCP is only a layer above UDP. If the problem comes from UDP
> being too slow, it'll be slow too.
>=20

Because of latency. Handling the UDPCP into the data_read() bh function
is much faster:
- No context switch
- Assembly Multi-Fragment Message is very efficient using skb buffer
chaining.
- Immediately handling an ack or data message save a lot of latency

Implementing it in User Space is to slow, due the context switches. Als=
o
the sunrpc approach is not faster due the using of kernel threads which
are not better than user space (okay, a little bit because not switchin=
g
the MMU).

The implementation is clean. I did fix all issues what i was asked for.
The protocol has now absolut no side effects. So i ask again for merge
into linux-next.

- Stefani

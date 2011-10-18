From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga) causes
 kernel oops
Date: Tue, 18 Oct 2011 12:01:33 +0200
Message-ID: <1318932093.2657.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CA+0Zf5Be5JUSvssH9CrDQq=jtETZr=veAPC7jriM8B-FZKbbpg@mail.gmail.com>
	 <1318604266.2223.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CA+0Zf5A-8X5MaXC4+BbLKtMb8S8B-Ln_a3JNfz0jR4O-ruefuw@mail.gmail.com>
	 <1318905032.2571.35.camel@edumazet-laptop>
	 <20111018093411.GA15165@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Elmar Vonlanthen <evonlanthen@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111018093411.GA15165@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 18 octobre 2011 =C3=A0 11:34 +0200, Herbert Xu a =C3=A9crit :
> On Tue, Oct 18, 2011 at 04:30:32AM +0200, Eric Dumazet wrote:
> >
> > If David/Herbert/Timo agree, then patch should find its way into cu=
rrent
> > kernel, then to stable trees as well.
>=20
> Actually, I think we should instead fix the users of needed_headroom
> to not read it twice which is causing problems here.
>=20
> GRE tunnels by their nature do not have a fixed value for
> needed_headroom.  As the underlying routes change the necessary
> headroom may need to be adjusted due to further encapsulation such
> as IPsec.
>=20
> Keeping it constant from tunnel creation may result in suboptimal
> performance due to unnecessary header reallocations.
>=20
> However, until we audit the stack to see if there are further
> instances of double-readings such as the one causing the crash
> here, I'm fine with your patch making it constant.
>=20
> Once we're sure that all of the double-readings are gone we
> can revert to a dynamic needed_headroom.
>=20

Sure, we can work on this path for future kernels.

Adding an RCU protected structure to hold hard_header_len /
needed_headroom / needed_tailroom should be possible, but this adds yet
another pointer dereference...

Thanks !

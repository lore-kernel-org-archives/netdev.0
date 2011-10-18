From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga) causes
 kernel oops
Date: Tue, 18 Oct 2011 12:23:43 +0200
Message-ID: <1318933423.2657.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CA+0Zf5Be5JUSvssH9CrDQq=jtETZr=veAPC7jriM8B-FZKbbpg@mail.gmail.com>
	 <1318604266.2223.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CA+0Zf5A-8X5MaXC4+BbLKtMb8S8B-Ln_a3JNfz0jR4O-ruefuw@mail.gmail.com>
	 <1318905032.2571.35.camel@edumazet-laptop>
	 <20111018093411.GA15165@gondor.apana.org.au>
	 <1318932093.2657.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111018100527.GA15383@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Elmar Vonlanthen <evonlanthen@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111018100527.GA15383@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 18 octobre 2011 =C3=A0 12:05 +0200, Herbert Xu a =C3=A9crit :
> On Tue, Oct 18, 2011 at 12:01:33PM +0200, Eric Dumazet wrote:
> >
> > Adding an RCU protected structure to hold hard_header_len /
> > needed_headroom / needed_tailroom should be possible, but this adds=
 yet
> > another pointer dereference...
>=20
> I don't think we need RCU here since the problem is simply that
> we're using two different values for skb allocations and skb_reserve.
>=20
> As long as we use one and the same value it should work.  The value
> will rarely be incorrect and when it is, automatic reallocation will
> occur.
>=20

You're right, if reallocations are OK in all paths.

We'll need to change LL_RESERVED_SPACE() / LL_RESERVED_SPACE_EXTRA() /
LL_ALLOCATED_SPACE() macros and provide the [read once] values, instead
of a [read once] pointer to values.

Thats a bit complex change, but doable.

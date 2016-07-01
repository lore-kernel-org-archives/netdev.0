From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [RFC] WireGuard: next generation secure network tunnel
Date: Fri, 1 Jul 2016 16:25:18 +0200
Message-ID: <CAHmME9opjoOYQBacomKBMXMPkch8fxSjFp1B_uoPFFmQeLh24g@mail.gmail.com>
References: <CAHmME9q-6ioctzcB8gLdYOsMFqHVGY8GUsVGFisKv=wGdVqi2A@mail.gmail.com>
 <CAFLxGvzk5NywJou_g9_z6JQUrvcTNsAUPXt4R6AdS9nmRqYwcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, linux-crypto@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Richard Weinberger <richard.weinberger@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFLxGvzk5NywJou_g9_z6JQUrvcTNsAUPXt4R6AdS9nmRqYwcw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On Fri, Jul 1, 2016 at 1:42 PM, Richard Weinberger
<richard.weinberger@gmail.com> wrote:
> So every logical tunnel will allocate a new net device?
> Doesn't this scale badly? I have ipsec alike setups
> with many, many road warriors in mind.

No, this isn't the case. Each net device has multiple peers. Check out
the example config on the website, pasted here for convenience:

> [Interface]
> PrivateKey = yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=
> ListenPort = 41414
>
> [Peer]
> PublicKey = xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8Dg=
> AllowedIPs = 10.192.122.3/32, 10.192.124.1/24
>
> [Peer]
> PublicKey = TrMvSoP4jYQlY6RIzBgbssQqY3vxI2Pi+y71lOWWXX0=
> AllowedIPs = 10.192.122.4/32, 192.168.0.0/16
>
> [Peer]
> PublicKey = gN65BkIKy1eCE9pP1wdc8ROUtkHLF2PfAqYdyYBz6EA=
> AllowedIPs = 10.10.10.230/32

If that file is example.conf, you could set up a single device like this:

$ ip link add dev wg0 type wireguard
$ wg setconf wg0 example.conf

That single netdev is now configured to communicate with several peers.

I hope this clarifies things. Let me know if you have further questions.

Regards,
Jason

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NETIF_F_GSO_SOFTWARE vs NETIF_F_GSO
Date: Thu, 05 Nov 2015 07:56:07 -0800
Message-ID: <1446738967.4184.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHmME9rGvViDN2iFa8xfXvUJpQThJnrCcZ1yHgQrdgEQRUWtfg@mail.gmail.com>
	 <20151105121501.GA5776@gondor.apana.org.au>
	 <CAHmME9pP1E64CCc7+XW8X1duYGQZdYj9s_r8UNq3KMh6xey_Hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9pP1E64CCc7+XW8X1duYGQZdYj9s_r8UNq3KMh6xey_Hw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-11-05 at 16:00 +0100, Jason A. Donenfeld wrote:

> Right -- I saw the expansion in the header file -- it gets the various
> TSOs plus UFO. So what this means is that the packet hasn't yet been
> split up? So were I to add this option, then my driver would have to
> be responsible for splitting up the super-packets manually? In which
> case, there would be no performance benefit in using it, since GSO
> already does this just prior to ndo_start_xmit? Or would there be a
> performance benefit in receiving the super-packets and splitting them
> myself?

It is a performance benefit only if you use the helpers from
net/core/tso.c as some drivers already do.

Otherwise, calling the skb_gso_segment() from your driver has no gain
compared to the one done from core networking stack.

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: NETIF_F_GSO_SOFTWARE vs NETIF_F_GSO
Date: Fri, 6 Nov 2015 12:43:31 +0100
Message-ID: <CAHmME9ps+aZojr2192-pB54Fs5nGByxaNj16WULQkLqOnsAy_g@mail.gmail.com>
References: <CAHmME9rGvViDN2iFa8xfXvUJpQThJnrCcZ1yHgQrdgEQRUWtfg@mail.gmail.com>
	<20151105121501.GA5776@gondor.apana.org.au>
	<CAHmME9pP1E64CCc7+XW8X1duYGQZdYj9s_r8UNq3KMh6xey_Hw@mail.gmail.com>
	<1446738967.4184.35.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHmME9ptruMW4MFZ1q3=tgTANro1_CdwnCWS5O_0_WwbFKgUAw@mail.gmail.com>
	<CAHmME9ruZb=F+Nv5BqfS+9gEL4FriCgGkaD6Pvy2iD1FXv0EQg@mail.gmail.com>
	<20151106045842.GB14722@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151106045842.GB14722@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 6, 2015 at 5:58 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> I don't see anything fundamentally wrong with your idea.  After
> all what you're describing is the basis of GSO, i.e., letting
> data stay in the form of super-packets for as long as we can.
>
> Of course there's going to be a lot of niggly bits that you'll
> have to sort out to get it to work.

Okay, great. In that case, it's the niggly bits I need to wrestle
with. Any nice convenience functions for this? Or pointers to
examples?

Would it be best to (1) allocate a massive linear skb, and then bit by
bit call skb_put (as in my example in the last email)? Or would it be
best to (2) make individual packets, and then string them together in
a FRAGLIST fashion (or is there no driver support for this)? Or would
it be best (3) to some how use the array of 16 frags, and allocate
with the alloc_skb_wth_frags function, and then super cumbersomely try
to iterate over broken-up pages?

I think (3) is going to be super hard if not impossible for my setup.
If there were some way of combining multiple skbs into a super packet,
or if the fraglist was okay to use in this regard, that'd be a
lifesaver. So far my approach with (1) hasn't been working.

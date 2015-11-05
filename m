From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: NETIF_F_GSO_SOFTWARE vs NETIF_F_GSO
Date: Thu, 5 Nov 2015 16:00:55 +0100
Message-ID: <CAHmME9pP1E64CCc7+XW8X1duYGQZdYj9s_r8UNq3KMh6xey_Hw@mail.gmail.com>
References: <CAHmME9rGvViDN2iFa8xfXvUJpQThJnrCcZ1yHgQrdgEQRUWtfg@mail.gmail.com>
	<20151105121501.GA5776@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151105121501.GA5776@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

Thanks for your response!

On Thu, Nov 5, 2015 at 1:15 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> The NETIF_F_GSO flag turns on software GSO which should be on
> anyway.  So that could be why it seems to make no difference.

GSO is on by default? That makes sense, okay.

>
> NETIF_F_GSO_SOFTWARE is actually a collection of bits that lists
> the protocols for which we support software GSO.  The bits themselves
> are in fact an indication that the hardware supports GSO directly.
> So by turning them on you're electing to receive GSO packets
> directly.

Right -- I saw the expansion in the header file -- it gets the various
TSOs plus UFO. So what this means is that the packet hasn't yet been
split up? So were I to add this option, then my driver would have to
be responsible for splitting up the super-packets manually? In which
case, there would be no performance benefit in using it, since GSO
already does this just prior to ndo_start_xmit? Or would there be a
performance benefit in receiving the super-packets and splitting them
myself?

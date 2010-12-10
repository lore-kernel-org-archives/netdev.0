From: David Lamparter <equinox@diac24.net>
Subject: Re: Adding Support for SG,GSO,GRO
Date: Fri, 10 Dec 2010 17:23:28 +0100
Message-ID: <20101210162328.GA3922337@jupiter.n2.diac24.net>
References: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
 <1291906948.19763.16.camel@localhost>
 <AANLkTi=8zWMYWG0DU147B08nN7xcvwaB9Bpq9fE8_fBe@mail.gmail.com>
 <20101209.113806.71114756.davem@davemloft.net>
 <AANLkTi=7NLkHW6c88gUcyW8i0Wwmf2Cw4NdmRiGci4kE@mail.gmail.com>
 <20101210143140.GD3536057@jupiter.n2.diac24.net>
 <AANLkTi=cVufUAHn6LRs_vG-cW2cY87SdP9MOE7i5Ru09@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Lamparter <equinox@diac24.net>,
	David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	srk@ti.com, netdev@vger.kernel.org, Jens Axboe <axboe@kernel.dk>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:53200 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756556Ab0LJQXr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 11:23:47 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTi=cVufUAHn6LRs_vG-cW2cY87SdP9MOE7i5Ru09@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 10, 2010 at 05:01:33PM +0100, Micha=C5=82 Miros=C5=82aw wro=
te:
> W dniu 10 grudnia 2010 15:31 u=C5=BCytkownik David Lamparter
> <equinox@diac24.net> napisa=C5=82:
> > On Fri, Dec 10, 2010 at 03:18:11PM +0100, Micha=C5=82 Miros=C5=82aw=
 wrote:
> >> I'm trying to understand the dependency because it looks artificia=
l for me.
> > sendfile() is defined so that it works asynchronously, that means i=
f you
> > change the data while it is in the queue, you get unpredictable res=
ults.
>=20
> The question is do we really want good checksum for bogus data?

The data isn't neccessarily bogus. It will be in some state inbetween
old and new. What that means is up to the application.

>                                          Bad checksum in this case is
> actually a good thing as it clearly shows that something is broken in
> the sender and avoids accepting the data as valid at the receiving
> end.

No, because nothing is broken. sendfile() is working as advertised. The
specification of sendfile() is that it sends out data, and it that it
grabs that data at some more or less random point in time. The data is
valid. It is some data that corresponds to what the application wanted
written. It might be a "future" version of the data, but it will not be
random. Unpredictable, yes, in that you won't know where it will choose
old and where new data. But not random or broken.


-David


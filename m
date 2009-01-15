From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: b44 - swapper: page allocation failure
Date: Thu, 15 Jan 2009 15:40:55 +0200
Message-ID: <20090115134055.GA15551@ee.oulu.fi>
References: <20090115111537.GA994@gondor.apana.org.au> <200901151527.43646.mihai.dontu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mihai =?utf-8?B?RG9uyJt1?= <mihai.dontu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ee.oulu.fi ([130.231.61.23]:35929 "EHLO ee.oulu.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754645AbZAOOG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 09:06:28 -0500
Content-Disposition: inline
In-Reply-To: <200901151527.43646.mihai.dontu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 03:27:43PM +0200, Mihai Don=C8=9Bu wrote:
> > > A friend of mine just booted 2.6.28 and when someone else tried t=
o send
> > > something to him over ssh (scp), the transfer failed and the foll=
owing
> > > appeared in dmesg:
> > You missed the all important order line before the stack trace.
> Right, sorry for that. Here it is:
> swapper: page allocation failure. order:0, mode:0x21
> > If it's order 0, then you're just out of memory, if it's greater
> > than order 0, then either you're using jumbo frames or b44 is
> > broken.
> It is order zero, but he's not out of memory. He has just booted 2.6.=
28 (no X,=20
> no thing), has 3GB of RAM and 2GB of swap.
b44 uses GFP_DMA bounce buffers in some situations (x86_64 with > 1GB o=
f
memory would do the trick I think, as does x86 with 4:4 memory split),
and that's a very limited resource (Memory < 16MB ).=20

Lovely hardware feature requiring nasty workarounds
(the chip can't do DMA for addresses > 1GB).

Maybe something else sucks up GFP_DMA memory with 2.6.28?

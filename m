From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/3] sha512: make it work, undo percpu message schedule
Date: Sat, 14 Jan 2012 13:52:11 -0800
Message-ID: <CA+55aFxfKyqm9eC_XajLYJ6D5YhHn_9K0pkG+caZDhxrAwvA0w@mail.gmail.com>
References: <20120111000040.GA3801@p183.telecom.by> <20120111003611.GA12257@gondor.apana.org.au>
 <20120112235514.GA5065@p183.telecom.by> <20120113070813.GA20068@gondor.apana.org.au>
 <1326450942.2272.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1326451301.2272.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1326452246.2272.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CACVxJT9FOYdRFZJ0WRe+5ty4t4XLwgHKWaoZBWB+Zjm-yCEMEA@mail.gmail.com>
 <1326458053.3826.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20120114182024.GA4207@p183.telecom.by> <20120114182737.GB4207@p183.telecom.by>
 <1326577610.5287.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	security@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1326577610.5287.38.camel@edumazet-laptop>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 14, 2012 at 1:46 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> This is too risky, and we provided an alternate patch, not just for fun.

Did you see the second patch?

The one that got rid of the *stupid* 80-entry array?

I don't know why so many sha implementations do that idiotic full
array, when the circular one is much better.

In fact, the 16-entry circular array allows machines with lots of
registers to keep all the state in registers and the C implementation
can often be as good as hand-tuned assembly. At least that's true for
sha1, I'm not sure you can do the same with sha512.

But that actually *requires* that the 16-entry array be done on the
stack as an automatic array. Anything else, and the compiler won't be
able to do it.

                       Linus

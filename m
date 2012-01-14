From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/3] sha512: reduce stack usage to safe number
Date: Sat, 14 Jan 2012 13:14:33 -0800
Message-ID: <CA+55aFzMBFzxY0oT_fWegtMZ6rFGdtfv1CBnUM7YxnMza75spw@mail.gmail.com>
References: <20120113070813.GA20068@gondor.apana.org.au> <1326450942.2272.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1326451301.2272.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1326452246.2272.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CACVxJT9FOYdRFZJ0WRe+5ty4t4XLwgHKWaoZBWB+Zjm-yCEMEA@mail.gmail.com>
 <1326458053.3826.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20120114182024.GA4207@p183.telecom.by> <20120114182737.GB4207@p183.telecom.by>
 <20120114184057.GA5516@p183.telecom.by> <CA+55aFziQSzTpfnxQ+k83Ui-65TDHu5GZFoJhhPoR504K_d7pw@mail.gmail.com>
 <20120114204127.GA4100@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, security@kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20120114204127.GA4100@p183.telecom.by>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 14, 2012 at 12:41 PM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
>
> For the record, it generates "andl $15" here.

Ok. That means that gcc was able to prove that it never had any signed
values (which is certainly reasonable when you do things like "for
(i=0; i<X;i++)"). But it's better to simply not rely on gcc always
getting details like this right.

It's also better to use a model that simply doesn't even require you
as a programmer to have to even *think* about signed values.

It's easy to get "%" wrong by mistake (signed integer modulus didn't
even use to have well-defined semantics in traditional C), and there
is almost never any excuse for using it for powers-of-two.

> Here is updated patch which explicitly uses & (equally tested):

Thanks,

                     Linus

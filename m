From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [INET] Optimise away a branch in IP_ECN_set_ce
Date: Thu, 09 Sep 2004 09:36:25 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909.093625.124940653.yoshfuji@linux-ipv6.org>
References: <20040909000330.GA5581@gondor.apana.org.au>
	<20040909.092428.125540781.yoshfuji@linux-ipv6.org>
	<200409082127.57827.acme@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au, acme@conectiva.com.br
In-Reply-To: <200409082127.57827.acme@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200409082127.57827.acme@conectiva.com.br> (at Wed, 8 Sep 2004 21:27:57 -0300), Arnaldo Carvalho de Melo <acme@conectiva.com.br> says:

> Em Qua 08 Set 2004 21:24, YOSHIFUJI Hideaki / 吉藤英明 escreveu:
> > In article <20040909000330.GA5581@gondor.apana.org.au> (at Thu, 9 Sep 2004 
> 10:03:31 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:
> > > +       u32 ecn = (iph->tos + 1) & INET_ECN_MASK;
> > >
> > > + /*
> > > +  * The following gives us:
> > > +  * INET_ECN_ECT_1 => check += __constant_htons(0xFFFD)
> > > +  * INET_ECN_ECT_0 => check += __constant_htons(0xFFFE)
> > > +  */
> > > + if (__constant_htons(1) != 1)
> > > +  ecn <<= 8;
> > > + check += __constant_htons(0xFFFB) + ecn;
> > > +
> > >   iph->check = check + (check>=0xFFFF);
> > >   iph->tos |= INET_ECN_CE;
> > >  }
> >
> > s/__constant_htons/htons/g here, please.
> 
> For Herbert understanding: the generated code is the same in this case. :)

Yes, thanks.
And, we don't use __const_{hton,ntoh}{s,l}() unless it is really required.
e.g. variable initializer

--yoshfuji

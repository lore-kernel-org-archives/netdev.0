From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [INET] Optimise away a branch in IP_ECN_set_ce
Date: Wed, 8 Sep 2004 21:53:18 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409082153.18678.acme@conectiva.com.br>
References: <20040909000330.GA5581@gondor.apana.org.au> <200409082127.57827.acme@conectiva.com.br> <20040909.093625.124940653.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?q?=1B=24B5HF=231QL=40=1B=28B?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040909.093625.124940653.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Qua 08 Set 2004 21:36, YOSHIFUJI Hideaki / 吉藤英明 escreveu:
> In article <200409082127.57827.acme@conectiva.com.br> (at Wed, 8 Sep 2004 
21:27:57 -0300), Arnaldo Carvalho de Melo <acme@conectiva.com.br> says:
> > Em Qua 08 Set 2004 21:24, YOSHIFUJI Hideaki / 吉藤英明 escreveu:
> > > In article <20040909000330.GA5581@gondor.apana.org.au> (at Thu, 9 Sep
> > > 2004
> >
> > 10:03:31 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:
> > > > +       u32 ecn = (iph->tos + 1) & INET_ECN_MASK;
> > > >
> > > > + /*
> > > > +  * The following gives us:
> > > > +  * INET_ECN_ECT_1 => check += __constant_htons(0xFFFD)
> > > > +  * INET_ECN_ECT_0 => check += __constant_htons(0xFFFE)
> > > > +  */
> > > > + if (__constant_htons(1) != 1)
> > > > +  ecn <<= 8;
> > > > + check += __constant_htons(0xFFFB) + ecn;
> > > > +
> > > >   iph->check = check + (check>=0xFFFF);
> > > >   iph->tos |= INET_ECN_CE;
> > > >  }
> > >
> > > s/__constant_htons/htons/g here, please.
> >
> > For Herbert understanding: the generated code is the same in this case.
> > :)
>
> Yes, thanks.
> And, we don't use __const_{hton,ntoh}{s,l}() unless it is really required.
> e.g. variable initializer

Yes, that is the only case, like I learned in my early janitor days, using the
__constant_ variations is not needed and makes the code needlessly ugly :)

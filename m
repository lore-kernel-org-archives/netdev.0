From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [INET] Optimise away a branch in IP_ECN_set_ce
Date: Wed, 8 Sep 2004 21:27:57 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409082127.57827.acme@conectiva.com.br>
References: <20040909000330.GA5581@gondor.apana.org.au> <20040909.092428.125540781.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: herbert@gondor.apana.org.au, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?utf-8?q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040909.092428.125540781.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Qua 08 Set 2004 21:24, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=
=E6=98=8E escreveu:
> In article <20040909000330.GA5581@gondor.apana.org.au> (at Thu, 9 Sep 2=
004=20
10:03:31 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:
> > +       u32 ecn =3D (iph->tos + 1) & INET_ECN_MASK;
> >
> > + /*
> > +  * The following gives us:
> > +  * INET_ECN_ECT_1 =3D> check +=3D __constant_htons(0xFFFD)
> > +  * INET_ECN_ECT_0 =3D> check +=3D __constant_htons(0xFFFE)
> > +  */
> > + if (__constant_htons(1) !=3D 1)
> > +  ecn <<=3D 8;
> > + check +=3D __constant_htons(0xFFFB) + ecn;
> > +
> >   iph->check =3D check + (check>=3D0xFFFF);
> >   iph->tos |=3D INET_ECN_CE;
> >  }
>
> s/__constant_htons/htons/g here, please.

For Herbert understanding: the generated code is the same in this case. :=
)

>
> And, I think
>   u16 ecn =3D (iph->tos + 1) & INET_ECN_MASK;
>
>   check +=3D (u32)htons(0xfffb) + (u32)htons(ecn);
>
> or something like that?

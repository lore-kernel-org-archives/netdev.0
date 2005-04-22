From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: Problem with IPSEC tunnel mode
Date: Fri, 22 Apr 2005 11:37:38 +0200
Message-ID: <200504221137.38939.wolfgang.walter@studentenwerk.mhn.de>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au> <200504220240.31280.wolfgang.walter@studentenwerk.mhn.de> <20050422010445.GA10918@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050422010445.GA10918@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Am Freitag, 22. April 2005 03:04 schrieben Sie:
> On Fri, Apr 22, 2005 at 02:40:31AM +0200, Wolfgang Walter wrote:
> > > Although you probably have rp_filter turned, but please check
> > >
> > > cat /proc/sys/net/ipv4/conf/eth3/rp_filter
> > >
> > > anway.
>
> Please do this check.
>
> > > > src 10.148.0.0/23 dst 10.0.25.210/32
> > > >  dir fwd priority 0
> > >
> > > There you go.  This policy trumps your other policy.  This one
> > > says that forwarded traffic matching it must carry no tunnel
> > > IPsec transforms.  Therefore all IPsec packets matching it will
> > > be dropped.
> >
> > I don't understand that. 10.148.0.0/23 is 10.148.0.0-10.148.1.255, is=
n't
> > it? But 10.148.4.0/28 (is 10.148.4.0-10.148.4.15) is not within it.
>
> Sorry, I misread the netmask.  I was right about the problem though :)
> Further down it says
>
> src 0.0.0.0/0 dst 10.0.25.210/32
>  dir fwd priority 0
>
> which still trumps your IPsec policy.
>
> Cheers,

Oh yes, me stupid.

They are needed (these hosts are allowed to communicate with outside worl=
d=20
unencrypted), but priority is wrong.

Our rules are generated from a description of the network. And if we conn=
ect=20
10.0.25.210 directly to C and change netmask to 30 instead of 32 our=20
generator assumes that this system is not allowed to communicate with out=
side=20
world and does not generate this rule.

Thanks a lot, sorry for bothering you. I should have seen this difference=
. But=20
probably I would not have recognized that as a problemebecause I assumed =
that=20
in and fwd allow-rules only applies to non-ipsec packets which of course =
is=20
not logical :-).

--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
Leopoldstra=DFe 15
80802 M=FCnchen

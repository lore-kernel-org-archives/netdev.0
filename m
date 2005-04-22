From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: Problem with IPSEC tunnel mode
Date: Fri, 22 Apr 2005 02:40:31 +0200
Message-ID: <200504220240.31280.wolfgang.walter@studentenwerk.mhn.de>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au> <200504211640.16742.wolfgang.walter@studentenwerk.mhn.de> <20050421214618.GA29991@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050421214618.GA29991@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Am Donnerstag, 21. April 2005 23:46 schrieben Sie:
> On Thu, Apr 21, 2005 at 04:40:16PM +0200, Wolfgang Walter wrote:
> > 10.148.0.0/23 dev eth2.1001  scope link  src 10.148.0.1
> > 10.148.32.0/20 via 10.148.15.30 dev eth0.1014  src 10.148.15.29
> > default via 192.168.77.162 dev eth3  src 192.168.77.161
>
> Although you probably have rp_filter turned, but please check
>
> cat /proc/sys/net/ipv4/conf/eth3/rp_filter
>
> anway.
>
> > src 10.148.0.0/23 dst 10.0.25.210/32
> >  dir fwd priority 0
>
> There you go.  This policy trumps your other policy.  This one
> says that forwarded traffic matching it must carry no tunnel
> IPsec transforms.  Therefore all IPsec packets matching it will
> be dropped.

I don't understand that. 10.148.0.0/23 is 10.148.0.0-10.148.1.255, isn't =
it?=20
But 10.148.4.0/28 (is 10.148.4.0-10.148.4.15) is not within it.

>
> > src 10.148.4.0/28 dst 10.0.25.210/32
> >  dir fwd priority 2084
> >  tmpl src 192.168.9.237 dst 192.168.77.161
> >   proto esp spi 0x00000000 reqid 16465 mode tunnel
>
> The reason it worked with the old setkey and 2.6.7* is that all
> forwarded traffic would've been allowed, regardless of whether
> they matched the IPsec policy or not.
>
> Cheers,

Greetings,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
Leopoldstra=DFe 15
80802 M=FCnchen

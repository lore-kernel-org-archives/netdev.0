From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH|RFC] IPv6 netfilter: a module for complete proxy ND
 support
Date: Thu, 15 Jan 2004 16:53:42 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401151537000.29722@rhea.tcs.hut.fi>
References: <Pine.LNX.4.58.0401141250470.24125@rhea.tcs.hut.fi>
 <20040114.210427.104284595.yoshfuji@linux-ipv6.org>
 <Pine.LNX.4.58.0401141726490.24125@rhea.tcs.hut.fi>
 <20040115.223430.100570163.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable
Cc: netfilter-devel@lists.netfilter.org, davem@redhat.com, netdev@oss.sgi.com,
        kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040115.223430.100570163.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=D1=
=CC=C0 wrote:

> In article <Pine.LNX.4.58.0401141726490.24125@rhea.tcs.hut.fi> (at Thu,=
 15 Jan 2004 15:00:24 +0200 (EET)), Ville Nuorvala <vnuorval@tcs.hut.fi> =
says:
>
> > On Wed, 14 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=
=D1=CC=C0 wrote:
> >
> > > I don't think so. Proxy should not depend on netfilter.
> :
> > There aren't that many ways of doing this "hack" cleanly.
>
> Well...
>
> We (or only me?) might have mis-understood the "proxy" in Linux :-P
> It is not for proxy in rfc2461, is it?
> It is for proxy in Thaler's draft, isn't it?

No, it's for the proxy go old proxy in rfc2461 :(

The definition of a proxy is described so vaguely in the rfc, that you
have to think *really* carefully about how it is *supposed* to work.

I and Pekka were talking about starting a proxy ND discussion on the IEFT
ipv6 mailing list. I guess the text could be clarified a lot.

The rfc in its current form (lets hope we get an improvement in 2461bis :=
)
states the proxy verifies that the target address in a NS is a unicast
address it is proxying.

With multicast NS messages proxying is simple: to receive the message jus=
t
have the proxying router join the solicited nodes multicast group.

With unicast NS messages used for NUD, things get complicated: normally
the router just routes unicast packets between interfaces, but a proxying
router has to investigate the packets it receives to see if they happen t=
o
be NS messages sent to an address it is proxying.

I think netfilter is the best place for this kind of additional packet
parsing, since similar things are already done with the existing filters.

This way you also take the preformance hit caused by the extra parsing
only when you need the proxy functionality and load the module. If you
don't have the module loaded you don't take the hit.

Regards,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257

From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: ip -6 route shows incorrect route expiry times
Date: Mon, 31 Jan 2005 13:55:57 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0501311318300.23070@rhea.tcs.hut.fi>
References: <20050130160840.C25000@flint.arm.linux.org.uk>
 <20050131.012910.117562374.yoshfuji@linux-ipv6.org>
 <20050131.013018.131301320.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-2022-jp
Content-Transfer-Encoding: quoted-printable
Cc: rmk@arm.linux.org.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20050131.013018.131301320.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 31 Jan 2005, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=D1=
=CC=C0 wrote:

> In article <20050131.012910.117562374.yoshfuji@linux-ipv6.org> (at Mon,=
 31 Jan 2005 01:29:10 +0900 (JST)), YOSHIFUJI Hideaki / =B5=C8=C6=A3=B1=D1=
=CC=C0 <yoshfuji@linux-ipv6.org> says:
>
> > > It appears that the expiry seconds here are actually in units of
> > > 10 seconds.  Maybe someone's double-converting kernel Hz to user Hz=
?
> >
> > Kernel exports in USER_HZ.
> > iproute2 seem to convert it again; workaround is to do "export HZ=3D1=
00".
>                                                           ~~~~~~~~~~~~~
> This is example. Of course, this depends on your arch.

Please, couldn't the lifetimes be passed to userspace in a architecture
indepentent unit like whole seconds?

I don't think any routing protocols need a sub-second resolution for the
lifetimes but if they do, why not use milliseconds? Better still, why not
add a new attribute with a struct timespec or timeval to store the
sub-second lifetimes for those who need them?

Btw. we have the same HZ problem in many /proc files.

Here too I would like to see a millisecond based interface in addition to
the existing USER_HZ/jiffies/second based one. This especially applies to
values like base_reachable_time and retrans_time, which are originally
defined as millisecond values in the specification (RFC 2461).

Regards,
Ville

--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257

From: "Jeroen Massar" <jeroen@unfix.org>
Subject: RE: (usagi-users 02434) Re: IPv6 bugs introduced in 2.4.21
Date: Wed, 18 Jun 2003 17:20:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <003401c335ad$1c0cc880$210d640a@unfix.org>
References: <1055945454.7480.184.camel@slurv.ws.pasop.tomt.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <info@sixxs.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: <usagi-users@linux-ipv6.org>,
   "'YOSHIFUJI Hideaki / ????'" <yoshfuji@linux-ipv6.org>
In-Reply-To: <1055945454.7480.184.camel@slurv.ws.pasop.tomt.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andre Tomt [mailto:andre@tomt.net] wrote:

> On ons, 2003-06-18 at 15:42, YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > In article
> <1055793048.24660.160.camel@slurv.ws.pasop.tomt.net> (at 16
> Jun 2003 21:50:48 +0200), Andre Tomt <andre@skjellin.no> says:
> >
> > > I mailed you guys a little while ago on the "unable to use
> > > SOMENETWORK::0000 as a nexthop gateway" bug in
> 2.4.21-pre/rc a while
> > > ago. It is still present in 2.4.21, rendering the "first"
> /128 of a
> > > arbitrary prefixlen unusable - :0000. This is especially
> bad with /127
> > > tunnels, rendering :0000 and :0001 unusable). But! There
> is one more
> > :
> >
> > This is NOT the bug but by the spec.
> > prefix:: is an anycast address, not a unicast;
> > you cannot use it like an unicast address.

This kind of explains it, though I don't really like the way it was
forced upon us
without any big notification, then again I didn't read the changelog
so
it could be there ;)
Is there a toggle for turning this behaviour off ?

Notez bien that many people use :: and ::1 and ::2 etc as a unicast
address.
This will force them to stop using those ofcourse unless one simply
removes
those routes to the lo device, like I did :)

<SNIP>

> > If yes, you should not use /127 prefix; please use /64 instead.
>
> No one in their right mind assigns /64's for a linknetwork with two
> peers. It's a pointopoint-link. All people I know use either /128
> pointopoint or pointomultipoint semantics (BSD, KAME), or /127's as
> Linux refuses to use the traditional pointopoint or peer parameter
in
> ifconfig and iproute for ipv6.

For SixXS we only use /127's on the IPng POP because of the age of the
POP.
The other POP's all use /64's for 'transitnetworks', the point to
point
tunnels.
Those are a lot of users. The endpoints currently on the IPng POP will
not be
migrated to use /64's all of a sudden though.

> The /127 matches both 2a and 2b, why does it end up at localhost?

Routing, remove the route which goes over lo.

Greets,
 Jeroen

From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2 2/2] ip: remove NLM_F_EXCL in case of ECMPv6
 routes
Date: Thu, 25 Oct 2012 09:25:26 -0700
Message-ID: <20121025092526.5bb0a7ca@nehalam.linuxnetplumber.net>
References: <20121023.023910.80461258323920266.davem@davemloft.net>
	<1350996176-4000-1-git-send-email-nicolas.dichtel@6wind.com>
	<1350996176-4000-2-git-send-email-nicolas.dichtel@6wind.com>
	<20121025090628.25e484d1@nehalam.linuxnetplumber.net>
	<508966E1.2050205@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, joe@perches.com, bernat@luffy.cx,
	eric.dumazet@gmail.com, yoshfuji@linux-ipv6.org,
	davem@davemloft.net
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34995 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757050Ab2JYQ0P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 12:26:15 -0400
In-Reply-To: <508966E1.2050205@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Oct 2012 18:20:49 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Le 25/10/2012 18:06, Stephen Hemminger a =E9crit :
> > On Tue, 23 Oct 2012 14:42:56 +0200
> > Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> >
> >> ECMPv6 routes are added each one after the other by the kernel, so=
 we should
> >> avoid to set the flag NLM_F_EXCL.
> >>
> >> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> >> ---
> >>   ip/iproute.c | 5 ++++-
> >>   1 file changed, 4 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/ip/iproute.c b/ip/iproute.c
> >> index c60156f..799a70e 100644
> >> --- a/ip/iproute.c
> >> +++ b/ip/iproute.c
> >> @@ -694,8 +694,11 @@ int parse_nexthops(struct nlmsghdr *n, struct=
 rtmsg *r, int argc, char **argv)
> >>   		rtnh =3D RTNH_NEXT(rtnh);
> >>   	}
> >>
> >> -	if (rta->rta_len > RTA_LENGTH(0))
> >> +	if (rta->rta_len > RTA_LENGTH(0)) {
> >>   		addattr_l(n, 1024, RTA_MULTIPATH, RTA_DATA(rta), RTA_PAYLOAD(r=
ta));
> >> +		if (r->rtm_family =3D=3D AF_INET6)
> >> +			n->nlmsg_flags &=3D ~NLM_F_EXCL;
> >> +	}
> >>   	return 0;
> >>   }
> >>
> >
> > Shouldn't this be true for multipath IPv4 as well?
> >
> In IPv4, the message is treating in one shot, because all nexthops ar=
e added in=20
> the route. In IPv6, each nexthop is added like a single route and the=
n they are=20
> linked together.

So it is a fundamental design flaw in how either v4 or v6 was implement=
ed in
the kernel?

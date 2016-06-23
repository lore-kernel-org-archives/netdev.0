From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net v2] ipv6: enforce egress device match in per table
 nexthop lookups
Date: Thu, 23 Jun 2016 16:39:22 +0200
Message-ID: <1466692762.4910.48.camel@redhat.com>
References: <5257997d95ca10b106fd44bcb754233d18587f63.1466687942.git.pabeni@redhat.com>
	 <786d9687-922f-6e89-c281-ddacae8f83b2@cumulusnetworks.com>
	 <14311cf1-0b8e-cde2-54c0-c49a1b39b0c6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Beniamino Galvani <bgalvani@redhat.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49514 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890AbcFWOjY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2016 10:39:24 -0400
In-Reply-To: <14311cf1-0b8e-cde2-54c0-c49a1b39b0c6@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-06-23 at 08:29 -0600, David Ahern wrote:
> On 6/23/16 8:20 AM, David Ahern wrote:
> >> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> >> index 969913d..520b788 100644
> >> --- a/net/ipv6/route.c
> >> +++ b/net/ipv6/route.c
> >> @@ -1782,7 +1782,7 @@ static struct rt6_info
> >> *ip6_nh_lookup_table(struct net *net,
> >>      };
> >>      struct fib6_table *table;
> >>      struct rt6_info *rt;
> >> -    int flags = 0;
> >> +    int flags = RT6_LOOKUP_F_IFACE;
> >>
> >>      table = fib6_get_table(net, cfg->fc_table);
> >>      if (!table)
> >>
> >
> > Acked-by: David Ahern <dsa@cumulusnetworks.com>
> 
> I take that back.
> 
> I think RT6_LOOKUP_F_IFACE should only be set if cfg->fc_ifindex is set.

AFAICS the latter condition should not be needed. The related
information is passed all way down to rt6_score_route(), where it's
really used:

	m = rt6_check_dev(rt, oif);
        if (!m && (strict & RT6_LOOKUP_F_IFACE))
                return RT6_NUD_FAIL_HARD;

and 'm' can be 0 only if oif is set: RT6_LOOKUP_F_IFACE has no effect
ifindex is set.

Paolo

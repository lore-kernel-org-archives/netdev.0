From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] [IPv6]: IPV6_MULTICAST_IF setting is ignored on link-local
 connect()
Date: Wed, 19 Dec 2007 10:57:45 -0800
Message-ID: <OF27B7DA9C.52E5380F-ON882573B6.00650422-882573B6.0068581B@us.ibm.com>
References: <47693A52.5020301@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:34704 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505AbXLSTAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 14:00:00 -0500
In-Reply-To: <47693A52.5020301@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> wrote on 12/19/2007 07:35:46 AM:
...
> >                 if (usin->sin6_scope_id)
> >                         sk->sk_bound_dev_if = usin->sin6_scope_id;
> >                 if (!sk->sk_bound_dev_if &&
> >                      (addr_type & IPV6_ADDR_MULTICAST))
> >                         fl.oif = np->mcast_oif;
> 
> This assignment will not get us past the next check...

        Yeah, that's what I get for typing in off-the-cuff code. What
I was thinking was the fl.oif assignment instead was:
        if (!sk->sk_bound_dev_if &&
                (addr_type & IPV6_ADDR_MULTICAST))
                        sk->sk_bound_dev_if = np->mcast_oif;

Which it is not, but maybe it could be, since this is a connect().

That patch looks better, but I'm wondering if we could just remove the
requirement that sin6_scope_id be set here if it's multicast, since it
is doing the following later in the code:

        if (!fl.oif && (addr_type&IPV6_ADDR_MULTICAST))
                fl.oif = np->mcast_oif;

So, really, all we need to do is get through the LINKLOCAL section
without error in the multicast case and we can remove the redundant
multicast check there. I think that'd be simpler.

I also note that sin6_scope_id appears not to be honored at all in
the non-linklocal case, which may be correct, but surprises me.

I want to look a little more at this; I know you have a customer
issue, so I'll make it quick.

                                                                +-DLS


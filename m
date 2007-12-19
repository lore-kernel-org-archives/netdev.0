From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] [IPv6]: IPV6_MULTICAST_IF setting is ignored on link-local
 connect()
Date: Wed, 19 Dec 2007 14:15:27 -0500
Message-ID: <47696DCF.3000009@hp.com>
References: <OF27B7DA9C.52E5380F-ON882573B6.00650422-882573B6.0068581B@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:44540 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752579AbXLSTPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 14:15:30 -0500
In-Reply-To: <OF27B7DA9C.52E5380F-ON882573B6.00650422-882573B6.0068581B@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens wrote:
> Brian Haley <brian.haley@hp.com> wrote on 12/19/2007 07:35:46 AM:
> ...
>>>                 if (usin->sin6_scope_id)
>>>                         sk->sk_bound_dev_if = usin->sin6_scope_id;
>>>                 if (!sk->sk_bound_dev_if &&
>>>                      (addr_type & IPV6_ADDR_MULTICAST))
>>>                         fl.oif = np->mcast_oif;
>> This assignment will not get us past the next check...
> 
>         Yeah, that's what I get for typing in off-the-cuff code. What
> I was thinking was the fl.oif assignment instead was:
>         if (!sk->sk_bound_dev_if &&
>                 (addr_type & IPV6_ADDR_MULTICAST))
>                         sk->sk_bound_dev_if = np->mcast_oif;
> 
> Which it is not, but maybe it could be, since this is a connect().

My original patch did this, but also checked for a possible mis-match 
with sk_bound_dev_if - it would actually wind-up setting it to the same 
value if it was already set correctly.

> That patch looks better, but I'm wondering if we could just remove the
> requirement that sin6_scope_id be set here if it's multicast, since it
> is doing the following later in the code:
> 
>         if (!fl.oif && (addr_type&IPV6_ADDR_MULTICAST))
>                 fl.oif = np->mcast_oif;

We would still have to check np->mcast_oif is set in the link-local case 
since we shouldn't be getting here with a zero.

> So, really, all we need to do is get through the LINKLOCAL section
> without error in the multicast case and we can remove the redundant
> multicast check there. I think that'd be simpler.
> 
> I also note that sin6_scope_id appears not to be honored at all in
> the non-linklocal case, which may be correct, but surprises me.
> 
> I want to look a little more at this; I know you have a customer
> issue, so I'll make it quick.

Don't worry about that, they can wait, and I'm leaving for 10 days 
anyways...

-Brian

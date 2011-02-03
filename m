From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH] NETFILTER module xt_hmark new target for HASH MARK
Date: Thu, 3 Feb 2011 15:23:15 +0100
Message-ID: <1296742995.6662.57.camel@seasc0214>
References: <1296740050-6311-1-git-send-email-hans.schillstrom@ericsson.com>
	 <1296740050-6311-2-git-send-email-hans.schillstrom@ericsson.com>
	 <4D4AB2D6.7070302@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:56511 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932281Ab1BCOXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 09:23:17 -0500
In-Reply-To: <4D4AB2D6.7070302@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-02-03 at 14:51 +0100, Pablo Neira Ayuso wrote:
> On 03/02/11 14:34, Hans Schillstrom wrote:
> > +/*
> > + * Calc hash value, special casre is taken on icmp and fragmented messages
> > + * i.e. fragmented messages don't use ports.
> > + */
> > +static __u32 get_hash(struct sk_buff *skb, struct xt_hmark_info *info)
> > +{
> [...]
> > +	ip_proto &= info->prmask;
> > +	/* get a consistent hash (same value on both flow directions) */
> > +	if (addr2 < addr1)
> > +		swap(addr1, addr2);
> 
> this assumption is not valid in NAT handlings.

That's true, because I want to avoid conntrack

> 
> If you want consistent hashing with NAT handlings you'll have to make
> this stateful and use the conntrack source and reply directions of the
> original tuples (thus making it stateful). That may be a problem because
> some people may want to use this without enabling connection tracking.

What about a compilation switch or a sysctl ?

> 
> Are you using this for (uplink) load balancing?

Actually in both ways 
 - in front of a bunch of ipvs
 - and in the payloads for outgoing traffic.

> Could you also include one realistic example in the patch description on
> how this is used?
Sure, I guess you mean some nice ascii graphics,  
iptables and ip route commands

> 
> If this is accepted, I think this has to be merge with the (already
> overloaded) MARK target.

I have no opinion about that, others might have.

Thanks
Hans


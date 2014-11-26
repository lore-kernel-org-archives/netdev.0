From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/5 net] bridge: Fix missing Netlink message validations
Date: Wed, 26 Nov 2014 23:14:36 +0000
Message-ID: <20141126231436.GF32174@casper.infradead.org>
References: <cover.1417005245.git.tgraf@suug.ch>
 <547606B3.3060808@gmail.com>
 <20141126170610.GA2399@casper.infradead.org>
 <54760D1D.3070201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35291 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbaKZXOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 18:14:39 -0500
Content-Disposition: inline
In-Reply-To: <54760D1D.3070201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14 at 09:25am, John Fastabend wrote:
> >--- a/net/ipv4/devinet.c
> >+++ b/net/ipv4/devinet.c
> >@@ -1687,8 +1687,11 @@ static int inet_set_link_af(struct net_device *dev, const struct nlattr *nla)
> >                BUG();
> >
> >        if (tb[IFLA_INET_CONF]) {
> >-               nla_for_each_nested(a, tb[IFLA_INET_CONF], rem)
> >+               nla_for_each_nested(a, tb[IFLA_INET_CONF], rem) {
> >+                       if (nla_len(a) < sizeof(u32))
> >+                               return -EINVAL;
> >                        ipv4_devconf_set(in_dev, nla_type(a), nla_get_u32(a));
> >+               }

Looked into this and found a validation function
inet_validate_link_af(). It's split to keep the updates atomic.

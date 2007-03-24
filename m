From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Fix fib_rules compatibility breakage
Date: Sat, 24 Mar 2007 12:48:24 -0700 (PDT)
Message-ID: <20070324.124824.122609737.davem@davemloft.net>
References: <46001300.90804@trash.net>
	<20070320181547.GO521@postel.suug.ch>
	<46003CFF.8050109@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, lartc@mailman.ds9a.nl
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60324
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753195AbXCXVe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 17:34:56 -0400
In-Reply-To: <46003CFF.8050109@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 20 Mar 2007 20:58:55 +0100

> Thomas Graf wrote:
> > * Patrick McHardy <kaber@trash.net> 2007-03-20 17:59
> > 
> >>The presence of the attributes when src_len/dst_len is non-zero
> >>is only verified in fib_newrule, so this looks like it might crash
> >>when something broken sets src_len/dst_len to a non-zero value
> >>without actually adding the attributes.
> > 
> > 
> > You're right, we need to validate in fib_nl_delrule() as well.
> > 
> > Based on Patrick's patch:
> > The fib_rules netlink attribute policy introduced in 2.6.19 broke
> > userspace compatibilty. When specifying a rule with "from all"
> > or "to all", iproute adds a zero byte long netlink attribute,
> > but the policy requires all addresses to have a size equal to
> > sizeof(struct in_addr)/sizeof(struct in6_addr), resulting in a
> > validation error.
> > 
> > Check attribute length of FRA_SRC/FRA_DST in the generic framework
> > by letting the family specific rules implementation provide the
> > length of an address. Report an error if address length is non
> > zero but no address attribute is provided. Fix actual bug by
> > checking address length for non-zero instead of relying on
> > availability of attribute.
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> This looks good, thanks.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks guys, I'll push this to 2.6.20-stable as well.


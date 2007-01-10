From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH/RFC 01/10] Implement local diversion of IPv4 skbs
Date: Wed, 10 Jan 2007 13:32:24 +0100
Message-ID: <45A4DCD8.2080103@trash.net>
References: <20070103163357.14635.37754.stgit@nienna.balabit>	<20070103163427.14635.49596.stgit@nienna.balabit>	<45A48BD6.5010507@trash.net> <1168421515.6746.14.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33743 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932783AbXAJMc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 07:32:27 -0500
To: Balazs Scheidler <bazsi@balabit.hu>
In-Reply-To: <1168421515.6746.14.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Balazs Scheidler wrote:
> On Wed, 2007-01-10 at 07:46 +0100, Patrick McHardy wrote:
> 
>>I'm wondering if it would be possible to use normal input routing
>>combined with netfilter marks to do the diversion ..
>
> 
> The problem is that userspace proxies open ports dynamically (think of
> FTP data channels), you cannot add iptables rule for every such
> redirection. So one rule for every dynamic redirection is a no-go.
> 
> If we'd add a single rule, which would do some kind of lookup and then
> mark packets, would again introduce a state inside tproxy that'd need to
> be synchronized with the socket table. We explicitly wanted to avoid
> such tables.

How exactly are dynamic ports handled? Do you just add a catch-all rule
that filters based on socket lookups?

In that case you could do something like this:

ip route add local default dev lo scope host table 1
ip rule add fwmark 0x1 lookup 1

and still use the socket lookups for marking, which would (without the
socket caching) remove the need for this patch entirely.

> And additionally, using the mark this way would prevent the admin to use
> it they way he/she likes. 

We support bitwise use of the mark everywhere in current kernels, so
that shouldn't be a problem anymore.

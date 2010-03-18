From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] netlink: fix NETLINK_RECV_NO_ENOBUFS in netlink_set_err()
Date: Thu, 18 Mar 2010 17:46:46 +0100
Message-ID: <4BA258F6.1050909@trash.net>
References: <20100316232247.4185.19426.stgit@decadence> <20100316232957.4185.46217.stgit@decadence> <4BA0F4C0.8050901@trash.net> <4BA10095.2030905@netfilter.org> <4BA22463.6050601@trash.net> <4BA25612.3080804@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52395 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182Ab0CRQqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 12:46:48 -0400
In-Reply-To: <4BA25612.3080804@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>> Pablo Neira Ayuso wrote:
>>> Yes, allocation is a different situation but we still report ENOBUFS to
>>> user-space. I think that NETLINK_RECV_NO_ENOBUFS is there to a) disable
>>> ENOBUFS reports to user-space and b) disable Netlink congestion.
>>>
>>>> Is there any problem with these errors?
>>> Specifically in ctnetlink, if we fail to allocate a message in ctnetlink
>>> and NETLINK_RECV_NO_ENOBUFS is set, we still lose an event and that
>>> should not happen.
>> I assume you mean "not set"? Otherwise I fail to follow :)
> 
> OK, I'll try again :-)
> 
> Currently, no matter if NETLINK_RECV_NO_ENOBUFS is set or not: if we
> fail to allocate the netlink message, then ctnetlink_conntrack_event()
> returns 0. Thus, we report ENOBUFS to user-space and we lose the event.
> 
> With my patches, if NETLINK_RECV_NO_ENOBUFS is set and we fail to
> allocate the message, we don't report ENOBUFS and we don't lose the event.

That last part is what keeps confusing me. With your patch, if the
ENOBUFS options is set, we don't report the error to userspace
and therefore don't return it to conntrack, thus we *do* loose the
event. Which is correct however.

Did I get it right this time? :)

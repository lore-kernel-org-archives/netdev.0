From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/3] netlink: fix NETLINK_RECV_NO_ENOBUFS in netlink_set_err()
Date: Thu, 18 Mar 2010 18:01:54 +0100
Message-ID: <4BA25C82.7000301@netfilter.org>
References: <20100316232247.4185.19426.stgit@decadence> <20100316232957.4185.46217.stgit@decadence> <4BA0F4C0.8050901@trash.net> <4BA10095.2030905@netfilter.org> <4BA22463.6050601@trash.net> <4BA25612.3080804@netfilter.org> <4BA258F6.1050909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58124 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753039Ab0CRSCJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 14:02:09 -0400
In-Reply-To: <4BA258F6.1050909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Pablo Neira Ayuso wrote:
>> Patrick McHardy wrote:
>>> Pablo Neira Ayuso wrote:
>>>> Yes, allocation is a different situation but we still report ENOBUFS to
>>>> user-space. I think that NETLINK_RECV_NO_ENOBUFS is there to a) disable
>>>> ENOBUFS reports to user-space and b) disable Netlink congestion.
>>>>
>>>>> Is there any problem with these errors?
>>>> Specifically in ctnetlink, if we fail to allocate a message in ctnetlink
>>>> and NETLINK_RECV_NO_ENOBUFS is set, we still lose an event and that
>>>> should not happen.
>>> I assume you mean "not set"? Otherwise I fail to follow :)
>> OK, I'll try again :-)
>>
>> Currently, no matter if NETLINK_RECV_NO_ENOBUFS is set or not: if we
>> fail to allocate the netlink message, then ctnetlink_conntrack_event()
>> returns 0. Thus, we report ENOBUFS to user-space and we lose the event.
>>
>> With my patches, if NETLINK_RECV_NO_ENOBUFS is set and we fail to
>> allocate the message, we don't report ENOBUFS and we don't lose the event.
> 
> That last part is what keeps confusing me. With your patch, if the
> ENOBUFS options is set, we don't report the error to userspace
> and therefore don't return it to conntrack, thus we *do* loose the
> event. Which is correct however.

Sorry, I'm being a bit imprecise myself: we do lose the event anyway.
However, with my patch, if the NO_ENOBUFS option is set, we keep the
event in the ctevent cache, so we can try to deliver it again with the
next packet (this is what I initially meant with "we don't lose the
event", yes, confusing...).

> Did I get it right this time? :)

I think so! :-)

From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] netlink: add socket destruction notification
Date: Mon, 09 Nov 2009 13:59:27 +0100
Message-ID: <4AF8122F.9060807@trash.net>
References: <1254473048.3959.76.camel@johannes.local>	 <4AF43EF9.3020707@trash.net> <1257521204.29454.31.camel@johannes.local>	 <4AF442C2.9040704@trash.net> <1257762132.29454.161.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38760 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754730AbZKIM71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 07:59:27 -0500
In-Reply-To: <1257762132.29454.161.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
> On Fri, 2009-11-06 at 16:37 +0100, Patrick McHardy wrote:
> 
>>>> This seems pretty similar to the NETLINK_URELEASE notifier invoked
>>>> in netlink_release(). Wouldn't that one work as well?
>>> Hmm, it does seem similar, thanks for pointing it out. What exactly does
>>> the condition
>>> 	if (nlk->pid && !nlk->subscriptions) {
>>>
>>> mean though?
>> nlk->pid is non-zero for bound sockets, which is basically any
>> non-kernel socket which has either sent a message or explicitly
>> called bind(). nlk->subscriptions is zero for sockets not bound
>> to multicast groups.
>>
>> So effectively it invokes the notifier for all bound unicast
>> userspace sockets. Not sure why it doesn't invoke the notifier
>> for sockets that are used for both unicast and multicast
>> reception. If that is a problem I think the second condition
>> could be removed.
> 
> Thanks for the explanation. I think we'd need the second condition
> removed, I don't see a reason to force a socket to not also have
> multicast RX if it's used for any of the purposes we're looking at this
> for. Guess we need to audit the callees to determine whether that's ok.

I've already done that. Its currently only used by netfilter
for which this change also makes sense.

> Can you quickly explain the difference between release and destruct?

release is called when the socket is closed, destruct is called
once all references are gone. I think with the synchonous processing
done nowadays they shouldn't make any difference, but release
should be fine in either case.

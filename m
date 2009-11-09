From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] netlink: add socket destruction notification
Date: Mon, 09 Nov 2009 14:19:15 +0100
Message-ID: <4AF816D3.7000304@trash.net>
References: <1254473048.3959.76.camel@johannes.local>	 <4AF43EF9.3020707@trash.net> <1257521204.29454.31.camel@johannes.local>	 <4AF442C2.9040704@trash.net> <1257762132.29454.161.camel@johannes.local>	 <4AF8122F.9060807@trash.net> <1257771787.29454.173.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39368 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754730AbZKINTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 08:19:14 -0500
In-Reply-To: <1257771787.29454.173.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
> On Mon, 2009-11-09 at 13:59 +0100, Patrick McHardy wrote:
> 
>>> Thanks for the explanation. I think we'd need the second condition
>>> removed, I don't see a reason to force a socket to not also have
>>> multicast RX if it's used for any of the purposes we're looking at this
>>> for. Guess we need to audit the callees to determine whether that's ok.
>> I've already done that. Its currently only used by netfilter
>> for which this change also makes sense.
> 
> Cool, I arrived at that conclusion too, it seemed that it would
> currently be somewhat strangely broken if you could add multicast groups
> to those sockets used there. Not sure if you can though.

I don't see anything preventing it.

>>> Can you quickly explain the difference between release and destruct?
>> release is called when the socket is closed, destruct is called
>> once all references are gone. I think with the synchonous processing
>> done nowadays they shouldn't make any difference, but release
>> should be fine in either case.
> 
> Ok, cool, thanks. Do you want me to send the change removing the
> multicast check, or would you want to do that since you audited all the
> netlink callers?

Please go ahead.

> Also, it's called URELEASE for unicast -- should we rename it to just
> RELEASE?

I think URELEASE is still fine since won't necessarily get called
for sockets that are used for pure multicast reception when using
setsockopt to bind to groups. I also have a cleanup patch removing
unneccessary nlk->pid checks from netfilter which would clash with
a rename :)

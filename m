From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] netlink: add socket destruction notification
Date: Mon, 09 Nov 2009 17:57:26 +0100
Message-ID: <4AF849F6.4050308@trash.net>
References: <1254473048.3959.76.camel@johannes.local>	 <4AF43EF9.3020707@trash.net> <1257521204.29454.31.camel@johannes.local>	 <4AF442C2.9040704@trash.net> <1257762132.29454.161.camel@johannes.local>	 <4AF8122F.9060807@trash.net> <1257771787.29454.173.camel@johannes.local>	 <4AF816D3.7000304@trash.net> <1257785502.29454.178.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44985 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491AbZKIQ5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 11:57:25 -0500
In-Reply-To: <1257785502.29454.178.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
> On Mon, 2009-11-09 at 14:19 +0100, Patrick McHardy wrote:
> 
>>> Ok, cool, thanks. Do you want me to send the change removing the
>>> multicast check, or would you want to do that since you audited all the
>>> netlink callers?
>> Please go ahead.
> 
> Will do.
> 
>>> Also, it's called URELEASE for unicast -- should we rename it to just
>>> RELEASE?
>> I think URELEASE is still fine since won't necessarily get called
>> for sockets that are used for pure multicast reception when using
>> setsockopt to bind to groups.
> 
> Oh? So on which sockets can I rely on it being used? After sending at
> least one unicast message into the kernel? This seems to depend on pid
> being assigned -- when is that?

All unicast sockets that have either manually or automatically
bound. Automatic binding happens when sending the first message
or when calling connect().

Before that, your code can't know of the sockets existance, so
I guess this should be fine.

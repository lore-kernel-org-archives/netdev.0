From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] netlink: add socket destruction notification
Date: Fri, 06 Nov 2009 16:37:38 +0100
Message-ID: <4AF442C2.9040704@trash.net>
References: <1254473048.3959.76.camel@johannes.local>	 <4AF43EF9.3020707@trash.net> <1257521204.29454.31.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64740 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517AbZKFPhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 10:37:35 -0500
In-Reply-To: <1257521204.29454.31.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
> On Fri, 2009-11-06 at 16:21 +0100, Patrick McHardy wrote:
>> Johannes Berg wrote:
>>> When we want to keep track of resources associated with applications, we
>>> need to know when an app is going away. Add a notification function to
>>> netlink that tells us that, and also hook it up to generic netlink so
>>> generic netlink can notify the families. Due to the way generic netlink
>>> works though, we need to notify all families and they have to sort out
>>> whatever resources some commands associated with the socket themselves.
> 
> 
>> This seems pretty similar to the NETLINK_URELEASE notifier invoked
>> in netlink_release(). Wouldn't that one work as well?
> 
> Hmm, it does seem similar, thanks for pointing it out. What exactly does
> the condition
> 	if (nlk->pid && !nlk->subscriptions) {
> 
> mean though?

nlk->pid is non-zero for bound sockets, which is basically any
non-kernel socket which has either sent a message or explicitly
called bind(). nlk->subscriptions is zero for sockets not bound
to multicast groups.

So effectively it invokes the notifier for all bound unicast
userspace sockets. Not sure why it doesn't invoke the notifier
for sockets that are used for both unicast and multicast
reception. If that is a problem I think the second condition
could be removed.

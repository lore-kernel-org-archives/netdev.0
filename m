From: Patrick McHardy <kaber@trash.net>
Subject: Re: multicasting netlink messages to groups > 31 from userspace
Date: Wed, 04 Jul 2007 16:30:40 +0200
Message-ID: <468BAF10.6080208@trash.net>
References: <1183492286.4021.21.camel@johannes.berg>	 <468BAADC.4030203@trash.net> <1183558702.3812.33.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38773 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758557AbXGDObr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 10:31:47 -0400
In-Reply-To: <1183558702.3812.33.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Wed, 2007-07-04 at 16:12 +0200, Patrick McHardy wrote:
> 
>>Johannes Berg wrote:
>>
>>>Hey,
>>>
>>>Looking through the code that uses NL_NONROOT_SEND I just realised that
>>>it's impossible to send multicast messages from userspace to multicast
>>>groups with IDs higher than 31. That's not really good given that
>>>everywhere else we handle multicast groups up to 2^32-1 :/
>>
>>
>>Why do you want to send to a multicast group from userspace?
> 
> 
> Why not, what's wrong with that?


The kernel doesn't have any multicast listeners (yet).

> Actually, I think I mentioned this earlier, I was thinking about doing
> wireless configuration as a group where both the kernel and possibly a
> userspace process listen on that multicast group and processes that want
> to configure a device just send to that group. Then the kernel ignores
> the message if a userspace process is handling the specific device
> completely. For example changing the BSSID: if the kernel is doing MLME
> then it changes the BSSID, but if a userspace process is doing it then
> the kernel doesn't do anything since BSSID changing is a pure MLME
> function, but for consistency it'd be nice if both could be done the
> same way, hence a multicast group.
> 
> This was actually suggested by Herbert since it's easy to find out if
> that multicast group has a listener and not so easy if a special generic
> netlink socket in userspace is (still) open.


I wonder if thats really a good idea to use multicast for device
configuration. Unicast transmissions from userspace to kernel
are reliable when you don't use MSG_DONTWAIT. For multicasts
doing the same would mean blocking on each receiver when the
receive queue is full.

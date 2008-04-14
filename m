From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-rc9: Reported regressions from 2.6.24
Date: Mon, 14 Apr 2008 10:50:04 +0200
Message-ID: <48031ABC.9010502@trash.net>
References: <RR4Oy_oXY2J.A.b0H.A3lAIB@albercik> <480262E9.4030500@trash.net> <4803184E.1050102@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, andy@greyhouse.net
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33847 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754681AbYDNIuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 04:50:10 -0400
In-Reply-To: <4803184E.1050102@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> Patrick McHardy wrote:
>> Rafael J. Wysocki wrote:
>>> This message contains a list of some regressions from 2.6.24, for which there
>>> are no fixes in the mainline I know of.  If any of them have been fixed already,
>>> please let me know.
>>>
>>>
>>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=10323
>>> Subject		: panic using bridging on linus kernel 2.6.25-rc6
>>> Submitter	: Andy Gospodarek <andy@greyhouse.net>
>>> Date		: 2008-03-25 11:40 (20 days old)
>> This looks like another network-namespace regression.
>> icmp_send() does:
>>
>>         net = rt->u.dst.dev->nd_net;
>>
>> The bridge netfilter code attaches a fake dst_entry to the
>> skb which has dev == NULL when passing it to IPv4 netfilter.
>>
>> Pavel, do you have a better ideas for fixing this than
>> instantiating a dst_entry in br_netfilter.c for every
>> device (or at least for every namespace)?
> 
> Hm... Why not make this dst entry point to looback device? This would
> allow us to make the dst entry per-namespace and instantiate it with
> the ns's lo.


I thought of that myself, but that will result in MTU problems.
The current way is not ideal either (hardcoded MTU of 1500 for
the fake net_device), but that at least works in normal bridge
setups.

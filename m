From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: 2.6.25-rc9: Reported regressions from 2.6.24
Date: Mon, 14 Apr 2008 12:39:42 +0400
Message-ID: <4803184E.1050102@openvz.org>
References: <RR4Oy_oXY2J.A.b0H.A3lAIB@albercik> <480262E9.4030500@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, andy@greyhouse.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:54587 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753494AbYDNIkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 04:40:40 -0400
In-Reply-To: <480262E9.4030500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Rafael J. Wysocki wrote:
>> This message contains a list of some regressions from 2.6.24, for which there
>> are no fixes in the mainline I know of.  If any of them have been fixed already,
>> please let me know.
>>
>>
>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=10323
>> Subject		: panic using bridging on linus kernel 2.6.25-rc6
>> Submitter	: Andy Gospodarek <andy@greyhouse.net>
>> Date		: 2008-03-25 11:40 (20 days old)
> 
> This looks like another network-namespace regression.
> icmp_send() does:
> 
>         net = rt->u.dst.dev->nd_net;
> 
> The bridge netfilter code attaches a fake dst_entry to the
> skb which has dev == NULL when passing it to IPv4 netfilter.
> 
> Pavel, do you have a better ideas for fixing this than
> instantiating a dst_entry in br_netfilter.c for every
> device (or at least for every namespace)?

Hm... Why not make this dst entry point to looback device? This would
allow us to make the dst entry per-namespace and instantiate it with
the ns's lo.

Thanks,
Pavel

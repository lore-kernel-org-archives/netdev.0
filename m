From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-rc9: Reported regressions from 2.6.24
Date: Sun, 13 Apr 2008 22:06:24 +0200
Message-ID: <480267C0.6020402@trash.net>
References: <RR4Oy_oXY2J.A.b0H.A3lAIB@albercik> <480262E9.4030500@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	andy@greyhouse.net
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51539 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752595AbYDMUJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 16:09:53 -0400
In-Reply-To: <480262E9.4030500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[CC list trimmed slightly]

Patrick McHardy wrote:
> Rafael J. Wysocki wrote:
>> This message contains a list of some regressions from 2.6.24, for 
>> which there
>> are no fixes in the mainline I know of.  If any of them have been 
>> fixed already,
>> please let me know.
>>
>>
>> Bug-Entry    : http://bugzilla.kernel.org/show_bug.cgi?id=10323
>> Subject        : panic using bridging on linus kernel 2.6.25-rc6
>> Submitter    : Andy Gospodarek <andy@greyhouse.net>
>> Date        : 2008-03-25 11:40 (20 days old)
>
> This looks like another network-namespace regression.
> icmp_send() does:
>
>        net = rt->u.dst.dev->nd_net;
>
> The bridge netfilter code attaches a fake dst_entry to the
> skb which has dev == NULL when passing it to IPv4 netfilter.
>
> Pavel, do you have a better ideas for fixing this than
> instantiating a dst_entry in br_netfilter.c for every
> device (or at least for every namespace)? 

The description of the problem was not entirely correct, the
bridge-netfilter dst_entry does have a proper device pointer,
it points to a dummy net_device structure however that doesn't
have a namespace associated with it. This blows up in
__ip_route_output_key.


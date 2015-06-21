From: Markus Stenberg <markus.stenberg@iki.fi>
Subject: Re: [PATCH] ipv6: Fixed source specific default route handling.
Date: Mon, 22 Jun 2015 00:01:54 +0100
Message-ID: <142D0D97-B67D-4A39-BBF5-225D1C861C1B@iki.fi>
References: <7922B483-7EA7-4B50-BF1C-7681EB7CC454@iki.fi> <5586F1F8.1070800@universe-factory.net> <0D0CB420-018B-465C-B27B-72016F41C268@iki.fi> <55873C46.4090804@universe-factory.net>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Steven Barth <steven@midlink.org>
To: Matthias Schiffer <mschiffer@universe-factory.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-out1.inet.fi ([62.71.2.229]:58791 "EHLO kirsi2.inet.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342AbbFUXNH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 19:13:07 -0400
In-Reply-To: <55873C46.4090804@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You have /128 dst. To override it you need dst/128 AND src/>0 route. ( or just /128 dst and higher metric). 

Sorry if I am bit unclear - can explain better given real keyboard but that is avail only week from now. 

-Markus

(on the road, via iPhone)

21.6.2015 23.35、Matthias Schiffer <mschiffer@universe-factory.net> のメッセージ:

>> On 06/22/2015 12:05 AM, Markus Stenberg wrote:
>> Prefsrc is essentially historic non IPv6 construct. IPv6 SAS is based on dst, src, metric ordered lookup just like the routing is too ( lookup rfc, some src specific routing drafts for details ). 
>> 
>> Therefore I do not see a problem. If you want specific SA, add same route with higher metric and/or (more) specific src match. 
>> 
>> There might be bugs there tho, but that is how it should work. As SAS is supposed to happen before routing ( see rfc ) the prefsrc is .. Cough.
>> 
>> -Markus
> 
> Could you explain in detail what you mean with "If you want specific SA,
> add same route with higher metric and/or (more) specific src match."?
> Routes aren't bound to specific addresses except via the "src" attribute
> (which is called prefsrc in the kernel), which is exactly what it not
> working. I can't control the chosen source address at all when
> source-specific routes are involved.
> 
> Also, metric-based route selection is broken when source-specific routes
> are involved. The commands mentioned in my first mail will create the
> following configuration:
> 
> # ip a
> 3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state
> UNKNOWN group default qlen 500
>    link/ether 22:46:f4:9c:9e:3a brd ff:ff:ff:ff:ff:ff
>    inet6 fd00::20/64 scope global
>       valid_lft forever preferred_lft forever
>    inet6 fe80::2046:f4ff:fe9c:9e3a/64 scope link
>       valid_lft forever preferred_lft forever
> 4: test@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
> state UNKNOWN group default
>    link/ether ae:2b:02:16:23:0f brd ff:ff:ff:ff:ff:ff
>    inet6 fd00::1/128 scope global
>       valid_lft forever preferred_lft forever
>    inet6 fe80::ac2b:2ff:fe16:230f/64 scope link
>       valid_lft forever preferred_lft forever
> 
> # ip -6 r
> fd00::/64 from fd00::/64 dev eth0 metric 1024
> fd00::1 dev test proto kernel metric 256
> fd00::/64 dev eth0 proto kernel metric 256
> 
> The only route I have added manually is the source-specific one, the
> other two have been created by address assignment. Adding a "src"
> address to the source-specific route has no effect.
> 
> Even though the source-specific route has a higher metric than the
> generic one, the source-specific one shadows the generic route.
> 
> Thanks for your reply,
> Matthias
> 

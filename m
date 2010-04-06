From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: Re: [RFC PATCH 1/2] netdev: buffer infrastructure to log network
 driver's information
Date: Tue, 06 Apr 2010 14:43:59 +0900
Message-ID: <4BBACA1F.9030702@jp.fujitsu.com>
References: <4BB98828.5030302@jp.fujitsu.com> <4BB988C9.9070709@jp.fujitsu.com> <1270456946.1971.27.camel@edumazet-laptop> <20100405.123155.263974951.davem@davemloft.net> <20100406001034.GA2156@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, izumi.taku@jp.fujitsu.com,
	kaneshige.kenji@jp.fujitsu.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:35963 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992Ab0DFFnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 01:43:52 -0400
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o365hoJE028601
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Tue, 6 Apr 2010 14:43:50 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 29F7345DE4F
	for <netdev@vger.kernel.org>; Tue,  6 Apr 2010 14:43:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 065BE45DE4E
	for <netdev@vger.kernel.org>; Tue,  6 Apr 2010 14:43:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D7E4FE38004
	for <netdev@vger.kernel.org>; Tue,  6 Apr 2010 14:43:49 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AE501DB803B
	for <netdev@vger.kernel.org>; Tue,  6 Apr 2010 14:43:49 +0900 (JST)
In-Reply-To: <20100406001034.GA2156@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2010/04/06 9:10), Neil Horman wrote:
> On Mon, Apr 05, 2010 at 12:31:55PM -0700, David Miller wrote:
>> From: Eric Dumazet<eric.dumazet@gmail.com>
>> Date: Mon, 05 Apr 2010 10:42:26 +0200
>>
>>> Le lundi 05 avril 2010 =C3=A0 15:52 +0900, Koki Sanagi a =C3=A9crit=
 :
>>>> This patch implements buffer infrastructure under driver/net.
>>>> This buffer records information from network driver.
>>>>
>>>> Signed-off-by: Koki Sanagi<sanagi.koki@jp.fujitsu.com>
>>>> ---
>>>>    drivers/net/Kconfig     |    8 +
>>>>    drivers/net/Makefile    |    1 +
>>>>    drivers/net/ndrvbuf.c   |  535 ++++++++++++++++++++++++++++++++=
+++++++++++++++
>>>>    include/linux/ndrvbuf.h |   57 +++++
>>>>    4 files changed, 601 insertions(+), 0 deletions(-)
>>>>
>>>
>>> Wow, 600 lines... thats what I call bloat...
>>
>> And we have all sorts of facilities for creating filesystem
>> streams and ring buffers of debug information.
>>
>> You could even hook into 'perf' to log and process these
>> events in probably like 12 lines of code.
>>
> I'm still having a hard time understanding why this approach is prefe=
rable to
> the previous approach you took using tracepoints.  Granted you can't =
get driver
> internal state as easily, but its generic and doesn't do...this.
> Neil
>
>
>

We can get below information with this patch

1. Driver operates normaly or not
2. Tx ring's state

About 1, the preivous approach meets, but about 2, some hooks need in d=
river
code like this patch. If we get it, it is available to solute "Tx Unit =
Hung"
message. This message indicates that tx descriptor ring's process is no=
t smooth.
When a countermeasure was taken to system that outputs "Tx Unit Hung" m=
essage,
this state information is available to evaluate a countermeasure.
But what you say is true, this patch is not generic.
it may be good to rebase the previous approach to focus on 1.
And it is better to consider separately about 2.



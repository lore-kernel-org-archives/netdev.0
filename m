From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: HTB, HFSC, PIE, FIFO stuck on 2.4Gbit on default values
Date: Wed, 04 Nov 2015 06:12:14 +0200
Message-ID: <0394a0a8c8f65e367a596274719ed759@visp.net.lb>
References: <14bd7629199800f798c8ab932e0285d3@visp.net.lb>
 <1446577894.23275.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <907cb54c0a27beed12381247ba29bca5@visp.net.lb>
 <1446580156.23275.74.camel@edumazet-glaptop2.roam.corp.google.com>
 <f970215bd46efe3ea3dc5c7fccfa0509@visp.net.lb>
 <1446585826.23275.78.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:42371 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754507AbbKDEMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 23:12:18 -0500
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id DEE0B480CE9
	for <netdev@vger.kernel.org>; Wed,  4 Nov 2015 06:12:16 +0200 (EET)
In-Reply-To: <1446585826.23275.78.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-11-03 23:23, Eric Dumazet wrote:
> On Tue, 2015-11-03 at 22:24 +0200, Denys Fedoryshchenko wrote:
> 
>> I wont argue on that, you are right.
>> Ok, then it is a bit offtopic in current case, different setup, but i
>> know this one has easy to reproduce issues with offloading. but this 
>> is
>> bug related to that, directly appearing when i enable tso/gso/gro. I 
>> am
>> losing access to remote box, so max i can do right now:
>> ethtool -K eth0 tso on gso on gro on; sleep 5;ethtool -K eth0 tso off
>> gso off gro off
>> 
>> No shapers, just plain nat. I suspect it might be specific to network
>> card, but not sure.
>> 
> 
> 
> 
> What happens if you enable gro, but disable tso ?
> 
> With GRO enabled, you'll get a good performance increase, as forwarding
> and qdisc will use big packets.
Just enabling gro or gso (or together) is fine there. Thanks for advice. 
Seems only tso causing problems.
Also i guess if i keep tso disabled, it will solve my MTU issues (i had 
once issue, that traffic heading to pppoe users,
who have 14xx mtu, was blocked, when offloading enabled on transit 
server, but can't reproduce it quickly again).
Should i try to report to e1000e maintainers this bug? On similar setup 
it is happening only at specific locations,
but i am not definitely sure what can be the reason.

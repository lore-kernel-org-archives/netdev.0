From: Andreas Tobler <andreas.tobler@cloudguard.ch>
Subject: Re: Problems with mvneta
Date: Mon, 23 Oct 2017 08:29:33 +0200
Message-ID: <01d0cd47-20ef-bbad-cd93-749cc94d0d2f@cloudguard.ch>
References: <20171018223425.42ce7a74@gmx.de>
 <20171018225557.43837338@windsurf.home> <20171020002524.4b4cf122@gmx.de>
 <20171020090956.2b6cc34b@windsurf.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?Q?Gr=c3=a9gory_Clement?=
        <gregory.clement@free-electrons.com>,
        =?UTF-8?Q?Antoine_T=c3=a9nart?= <antoine.tenart@free-electrons.com>,
        netdev@vger.kernel.org, Marcin Wojtas <mw@semihalf.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        =?UTF-8?Q?Sven_M=c3=bcller?= <musv@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.wlp.is ([185.12.129.23]:44106 "EHLO smtp.wlp.is"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751207AbdJWGge (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Oct 2017 02:36:34 -0400
In-Reply-To: <20171020090956.2b6cc34b@windsurf.home>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,


On 20.10.17 09:09, Thomas Petazzoni wrote:
> Hello,
> 
> On Fri, 20 Oct 2017 00:25:24 +0200, Sven Müller wrote:
> 
>> First of all I'm not familiar with kernel programming at all, so
>> please excuse me, if I don't understand everything at the first
>> glance.
> 
> No problem. Your bug report and effort to nail down the issue are much
> appreciated!
> 
>> It compiles and runs fine. After a couple of hours and testing no
>> issues were found.
> 
> OK, so this really hints at a regression in the mvneta driver itself.
> 
> Could you try to revert just:
> 
>    6ad20165d376fa07919a70e4f43dfae564601829
>    a29b6235560a1ed10c8e1a73bfc616a66b802b90
>    2a90f7e1d5d04e4f1060268e0b55a2c702bbd67a
> 
> first all of them, and then each one by one, so that we can pin-point
> the commit that causes the breakage ?
> 
> I looked at all the other changes in mvneta between 4.10 and 4.12, and
> I don't see how any of the other changes can cause a functional
> difference. So let's focus on those 3 commits for the moment.

We did also experience some issues with the mvneta driver.

I nailed it down to the BQL commit. 
(a29b6235560a1ed10c8e1a73bfc616a66b802b90 net: mvneta: add BQL support)

Here we did an upgrade from 4.10.13 to 4.13.5. Before it was stable and 
a 4.13.5 with the 4.10.13 driver was also ok.

Our scenario is the following, the board we use acts as router and 
forwards some traffic. To distribute the load to both cpu's we have, we 
enabled RPS (receive packet steering). Now as soon as we stress the 
router with iperf3 the eth links go down. The router sits between a 
client and a server where we blow load with iperf3.

If we disable RPS, the links seems stable.

Doing the iperf3 tests from/to the router directly, iperf3 client is 
started on the router, does not show any instability.

Maybe these observations help to find out what's going on.

Thx,
Andreas

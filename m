From: Sven =?UTF-8?B?TcO8bGxlcg==?= <musv@gmx.de>
Subject: Re: Problems with mvneta
Date: Mon, 23 Oct 2017 11:30:24 +0200
Message-ID: <20171023113024.7138970e@r84n0nz>
References: <20171018223425.42ce7a74@gmx.de>
        <20171018225557.43837338@windsurf.home>
        <20171020002524.4b4cf122@gmx.de>
        <20171020090956.2b6cc34b@windsurf.home>
        <01d0cd47-20ef-bbad-cd93-749cc94d0d2f@cloudguard.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        =?UTF-8?B?R3I=?= =?UTF-8?B?w6lnb3J5?= Clement
        <gregory.clement@free-electrons.com>,
        Antoine =?UTF-8?B?VMOpbmFydA==?=
        <antoine.tenart@free-electrons.com>, netdev@vger.kernel.org,
        Marcin Wojtas <mw@semihalf.com>
To: Andreas Tobler <andreas.tobler@cloudguard.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:56907 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751116AbdJWJab (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Oct 2017 05:30:31 -0400
In-Reply-To: <01d0cd47-20ef-bbad-cd93-749cc94d0d2f@cloudguard.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've tested a lot on weekend, but the results are still contradictory and therefore not reliable enough.

Kernel 4.13.7 with driver of that version: 

Reverted all 3 patches: 6ad2, a29b, 2a90: works fine. No issues.
Applied only 6ad2: Got the nfs socket shutdown error on the first test, but yesterday it has been worked perfectly for a lot of hours. 
Applied only a29b: No issues
Applied only 2a90: No issues. 
Applied a29b and 2a90: No issues. 

The main problem is to create a reproducible crash scenario. 

Regards
Sven

Am Mon, 23 Oct 2017 08:29:33 +0200
schrieb Andreas Tobler <andreas.tobler@cloudguard.ch>:

> Hi all,
> 
> 
> We did also experience some issues with the mvneta driver.
> 
> I nailed it down to the BQL commit. 
> (a29b6235560a1ed10c8e1a73bfc616a66b802b90 net: mvneta: add BQL
> support)
> 
> Here we did an upgrade from 4.10.13 to 4.13.5. Before it was stable
> and a 4.13.5 with the 4.10.13 driver was also ok.
> 
> Our scenario is the following, the board we use acts as router and 
> forwards some traffic. To distribute the load to both cpu's we have,
> we enabled RPS (receive packet steering). Now as soon as we stress
> the router with iperf3 the eth links go down. The router sits between
> a client and a server where we blow load with iperf3.
> 
> If we disable RPS, the links seems stable.
> 
> Doing the iperf3 tests from/to the router directly, iperf3 client is 
> started on the router, does not show any instability.
> 
> Maybe these observations help to find out what's going on.
> 
> Thx,
> Andreas

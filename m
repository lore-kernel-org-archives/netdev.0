From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: One way TCP bottleneck over 6 x Gbit tecl aggregated link
Date: Fri, 20 Mar 2015 18:15:11 -0700
Message-ID: <1426900511.25985.38.camel@edumazet-glaptop2.roam.corp.google.com>
References: <201503210110.48980.wrosner@tirnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Wolfgang Rosner <wrosner@tirnet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34193 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723AbbCUBPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 21:15:14 -0400
Received: by igcau2 with SMTP id au2so1663210igc.1
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 18:15:13 -0700 (PDT)
In-Reply-To: <201503210110.48980.wrosner@tirnet.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-03-21 at 01:10 +0100, Wolfgang Rosner wrote:
> Hello, 
> 
> Im trying to configure a beowulf style cluster based on venerable HP blade 
> server hardware.
> I configured 6 parallel GBit vlans between 16 blade nodes and a gateway server 
> with teql link aggregation.
> 
> After lots of tuning, nearly everything runs fine (i.e. > 5,5 GBit/s iperf 
> transfer rate, which is 95 % of theoretical limit), but one bottleneck 
> remains left:
> 
> From gateway to blade nodes, I get only half of full rate if I use only a 
> single iperf process / single TCP link. 
> With 2 or more iperf in parallel, transfer rate is OK.
> 
> I don't see this bottleneck in the other direction, nor in the links between 
> the blade nodes: 
> there I have always > 5,5 GBit, even for a single process.
> 
> Is there just a some simple tuning paramter I overlooked, or do I have to dig 
> for a deeper cause?

What linux version runs on sender ?

Could you send output of :

nstat >/dev/null
iperf -c 192.168.130.225
nstat

Also, please send ss output while iperf is running as in :

(please use a recent ss command, found in iproute2 package :
https://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/  
so that it outputs the reordering level)

iperf -c 192.168.130.225 &
ss -temoi dst 192.168.130.225

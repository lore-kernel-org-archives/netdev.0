From: Rick Jones <rick.jones2@hp.com>
Subject: Re: large degradation in ip netns add/exec performance in 3.13?
Date: Tue, 11 Feb 2014 14:26:46 -0800
Message-ID: <52FAA3A6.9050608@hp.com>
References: <52F1461D.8050703@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:14462 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbaBKW0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 17:26:46 -0500
Received: from g9t2301.houston.hp.com (g9t2301.houston.hp.com [16.216.185.78])
	by g4t0016.houston.hp.com (Postfix) with ESMTP id 85CAB14002
	for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 22:26:46 +0000 (UTC)
Received: from [16.103.148.51] (tardy.usa.hp.com [16.103.148.51])
	by g9t2301.houston.hp.com (Postfix) with ESMTP id 6096B5C
	for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 22:26:46 +0000 (UTC)
In-Reply-To: <52F1461D.8050703@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/2014 11:57 AM, Rick Jones wrote:
> Hi -
>
> I have a dinky little script which creates what I've been calling "fake
> routers."  It is far from a complete fake router, but it shows what
> appears to be a very large degradation in performance in 3.13 compared
> to 3.12.9 which itself is slow compared to a 3.5.0-44 kernel canonical
> kernel with some upstream commits included:
>
>
> Start/End    Average Rate of Creation per Second
> "Router" Count  3.5.0-44+  3.12.9  3.13.0
> ------------------------------------------------------
> 0 to 250          7.58      5.56    2.55
> 250 to 500        7.14      5.81    2.55
> 500 to 750        6.41      5.56    2.55
> 750 to 1000       6.10      4.90    2.55
> 1000 to 1250      5.68      4.39    2.50
> 1250 to 1500      5.21      4.24    2.36
> 1500 to 1750      5.00      3.85    2.23
> 1750 to 2000      4.81      3.62    2.21
> 2000 to 2250      4.55      3.47    2.21
> 2250 to 2500      4.31      3.29    2.14
> 2500 to 2750      4.03      3.09    2.05
> 2750 to 3000      3.73      3.09    2.02
> 3000 to 3250      3.62      2.81    2.02
> 3250 to 3500      3.38      2.72    1.97
> 3500 to 3750      3.21      2.55    1.92
> 3750 to 4000      3.01      2.48    1.87

I see that the 3.13.0 kernel will scale rather well - out to 16 
concurrent streams creating these "fake routers" - it drops-off at 32, 
but this system is only 16 cores, 32 threads (two socket E5-2670) so I 
suppose that really shouldn't come as a surprise.

I did have the system lockup once at 16 concurrent streams on the 3.13.0 
kernel.  Didn't happen the next two times I tried.

happy benchmarking,

rick jones

Time,3.5.0-44+ 4streams,3.13.0 4 streams,3.13.0 8 streams,3.13.0 16 
streams,3.13.0 32 streams
0,0,0,0,0,0
30,518,419,840,1357,1327
60,914,826,1501,1988,1905
90,1242,1189,1995,2465,2332
120,1532,1519,2403,2872,2680
150,1792,1811,2751,3228,2985
180,2060,2089,3076,3537,3278
210,,2347,3359,3830,3542
232,,,,4016,
240,2447,2588,3627,,3778
270,,,3867,,
276,,,,,4032
289,,,4008,,
300,2808,2999,,,
330,,,,,
360,3131,3379,,,
390,,,,,
420,3418,3747,,,
450,,,,,
468,,4004,,,
480,3690,,,,
510,,,,,
540,3945,,,,
556,4004,,,,

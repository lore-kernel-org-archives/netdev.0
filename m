From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: be more strict before accepting ECN negociation
Date: Fri, 04 May 2012 13:36:30 -0700
Message-ID: <4FA43DCE.8040901@hp.com>
References: <1336144442.3752.348.camel@edumazet-glaptop> <4FA41B5B.5080103@hp.com> <1336155815.3752.365.camel@edumazet-glaptop> <4FA42491.2020104@hp.com> <1336158359.3752.382.camel@edumazet-glaptop> <4FA43A03.4090707@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Perry Lorier <perryl@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Wilmer van der Gaast <wilmer@google.com>,
	=?UTF-8?B?RGF2ZSBUw6RodA==?= <dave.taht@bufferbloat.net>,
	Ankur Jain <jankur@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:38276 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753868Ab2EDUgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 16:36:32 -0400
In-Reply-To: <4FA43A03.4090707@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2012 01:20 PM, Rick Jones wrote:
> True, I'm looking at more than the ECN bits, but in the 90 minutes the
> tcpdump has been running there have been no packets with the any of the
> 8 bits at ip[1] being 1 anyway :) Netperf.org doesn't get a massive
> quantity of traffic. It may go the entire week-end or longer without
> seeing such a packet.

I see fate is working as intended, or someone decided to try to feed me 
my words :) for within 6 minutes of my sending the above I got:

13:26:16.866007 IP (tos 0x3,CE, ttl 41, id 28850, offset 0, flags [DF], 
proto TCP (6), length 64)
     somesystemin.de.55363 > www.netperf.org.www: Flags [S], cksum 
0x4cfc (correct), seq 304457158, win 65535, options [mss 1460,nop,wscale 
3,nop,nop,TS val 288116308 ecr 0,sackOK,eol], length 0
13:26:17.831880 IP (tos 0x3,CE, ttl 41, id 6911, offset 0, flags [DF], 
proto TCP (6), length 64)
     somesystemin.de.55367 > www.netperf.org.www: Flags [S], cksum 
0x17aa (correct), seq 586073737, win 65535, options [mss 1460,nop,wscale 
3,nop,nop,TS val 288117270 ecr 0,sackOK,eol], length 0
13:26:17.831929 IP (tos 0x3,CE, ttl 41, id 28924, offset 0, flags [DF], 
proto TCP (6), length 64)
     somesystemin.de.55368 > www.netperf.org.www: Flags [S], cksum 
0x07cc (correct), seq 1513398047, win 65535, options [mss 
1460,nop,wscale 3,nop,nop,TS val 288117271 ecr 0,sackOK,eol], length 0
13:26:17.831952 IP (tos 0x3,CE, ttl 41, id 2494, offset 0, flags [DF], 
proto TCP (6), length 64)
     somesystemin.de.55366 > www.netperf.org.www: Flags [S], cksum 
0x75f4 (correct), seq 1153058420, win 65535, options [mss 
1460,nop,wscale 3,nop,nop,TS val 288117270 ecr 0,sackOK,eol], length 0
13:26:17.832177 IP (tos 0x3,CE, ttl 41, id 6854, offset 0, flags [DF], 
proto TCP (6), length 64)
     somesystemin.de.55365 > www.netperf.org.www: Flags [S], cksum 
0xfca0 (correct), seq 2332522875, win 65535, options [mss 
1460,nop,wscale 3,nop,nop,TS val 288117270 ecr 0,sackOK,eol], length 0
13:26:17.832239 IP (tos 0x3,CE, ttl 41, id 64733, offset 0, flags [DF], 
proto TCP (6), length 64)
     somesystemin.de.55364 > www.netperf.org.www: Flags [S], cksum 
0x7414 (correct), seq 1544827132, win 65535, options [mss 
1460,nop,wscale 3,nop,nop,TS val 288117270 ecr 0,sackOK,eol], length 0
13:26:38.649126 IP (tos 0x3,CE, ttl 41, id 9860, offset 0, flags [DF], 
proto TCP (6), length 64)
     somesystemin.de.55369 > www.netperf.org.www: Flags [S], cksum 
0x6270 (correct), seq 683091230, win 65535, options [mss 1460,nop,wscale 
3,nop,nop,TS val 288137968 ecr 0,sackOK,eol], length 0
13:26:39.417589 IP (tos 0x3,CE, ttl 41, id 13478, offset 0, flags [DF], 
proto TCP (6), length 64)
     somesystemin.de.55370 > www.netperf.org.www: Flags [S], cksum 
0x2862 (correct), seq 3168323595, win 65535, options [mss 
1460,nop,wscale 3,nop,nop,TS val 288138734 ecr 0,sackOK,eol], length 0

rick

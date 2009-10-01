From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] pkt_sched: gen_estimator: Dont report fake rate   estimators
Date: Thu, 01 Oct 2009 23:05:53 +0200
Message-ID: <4AC519B1.1090701@gmail.com>
References: <4AC4FE07.5070204@gmail.com> <20091001.123725.02194664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:24699 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbZJAVG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 17:06:57 -0400
Received: by fg-out-1718.google.com with SMTP id 22so1900122fge.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2009 14:07:00 -0700 (PDT)
In-Reply-To: <20091001.123725.02194664.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 10/01/2009 09:37 PM:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 01 Oct 2009 21:07:51 +0200
> 
>> We currently send TCA_STATS_RATE_EST elements to netlink users, even if no estimator
>> is running.
>>
>> # tc -s -d qdisc
>> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>>  Sent 112833764978 bytes 1495081739 pkt (dropped 0, overlimits 0 requeues 0)
>>  rate 0bit 0pps backlog 0b 0p requeues 0
>>
>> User has no way to tell if the "rate 0bit 0pps" is a real estimation, or a fake
>> one (because no estimator is active)
>>
>> After this patch, tc command output is :
>> $ tc -s -d qdisc
>> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>>  Sent 561075 bytes 1196 pkt (dropped 0, overlimits 0 requeues 0)
>>  backlog 0b 0p requeues 0
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> I'm generally fine with this idea.
> 
> The new behavior is certainly more intuitive even to me :-)
> 
> Unless there are other objections I'm ok with this and I'll apply

Since you ask... I wonder about this whole int plus quite a bit of
struct unreadability for one flag only. Maybe it could be queried
on qdisc level (with a flag if necessary), and additional parameter
of gnet_stats_copy_rate_est()? (Qdiscs should have no problem with
setting this param for their classes too.)


Jarek P.

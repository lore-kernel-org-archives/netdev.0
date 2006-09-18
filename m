From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH][RFC] Re: high latency with TCP connections
Date: Mon, 18 Sep 2006 10:11:19 -0700
Message-ID: <450ED337.8000700@hp.com>
References: <20060830100734.GA22235@isil.ipib.msu.ru>	<20060904160045.GA15599@ms2.inr.ac.ru> <44FDBA04.3080104@hp.com> <20060918.003938.26278728.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:15810 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S965305AbWIRRLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 13:11:23 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060918.003938.26278728.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Tue, 05 Sep 2006 10:55:16 -0700
> 
> 
>>Is this really necessary?  I thought that the problems with ABC were in 
>>trying to apply byte-based heuristics from the RFC(s) to a 
>>packet-oritented cwnd in the stack?
> 
> 
> This is receiver side, and helps a sender who does congestion
> control based upon packet counting like Linux does.   It really
> is less related to ABC than Alexey implies, we've always had
> this kind of problem as I mentioned in previous talks in the
> past on this issue.

For a connection receiving nothing but sub-MSS segments this is going to 
non-trivially increase the number of ACKs sent no?  I would expect an 
unpleasant increase in service demands on something like a "burst 
enabled" (./configure --enable-burst) netperf TCP_RR test:

netperf -t TCP_RR -H foo -- -b N   # N > 1

to increase as a result.   Pipelined HTTP would be like that, some NFS 
over TCP stuff too, maybe X traffic, other "transactional" workloads as 
well - maybe Tuxeudo.

rick jones

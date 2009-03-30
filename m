From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] netfilter: finer grained nf_conn locking
Date: Mon, 30 Mar 2009 15:44:19 -0700
Message-ID: <49D14B43.6030203@hp.com>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.679540125@vyatta.com>	<499BDB5D.2050105@trash.net> <499C1894.7060400@cosmosbay.com>	<49CE568A.9090104@cosmosbay.com> <49D11635.2050809@hp.com>	<Pine.LNX.4.64.0903302131390.13325@ask.diku.dk>	<49D12387.20507@cosmosbay.com>	<Pine.LNX.4.64.0903302224120.13385@ask.diku.dk> <49D12E87.4090005@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:30596 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758810AbZC3WoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 18:44:24 -0400
In-Reply-To: <49D12E87.4090005@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Indeed, tbench is a mix of tcp and process scheduler test/bench

If I were inclined to run networking tests (eg netperf) over loopback and wanted 
to maximize the trips up and down the protocol stack while minimizing scheduler 
overheads, I might be inclinded to configure --enable-burst with netperf and then 
run N/2 concurrent instances of something like:

netperf -T M,N -t TCP_RR -l 30 -- -b 128 -D &

where M and N were chosen to have each netperf and netserver pair bound to a pair 
of suitable cores, and the value in the -b option wash picked to maximize the CPU 
utilization on those cores.  Then, in theory there would be little to no process 
to process context switching and presumably little in the way of scheduler effect.

What I don't know is if such a setup would have both netperf and netserver each 
consuming 100% of a CPU or if one of them might "peg" before the other.  If one 
did peg before the other, I might be inclined to switch to running N concurrent 
instances, with -T M to bind each  netperf/netserver pair to the same core. 
There would then be the process to process context switching though it would be 
limited to "related" processes.

rick jones

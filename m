From: Rick Jones <rick.jones2@hp.com>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Tue, 27 Jan 2009 11:24:54 -0800
Message-ID: <497F5F86.9010101@hp.com>
References: <497E361B.30909@hp.com>	<497E42F4.7080201@cosmosbay.com>	<497E44F6.2010703@hp.com>	<497ECF84.1030308@cosmosbay.com>	<497ED0A2.6050707@trash.net>	<497F350A.9020509@cosmosbay.com>	<497F457F.2050802@trash.net> <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Netfilter Developers <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:2371 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755278AbZA0TY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 14:24:59 -0500
In-Reply-To: <497F5BCD.9060807@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I will give it a try and let folks know the results - unless told 
>> otherwise, I will ass-u-me I only need rerun the "full_iptables" test 
>> case.
> 
> 
> The runemomniagg2.sh script is still running, but the initial cycles 
> profile suggests that the main change is converting the write_lock time 
> into spinlock contention time with 78.39% of the cycles spent in 
> ia64_spinlock_contention. When the script completes I'll upload the 
> profiles and the netperf results to the same base URL as in the basenote 
> under "contrack01/"

The script completed - although at some point I hit an fd limit - I think I have 
an fd leak in netperf somewhere :( .

Anyhow, there are still some netperfs that end-up kicking the bucket during the 
run - I suspect starvation because where in the other configs (no iptables, and 
empty iptables) each netperf seems to consume about 50% of a CPU - stands to 
reason - 64 netperfs, 32 cores - in the "full" case I see many netperfs consuming 
100% of a CPU.  My gut is thinking that one or more netperf contexts gets stuck 
doing something on behalf of others.  There is also ksoftirqd time for a few of 
those processes.

Anyhow, the spread on trans/s/netperf is now 600 to 500 or 6000, which does 
represent an improvement.

rick jones

PS - just to be certain that running-out of fd's didn't skew the results I'm 
rerunning the script with ulimit -n 10240 and will see if that changes the 
results any.  And I suppose I need to go fd leak hunting in netperf omni code :(

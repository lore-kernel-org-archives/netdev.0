From: Rick Jones <rick.jones2@hp.com>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Tue, 27 Jan 2009 10:02:23 -0800
Message-ID: <497F4C2F.9000804@hp.com>
References: <497E361B.30909@hp.com> <497E42F4.7080201@cosmosbay.com>	<497E44F6.2010703@hp.com> <497ECF84.1030308@cosmosbay.com>	<497ED0A2.6050707@trash.net> <497F350A.9020509@cosmosbay.com> <497F457F.2050802@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:46071 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755912AbZA0SC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 13:02:27 -0500
In-Reply-To: <497F457F.2050802@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Eric Dumazet wrote:
> 
>>[PATCH] netfilter: Get rid of central rwlock in tcp conntracking
>>
>>TCP connection tracking suffers of huge contention on a global rwlock,
>>used to protect tcp conntracking state.
>>
>>As each tcp conntrack state have no relations between each others, we
>>can switch to fine grained lock. Using an array of spinlocks avoids
>>enlarging size of connection tracking structures, yet giving reasonable
>>fanout.
>>
>>tcp_print_conntrack() doesnt need to lock anything to read
>>ct->proto.tcp.state, so speedup /proc/net/ip_conntrack as well.
>>
>>nf_conntrack_hash_rnd_initted & nf_conntrack_hash_rnd declared read_mostly
>>  
> 
> 
> This looks good to me. Rick, would you like to give it a try?
> 
> I'll convert the remaining conntrack protocols when applying it.

I will give it a try and let folks know the results - unless told otherwise, I 
will ass-u-me I only need rerun the "full_iptables" test case.

rick jones


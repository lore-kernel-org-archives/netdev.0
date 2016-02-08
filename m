From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: Disabling XPS for 4.4.0-1+ixgbe+OpenStack VM over a VLAN means
 65% increase in netperf TCP_STREAM
Date: Mon, 8 Feb 2016 11:03:30 -0800
Message-ID: <56B8E682.5050606@hpe.com>
References: <56B3A2D4.1010309@hpe.com>
 <CALx6S36PxgZufhFa4qChPJvW0eb1V_fQoQOH7HHKd4q00taR=A@mail.gmail.com>
 <56B8D877.5000402@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:53822 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462AbcBHTDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 14:03:32 -0500
In-Reply-To: <56B8D877.5000402@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Shame on me for not including bare-iron TCP_RR:

stack@fcperf-cp1-comp0001-mgmt:~$ grep "1       1" xps_tcp_rr_on_* | awk 
'{t+=$6;r+=$9;s+=$10}END{print "throughput",t/NR,"recv sd",r/NR,"send 
sd",s/NR}'
throughput 18589.4 recv sd 21.6296 send sd 20.5931
stack@fcperf-cp1-comp0001-mgmt:~$ grep "1       1" xps_tcp_rr_off_* | 
awk '{t+=$6;r+=$9;s+=$10}END{print "throughput",t/NR,"recv 
sd",r/NR,"send sd",s/NR}'
throughput 20883.6 recv sd 19.6255 send sd 20.0178

So that is 12% on TCP_RR throughput.

Looks like XPS shouldn't be enabled by default for ixgbe.

happy benchmarking,

rick jones

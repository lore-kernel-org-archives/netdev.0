From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [net-next 2/3] udp: Add udp early demux
Date: Tue, 01 Oct 2013 13:12:18 -0700
Message-ID: <524B2CA2.4090807@hp.com>
References: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com> <1380656025-8847-3-git-send-email-sbohrer@rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:45791 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881Ab3JAUMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 16:12:22 -0400
In-Reply-To: <1380656025-8847-3-git-send-email-sbohrer@rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2013 12:33 PM, Shawn Bohrer wrote:
> The removal of the routing cache introduced a performance regression for
> some UDP workloads since a dst lookup must be done for each packet.
> This change caches the dst per socket in a similar manner to what we do
> for TCP by implementing early_demux.
>
> For UDP multicast we can only cache the dst if there is only one
> receiving socket on the host.  Since caching only works when there is
> one receiving socket we do the multicast socket lookup using RCU.
>
> Benchmark results from a netperf UDP_RR test:
> Before 90596.44 transactions/s
> After  91296.97 transactions/s

Were those measured with confidence intervals enabled?  It would be a 
Good Idea (tm) to either use that - I would suggest -I 99,1 -i 30,3 
added to the global portion of the netperf command line - or take 
several runs.  (If you've not already done so since those look more like 
"raw" netperf numbers rather than theaverage of several runs)

happy benchmarking,

rick jones

> Benchmark results from a fio 1 byte UDP multicast pingpong test
> (Multicast one way unicast response):
> Before 12.647us RTT
> After  12.497us RTT

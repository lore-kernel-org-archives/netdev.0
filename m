From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in
 non-interrupt context.
Date: Wed, 01 Oct 2014 16:25:29 -0400 (EDT)
Message-ID: <20141001.162529.2246298941833907545.davem@davemloft.net>
References: <542C5C37.1040409@oracle.com>
	<20141001.161508.1823792090990427608.davem@davemloft.net>
	<20141001202315.GN17706@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36364 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbaJAUZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 16:25:31 -0400
In-Reply-To: <20141001202315.GN17706@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 1 Oct 2014 16:23:15 -0400

> On (10/01/14 16:15), David Miller wrote:
>> > 
>> > If I make this a NAPI driver that uses napi_gro_receive, I would
>> > still have to deal with a budget, right?
>> 
>> Absolutely, and YOU MUST, because the budget keeps one device from
>> hogging the RX packet input path from other devices on a given cpu.
> 
> yes, but limiting the budget of sk_buffs read mid-way during descriptor
> read is deadly to perf because of the ensuing LDC stop/start exchange -
> ends up being even worse than the baseline.
> 
> Doesnt the netif_rx/process_backlog infra already do a napi_schedule,
> thus avoiding the above concern? 

The limit is by default 64 packets, it won't matter.

I think you're overplaying the things that block use of NAPI, how
about implementing it properly, using netif_gso_receive() and proper
RCU accesses, and coming back with some real performance measurements?

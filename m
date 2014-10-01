From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in non-interrupt
 context.
Date: Wed, 1 Oct 2014 16:23:15 -0400
Message-ID: <20141001202315.GN17706@oracle.com>
References: <20141001185604.GG17706@oracle.com>
 <20141001.155009.2277009117294992988.davem@davemloft.net>
 <542C5C37.1040409@oracle.com>
 <20141001.161508.1823792090990427608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22639 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbaJAUXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 16:23:24 -0400
Content-Disposition: inline
In-Reply-To: <20141001.161508.1823792090990427608.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/01/14 16:15), David Miller wrote:
> > 
> > If I make this a NAPI driver that uses napi_gro_receive, I would
> > still have to deal with a budget, right?
> 
> Absolutely, and YOU MUST, because the budget keeps one device from
> hogging the RX packet input path from other devices on a given cpu.

yes, but limiting the budget of sk_buffs read mid-way during descriptor
read is deadly to perf because of the ensuing LDC stop/start exchange -
ends up being even worse than the baseline.

Doesnt the netif_rx/process_backlog infra already do a napi_schedule,
thus avoiding the above concern? 

--Sowmini

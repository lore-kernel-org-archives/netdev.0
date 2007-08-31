From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET_SCHED] sch_prio.c: remove duplicate call of
 tc_classify()
Date: Thu, 30 Aug 2007 22:36:06 -0700 (PDT)
Message-ID: <20070830.223606.112851411.davem@davemloft.net>
References: <20070830072817.GA9617@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: lucas.nussbaum@imag.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45157
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750845AbXHaFgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 01:36:07 -0400
In-Reply-To: <20070830072817.GA9617@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lucas Nussbaum <lucas.nussbaum@imag.fr>
Date: Thu, 30 Aug 2007 09:28:17 +0200

> Hi,
> 
> When CONFIG_NET_CLS_ACT is enabled, tc_classify() is called twice in
> prio_classify(). This causes "interesting" behaviour: with the setup
> below, packets are duplicated, sent twice to ifb0, and then loop in and
> out of ifb0.
> 
> The patch uses the previously calculated return value in the switch,
> which is probably what Patrick had in mind in commit
> bdba91ec70fb5ccbdeb1c7068319adc6ea9e1a7d -- maybe Patrick can
> double-check this?
> 
> -- example setup --
> ifconfig ifb0 up
> tc qdisc add dev ifb0 root netem delay 2s
> tc qdisc add dev $ETH root handle 1: prio
> tc filter add dev $ETH parent 1: protocol ip prio 10 u32 \
>  match ip dst 172.24.110.6/32 flowid 1:1 \
>  action mirred egress redirect dev ifb0
> ping -c1 172.24.110.6
> 
> Signed-off-by: Lucas Nussbaum <lucas.nussbaum@imag.fr>

Thank you for finding and fixing this bug, patch applied.

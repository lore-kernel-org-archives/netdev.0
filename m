From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_sfq: avoid giving spurious NET_XMIT_CN signals
Date: Mon, 23 May 2011 17:36:13 -0400 (EDT)
Message-ID: <20110523.173613.2131279677585645313.davem@davemloft.net>
References: <1306184562.2638.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, jarkao2@gmail.com,
	hadi@cyberus.ca, shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201Ab1EWVhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 17:37:24 -0400
In-Reply-To: <1306184562.2638.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 May 2011 23:02:42 +0200

> While chasing a possible net_sched bug, I found that IP fragments have
> litle chance to pass a congestioned SFQ qdisc :
> 
> - Say SFQ qdisc is full because one flow is non responsive.
> - ip_fragment() wants to send two fragments belonging to an idle flow.
> - sfq_enqueue() queues first packet, but see queue limit reached :
> - sfq_enqueue() drops one packet from 'big consumer', and returns
> NET_XMIT_CN.
> - ip_fragment() cancel remaining fragments.
> 
> This patch restores fairness, making sure we return NET_XMIT_CN only if
> we dropped a packet from the same flow.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good, applied, thanks Eric.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net_sched: TCQ_F_CAN_BYPASS generalization
Date: Fri, 21 Jan 2011 16:27:33 -0800 (PST)
Message-ID: <20110121.162733.123411406.davem@davemloft.net>
References: <1295531299.2825.175.camel@edumazet-laptop>
	<1295537236.2825.286.camel@edumazet-laptop>
	<1295607881.2601.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, hawk@diku.dk,
	jarkao2@gmail.com, hadi@cyberus.ca
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43422
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754942Ab1AVA07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 19:26:59 -0500
In-Reply-To: <1295607881.2601.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Jan 2011 12:04:41 +0100

> Now qdisc stab is handled before TCQ_F_CAN_BYPASS test in
> __dev_xmit_skb(), we can generalize TCQ_F_CAN_BYPASS to other qdiscs
> than pfifo_fast : pfifo, bfifo, pfifo_head_drop and sfq
> 
> SFQ is special because it can have external classifiers, and in these
> cases, we cannot bypass queue discipline (packet could be dropped by
> classifier) without admin asking it, or further changes.
> 
> Its worth doing this, especially for SFQ, avoiding dirtying memory in
> case no packets are already waiting in queue.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.

> I am not sure RED can use bypass too, feel free to comment on this ;)

The only thing that RED would seem to care about would be the
queue size average calculation.

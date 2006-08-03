From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SNMPv2 tcpOutSegs counter error
Date: Thu, 03 Aug 2006 16:35:54 -0700 (PDT)
Message-ID: <20060803.163554.26966486.davem@davemloft.net>
References: <1154620019.9095.5.camel@LINE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9680
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750753AbWHCXfv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 19:35:51 -0400
To: yjwei@nanjing-fnst.com
In-Reply-To: <1154620019.9095.5.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yjwei@nanjing-fnst.com>
Date: Thu, 03 Aug 2006 11:46:58 -0400

> I modified my patch by add a flag to sacked when retransmit, and it
> work well.

This is the most timing critical code path of the TCP stack output
packet processing, and you're adding a read-modify-write operation
just to get some statistics correct.

Let's look for a cheaper test, perhaps something like:

	if (!before(TCP_SKB_CB(skb)->seq, tp->snd_nxt))
		TCP_INC_STATS(TCP_MIB_OUTSEGS);

Would that work?

It should, because tp->snd_nxt always advances on new data
via update_send_head().

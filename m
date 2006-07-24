From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SNMPv2 tcpOutSegs counter error
Date: Mon, 24 Jul 2006 14:44:11 -0700 (PDT)
Message-ID: <20060724.144411.57446335.davem@davemloft.net>
References: <1152172878.4695.2.camel@LINE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63970
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932253AbWGXVoC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 17:44:02 -0400
To: yjwei@nanjing-fnst.com
In-Reply-To: <1152172878.4695.2.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yjwei@nanjing-fnst.com>
Date: Thu, 06 Jul 2006 04:01:18 -0400

> -	TCP_INC_STATS(TCP_MIB_OUTSEGS);
> +	if (!(tcb->sacked & TCPCB_LOST))
> +		TCP_INC_STATS(TCP_MIB_OUTSEGS);

This test is not accurate enough.  For example, timer based
retransmits will not set the TCPCB_LOST bit.

I'm tempted to say to pass a flag to tcp_transmit_skb()
which says whether it is a retransmit or not, but that
function already takes way too many arguments.

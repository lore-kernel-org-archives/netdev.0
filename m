From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SNMPv2 tcpAttemptFails counter error
Date: Mon, 24 Jul 2006 14:22:01 -0700 (PDT)
Message-ID: <20060724.142201.27783219.davem@davemloft.net>
References: <1152091195.3866.4.camel@LINE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16356
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751450AbWGXVVw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 17:21:52 -0400
To: yjwei@nanjing-fnst.com
In-Reply-To: <1152091195.3866.4.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yjwei@nanjing-fnst.com>
Date: Wed, 05 Jul 2006 05:19:54 -0400

> In my test, those direct state transition can not be counted to
> tcpAttemptFails. Following is my patch:
> 
> Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>

This change can be implemented more simply, I believe.

Except for the tcp_minisocks.c change, all the paths
changed go to tcp_done() which is what actually transfers
the state to TCP_CLOSE.  Therefore, tcp_done() can
simply be modified to check if the current state is
TCP_SYN_RECV, and is so bump the counter.

Once you implement it this way, please audit all call paths
to make sure we don't now bump this counter twice.

Thank you.

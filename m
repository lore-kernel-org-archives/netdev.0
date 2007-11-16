From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : Corrects a bug in ip_rt_acct_read()
Date: Fri, 16 Nov 2007 02:32:08 -0800 (PST)
Message-ID: <20071116.023208.188367224.davem@davemloft.net>
References: <20071116112519.ecbb96ae.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47268
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752130AbXKPKcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 05:32:08 -0500
In-Reply-To: <20071116112519.ecbb96ae.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 16 Nov 2007 11:25:19 +0100

> [PATCH] NET : Corrects a bug in ip_rt_acct_read()
> 
> It seems that stats of cpu 0 are counted twice, since 
> for_each_possible_cpu() is looping on all possible cpus,
> including 0
> 
> Before percpu conversion of ip_rt_acct, we should also remove
> the assumption that CPU 0 is online (or even possible)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, good catch Eric.

To make things easier for you I've applied it to both
net-2.6 and net-2.6.25

It seems like the code was trying to avoid that initial
memset, grabbing the first cpu explicitly and then copying
along the way.  But the loop iterator wasn't adjusted
correctly and of course the zero-cpu-assumption you
noticed as well plays into this :-)

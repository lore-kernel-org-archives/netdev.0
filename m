From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh: error out pending skbs if netlink invalidates
 incomplete neigh
Date: Thu, 11 Jun 2009 03:02:07 -0700 (PDT)
Message-ID: <20090611.030207.238260652.davem@davemloft.net>
References: <1244104855-2129-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33251
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754432AbZFKKCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 06:02:05 -0400
In-Reply-To: <1244104855-2129-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>
Date: Thu,  4 Jun 2009 11:40:55 +0300

> The state transition code from incomplete to invalid via neigh_update()
> is missing the proper clean up of skb queue. Separate the clean up
> code from neigh_timer_handler() to a new function and make neigh_update()
> is it also.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

We don't error out pending SKBs on the state transition alone, we do
it when we have the state transition _AND_ the number of probes
exceeds the limit.

And it seems that behavior is very much intentional.

I'm not going to apply this.

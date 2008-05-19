From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] L2TP: avoid skb truesize bug if headroom is increased
Date: Mon, 19 May 2008 14:10:38 -0700 (PDT)
Message-ID: <20080519.141038.267900372.davem@davemloft.net>
References: <200805192009.m4JK98DO003387@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bc-info@styx.cabel.net
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47605
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762952AbYESVKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 17:10:43 -0400
In-Reply-To: <200805192009.m4JK98DO003387@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Mon, 19 May 2008 21:09:08 +0100

> A user reported seeing occasional bugs such as the following when
> using the L2TP driver.
> 
>   SKB BUG: Invalid truesize (272) len=72, sizeof(sk_buff)=208
> 
> When L2TP adds its header in the transmit path, it might need to
> increase the headroom of the skb. In some cases, the increased
> headroom trips a kernel bug when the skb is freed because the skb has
> grown beyond its truesize value. The fix is to increase the truesize
> by the amount of headroom added, after orphaning the skb.
> 
> While here, fix a misleading comment.
> 
> Thanks to Iouri Kharon <bc-info@styx.cabel.net> for the initial
> report and testing the fix.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

Applied, thanks James.

Longer term I'll try to come up with a way to make it harder
to get this stuff wrong.

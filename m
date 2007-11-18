From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket filter
Date: Sun, 18 Nov 2007 22:45:15 +0100
Message-ID: <20071118214515.GA8161@one.firstfloor.org>
References: <E1IssYb-0000KG-00@gondolin.me.apana.org.au> <473D19EC.6030903@cn.fujitsu.com> <p73bq9tau2x.fsf@bingen.suse.de> <20071117.160926.232024605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, wangchen@cn.fujitsu.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:57074 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759AbXKRVpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2007 16:45:20 -0500
Content-Disposition: inline
In-Reply-To: <20071117.160926.232024605.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> We could defer the increment until we check the checksum,
> but that is likely to break even more things because people
> (as Wang Chen did initially) will send a packet to some
> port with an app that doesn't eat the packets, and expect the
> InDatagrams counter to increase once the stack eats the packet.

Who expects that? Is there really any program who relies on that?

If it's just a human: there are a couple of "non intuitive" behaviours
in the stack. This would be just another one. Not too big a deal.

> But it won't until the application does the read.
> 
> All of our options suck, we just have to choose the least sucking one
> and right now to me that's decrementing the counter as much as I
> empathize with the SNMP application overflow detection issue.

If the SNMP monitor detects an false overflow the error it reports 
will be much worse than a single missing packet. So you would replace 
one error with a worse error.

-Andi

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix tcp_v6_send_response(): it didn't set skb
 transport header
Date: Thu, 03 Sep 2009 20:45:10 -0700 (PDT)
Message-ID: <20090903.204510.170648802.davem@davemloft.net>
References: <200909031925.54197.cratiu@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cratiu@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43776
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755512AbZIDDoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:44:55 -0400
In-Reply-To: <200909031925.54197.cratiu@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cosmin Ratiu <cratiu@ixiacom.com>
Date: Thu, 3 Sep 2009 19:25:53 +0300

> Hello,
> 
> Here is a patch which fixes an issue observed when using TCP over IPv6 and AH 
> from IPsec.
> 
> When a connection gets closed the 4-way method and the last ACK from the 
> server gets dropped, the subsequent FINs from the client do not get ACKed 
> because tcp_v6_send_response does not set the transport header pointer. This 
> causes ah6_output to try to allocate a lot of memory, which typically fails, 
> so the ACKs never make it out of the stack.
> 
> I have reproduced the problem on kernel 2.6.7, but after looking at the latest 
> kernel it seems the problem is still there.
> 
> Signed-off-by: Cosmin Ratiu <cratiu@ixiacom.com>

Great catch.  IPV4 handles this transparently via ip_append_data()
which is what it uses to send these kinds of frames.  IPV6 does
this stuff by hand.

Applied to net-next-2.6, thanks!

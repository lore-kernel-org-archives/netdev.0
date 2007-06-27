From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5 2.6.22-rc6] UDP: Introduce UDP encapsulation type
 for L2TP
Date: Wed, 27 Jun 2007 15:38:51 -0700 (PDT)
Message-ID: <20070627.153851.42902028.davem@davemloft.net>
References: <200706272220.l5RMKc7I004940@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58454
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760254AbXF0Wic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 18:38:32 -0400
In-Reply-To: <200706272220.l5RMKc7I004940@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Wed, 27 Jun 2007 23:20:38 +0100

> This patch adds a new UDP_ENCAP_L2TPINUDP encapsulation type for UDP
> sockets. When a UDP socket's encap_type is UDP_ENCAP_L2TPINUDP, the
> skb is delivered to a function pointed to by the udp_sock's
> encap_rcv funcptr. If the skb isn't wanted by L2TP, it returns >0, which
> causes it to be passed through to UDP.
> 
> Include padding to put the new encap_rcv field on a 4-byte boundary.
> 
> Previously, the only user of UDP encap sockets was ESP, so when
> CONFIG_XFRM was not defined, some of the encap code was compiled 
> out. This patch changes that. As a result, udp_encap_rcv() will
> now do a little more work when CONFIG_XFRM is not defined. 
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

Patch applied, thanks.

Note that we could use the callback pointer for the XFRM
case too, and I kind of thought you would understand that
logical progression and implement that too :-/

That way we don't need any funny return values, there is
just one and it simply triggers the callback.

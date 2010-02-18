From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] net: bug fix for vlan + gro issue
Date: Wed, 17 Feb 2010 16:02:51 -0800 (PST)
Message-ID: <20100217.160251.170027820.davem@davemloft.net>
References: <20100212053451.GA23351@serverengines.com>
	<20100216114015.GB31642@gondor.apana.org.au>
	<20100217062541.GA10350@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kaber@trash.net,
	netdev@vger.kernel.org
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42061
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756767Ab0BRACg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 19:02:36 -0500
In-Reply-To: <20100217062541.GA10350@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Wed, 17 Feb 2010 11:55:43 +0530

> Thanks Herbert. I think you meant something like this:
> +		skb->protocol = eth_type_trans(skb, skb->dev);
> 
> Here is the patch:-
> 
> Traffic (tcp) doesnot start on a vlan interface when gro is enabled.
> Even the tcp handshake was not taking place.
> This is because, the eth_type_trans call before the netif_receive_skb
> in napi_gro_finish() resets the skb->dev to napi->dev from the previously
> set vlan netdev interface. This causes the ip_route_input to drop the
> incoming packet considering it as a packet coming from a martian source.
> 
> I could repro this on 2.6.32.7 (stable) and 2.6.33-rc7.
> With this fix, the traffic starts and the test runs fine on both vlan
> and non-vlan interfaces.
> 
> CC: Herbert Xu <herbert@gondor.apana.org.au>
> CC: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied, thanks.

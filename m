From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6] net: bug fix for vlan + gro issue
Date: Wed, 17 Feb 2010 14:40:30 +0800
Message-ID: <20100217064030.GA15791@gondor.apana.org.au>
References: <20100212053451.GA23351@serverengines.com> <20100216114015.GB31642@gondor.apana.org.au> <20100217062541.GA10350@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net,
	netdev <netdev@vger.kernel.org>
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37349 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752542Ab0BQGkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 01:40:39 -0500
Content-Disposition: inline
In-Reply-To: <20100217062541.GA10350@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2010 at 11:55:43AM +0530, Ajit Khaparde wrote:
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

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks a lot!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

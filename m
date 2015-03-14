From: =?UTF-8?B?SG9yaWEgR2VhbnTEgw==?= <horia.geanta@freescale.com>
Subject: Re: [PATCH 2/4] net: esp: check CRYPTO_TFM_REQ_DMA flag when allocating
 crypto request
Date: Sat, 14 Mar 2015 14:16:37 +0200
Message-ID: <550426A5.4090603@freescale.com>
References: <1426266882-31626-1-git-send-email-horia.geanta@freescale.com>
	<1426266922-31679-1-git-send-email-horia.geanta@freescale.com>
 <20150313.154608.548532696978553073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-crypto@vger.kernel.org>, <netdev@vger.kernel.org>,
	<kim.phillips@freescale.com>
To: David Miller <davem@davemloft.net>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0135.outbound.protection.outlook.com ([157.56.110.135]:36546
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751845AbbCNMQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Mar 2015 08:16:50 -0400
In-Reply-To: <20150313.154608.548532696978553073.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/2015 9:46 PM, David Miller wrote:
> From: Horia Geanta <horia.geanta@freescale.com>
> Date: Fri, 13 Mar 2015 19:15:22 +0200
> 
>> Some crypto backends might require the requests' private contexts
>> to be allocated in DMA-able memory.
>>
>> Signed-off-by: Horia Geanta <horia.geanta@freescale.com>
> 
> No way.
> 
> Upper layers should be absolutely not required to know about such
> requirements.
> 
> Such details _must_ be hidden inside of the crypto layer and drivers
> and not leak out into the users of the crypto interfaces.

If you look at patch 1/4:
http://www.mail-archive.com/linux-crypto@vger.kernel.org/msg13428.html
that's what's done for {aead,ablkcipher,ahash}_request_alloc().

Thus users (upper layers) that allocate the crypto requests using the
crypto API are unaware of the requirement.

However, ESP is not using aead_request_alloc(). This breaks the
interface and thus some crypto implementation details are not transparent.

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] netlink: fix boolean evaluation on bound
Date: Mon, 14 Dec 2015 18:27:12 +0100
Message-ID: <566EFBF0.5020604@stressinduktion.org>
References: <1450112125-29848-1-git-send-email-hannes@stressinduktion.org>
 <20151214170642.GA4180@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:33522 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751901AbbLNR1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 12:27:14 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 4B6DC22242
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 12:27:13 -0500 (EST)
In-Reply-To: <20151214170642.GA4180@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.12.2015 18:06, Herbert Xu wrote:
> On Mon, Dec 14, 2015 at 05:55:25PM +0100, Hannes Frederic Sowa wrote:
>> portid may be 0, thus bound will set the flag to false for in-kernel
>> created netlink sockets.
>>
>> Fixes: da314c9923fed55 ("netlink: Replace rhash_portid with bound")
>> Cc: Herbert Xu <herbert@gondor.apana.org.au>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> ---
>> This patch should not affect anything and is just meant to close this
>> loophole in future. I based it on net, but you can also apply it to
>> net-next.
> 
> Nack.  The bound field only needs to be true for user-space sockets.
> So please explain why you need it to be true for kernel sockets.

I reviewed this very carefully and think this is currently a matter of
taste as it does not change current logic.

Otherwise I would recommend adding a "!!" to express that we actually
want bound set based on the portid value?

Bye,
Hannes

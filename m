From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] Remove notifier block from chain when register_netdevice_notifier
 fails
Date: Wed, 14 Nov 2007 16:47:24 +0300
Message-ID: <473AFC6C.6000505@openvz.org>
References: <473AE523.70501@openvz.org> <20071114133717.GA14746@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:60470 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752276AbXKNNrn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 08:47:43 -0500
In-Reply-To: <20071114133717.GA14746@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Wed, Nov 14, 2007 at 03:08:03PM +0300, Pavel Emelyanov wrote:
>> Commit fcc5a03ac42564e9e255c1134dda47442289e466 makes the
>> register_netdevice_notifier() handle the error from the
>> NETDEV_REGISTER event, sent to the registering block. 
>>
>> The bad news is that in this case the notifier block is 
>> not removed from the list, but the error is returned to the 
>> caller. In case the caller is in module init function and 
>> handles this error this can abort the module loading. The
>> notifier block will be then removed from the kernel, but 
>> will be left in the list. Oops :(
>>
>> I think that the notifier block should be removed from the
>> chain in case of error, regardless whether this error is 
>> handled by the caller or not. In the worst case (the error 
>> is _not_ handled) module will not receive the events any 
>> longer.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Good catch.  Thanks Pavel!
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks :)

BTW, I have one more question I can't find the answer to by 
myself. Why the unregister_netdevice_notifier doesn't produce 
the GOING_DOWN-DOWN-UNREGISTER event sequence for the notifier
block which is being unregistered? Was this made deliberately?

Pavel

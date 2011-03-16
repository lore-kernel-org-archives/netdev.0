From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] xfrm: Force a dst refcount before entering the
 xfrm type handlers
Date: Wed, 16 Mar 2011 10:41:18 -0700 (PDT)
Message-ID: <20110316.104118.71120514.davem@davemloft.net>
References: <20110316070828.GQ31402@secunet.com>
	<20110316.001732.112599674.davem@davemloft.net>
	<20110316074306.GT31402@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45394
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751218Ab1CPRkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 13:40:40 -0400
In-Reply-To: <20110316074306.GT31402@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 16 Mar 2011 08:43:06 +0100

> On Wed, Mar 16, 2011 at 12:17:32AM -0700, David Miller wrote:
>> 
>> Steffen we really need to find another way to fix these problems.
>> 
>> We already make way too many expensive atomic operations in these code
>> paths modified by your 3 patches, we should strive to not add new
>> ones.
>> 
> 
> I know that it is exspensive, but we have to take a refcount if
> the crypto layer returns asyncronous. Unfortunately it is too
> late to take the refcount when the crypto layer notifies us about
> that as the skb might be already gone.

We can pass around an atomic_t for the crypto layer to bump when
it decides to take an async path, bump it on entry and upon event
wakeup decrement it.

Actually, a plain atomic_t is a bad idea because we might have to
release the object.  So callbacks with private void pointer arg is
better.

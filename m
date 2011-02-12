From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Fix mglist corruption that leads to memory corruption
Date: Fri, 11 Feb 2011 21:58:04 -0800 (PST)
Message-ID: <20110211.215804.15260765.davem@davemloft.net>
References: <20110211223655.GA5585@gondor.apana.org.au>
	<20110211225559.GA5922@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ihands@redhat.com, jbacik@redhat.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52380
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751097Ab1BLF52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Feb 2011 00:57:28 -0500
In-Reply-To: <20110211225559.GA5922@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 12 Feb 2011 09:55:59 +1100

> On Sat, Feb 12, 2011 at 09:36:55AM +1100, Herbert Xu wrote:
>> 
>> Normally this would be quite obvious as it would cause an infinite
>> loop when walking the list.  However, as this list is never actually
>> walked (which means that we don't really need it, I'll get rid of
>> it in a subsequent patch), this instead is hidden until we perform
>> a delete operation on the affected nodes.
> 
> Here is the patch that replaces the mglist hlist with just a bool.
> 
> bridge: Replace mp->mglist hlist with a bool
> 
> As it turns out we never need to walk through the list of multicast
> groups subscribed by the bridge interface itself (the only time we'd
> want to do that is when we shut down the bridge, in which case we
> simply walk through all multicast groups), we don't really need to
> keep an hlist for mp->mglist.
> 
> This means that we can replace it with just a single bit to indicate
> whether the bridge interface is subscribed to a group.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Well if it's a bool, please use "true" and "false" instead of "1" and
"0" :-)

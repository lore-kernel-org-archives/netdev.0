From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] [NET]: Take dev_base_lock when moving device name
 hash list entry
Date: Mon, 30 Jul 2007 16:36:08 -0700 (PDT)
Message-ID: <20070730.163608.35468199.davem@davemloft.net>
References: <20070726090725.GA510@gondor.apana.org.au>
	<E1IDzLe-0000A4-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45147
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760741AbXG3XgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 19:36:09 -0400
In-Reply-To: <E1IDzLe-0000A4-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 26 Jul 2007 17:09:30 +0800

> [NET]: Take dev_base_lock when moving device name hash list entry
> 
> When we added name-based hashing the dev_base_lock was designated as the
> lock to take when changing the name hash list.  Unfortunately, because
> it was a preexisting lock that just happened to be taken in the right
> spots we neglected to take it in dev_change_name.
> 
> The race can affect calles of __dev_get_by_name that do so without taking
> the RTNL.  They may end up walking down the wrong hash chain and end up
> missing the device that they're looking for.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Good catch, applied, thanks Herbert.

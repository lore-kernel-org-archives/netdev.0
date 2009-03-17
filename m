From: David Miller <davem@davemloft.net>
Subject: Re: GRO with non napi driver: BUG in __napi_complete
Date: Tue, 17 Mar 2009 13:11:40 -0700 (PDT)
Message-ID: <20090317.131140.187586185.davem@davemloft.net>
References: <49BF60C9.1080100@linux.vnet.ibm.com>
	<20090317102244.GB23396@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: blaschka@linux.vnet.ibm.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33666
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753546AbZCQULy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 16:11:54 -0400
In-Reply-To: <20090317102244.GB23396@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 17 Mar 2009 18:22:44 +0800

> On Tue, Mar 17, 2009 at 09:35:21AM +0100, Frank Blaschka wrote:
> >
> > What is the intention process_backlog calls __napi_complete() instead of
> > napi_complete(), this looks suspicious to me. Can anybody help?
> 
> You're absolutely right.  Dave, we need this fix for both net
> and net-next.
> 
> gro: Fix legacy path napi_complete crash
> 
> On the legacy netif_rx path, I incorrectly tried to optimise
> the napi_complete call by using __napi_complete before we reenable
> IRQs.  This simply doesn't work since we need to flush the held
> GRO packets first.
> 
> This patch fixes it by doing the obvious thing of reenabling
> IRQs first and then calling napi_complete.
> 
> Reported-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Avoid undefined shift operation when testing
 algorithm ID
Date: Wed, 19 Dec 2007 23:44:55 -0800 (PST)
Message-ID: <20071219.234455.79622323.davem@davemloft.net>
References: <20071220042937.GA18679@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50853
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752906AbXLTHoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 02:44:55 -0500
In-Reply-To: <20071220042937.GA18679@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 20 Dec 2007 12:29:37 +0800

> [IPSEC]: Avoid undefined shift operation when testing algorithm ID
> 
> The aalgos/ealgos fields are only 32 bits wide.  However, af_key tries
> to test them with the expression 1 << id where id can be as large as
> 253.  This produces different behaviour on different architectures.
> 
> The following patch explicitly checks whether ID is greater than 31
> and fails the check if that's the case.
> 
> We cannot easily extend the mask to be longer than 32 bits due to
> exposure to user-space.  Besides, this whole interface is obsolete
> anyway in favour of the xfrm_user interface which doesn't use this
> bit mask in templates (well not within the kernel anyway).
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for fixing this bug, patch applied!

From: David Miller <davem@davemloft.net>
Subject: Re: [2/2] [IPV4]: Use network-order dport for all visible
 inet_lookup_*
Date: Tue, 08 Aug 2006 02:24:43 -0700 (PDT)
Message-ID: <20060808.022443.62664150.davem@davemloft.net>
References: <20060808084614.GA6651@gondor.apana.org.au>
	<20060808084729.GA8085@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49858
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932163AbWHHJYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 05:24:39 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060808084729.GA8085@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 8 Aug 2006 18:47:29 +1000

> So this patch changes all visible inet_lookup functions to take a
> dport and move all dport->hnum conversion inside them.

This isn't so nice because we will now byte-swap the port twice when
we try looking up a listening socket.  Once for the established lookup
and once for the listening hash lookup.

It should be easy to do the byte-swap once at a higher level right?

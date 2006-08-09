From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2]: [IPV4] route: Locking infrastructure for dynamic
 routing cache sizing.
Date: Wed, 09 Aug 2006 16:05:00 -0700 (PDT)
Message-ID: <20060809.160500.95505425.davem@davemloft.net>
References: <20060809.005310.108740577.davem@davemloft.net>
	<E1GAmHp-0006RS-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36561
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751429AbWHIXFI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 19:05:08 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1GAmHp-0006RS-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 09 Aug 2006 21:31:45 +1000

> If we hit a writer just as they begin resizing, we could be here for
> quite a while.

Yes, we discussed this a bit on IRC.

> In fact because we expect each writer to stick around for a
> relatively long time, we could use a new seqlock primitive that just
> spun until the LSB becomes zero again.

Indeed, and put a cpu_relax() in there.

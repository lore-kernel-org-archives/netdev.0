From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Prevent multiple qdisc runs
Date: Mon, 19 Jun 2006 23:57:19 -0700 (PDT)
Message-ID: <20060619.235719.58454931.davem@davemloft.net>
References: <20060619121519.GA16031@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58058
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965104AbWFTG5N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 02:57:13 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060619121519.GA16031@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 19 Jun 2006 22:15:19 +1000

> [NET]: Prevent multiple qdisc runs

I have no real objection to this semantically.

But this is yet another atomic operation on the transmit
path :-(  This problem, however, is inevitable because of
how we do things and thus isn't the fault of your change.

I'm going to apply this patch to 2.6.18, however...  we should split
up the dev->state handling into seperate cacheline synchronizers.
Sharing RX and TX locking bits in the same word is not all that
efficient.

Thanks.

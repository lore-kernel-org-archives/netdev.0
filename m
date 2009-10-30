From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: set carrier off in probe
Date: Fri, 30 Oct 2009 11:10:27 -0700 (PDT)
Message-ID: <20091030.111027.234994529.davem@davemloft.net>
References: <20091029.213816.35637194.davem@davemloft.net>
	<20091030155420.GA8345@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bphilips@suse.de, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48345
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932708AbZJ3SKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 14:10:03 -0400
In-Reply-To: <20091030155420.GA8345@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 30 Oct 2009 11:54:20 -0400

> David Miller <davem@davemloft.net> wrote:
>> 
>> I agree that we should report something consistent before interface
>> up and 'no' is probably the best.
>> 
>> I remember fixing something similar in other drivers a few months
>> ago.
> 
> Can't we do this in one spot rather than having every driver
> duplicate this?

It doesn't matter if we do.

Because the driver must start in state with carrier off anyways,
so that we get the transition event when the device comes up
from link down to link up.

So many things depend upon that link state transition event, that
we're not saving anything by just mucking with the carrier test.

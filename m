From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 1/2] rhashtable: Schedule async resize when sync
 realloc fails
Date: Wed, 22 Apr 2015 08:18:05 +0100
Message-ID: <20150422071805.GD21799@casper.infradead.org>
References: <cover.1429620438.git.tgraf@suug.ch>
 <4f55f5c9abd6b09ed44f0da3f0e72a10040e8278.1429620438.git.tgraf@suug.ch>
 <20150422003634.GA5724@gondor.apana.org.au>
 <20150421.221033.573953908362966477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, kaber@trash.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51715 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbbDVHSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 03:18:08 -0400
Content-Disposition: inline
In-Reply-To: <20150421.221033.573953908362966477.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/21/15 at 10:10pm, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 22 Apr 2015 08:36:34 +0800
> 
> > On Tue, Apr 21, 2015 at 02:55:34PM +0200, Thomas Graf wrote:
> >> When rhashtable_insert_rehash() fails with ENOMEM, this indicates that
> >> we can't allocate the necessary memory in the current context but the
> >> limits as set by the user would still allow to grow.
> >> 
> >> Thus attempt an async resize in the background where we can allocate
> >> using GFP_KERNEL which is more likely to succeed. The insertion itself
> >> will still fail to indicate pressure.
> >> 
> >> This fixes a bug where the table would never continue growing once the
> >> utilization is above 100%.
> >> 
> >> Fixes: ccd57b1bd324 ("rhashtable: Add immediate rehash during insertion")
> >> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > 
> > Good catch.  But I think this call should happen in
> > rhashtable_insert_rehash since it's on the slow-path.
> 
> Ok, then I expect a respin of this series.

Agreed, respinning.

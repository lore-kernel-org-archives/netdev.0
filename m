From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] rhashtable: Schedule async resize when sync
 realloc fails
Date: Tue, 21 Apr 2015 22:10:33 -0400 (EDT)
Message-ID: <20150421.221033.573953908362966477.davem@davemloft.net>
References: <cover.1429620438.git.tgraf@suug.ch>
	<4f55f5c9abd6b09ed44f0da3f0e72a10040e8278.1429620438.git.tgraf@suug.ch>
	<20150422003634.GA5724@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798AbbDVCKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 22:10:37 -0400
In-Reply-To: <20150422003634.GA5724@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 22 Apr 2015 08:36:34 +0800

> On Tue, Apr 21, 2015 at 02:55:34PM +0200, Thomas Graf wrote:
>> When rhashtable_insert_rehash() fails with ENOMEM, this indicates that
>> we can't allocate the necessary memory in the current context but the
>> limits as set by the user would still allow to grow.
>> 
>> Thus attempt an async resize in the background where we can allocate
>> using GFP_KERNEL which is more likely to succeed. The insertion itself
>> will still fail to indicate pressure.
>> 
>> This fixes a bug where the table would never continue growing once the
>> utilization is above 100%.
>> 
>> Fixes: ccd57b1bd324 ("rhashtable: Add immediate rehash during insertion")
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Good catch.  But I think this call should happen in
> rhashtable_insert_rehash since it's on the slow-path.

Ok, then I expect a respin of this series.

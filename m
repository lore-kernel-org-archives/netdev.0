From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] ila: Support for checksum neutral
 translations
Date: Tue, 26 Apr 2016 01:41:56 -0400 (EDT)
Message-ID: <20160426.014156.735283836221227478.davem@davemloft.net>
References: <1461437217-1568717-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbcDZFmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 01:42:01 -0400
In-Reply-To: <1461437217-1568717-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Sat, 23 Apr 2016 11:46:54 -0700

> This patch set updates ILA to support draft-herbert-nvo3-ila-02. The
> primary addition is support checksum neutral ILA translation.
> This allows address to be performed and still keep any transport
> layer checksums that include the addresses in their pseudo header to
> still be correct without the translator needing to parse L4.
> 
> Other items are:
>    - Structures for ILA addresses, identifiers, locators
>    - Disallow translation on non-ILA addresses (check by
>      type in identifier).
>    - Change xlat (nf_input) to translates solely based
>      on matching locators not identifiers (since identifiers
>      are not obfuscated by checksum neutral).
>    - Side effect if above is that multiple ILA domains are
>      supported. Each local locator can map to a different
>      SIR address (ILA domain), and each domain defines its
>      own identifier space.
> 
> Tested: Ran TCP_RR with 200 cnxs. ILA performance is slightly better
> than previously since we are not longer parsing L4 for checksum
> handling. I amd seeing about 1% performance overhead. Also ran
> TCP_STREAM and tested non-ILA address (type=0) are not translated.
> 
> v2: Fix complilation errors

Series applied.

There were some conflicts I had to resolve due to the recent 64-bit
padding fixes, but those weren't too difficult to deal with.

Thanks.

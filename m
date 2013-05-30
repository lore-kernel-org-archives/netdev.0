From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v3] net: clean up skb headers code
Date: Thu, 30 May 2013 13:16:03 -0700 (PDT)
Message-ID: <20130530.131603.1155012584617016387.davem@davemloft.net>
References: <1369879575-18701-1-git-send-email-amwang@redhat.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7258@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, horms@verge.net.au
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56527 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757639Ab3E3UQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 16:16:07 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7258@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Thu, 30 May 2013 12:18:13 +0100

>> commit 1a37e412a0225fcba5587 (net: Use 16bits for *_headers
>> fields of struct skbuff) converts skb->*_header to u16,
>> some #if NET_SKBUFF_DATA_USES_OFFSET are now useless,
>> and to be safe, we could just use "X = ~(typeof(X))0;"
>> as suggested by David and Ben.
> 
> IIRC ~(unsigned short)0 is the same as ~0 and will be -1.
> define an actual constant with value 0xffff

The problem with doing that is that if this type is changed again,
we'lll go through this same circus changing the constant everywhere
and missing some cases.

I absolutely want to see a version of this fix that makes sure that if
the type changes, either the constantly automatically change (that's
the "typeof(X)" approach) or the build breaks spectacularly until the
value is fixed up.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Set CHECKSUM_UNNECESSARY in tcp_init_nondata_skb
Date: Thu, 08 Apr 2010 11:34:20 -0700 (PDT)
Message-ID: <20100408.113420.268424579.davem@davemloft.net>
References: <20100408.012617.98660541.davem@davemloft.net>
	<20100408135715.GA24890@gondor.apana.org.au>
	<20100408153906.GA26376@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35138
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933028Ab0DHSeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 14:34:17 -0400
In-Reply-To: <20100408153906.GA26376@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 8 Apr 2010 23:39:06 +0800

> On Thu, Apr 08, 2010 at 09:57:15PM +0800, Herbert Xu wrote:
>> 
>> The problem here is that for non-data packets CHECKSUM_PARTIAL
>> can actually end up being worse if we wind up going out through
>> an interface that doesn't support checksums.
> 
> I don't know what I was thinking but the above is totally wrong.
> CHECKSUM_PARTIAL should be just fine on non-checksuming interfaces
> as we'll checksum everything once just as the CHECKSUM_NONE case
> would.
> 
> So with that in mind, we don't need my CHECKSUM_UNNECESSARY patch
> at all and your CHECKSUM_PARTIAL path is the right solution after
> all :)

Ok, thanks for doing all of the analysis :)

That still leaves that MC loopback code in ip_dev_loopback_xmit()
which still sets CHECKSUM_UNNECESSARY unconditionally.

Should it do like the loopback driver and just leave the ip_summed
value alone?

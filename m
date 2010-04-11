From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ssh server etc doesn't work anymore with net-2.6
Date: Sun, 11 Apr 2010 18:09:02 +0800
Message-ID: <20100411100902.GA20141@gondor.apana.org.au>
References: <20100411.024352.209996508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yinghai@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, torvalds@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:47081 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751130Ab0DKKJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 06:09:13 -0400
Content-Disposition: inline
In-Reply-To: <20100411.024352.209996508.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Yinghai Lu <yinghai@kernel.org>
> Date: Sun, 11 Apr 2010 02:32:33 -0700
> 
>> server side: 82576 with net-2.6
>> client side: opensuse 11.2 on thinkpad T61 wireless + vpnc
> 
> I've pushed out a revert, we'll sort this out in net-next-2.6
> and meanwhile I've started a dialog with the Intel driver
> folks to see if there IGB chip has a problem with handling
> CHECKSUM_PARTIAL packets with a zero length data area.
> 
> Thanks for your report.

I was confused at first as to whether it was CHECKSUM_UNNECESSARY
that broke or CHECKSUM_PARTIAL.

After looking at the actual net-2.6 tree I see that it is actually
CHECKSUM_PARTIAL that caused this breakage.

The fact that when this was first implemented we didn't use hw
checksums on dataless packets might not have been an oversight
after all.

As I don't think such packets have been tested all by our kernel
on any NICs, and given the fact that IGB apparently broke, I think
the risk of this change is too high.

However, all is not lost as we can still adopt the approach of
the actual patch subject :) That is, we can use CHECKSUM_UNNECESSARY
for packets checksummed locally by software.

This does need a lot more testing so it should spend some time
in net-next first.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

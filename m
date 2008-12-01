From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v4] xfrm: Fix kernel panic when flush and dump SPD
	entries
Date: Mon, 1 Dec 2008 16:11:11 +0800
Message-ID: <20081201081111.GA19615@gondor.apana.org.au>
References: <49334542.3070502@cn.fujitsu.com> <49334788.4030409@cn.fujitsu.com> <20081201050046.GB18292@gondor.apana.org.au> <493383E9.50509@cn.fujitsu.com> <4933975E.3030503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48455 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750740AbYLAILT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 03:11:19 -0500
Content-Disposition: inline
In-Reply-To: <4933975E.3030503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 03:50:54PM +0800, Wei Yongjun wrote:
> After flush the SPD entries, dump the SPD entries will cause kernel painc.
> 
> Used the following commands to reproduct:
> 
> - echo 'spdflush;' | setkey -c
> - echo 'spdadd 3ffe:501:ffff:ff01::/64 3ffe:501:ffff:ff04::/64  any -P out ipsec \
>   ah/tunnel/3ffe:501:ffff:ff00:200:ff:fe00:b0b0-3ffe:501:ffff:ff02:200:ff:fe00:a1a1/require;\
>   spddump;' | setkey -c
> - echo 'spdflush; spddump;' | setkey -c
> - echo 'spdadd 3ffe:501:ffff:ff01::/64 3ffe:501:ffff:ff04::/64  any -P out ipsec \
>   ah/tunnel/3ffe:501:ffff:ff00:200:ff:fe00:b0b0-3ffe:501:ffff:ff02:200:ff:fe00:a1a1/require;\
>   spddump;' | setkey -c
> 
> This is because when flush the SPD entries, the SPD entry is not remove
> from the list.
> 
> This patch fix the problem by remove the SPD entry from the list. And
> also do clean up of remove SPD entry.

I like the clean-up but it's best if you separate the two changes
into two patches.  That way it's easy to see exactly what the bug
fix patch is trying to fix and to verify that the clean-up patch
really doesn't change behaviour.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

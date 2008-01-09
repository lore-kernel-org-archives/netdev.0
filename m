From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Thu, 10 Jan 2008 09:05:34 +1100
Message-ID: <20080109220534.GA2692@gondor.apana.org.au>
References: <11997574203125-git-send-email-fubar@us.ibm.com> <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl> <29560.1199820632@death> <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl> <17850.1199865514@death> <20080109152740.GE8728@gospo.usersys.redhat.com> <32361.1199901296@death> <20080109201709.GF8728@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, Krzysztof Oledzki <olel@ans.pl>,
	netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2695 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752270AbYAIWGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 17:06:16 -0500
Content-Disposition: inline
In-Reply-To: <20080109201709.GF8728@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 09, 2008 at 03:17:09PM -0500, Andy Gospodarek wrote:
>
> Agreed.  And despite Herbert's opinion that this isn't the correct fix,
> I think this will work fine.  This is one of the cases where we can take
> a write_lock(bond->lock) in softirq context, so we need to drop that (or
> make sure all the read_lock's are read_lock_bh's).  The latter isn't
> really an option since having a majority of the bonding code run in
> softirq context was what we are trying to avoid with the workqueue
> conversion.

No that's not the point.  The point is to move the majority of the code
into process context so that you can take the RTNL.  Once you have taken
the RTNL you can disable BH all you want and I don't care one bit.

In any case, fixing a known dead-lock is important.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

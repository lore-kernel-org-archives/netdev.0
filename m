From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Thu, 10 Jan 2008 11:58:09 +1100
Message-ID: <20080110005809.GA3851@gondor.apana.org.au>
References: <11997574203125-git-send-email-fubar@us.ibm.com> <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl> <29560.1199820632@death> <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl> <17850.1199865514@death> <20080109152740.GE8728@gospo.usersys.redhat.com> <32361.1199901296@death> <20080109201709.GF8728@gospo.usersys.redhat.com> <20080109220534.GA2692@gondor.apana.org.au> <7603.1199920750@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3584 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753906AbYAJA6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 19:58:33 -0500
Content-Disposition: inline
In-Reply-To: <7603.1199920750@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 09, 2008 at 03:19:10PM -0800, Jay Vosburgh wrote:
>
> >No that's not the point.  The point is to move the majority of the code
> >into process context so that you can take the RTNL.  Once you have taken
> >the RTNL you can disable BH all you want and I don't care one bit.
> 
> 	I'm not sure how we could move more code into a process context;
> much of the bonding driver is at the mercy of its callers, as in this
> case.  The monitoring stuff and enslave / deslave is all in a process
> context now (workqueue).  The transmit processing functions, for
> example, can't be assumed to be in any particular context as they're
> called by dev_queue_xmit.

No I'm not calling for you to move any more code into process context.
I was replying to the comment that changing the read_lock calls in
process context to read_lock_bh somehow undoes the benefit of moving
softirq code into process context.  It does not since the point of the
move is to be able to take the RTNL, which you can still do as long as
you do it before you disable BH.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

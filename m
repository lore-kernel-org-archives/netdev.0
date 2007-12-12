From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bug 9542] BUG: bad unlock balance detected!
Date: Wed, 12 Dec 2007 22:20:52 +0800
Message-ID: <20071212142052.GA26540@gondor.apana.org.au>
References: <bug-9542-27@http.bugzilla.kernel.org/> <20071211150313.EF4D210806E@picon.linux-foundation.org> <20071211140614.7c1738a5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	olel@ans.pl, Jay Vosburgh <fubar@us.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1141 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751292AbXLLOU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 09:20:57 -0500
Content-Disposition: inline
In-Reply-To: <20071211140614.7c1738a5.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 11, 2007 at 10:06:14PM +0000, Andrew Morton wrote:
>
> > events/0/9 just changed the state of lock:
> >  (&mc->mca_lock){-+..}, at: [<c0412602>] mld_ifc_timer_expire+0x130/0x1fb
> > but this lock took another, soft-read-irq-unsafe lock in the past:
> >  (&bond->lock){-.--}
> > 
> > and interrupts could create inverse lock ordering between them.

Yes this is a bug in the bonding driver.

It's assuming that bond->lock is only ever held for writing in
process context.  Unfortunately our current set_multicast_list
interface violates this constraint.

Now I do have a TODO item to fix set_multicast_list to not do
that, but until that happens, bond->lock should always turn BH
off, even on read lock.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

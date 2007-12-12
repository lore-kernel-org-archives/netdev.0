From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c (1055)
Date: Wed, 12 Dec 2007 14:07:05 -0500
Message-ID: <20071212190705.GB25879@gospo.usersys.redhat.com>
References: <E1J2Rgs-0006mz-00@gondolin.me.apana.org.au> <28503.1197481615@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Andrew Morton <akpm@linux-foundation.org>, olel@ans.pl,
	bugme-daemon@bugzilla.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, andy@greyhouse.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33273 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752287AbXLLTH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 14:07:56 -0500
Content-Disposition: inline
In-Reply-To: <28503.1197481615@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 12, 2007 at 09:46:55AM -0800, Jay Vosburgh wrote:
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> >> diff -puN drivers/net/bonding/bond_sysfs.c~bonding-locking-fix drivers/net/bonding/bond_sysfs.c
> >> --- a/drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
> >> +++ a/drivers/net/bonding/bond_sysfs.c
> >> @@ -1111,8 +1111,6 @@ static ssize_t bonding_store_primary(str
> >> out:
> >>        write_unlock_bh(&bond->lock);
> >> 
> >> -       rtnl_unlock();
> >> -
> >
> >Looking at the changeset that added this perhaps the intention
> >is to hold the lock? If so we should add an rtnl_lock to the start
> >of the function.
> 
> 	Yes, this function needs to hold locks, and more than just
> what's there now.  I believe the following should be correct; I haven't
> tested it, though (I'm supposedly on vacation right now).
> 
> 	The following change should be correct for the
> bonding_store_primary case discussed in this thread, and also corrects
> the bonding_store_active case which performs similar functions.
> 
> 	The bond_change_active_slave and bond_select_active_slave
> functions both require rtnl, bond->lock for read and curr_slave_lock for
> write_bh, and no other locks.  This is so that the lower level
> mode-specific functions can release locks down to just rtnl in order to
> call, e.g., dev_set_mac_address with the locks it expects (rtnl only).
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

This looks good to me as well....

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>


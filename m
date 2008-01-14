From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch for 2.6.24? 1/1] bonding: locking fix
Date: Mon, 14 Jan 2008 14:47:54 -0800
Message-ID: <20080114144754.29a448ad.akpm@linux-foundation.org>
References: <200801140904.m0E94vJd020425@imap1.linux-foundation.org>
	<Pine.LNX.4.64.0801142313350.26034@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeff@garzik.org,
	shemminger@linux-foundation.org, Jay Vosburgh <fubar@us.ibm.com>,
	netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35157 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753645AbYANWtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 17:49:04 -0500
In-Reply-To: <Pine.LNX.4.64.0801142313350.26034@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(cc's added)

On Mon, 14 Jan 2008 23:14:25 +0100 (CET)
Krzysztof Oledzki <olel@ans.pl> wrote:

> 
> 
> On Mon, 14 Jan 2008, akpm@linux-foundation.org wrote:
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> >
> > Remove stray rtnl_unlock().
> >
> > Addresses http://bugzilla.kernel.org/show_bug.cgi?id=9542
> >
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: Stephen Hemminger <shemminger@linux-foundation.org>
> > Cc: Krzysztof Oledzki <olel@ans.pl>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> >
> > drivers/net/bonding/bond_sysfs.c |    2 --
> > 1 file changed, 2 deletions(-)
> >
> > diff -puN drivers/net/bonding/bond_sysfs.c~bonding-locking-fix drivers/net/bonding/bond_sysfs.c
> > --- a/drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
> > +++ a/drivers/net/bonding/bond_sysfs.c
> > @@ -1111,8 +1111,6 @@ static ssize_t bonding_store_primary(str
> > out:
> > 	write_unlock_bh(&bond->lock);
> >
> > -	rtnl_unlock();
> > -
> > 	return count;
> > }
> > static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR, bonding_show_primary, bonding_store_primary);
> > _
> >
> 
> http://thread.gmane.org/gmane.linux.network/82566/focus=83142
> 

That's bond_lock.

This patch (below) addresses what appears to me to be an obvious
imbalance in rtnl_lock.

I don't care how it's fixed, really.  Someone please fix it?




From: Andrew Morton <akpm@linux-foundation.org>

Remove stray rtnl_unlock().

Addresses http://bugzilla.kernel.org/show_bug.cgi?id=9542

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Krzysztof Oledzki <olel@ans.pl>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/bonding/bond_sysfs.c |    2 --
 1 file changed, 2 deletions(-)

diff -puN drivers/net/bonding/bond_sysfs.c~bonding-locking-fix drivers/net/bonding/bond_sysfs.c
--- a/drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
+++ a/drivers/net/bonding/bond_sysfs.c
@@ -1111,8 +1111,6 @@ static ssize_t bonding_store_primary(str
 out:
 	write_unlock_bh(&bond->lock);
 
-	rtnl_unlock();
-
 	return count;
 }
 static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR, bonding_show_primary, bonding_store_primary);
_


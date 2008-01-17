From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch for 2.6.24? 1/1] bonding: locking fix
Date: Thu, 17 Jan 2008 15:42:43 -0800
Message-ID: <20080117154243.9ee4265c.akpm@linux-foundation.org>
References: <200801140904.m0E94vJd020425@imap1.linux-foundation.org>
	<Pine.LNX.4.64.0801142313350.26034@bizon.gios.gov.pl>
	<20080114144754.29a448ad.akpm@linux-foundation.org>
	<16796.1200351673@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: olel@ans.pl, davem@davemloft.net, jeff@garzik.org,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53837 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758895AbYAQXnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 18:43:21 -0500
In-Reply-To: <16796.1200351673@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Jan 2008 15:01:13 -0800
Jay Vosburgh <fubar@us.ibm.com> wrote:

> Andrew Morton <akpm@linux-foundation.org> wrote:
> [...]
> >That's bond_lock.
> >
> >This patch (below) addresses what appears to me to be an obvious
> >imbalance in rtnl_lock.
> >
> >I don't care how it's fixed, really.  Someone please fix it?
> 
> 	I posted a correct patch for this a few days ago:
> 
> http://marc.info/?l=linux-netdev&m=119975746803886&w=2
> 
> 	The correct fix requires more than simply removing the rtnl calls.
> 
> 	I've got a few other patches in the pipeline, so I'm planning to
> repost the set the above patch was a part of plus a few others, most
> likely tomorrow.

Can we get this bug fixed please?  Today?  It has been known about for more
than two months.

I can only assume that people don't use this feature much because this bug
will kill your kernel, every time.

Applying this:

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


is better than doing nothing.

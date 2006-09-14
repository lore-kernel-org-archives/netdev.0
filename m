From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: netdev tx timeouts
Date: Thu, 14 Sep 2006 11:21:40 +0900
Message-ID: <20060914112140.192e980a@localhost.localdomain>
References: <45076C00.2000100@lwfinger.net>
	<200609131430.53820.mb@bu3sch.de>
	<450806D1.4080809@lwfinger.net>
	<200609131549.23764.mb@bu3sch.de>
	<20060914102337.137d4591@localhost.localdomain>
	<4508B892.4040309@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org, Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:1743 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750797AbWINCVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 22:21:55 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <4508B892.4040309@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Sep 2006 21:04:02 -0500
Larry Finger <Larry.Finger@lwfinger.net> wrote:

> Stephen Hemminger wrote:
> > On Wed, 13 Sep 2006 15:49:23 +0200
> > Michael Buesch <mb@bu3sch.de> wrote:
> >> Simple. Reading the code of synchronize_net() and
> >> netif_stop_queue() and thinking about why it breaks, instead
> >> of committing bugfixes that only substitute one bug by another. ;)
> >> I'll take a look, too.
> > 
> > Why are you doing the synchronize_net()? it is meant for RCU.
> 
> We know and it no longer is in the code. We have known for a couple of days that 
> it was the synchronize_net() step that led to the netdev timeouts, but we were 
> afraid that a bare netif_stop_queue would not be SMP safe. The current structure has
> 
> mutex_lock
> netif_tx_disable(dev)   (equivalent to  netif_tx_lock_bh(dev);
> 				        netif_stop_queue(dev);
> 			                netif_tx_unlock_bh(dev);
> spin_lock_irqsafe
> 
> I see you listed as a maintainer in several network-related parts of the system, 
> so AFAIK, you are a network guru. Do you think this will work? I have tested 
> code with just a netif_stop_queue (without the lock_bh/unlock_bh parts) on a UP 
> system and have gotten no errors, but I do not have access to SMP hardware.
> 
> Thanks,
> 

I haven't done a careful review of the broadcom driver. What you
are proposing looks fine. But most network devices just use spin_lock's
rather than mutexs because there is little need for holding the lock
for a long length of time.
> 

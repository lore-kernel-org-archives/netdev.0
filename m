From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/7] bonding: fix locking in sysfs primary/active selection
Date: Fri, 18 Jan 2008 14:39:02 -0500
Message-ID: <47910056.5070603@pobox.com>
References: <12006159033257-git-send-email-fubar@us.ibm.com> <12006159063217-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52179 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763278AbYARTjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 14:39:06 -0500
In-Reply-To: <12006159063217-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> 	Fix the functions that store the primary and active slave
> options via sysfs to hold the correct locks in the correct order.
> 
> 	The bond_change_active_slave and bond_select_active_slave
> functions both require rtnl, bond->lock for read and curr_slave_lock for
> write_bh, and no other locks.  This is so that the lower level
> mode-specific functions (notably for balance-alb mode) can release locks
> down to just rtnl in order to call, e.g., dev_set_mac_address with the
> locks it expects (rtnl only).
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
>  drivers/net/bonding/bond_sysfs.c |   15 ++++++++++-----
>  1 files changed, 10 insertions(+), 5 deletions(-)

applied 1-7



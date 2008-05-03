From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] bonding: Deadlock between bonding_store_bonds and
 bond_destroy_sysfs.
Date: Fri, 02 May 2008 17:51:53 -0700 (PDT)
Message-ID: <20080502.175153.47024492.davem@davemloft.net>
References: <12097757822222-git-send-email-fubar@us.ibm.com>
	<12097757832778-git-send-email-fubar@us.ibm.com>
	<12097757842821-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, xemul@openvz.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34540
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757904AbYECAvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 20:51:53 -0400
In-Reply-To: <12097757842821-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri,  2 May 2008 17:49:39 -0700

> From: Pavel Emelyanov <xemul@openvz.org>
> 
> The sysfs layer has an internal protection, that ensures, that
> all the process sitting inside ->sore/->show callback exits
> before the appropriate entry is unregistered (the calltraces
> are rather big, but I can provide them if required).
> 
> On the other hand, bonding takes rtnl_lock in
> a) the bonding_store_bonds, i.e. in ->store callback,
> b) module exit before calling the sysfs unregister routines.
> 
> Thus, the classical AB-BA deadlock may occur. To reproduce run
> # while :; do modprobe bonding; rmmod bonding; done
> and
> # while :; do echo '+bond%d' > /sys/class/net/bonding_masters ; done
> in parallel.
> 
> The fix is to move the bond_destroy_sysfs out of the rtnl_lock,
> but _before_ bond_free_all to make sure no bonding devices exist
> after module unload.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Acked-by: Jay Vosburgh <fubar@us.ibm.com>

Acked-by: David S. Miller <davem@davemloft.net>

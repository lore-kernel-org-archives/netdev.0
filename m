From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] [PATCH] bonding: fix multiple module load problem
Date: Tue, 09 Jun 2009 10:37:58 -0700
Message-ID: <15545.1244569078@death.nxdomain.ibm.com>
References: <20090608151127.70146505@nehalam> <200906091406.45463.arnd@arndb.de> <20090609080232.45f81833@nehalam> <4A2E80B3.6010600@trash.net> <4752.1244564082@death.nxdomain.ibm.com> <4A2E8D62.6090004@trash.net> <20090609102329.565e9019@nehalam>
Cc: Patrick McHardy <kaber@trash.net>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bonding-devel@lists.sf.net, "David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:48462 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbZFIRh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 13:37:58 -0400
In-reply-to: <20090609102329.565e9019@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>Some users still load bond module multiple times to create bonding
>devices.  This accidentally was broken when sysfs interface was added.

	After looking at it, I think the multiple load stuff was broken
by the following:

commit b8a9787eddb0e4665f31dd1d64584732b2b5d051
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Fri Jun 13 18:12:04 2008 -0700

    bonding: Allow setting max_bonds to zero
    
        Permit bonding to function rationally if max_bonds is set to
    zero.  This will load the module, but create no master devices (which can
    be created via sysfs).
    
        Requires some change to bond_create_sysfs; currently, the
    netdev sysfs directory is determined from the first bonding device created,
    but this is no longer possible.  Instead, an interface from net/core is
    created to create and destroy files in net_class.
    
        Based on a patch submitted by Phil Oester <kernel@linuxaces.com>.
    Modified by Jay Vosburgh to fix the sysfs issue mentioned above and to
    update the documentation.
    
    Signed-off-by: Phil Oester <kernel@linuxace.com>
    Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

	So, the patch below should probably go to -stable, too.

>Note: sysfs and procfs still produce WARN() messages when this is done
>so the sysfs method is the recommended API.
>
>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>---
>Patch against 2.6.30-rc8
>
>--- a/drivers/net/bonding/bond_sysfs.c	2009-06-09 10:07:29.618979856 -0700
>+++ b/drivers/net/bonding/bond_sysfs.c	2009-06-09 10:18:04.039973238 -0700
>@@ -1538,6 +1538,7 @@ int bond_create_sysfs(void)
> 			printk(KERN_ERR
> 			       "network device named %s already exists in sysfs",
> 			       class_attr_bonding_masters.attr.name);
>+		ret = 0;
> 	}
>
> 	return ret;
>

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

From: nhorman@tuxdriver.com
Subject: [PATCH] bonding: various fixes for bonding, netpoll & netconsole (v3)
Date: Wed, 13 Oct 2010 22:01:48 -0400
Message-ID: <1287021713-1750-1-git-send-email-nhorman@tuxdriver.com>
Cc: bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	davem@davemloft.net, andy@greyhouse.net, amwang@redhat.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39872 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974Ab0JNCCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 22:02:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version 3, taking the following changes into account:

1) Gospo noted an oops on his test system, which arose from a use after free of the
cpumask_var_t that I allocate for use in tx blocking.  Easy fix, just alloc the
cpumask first, and free it last in the module init/exit routines

Summary:
A while ago we tried to enable netpoll on the bonding driver to enable
netconsole.  That worked well in a steady state, but deadlocked frequently in
failover conditions due to some recursive lock-taking (as well as a few other
problems).  I've gone through the driver, netconsole and netpoll code, fixed up
those deadlocks, and confirmed that, with this patch series, we can use
netconsole on bonding without deadlock in all bonding modes with all slaves,
even accross failovers.  I've also fixed up some incidental bugs that I ran
across while looking through this code, as described in individual patches

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


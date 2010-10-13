From: nhorman@tuxdriver.com
Subject: [PATCH] bonding: various fixes for bonding, netpoll & netconsole (v2)
Date: Wed, 13 Oct 2010 08:35:29 -0400
Message-ID: <1286973334-4339-1-git-send-email-nhorman@tuxdriver.com>
Cc: bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	davem@davemloft.net, andy@greyhouse.net, amwang@redhat.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38049 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754102Ab0JMMfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 08:35:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version 2, taking teh following changes into account:

1) Moved tx blocking/checking macros to netpoll.h as suggested by amwang

2) Added tx blocking macro calls to sysfs paths, as they can deadlock in the
same way that the link monitoring paths can.

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

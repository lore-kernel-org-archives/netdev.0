From: nhorman@tuxdriver.com
Subject: [PATCH] bonding: various fixes for bonding, netpoll & netconsole
Date: Tue, 12 Oct 2010 17:55:47 -0400
Message-ID: <1286920552-2173-1-git-send-email-nhorman@tuxdriver.com>
Cc: bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	davem@davemloft.net, andy@greyhouse.net, amwang@redhat.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56558 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390Ab0JLV4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 17:56:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grr, really sorry guys, 3rd times the charm.  netdev greylisted this and several
others pitched it because of a bad mail header.  I'm resending through tuxdriver
like I should have done before

A while ago we tried to enable netpoll on the bonding driver to enable
netconsole.  That worked well in a steady state, but deadlocked frequently in
failover conditions due to some recursive lock-taking (as well as a few other
problems).  I've gone through the driver, netconsole and netpoll code, fixed up
those deadlocks, and confirmed that, with this patch series, we can use
netconsole on bonding without deadlock in all bonding modes with all slaves,
even accross failovers.  I've also fixed up some incidental bugs that I ran
across while looking through this code, as described in individual patches

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


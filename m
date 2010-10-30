From: Simon Horman <horms@verge.net.au>
Subject: bonding: propagation of offload settings
Date: Sat, 30 Oct 2010 11:54:35 +0900
Message-ID: <20101030025435.GF12842@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:54477 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000Ab0J3Cy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 22:54:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am wondering what the desired behaviour for the propagating
of offload settings between master and slaves when the settings
are modified using ethtool.

I have observed the following (using Linus' latest tree, 2.6.36+)

#1 Disabling gro on a slave device propagates to the master
   but not other slaves

   bond1: generic-receive-offload: on
   eth1: generic-receive-offload: on
   eth4: generic-receive-offload: on

   # ethtool -K eth1 gro off

   bond1: generic-receive-offload: off
   eth1: generic-receive-offload: on
   eth4: generic-receive-offload: off

   This seems to occur regardless of if the slave is the
   active slave or not.

#2 No other propagation of settings occurs


It seems to me that from a user point of view it may make more sense to:

a) propagate settings from the master to the slaves and;
b) possibly disallow setting the slaves directly


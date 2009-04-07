From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: zero features for a vlan over bond
Date: Tue, 07 Apr 2009 07:16:51 -0700
Message-ID: <6223.1239113811@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0904061556140.32757@zuben.voltaire.com>
Cc: netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:56148 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861AbZDGORK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2009 10:17:10 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n37E8Vr4014252
	for <netdev@vger.kernel.org>; Tue, 7 Apr 2009 10:08:31 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n37EGwZL5091444
	for <netdev@vger.kernel.org>; Tue, 7 Apr 2009 10:16:59 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n37EGsmL011166
	for <netdev@vger.kernel.org>; Tue, 7 Apr 2009 08:16:56 -0600
In-reply-to: <Pine.LNX.4.64.0904061556140.32757@zuben.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <ogerlitz@voltaire.com> wrote:

>Using vconfig and the 8021q modules I have created a vlan device over a
>bond (e.g bond0.4001 over bond0 which is over eth0,eth1) - but for some
>reason the vlan device has no features - any idea what may be the reason
>for that? below is the flags/features matrix (eth0/1 are igb, 2.6.29)
>
>device		flags	features
>================================
>bond0.4001	0x1403	0x0
>bond0		0x1403	0x1113a9
>eth0/1		0x1803	0x111ba9

	The features system now has a dev->vlan_features that lists the
features that will work through a vlan; bond_compute_features isn't
using netdev_increment/fix_features to additionally compute the
vlan_features, so that's ending up always empty even if the underlying
device supports vlan passthrough.

	I suspect a bridge will display the same symptoms.

	I'm working on a patch; I'll see what I can come up with.  Note,
however, that at this writing, the set of drivers that explicitly
supports VLAN passthrough (a non-zero vlan_features) is rather limited.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Missing VLAN tags in bnx2
Date: Wed, 28 Feb 2007 21:12:03 +0200
Message-ID: <20070228191203.GA6576@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: netdev@vger.kernel.org, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ee.oulu.fi ([130.231.61.23]:39971 "EHLO ee.oulu.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751551AbXB1TiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 14:38:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just had to spend some time figuring out why a bnx2 card connected to
a switch monitor port didn't see any vlan tags (when in our scenario the
tags are pretty vital).  Found the following explanation:

[BNX2]: Fix VLAN on ASF
    
    Always set up the device to strip incoming VLAN tags when ASF is
    enabled. ASF firmware will not parse packets correctly if VLAN tags
    are not stripped

My fix:

#ifdef I_DONT_KNOW_WHAT_ASF_IS_AND_DONT_REALLY_CARE_EITHER
        if (REG_RD_IND(bp, bp->shmem_base + BNX2_PORT_FEATURE) &
            BNX2_PORT_FEATURE_ASF_ENABLED)
                bp->flags |= ASF_ENABLE_FLAG;
#endif

Any hope of getting this as a ethtool tunable or something similar?
There didn't seem to be a BIOS option for this (Dell PE2900), at least.

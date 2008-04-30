From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/5] e1000e: Allow TSO to trickle down to VLAN device
Date: Tue, 29 Apr 2008 17:42:48 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904FE0E6B@orsmsx414.amr.corp.intel.com>
References: <20080414170557.23286.71580.stgit@localhost.localdomain> <20080414170609.23286.42880.stgit@localhost.localdomain> <4803903B.1020100@trash.net> <4807C516.90308@intel.com> <480CA399.50708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, <netdev@vger.kernel.org>,
	<e1000-devel@lists.sourceforge.net>
To: "Patrick McHardy" <kaber@trash.net>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16497 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755879AbYD3Amr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 20:42:47 -0400
Content-class: urn:content-classes:message
In-Reply-To: <480CA399.50708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> That was a typo, I meant netdev_features_change(), which is invoked
> by dev_ethtool() and calls the netdev notifier with 
> NETDEV_FEAT_CHANGE,
> on which the VLAN code could react. I wasn't aware of the TSO + VLAN
> acceleration problems you've mentioned, do you have a pointer to more
> information about this?
> 
> In any case I would prefer to avoid having drivers mess with VLAN
> device flags. How about adding a device flag indicating that the
> driver supports TSO + VLAN acceleration and using the
> NETDEV_FEAT_CHANGE notification inside the VLAN code do adjust
> the device's flags properly?

I've been looking into this, and I agree this makes sense when creating
a new VLAN to get the device flags to the VLAN device.  However, we need
to get the TSO and/or Tx checksum offload feature flags off all VLAN
devices when the parent device has it turned off.  I don't see any clean
way of doing this with netdev_features_change().  I'd really love to
implement this correctly, so if you have any ideas on how to handle this
latter case, I'm all ears.  :-)

Thanks Patrick,
-PJ Waskiewicz

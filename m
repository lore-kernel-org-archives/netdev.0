From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/5] e1000e: Allow TSO to trickle down to VLAN device
Date: Tue, 22 Apr 2008 00:46:12 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904EE4BD3@orsmsx414.amr.corp.intel.com>
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
Received: from mga02.intel.com ([134.134.136.20]:30000 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755776AbYDVHqL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 03:46:11 -0400
Content-class: urn:content-classes:message
In-Reply-To: <480CA399.50708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> That was a typo, I meant netdev_features_change(), which is invoked
> by dev_ethtool() and calls the netdev notifier with
NETDEV_FEAT_CHANGE,
> on which the VLAN code could react. I wasn't aware of the TSO + VLAN
> acceleration problems you've mentioned, do you have a pointer to more
> information about this?

This was a conversation I had late last year on the list regarding TSO
and Tx checksum offload not getting turned on for VLAN devices, since
the VLAN device creation code doesn't copy those device feature flags.
I had proposed sending a patch, and the statement was made that some
devices might not support both of those hardware features at the same
time.  I'll try to dig up those mails.

> In any case I would prefer to avoid having drivers mess with VLAN
> device flags. How about adding a device flag indicating that the
> driver supports TSO + VLAN acceleration and using the
> NETDEV_FEAT_CHANGE notification inside the VLAN code do adjust
> the device's flags properly?

I hear you loud and clear.  I wanted to do this the "right" way in the
drivers if I couldn't do it in the kernel, and your suggestions sound
like the right way.  Let me take the suggestions here and respin this
part of the code, since I have this change in e1000, e1000e, igb, and
ixgbe, and want it to be correct.

Thanks Patrick for the feedback here.  Hopefully I'll soon have
something for Auke to resend.

Cheers,
-PJ Waskiewicz

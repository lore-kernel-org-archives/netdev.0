From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next 6/10] bnx2x: Update vlan_features
Date: Thu, 23 Jul 2009 13:21:03 +0200
Message-ID: <4A68479F.1000807@trash.net>
References: <1248191263.18195.49.camel@lb-tlvb-eilong> <4A683F83.1060701@trash.net> <4A68462C.1080709@Voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Or Gerlitz <ogerlitz@Voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34187 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753916AbZGWLVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 07:21:05 -0400
In-Reply-To: <4A68462C.1080709@Voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz wrote:
> Patrick McHardy wrote:
>> vlan_features doesn't need to be updated, the resulting dev->features
>> of the VLAN device is computed as the intersection of dev->features
>> and dev->vlan_features.
> 
> I'm not sure to follow, do you claim that the patches to bnx2x and bonding aren't needed to make vlans set on top of such devices to support these features?

In case of bnx2x, its enough to initialize dev->vlan_features once
to a static set and update only dev->features when appropriately.
vlan_features is meant to contain the hardware supported features
for VLANs, which are not necessarily active.

In case of bonding, its necessary to update vlan_features so it
contains the intersection of all underlying devices. But a
change will only take effect for existing VLANs (f.i. when
enslaving a new device) if you call netdev_features_change().

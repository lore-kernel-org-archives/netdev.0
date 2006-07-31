From: David Miller <davem@davemloft.net>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Sun, 30 Jul 2006 20:50:32 -0700 (PDT)
Message-ID: <20060730.205032.130618331.davem@davemloft.net>
References: <44CA34D0.1070507@candelatech.com>
	<20060728215032.GA17930@walrus.eth1.org>
	<44CA87C5.1060905@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christophe.devriese@eth1.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40682
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751115AbWGaDuW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 23:50:22 -0400
To: greearb@candelatech.com
In-Reply-To: <44CA87C5.1060905@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 28 Jul 2006 14:55:17 -0700

> The skb_bond method assigns skb->dev when it does the 'keep',
> but the VLAN code immediately over-writes the skb->dev when
> searching for the vlan device.
> 
> What is the purpose of assinging skb->dev to the master device?

This makes me consider this patch highly dubious, at best.

The whole intention of bonding on input is to make all packets
incoming on the individual bond slaves to look like they come in via
the master device.

Therefore, even when the bond slaves are VLAN devices, in the end the
skb->dev should be the bond master device _not_ the VLAN device.

I'm not applying this patch, it doesn't look correct at all.

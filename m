From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/33] netdev: introduce dev_get_stats()
Date: Thu, 20 Nov 2008 04:27:23 -0800 (PST)
Message-ID: <20081120.042723.155391181.davem@davemloft.net>
References: <20081117234354.948324675@vyatta.com>
	<20081119.214057.200155427.davem@davemloft.net>
	<49252B0E.10602@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58445
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754454AbYKTM1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:27:23 -0500
In-Reply-To: <49252B0E.10602@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 20 Nov 2008 10:17:02 +0100

> I have one comment about netdev stats
> 
> on 32bit arches, SMP :
> 
> struct net_device = 0x480
> offsetof(struct net_device, features)=0x44
> offsetof(struct net_device, stats)=0x50
> offsetof(struct net_device, stats.rx_packets)=0x50
> 
> So we trash features field, thats a problem...
> 
> I wonder if we could zap stats from netdev structure.
> Some drivers already use external stats handling (like loopback)

Some... but most just want a single stats structure, and that's
what this is for.

Let's just put the appropriate alignment tags in struct net_device
after all of this dust settles, ok?

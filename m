From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: b53: Fix VLAN usage and how we treat CPU
 port
Date: Wed, 16 Nov 2016 23:26:03 -0500 (EST)
Message-ID: <20161116.232603.2010098159063305096.davem@davemloft.net>
References: <20161115235815.25641-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, knaack.h@gmx.de
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33052 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752375AbcKQE0F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 23:26:05 -0500
In-Reply-To: <20161115235815.25641-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 15 Nov 2016 15:58:15 -0800

> We currently have a fundamental problem in how we treat the CPU port and
> its VLAN membership. As soon as a second VLAN is configured to be
> untagged, the CPU automatically becomes untagged for that VLAN as well,
> and yet, we don't gracefully make sure that the CPU becomes tagged in
> the other VLANs it could be a member of. This results in only one VLAN
> being effectively usable from the CPU's perspective.
> 
> Instead of having some pretty complex logic which tries to maintain the
> CPU port's default VLAN and its untagged properties, just do something
> very simple which consists in neither altering the CPU port's PVID
> settings, nor its untagged settings:
> 
> - whenever a VLAN is added, the CPU is automatically a member of this
>   VLAN group, as a tagged member
> - PVID settings for downstream ports do not alter the CPU port's PVID
>   since it now is part of all VLANs in the system
> 
> This means that a typical example where e.g: LAN ports are in VLAN1, and
> WAN port is in VLAN2, now require having two VLAN interfaces for the
> host to properly terminate and send traffic from/to.
> 
> Fixes: Fixes: a2482d2ce349 ("net: dsa: b53: Plug in VLAN support")
> Reported-by: Hartmut Knaack <knaack.h@gmx.de>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> David,
> 
> Can you queue this for -stable so it makes it into 4.8.4?

Applied and queued up for -stable, thanks.

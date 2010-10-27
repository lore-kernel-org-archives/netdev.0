From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG net-2.6 vlan/bonding] lockdep splats
Date: Wed, 27 Oct 2010 12:03:34 +0000
Message-ID: <20101027120334.GA11247@ff.dom.local>
References: <1288175070.2709.86.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34157 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760864Ab0J0MDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 08:03:44 -0400
Received: by bwz11 with SMTP id 11so471004bwz.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 05:03:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1288175070.2709.86.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 27, 2010 at 12:24:30PM +0200, Eric Dumazet wrote:
> On latest net-2.6 kernel I got following splat, not sure its related to
> vlan changes...

Seems to be even older. Could you try this patch?

Thanks,
Jarek P.
---

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index beb3b7c..bdb68a6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -493,9 +493,9 @@ static void bond_vlan_rx_register(struct net_device *bond_dev,
 	struct slave *slave;
 	int i;
 
-	write_lock(&bond->lock);
+	write_lock_bh(&bond->lock);
 	bond->vlgrp = grp;
-	write_unlock(&bond->lock);
+	write_unlock_bh(&bond->lock);
 
 	bond_for_each_slave(bond, slave, i) {
 		struct net_device *slave_dev = slave->dev;

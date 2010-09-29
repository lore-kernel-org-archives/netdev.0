From: Roger Luethi <rl@hellgate.ch>
Subject: VLAN packets silently dropped in promiscuous mode
Date: Wed, 29 Sep 2010 13:37:57 +0200
Message-ID: <20100929113757.GA23755@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail13.bluewin.ch ([195.186.18.62]:39122 "EHLO
	mail13.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323Ab0I2LpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 07:45:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed packets for unknown VLANs getting silently dropped even in
promiscuous mode (this is true only for the hardware accelerated path).
netif_nit_deliver was introduced specifically to prevent that, but the
function gets called only _after_ packets from unknown VLANs have been
dropped.

Presumably this has been the case since

commit e1c096e251e52773afeffbbcb74d0a072be47ea3
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Tue Jan 6 10:50:09 2009 -0800
    vlan: Add GRO interfaces

I didn't find any indication that the change in behavior is intentional. Is
it?

Roger

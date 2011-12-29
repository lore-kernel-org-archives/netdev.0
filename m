From: Florian Zumbiehl <florz@florz.de>
Subject: Re: [PATCH] skge: restore multicast rx filter on resume
Date: Thu, 29 Dec 2011 07:48:50 +0100
Message-ID: <20111229064849.GB8041@florz.florz.dyndns.org>
References: <20111227095635.19087752@nehalam.linuxnetplumber.net>
 <20111228074143.GA8041@florz.florz.dyndns.org>
 <20111228092714.0a6d5f80@nehalam.linuxnetplumber.net>
 <20111228.130908.182833189468208987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rain.florz.de ([62.216.164.86]:55548 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751019Ab1L2Gs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 01:48:57 -0500
Content-Disposition: inline
In-Reply-To: <20111228.130908.182833189468208987.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Florian, please formally resubmit this with proper changelog and
> Stephen's ack.

Erm, yeah, indeed. Well, there you go ...

Florian

---------------------------------------------------------------------------
skge: restore rx multicast filter on resume and after config changes

Restore skge hardware registers for multicast filtering to their
appropriate values after system resume and after hardware restarts
that are done when changing certain settings.

Signed-off-by: Florian Zumbiehl <florz@florz.de>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index f4be5c7..8f985a8 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2587,6 +2587,9 @@ static int skge_up(struct net_device *dev)
 	spin_unlock_irq(&hw->hw_lock);
 
 	napi_enable(&skge->napi);
+
+	skge_set_multicast(dev);
+
 	return 0;
 
  free_rx_ring:

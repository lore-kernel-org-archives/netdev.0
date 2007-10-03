From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: jumbo frame regression fix
Date: Tue, 2 Oct 2007 18:02:09 -0700
Message-ID: <20071002180209.47c350a3@freepuppy.rosehill>
References: <1191372129.26233.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: pomac@vapor.com, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46129 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753121AbXJCBCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 21:02:33 -0400
In-Reply-To: <1191372129.26233.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unneeded check that caused problems with jumbo frame sizes.
The check was recently added and is wrong.
When using jumbo frames the sky2 driver does fragmentation, so
rx_data_size is less than mtu.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-10-02 17:56:31.000000000 -0700
+++ b/drivers/net/sky2.c	2007-10-02 17:58:56.000000000 -0700
@@ -2163,9 +2163,6 @@ static struct sk_buff *sky2_receive(stru
 	sky2->rx_next = (sky2->rx_next + 1) % sky2->rx_pending;
 	prefetch(sky2->rx_ring + sky2->rx_next);
 
-	if (length < ETH_ZLEN || length > sky2->rx_data_size)
-		goto len_error;
-
 	/* This chip has hardware problems that generates bogus status.
 	 * So do only marginal checking and expect higher level protocols
 	 * to handle crap frames.

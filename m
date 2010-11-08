From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ip_summed setting for TCP pure-ACK packets
Date: Mon, 08 Nov 2010 16:35:13 +0000
Message-ID: <1289234113.2222.20.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sf-linux-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:52718 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904Ab0KHQfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 11:35:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we discussed at LPC:

Current controllers handled by the sfc driver have a per-queue (rather
than per-packet) option for checksum generation.  Currently pure-ACK
packets sent by TCP have ip_summed == CHECKSUM_NONE and we must send
them on hardware queues with checksum generation disabled.  To support
this, we allocate 2 hardware queues per core TX queue.

To reduce the risk of reordering (and possibly the number of hardware TX
queues required), it would be helpful for TCP to set ip_summed ==
CHECKSUM_PARTIAL on pure-ACK packets when the output device is known to
support checksum generation.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


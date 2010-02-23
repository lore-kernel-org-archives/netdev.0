From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH] Preserve queue mapping with bonding and
 VLAN devices
Date: Tue, 23 Feb 2010 15:59:01 +0000
Message-ID: <1266940741.2109.7.camel@achroite.uk.solarflarecom.com>
References: <33081266938239@webmail48.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:6987 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164Ab0BWP7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 10:59:06 -0500
In-Reply-To: <33081266938239@webmail48.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-02-23 at 18:17 +0300, "Oleg A. Arkhangelsky" wrote:
> 
> Must be applied with "[net-next-2.6 PATCH] Multiqueue support for bonding devices"
> 
> Forwarded packet goes more that once throught dev_queue_xmit() when
> using bonding or 802.1q VLAN devices, so we've lost rx-tx queue mapping
> index for real devices.
[...]

The queue mapping will normally be the same, only no longer biased by 1.
So I think a better solution would be to maintain that bias on TX as
well, or to remove the bias and reserve -1 for unknown RX queue.

We already have hardware that can do RSS across up to 128 RX queues, so
an 8-bit limit is uncomfortably close.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


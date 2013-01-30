From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 11/11] net/mlx4_en: Fix transmit timeout when
 driver restarts port
Date: Wed, 30 Jan 2013 16:50:12 +0000
Message-ID: <1359564612.2789.5.camel@bwh-desktop.uk.solarflarecom.com>
References: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
	 <1359542067-10760-12-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41974 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368Ab3A3QuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 11:50:15 -0500
In-Reply-To: <1359542067-10760-12-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-30 at 12:34 +0200, Amir Vadai wrote:
> Under heavy CPU load, changing, ring size/mtu/etc. could result in transmit
> timeout, since stop-start port might take more than 10 seconds.
> Calling netif_detach_device to prevent tx queue transmit timeout.
[...]

It's actually worse than that - the watchdog can fire instantly if it
has been 10 seconds since the last packet was queued.

Anyway, this looks very much like a pending fix for the same issue in
sfc, so hopefully we both did it right. :-)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

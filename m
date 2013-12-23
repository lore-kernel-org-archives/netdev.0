From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Definition of the term rx/tx/combined channel
Date: Mon, 23 Dec 2013 22:28:17 +0000
Message-ID: <1387837697.1635.5.camel@bwh-desktop.uk.level5networks.com>
References: <52B6FFE7.6080906@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eugenia Emantayev <eugenia@mellanox.com>,
	netdev <netdev@vger.kernel.org>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20422 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757627Ab3LWW2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 17:28:25 -0500
In-Reply-To: <52B6FFE7.6080906@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-12-22 at 17:06 +0200, Amir Vadai wrote:
> Hi Ben,
> 
> I'm trying to understand the exact definition of the term channel.
> 
> According to ethtool: A channel is an IRQ and the set of queues that can
> trigger that IRQ.
> 
> In our driver (Mellanox's Connect-X), we have an IRQ's, rx rings and tx
> rings.
> 
> Usually we have one IRQ per rx ring, but if system resources are
> limited, those numbers could be different.
> tx rings are sharing the same IRQ's assigned by rx rings (for
> completions), but many tx rings could share the same IRQ.
> 
> Is the rx channels == number of rx rings, and same for tx?
> How is this related to the number of IRQ's?

If an IRQ is triggered by completions from both RX and TX rings then
that's a combined channel.

Do you want to make the number of TX rings per IRQ configurable through
ethtool?

> Should we show other IRQ's we use for async events from the HW, as 'other'?

If they are only used for those events and not also for completions,
then yes.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

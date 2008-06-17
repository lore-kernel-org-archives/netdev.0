From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 11/15]bnx2x: Add TPA, Broadcoms HW LRO
Date: Tue, 17 Jun 2008 16:05:40 +0100
Message-ID: <20080617150539.GJ5350@solarflare.com>
References: <1213714166.5817.181.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.mbr-roch.zen.net.uk ([212.23.3.140]:58633 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755862AbYFQPFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 11:05:48 -0400
Content-Disposition: inline
In-Reply-To: <1213714166.5817.181.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eilon Greenstein wrote:
> The TPA stands for Transparent Packet Aggregation. When enabled, the FW
> aggregate in-order TCP packets according to the 4-tuple match and sends
> 1 big packet to the driver. This packet is stored on an SGL in which
> each SGE is 1 page. The FW also implements a timeout algorithm and it
> honors all TCP flag, including the push flag as a trigger to halt
> aggregation.
[...]

LRO is not compatible with forwarding and will currently trigger a BUG() or
WARN() if used on packets that are then forwarded.  I am about to post a
fix for that which will automatically disable LRO as necessary, but it
depends on drivers behaving properly.

TPA needs to be controllable per-device through the ethtool set_flags()
operation and should be visible in the device feature flags as NETIF_F_LRO
(and through get_flags()).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.

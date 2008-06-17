From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 11/15]bnx2x: Add TPA, Broadcoms HW LRO
Date: Tue, 17 Jun 2008 16:17:06 +0100
Message-ID: <20080617151704.GK5350@solarflare.com>
References: <1213714166.5817.181.camel@lb-tlvb-eliezer> <20080617150539.GJ5350@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.mbr-roch.zen.net.uk ([212.23.3.142]:43891 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755739AbYFQPRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 11:17:11 -0400
Content-Disposition: inline
In-Reply-To: <20080617150539.GJ5350@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Eilon Greenstein wrote:
> > The TPA stands for Transparent Packet Aggregation. When enabled, the FW
> > aggregate in-order TCP packets according to the 4-tuple match and sends
> > 1 big packet to the driver. This packet is stored on an SGL in which
> > each SGE is 1 page. The FW also implements a timeout algorithm and it
> > honors all TCP flag, including the push flag as a trigger to halt
> > aggregation.
> [...]
> 
> LRO is not compatible with forwarding and will currently trigger a BUG() or
> WARN() if used on packets that are then forwarded.

Actually, since this implementation doesn't set gso_size in LRO'd skbs, it
will confuse TCP in interesting ways instead.  You need to set gso_size to
the largest segment size seen in the packets that were aggregated.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.

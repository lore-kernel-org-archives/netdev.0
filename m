From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 05/11] net/mlx4_en: Fix vlan mask for ethtool
 steering rules
Date: Wed, 30 Jan 2013 17:20:17 +0000
Message-ID: <1359566417.2789.17.camel@bwh-desktop.uk.solarflarecom.com>
References: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
	 <1359542067-10760-6-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6202 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756017Ab3A3RUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 12:20:21 -0500
In-Reply-To: <1359542067-10760-6-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-30 at 12:34 +0200, Amir Vadai wrote:
> From: Hadar Hen Zion <hadarh@mellanox.com>
> 
> The vlan mask field should be validated and assigned according to the field
> size which is 12 bits.
[...]

My understanding is that ethtool_flow_ext::vlan_tci corresponds to the
whole VLAN tag; a filter rule that matches only the VID must have a mask
of htons(0xfff).

The original implementation of this extension was in ixgbe and it's now
unclear to me whether it's programming hardware filters to match just
the VID or the whole VLAN tag.  Alexander, can you answer this?

I was thinking about adding new keywords to ethtool -U ('vid', 'vtag'?)
to make it easier to specify just the VID and clearer when you're
specifying the full tag.  (The 'vlan' keyword would have to remain but
could be removed from documentation.)  But if no-one really implements
matching of the full tag then maybe we can pretend those 4 bits don't
exist.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

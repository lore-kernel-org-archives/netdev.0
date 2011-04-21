From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH] bonding: fix bridged bonds in 802.3ad mode
Date: Thu, 21 Apr 2011 21:27:49 +0200
Message-ID: <20110421192749.GA8732@midget.suse.cz>
References: <20110421184748.GD23756@midget.suse.cz>
 <1303412899.3165.47.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Benjamin Poirier <benjamin.poirier@polymtl.ca>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52212 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751557Ab1DUT1v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 15:27:51 -0400
Content-Disposition: inline
In-Reply-To: <1303412899.3165.47.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 21, 2011 at 08:08:19PM +0100, Ben Hutchings wrote:
> It seems to me that 1e253c3b8a1aeed51eef6fc366812f219b97de65 is bogus
> and should be reverted, rather than worked around by other drivers.  We
> shouldn't enable non-conformant forwarding behaviour by default just
> because some people find it useful.  The administrator should have to
> explicitly enable it.

This is what I thought as well. I find it even more awkward to 
make this behaviour dependend on the STP setting of the bridge
(turning on STP works around this bonding problem, btw).

But even if forwarding of link-local frames is made optional in
some way, it will still break bonding when turned on. So unless
this it is completely reverted, we still need some kind of fix
for bonding.

Btw, this could also be fixed by checking for 
skb->protocol == htons(ETH_P_SLOW) directly in the bridging code.
However, I think the wonderful rx_handler infrastructure makes it
much cleaner this way...

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ


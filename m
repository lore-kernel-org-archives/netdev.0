From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: deliver skbs on inactive slaves to exact
 matches
Date: Thu, 10 Jun 2010 22:31:13 -0700 (PDT)
Message-ID: <20100610.223113.200377963.davem@davemloft.net>
References: <20100603193011.4916.12354.stgit@jf-dev2-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, nhorman@tuxdriver.com,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39983
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754860Ab0FKFbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 01:31:02 -0400
In-Reply-To: <20100603193011.4916.12354.stgit@jf-dev2-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Thu, 03 Jun 2010 12:30:11 -0700

> Currently, the accelerated receive path for VLAN's will
> drop packets if the real device is an inactive slave and
> is not one of the special pkts tested for in
> skb_bond_should_drop().  This behavior is different then
> the non-accelerated path and for pkts over a bonded vlan.
 ...
> This patch adds a sk_buff flag which is used for tagging
> skbs that would previously been dropped and allows the
> skb to continue to skb_netif_recv().  Here we add
> logic to check for the deliver_no_wcard flag and if it
> is set only deliver to handlers that match exactly.  This
> makes both paths above consistent and gives pkt handlers
> a way to identify skbs that come from inactive slaves.
> Without this patch in some configurations skbs will be
> delivered to handlers with exact matches and in others
> be dropped out right in the vlan path.
 ...
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

I can't figure out a better way to fix this myself so I've
applied your patch, thanks John!

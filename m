From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] NET: [CORE] Stack changes to add multiqueue
 hardware support API
Date: Mon, 18 Jun 2007 23:28:43 -0700 (PDT)
Message-ID: <20070618.232843.111185541.davem@davemloft.net>
References: <20070618184208.12274.13017.stgit@localhost.localdomain>
	<20070618184229.12274.88596.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	hadi@cyberus.ca, kaber@trash.net
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54000
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752964AbXFSG2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 02:28:25 -0400
In-Reply-To: <20070618184229.12274.88596.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Date: Mon, 18 Jun 2007 11:42:29 -0700

> +
> + 	/* The TX queue control structures */
> + 	struct net_device_subqueue	*egress_subqueue;
> + 	int				egress_subqueue_count;

Since every net device will have at least one subqueue, I
would suggest that you do this as follows:

1) In net_device change the quoted part of the patch above to:

	int				egress_subqueue_count;
	struct net_device_subqueue	egress_subqueue[0];

2) In alloc_netdev():

   Factor (sizeof(struct egress_subqueue) * num_subqueues) into
   the net_device allocation size, place the "priv" area after
   the subqueues.

This will save us pointer dereferences on all of these quite
common accesses.

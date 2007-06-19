From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/3] NET: [CORE] Stack changes to add multiqueue hardware support API
Date: Tue, 19 Jun 2007 10:31:06 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903111571@orsmsx414.amr.corp.intel.com>
References: <20070618.232843.111185541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>,
	<kaber@trash.net>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:30941 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757500AbXFSRbJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 13:31:09 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070618.232843.111185541.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> Date: Mon, 18 Jun 2007 11:42:29 -0700
> 
> > +
> > + 	/* The TX queue control structures */
> > + 	struct net_device_subqueue	*egress_subqueue;
> > + 	int				egress_subqueue_count;
> 
> Since every net device will have at least one subqueue, I 
> would suggest that you do this as follows:
> 
> 1) In net_device change the quoted part of the patch above to:
> 
> 	int				egress_subqueue_count;
> 	struct net_device_subqueue	egress_subqueue[0];
> 
> 2) In alloc_netdev():
> 
>    Factor (sizeof(struct egress_subqueue) * num_subqueues) into
>    the net_device allocation size, place the "priv" area after
>    the subqueues.
> 
> This will save us pointer dereferences on all of these quite 
> common accesses.

Thanks Dave!  I'll be putting this in today and run a test pass on it.
Thanks for the feedback.

-PJ Waskiewicz 

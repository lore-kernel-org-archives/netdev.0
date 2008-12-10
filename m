From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] benet: header and init functions
Date: Tue, 09 Dec 2008 22:44:28 -0800 (PST)
Message-ID: <20081209.224428.261629001.davem@davemloft.net>
References: <1228832384.6435.94.camel@sperla-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, jeff@garzik.org,
	subbus@serverengines.com
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56781
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753603AbYLJGo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 01:44:27 -0500
In-Reply-To: <1228832384.6435.94.camel@sperla-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Tue, 09 Dec 2008 19:49:44 +0530

> +	pnob = netdev->priv;

netdev->priv should never be accessed directly, use
netdev_priv() always

netdev->priv has even been removed in the net-next-2.6
tree so we don't want any new references sneaking into
the tree as this will cause build failures.

> +	struct be_net_object *pnob = (struct be_net_object *)netdev->priv;
 ...
> +	struct be_net_object *pnob = (struct be_net_object *)netdev->priv;

And when you convert these cases, remove the casts.

They are pointless since netdev_priv() (and netdev->priv) are void
pointers.

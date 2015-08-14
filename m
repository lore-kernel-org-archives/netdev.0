From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rocker: hook ndo_neigh_destroy to cleanup
 neigh refs in driver
Date: Thu, 13 Aug 2015 17:07:02 -0700 (PDT)
Message-ID: <20150813.170702.2090658035067871522.davem@davemloft.net>
References: <1439430325-49311-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558AbbHNAHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 20:07:03 -0400
In-Reply-To: <1439430325-49311-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed, 12 Aug 2015 18:45:25 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> Rocker driver tracks arp_tbl neighs to resolve IPv4 route nexthops.  The
> driver uses NETEVENT_NEIGH_UPDATE for neigh adds and updates, but there is
> no event when the neigh is removed from the device (such as when the device
> goes admin down).  This patches hooks ndo_neigh_destroy so the driver can
> know when a neigh is removed from the device.  In response, the driver will
> purge the neigh entry from its internal tbl.
> 
> I didn't find an in-tree users of ndo_neigh_destroy, so I'm not sure if
> this ndo is vestigial or if there are out-of-tree users.  In any case, it
> does what I need here.  An alternative design would be to generate
> NETEVENT_NEIGH_UPDATE event when neigh is being destroyed, setting state to
> NUD_NONE so driver knows neigh entry is dead.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Also applied.

->ndo_neigh_destroy() is there simply for completeness.  If anyone
needed to manage neigh's they likely would have private software state
assosciated with entries they would need to release when the neigh
object is going away.

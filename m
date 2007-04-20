From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] PPPOE: race between interface going down and
 connect()
Date: Fri, 20 Apr 2007 16:57:42 -0700 (PDT)
Message-ID: <20070420.165742.66806114.davem@davemloft.net>
References: <11737949753580-git-send-email-mostrows@earthlink.net>
	<1173794975536-git-send-email-mostrows@earthlink.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mostrows@watson.ibm.com, netdev@vger.kernel.org, florz@florz.de
To: mostrows@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45922
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752414AbXDTX5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 19:57:39 -0400
In-Reply-To: <1173794975536-git-send-email-mostrows@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Ostrowski <mostrows@earthlink.net>
Date: Tue, 13 Mar 2007 09:09:33 -0500

> below you find a patch that (hopefully) fixes a race between an interface
> going down and a connect() to a peer on that interface. Before,
> connect() would determine that an interface is up, then the interface
> could go down and all entries referring to that interface in the
> item_hash_table would be marked as ZOMBIEs and their references to
> the device would be freed, and after that, connect() would put a new
> entry into the hash table referring to the device that meanwhile is
> down already - which also would cause unregister_netdevice() to wait
> until the socket has been release()d.
> 
> This patch does not suffice if we are not allowed to accept connect()s
> referring to a device that we already acked a NETDEV_GOING_DOWN for
> (that is: all references are only guaranteed to be freed after
> NETDEV_DOWN has been acknowledged, not necessarily after the
> NETDEV_GOING_DOWN already). And if we are allowed to, we could avoid
> looking through the hash table upon NETDEV_GOING_DOWN completely and
> only do that once we get the NETDEV_DOWN ...
> 
> mostrows:
> pppoe_flush_dev is called on NETDEV_GOING_DOWN and NETDEV_DOWN to deal with
> this "late connect" issue.  Ideally one would hope to notify users at the
> "NETDEV_GOING_DOWN" phase (just to pretend to be nice).  However, it is the
> NETDEV_DOWN scan that takes all the responsibility for ensuring nobody is
> hanging around at that time.
> 
> Signed-off-by: Florian Zumbiehl <florz@florz.de>
> Acked-by: Michal Ostrowski <mostrows@earthlink.net>

Applied to net-2.6.22, thanks!

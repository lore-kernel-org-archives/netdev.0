From: Anders Franzen <anders.franzen@ericsson.com>
Subject: Re: [PATCH] arp_notify: unconditionally send gratuitous ARP for
 NETDEV_NOTIFY_PEERS.
Date: Mon, 14 Mar 2011 10:26:39 +0100
Message-ID: <1300094799.30687.5.camel@seasc7941>
References: <1297446256-23917-1-git-send-email-ian.campbell@citrix.com>
	 <20110214.174654.115944453.davem@davemloft.net>
	 <1297761225.21980.3663.camel@zakaz.uk.xensource.com>
	 <20110215.105114.226760606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Ian.Campbell@eu.citrix.com" <Ian.Campbell@eu.citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:53536 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755137Ab1CNJXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 05:23:48 -0400
In-Reply-To: <20110215.105114.226760606.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nice, so this is a generic way of getting out gratuitous arps.
Can it be used by drivers (macvlan) on top of bonding.
Bonding is sending the BOND_FAILOVER event that could be mapped
to NOTIFY_PEERS in the higher level devices.

And bonding is implementing its own grat arps functions, maybe it could
be broken out to use the NOTIFY_PEERS instead.

And what about IPv6, would it be ok to implement an unsolicited NA on
the event?

I will happily implement the above, if anyone thinks it's worth it?

BR
 Anders


On Tue, 2011-02-15 at 19:51 +0100, David Miller wrote:
> From: Ian Campbell <Ian.Campbell@eu.citrix.com>
> Date: Tue, 15 Feb 2011 09:13:45 +0000
> 
> > On Tue, 2011-02-15 at 01:46 +0000, David Miller wrote:
> >> From: Ian Campbell <ian.campbell@citrix.com>
> >> Date: Fri, 11 Feb 2011 17:44:16 +0000
> >> 
> >> > NETDEV_NOTIFY_PEER is an explicit request by the driver to send a link
> >> > notification while NETDEV_UP/NETDEV_CHANGEADDR generate link
> >> > notifications as a sort of side effect.
>  ...
> > I nearly forgot -- the NETDEV_NOTIFY_PEER stuff was tagged for
> > stable/longterm backport (it appeared in 2.6.32.19 or so). I think this
> > change should likewise go back, what do you think?
> 
> Sure, I've queued it up for -stable.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



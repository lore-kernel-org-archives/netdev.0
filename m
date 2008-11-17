From: David Miller <davem@davemloft.net>
Subject: Re: ARP table question
Date: Sun, 16 Nov 2008 19:16:28 -0800 (PST)
Message-ID: <20081116.191628.135824721.davem@davemloft.net>
References: <491B1841.9050404@candelatech.com>
	<491B31EB.4050304@candelatech.com>
	<491B5452.6020709@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52684
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755061AbYKQDQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 22:16:28 -0500
In-Reply-To: <491B5452.6020709@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Wed, 12 Nov 2008 14:10:26 -0800

> Ben Greear wrote:
> > I have 500 mac-vlans on a system talking to 500 other
> > mac-vlans.  My problem is that the arp-table gets extremely
> > huge because every time an arp-request comes in on all mac-vlans,
> > a stale arp entry is added for each mac-vlan.  I have filtering
> > turned on, but that doesn't help because the neigh_event_ns call
> > below will cause a stale neighbor entry to be created regardless
> > of whether a replay will be sent or not.
> > Maybe the neigh_event code should be below the checks for dont_send,
> > and only create check neigh_event_ns if we are !dont_send?
> 
> The attached patch makes it work much better for me.  The patch
> will cause the code to NOT create a stale neighbor entry if we
> are not going to respond to the ARP request.  The old code
> *would* create a stale entry even if we are not going to respond.
> 
> This is against 2.6.25.15.
> 
> Signed-off-by:  Ben Greear<greearb@candelatech.com>

This change makes a lot of sense to me, I'll add it to net-next-2.6
so it can cook in there for a while just in case there are some
unwanted side-effects.

Thanks.

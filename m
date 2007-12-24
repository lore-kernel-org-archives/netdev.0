From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-2.6.25 1/2][NETNS] net: Modify the neighbour table
 code so it handles multiple network namespaces
Date: Mon, 24 Dec 2007 15:56:22 -0800 (PST)
Message-ID: <20071224.155622.05258191.davem@davemloft.net>
References: <20071221130223.348101205@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071221131601.818555294@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, den@openvz.org, benjamin.thery@bull.net
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46921
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751373AbXLXX4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 18:56:23 -0500
In-Reply-To: <20071221131601.818555294@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric.W.Biederman" <ebiederm@xmission.com>"@fr.ibm.com
Date: Fri, 21 Dec 2007 14:02:24 +0100

> I'm actually surprised at how much was involved.  At first glance it appears
> that the neighbour table data structures are already split by network device
> so all that should be needed is to modify the user interface commands
> to filter the set of neighbours by the network namespace of their devices.
> 
> However a couple things turned up while I was reading through the code.
> The proxy neighbour table allows entries with no network device, and
> the neighbour parms are per network device (except for the defaults)
> so they now need a per network namespace default.
> 
> So I updated the two structures (which surprised me) with their very
> own network namespace parameter.  Updated the relevant lookup and
> destroy routines with a network namespace parameter and modified
> the code that interacts with users to filter out neighbour
> table entries for devices of other namespaces.
> 
> I'm a little concerned that we can modify and display the global
> table configuration and from all network namespaces.  But
> this appears good enough for now.
> 
> I keep thinking modifying the neighbour table to have per network
> namespace instances of each table type would should be cleaner.  The
> hash table is already dynamically sized so there are it is not a limiter.
> The default parameter would be straight forward to take care of.  However
> when I look at the how the network table is built and used I still find
> some assumptions that there is only a single neighbour table for each
> type of table in the kernel.  The netlink operations, neigh_seq_start,
> the non-core network users that call neigh_lookup.  So while it might
> be doable it would require more refactoring than my current approach
> of just doing a little extra filtering in the code.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied, thanks.

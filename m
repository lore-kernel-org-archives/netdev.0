From: Patrick McHardy <kaber@trash.net>
Subject: Re: PATCH: fix bridged 802.3ad bonding
Date: Tue, 03 Jun 2008 16:13:13 +0200
Message-ID: <48455179.7030503@trash.net>
References: <20080603132106.GA3256@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41805 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216AbYFCONP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 10:13:15 -0400
In-Reply-To: <20080603132106.GA3256@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac wrote:
> Hi,
> 
> Bonding in 802.3ad mode breaks when the bond interface is added
> to a bridge (which makes 802.3ad unusable in XEN, for example).
> 
> The problem is that br_pass_frame_up() will change the skb's dev
> pointer to point to the bridge interface. As a result, the LACP
> packets will not reach the bond_3ad_lacpdu_recv() protocol
> handler registered on the bonding device. Even if they did, the
> handler won't work with the changed skb->dev.
> 
> The following patch fixes the problem.


This shouldn't be done in the core code. How about handling this
in either the bridging code or registering the ptype handler for
the briding device?


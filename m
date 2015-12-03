From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] ipv4: igmp: Allow removing groups from a
 removed interface
Date: Thu, 03 Dec 2015 12:07:36 -0500 (EST)
Message-ID: <20151203.120736.596557724540684861.davem@davemloft.net>
References: <1448983868-811-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752746AbbLCRHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 12:07:37 -0500
In-Reply-To: <1448983868-811-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue,  1 Dec 2015 16:31:08 +0100

> When a multicast group is joined on a socket, a struct ip_mc_socklist
> is appended to the sockets mc_list containing information about the
> joined group.
> 
> If the interface is hot unplugged, this entry becomes stale. Prior to
> commit 52ad353a5344f ("igmp: fix the problem when mc leave group") it
> was possible to remove the stale entry by performing a
> IP_DROP_MEMBERSHIP, passing either the old ifindex or ip address on
> the interface. However, this fix enforces that the interface must
> still exist. Thus with time, the number of stale entries grows, until
> sysctl_igmp_max_memberships is reached and then it is not possible to
> join and more groups.
> 
> The previous patch fixes an issue where a IP_DROP_MEMBERSHIP is
> performed without specifying the interface, either by ifindex or ip
> address. However here we do supply one of these. So loosen the
> restriction on device existence to only apply when the interface has
> not been specified. This then restores the ability to clean up the
> stale entries.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Fixes: 52ad353a5344f "(igmp: fix the problem when mc leave group")

Applied and queued up for -stable, thanks Andrew.

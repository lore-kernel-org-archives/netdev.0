From: David Miller <davem@davemloft.net>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Tue, 03 Mar 2009 00:48:29 -0800 (PST)
Message-ID: <20090303.004829.160372230.davem@davemloft.net>
References: <49AC5BC1.3030901@trash.net>
	<20090302.144725.223672439.davem@davemloft.net>
	<49AC65A4.6020908@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, shemminger@vyatta.com,
	ebiederm@xmission.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42906
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752208AbZCCIsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 03:48:47 -0500
In-Reply-To: <49AC65A4.6020908@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 03 Mar 2009 00:03:00 +0100

> David Miller wrote:
> > From: Patrick McHardy <kaber@trash.net>
> > Date: Mon, 02 Mar 2009 23:20:49 +0100
> > 
> >> This looks like its working fine. Despite the non-desirable active
> >> spinning, this seems like the best fix (actually much simpler than
> >> I expected to be possible) at this time. If we just could avoid
> >> the spinning when unnecessary, it would be perfect :)
> > Could you give that "not actually in-progress" detection a shot?
> > I don't like the spinning either.
> 
> I tried this morning, the problem is that its always the sysctl
> handler which will run into the deadlock first, but there is no
> reliable indication to avoid it other than that the RTNL is
> already held. The problem is that the sysctl interface puts the
> process holding the RTNL to sleep and allows a process requiring
> it to run. Any different synchronization attempt will have the
> same problem, it seems you simply can't hold any locks while
> unregistering sysctls.

Ok, I applied Stephen's patches then...

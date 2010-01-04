From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igmp: fix ip_mc_sf_allow race
Date: Sun, 03 Jan 2010 21:54:41 -0800 (PST)
Message-ID: <20100103.215441.43026709.davem@davemloft.net>
References: <1262183005-28406-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48512
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750824Ab0ADFyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:54:38 -0500
In-Reply-To: <1262183005-28406-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fleitner@redhat.com>
Date: Wed, 30 Dec 2009 12:23:25 -0200

> Almost all igmp functions accessing inet->mc_list are protected by
> rtnl_lock(), but there is one exception which is ip_mc_sf_allow(),
> so there is a chance of either ip_mc_drop_socket or ip_mc_leave_group
> remove an entry while ip_mc_sf_allow is running causing a crash.
> 
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>

Have you triggered this in practice or is this due purely
to code inspection?

That new synchronize_rcu() is very expensive and will decrease
the rate at which groups can be joined and left, _especially_
on high cpu count machines.

I do not think it is therefore a suitable problem to this
race, if it does in fact exist.

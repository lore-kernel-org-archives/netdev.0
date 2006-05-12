From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] fix IP-over-ATM and ARP interaction - formatting fixed.
Date: Fri, 12 May 2006 14:54:53 -0700 (PDT)
Message-ID: <20060512.145453.18024400.davem@davemloft.net>
References: <E1FcQAK-00054Z-00@thekelleys.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:62153
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932256AbWELVzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 17:55:08 -0400
To: simon@thekelleys.org.uk
In-Reply-To: <E1FcQAK-00054Z-00@thekelleys.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Kelley <simon@thekelleys.org.uk>
Date: Sat, 06 May 2006 18:02:00 +0100

> This patch adds a new function, neigh_table_init_no_netlink() which
> does everything the neigh_table_init() does, except add the table to
> the netlink all-arp-tables chain. In addition neigh_table_init() has a
> check that all tables on the chain have a distinct address family.
> The init call in clip.c is changed to call neigh_table_init_no_netlink().
> 
> Since ATM ARP tables are rather more complicated than can currently be
> handled by the available rtattrs in the netlink protocol, no
> functionality is lost by this patch, and non-ATM ARP manipulation via
> netlink is rescued. A more complete solution would involve a rtattr for 
> ATM ARP entries and some way for the netlink code to give neigh_add 
> and friends more information than just address family with which to find 
> the correct ARP table.
> 
> Signed-off-by: Simon Kelley <simon@thekelleys.org.uk>

This is an OK solution to this problem for now.  So I will apply
this.

I made a minor change to your patch, I changed the assertion added to
neigh_table_init().  It's not so nice to BUG_ON() with critical locks
held just to get a log of who tried to do the double-registry.  It
could cause the machine to deadlock and subsequently the debugging
log we need to analyze such cases is less likely to get reported.

Longer term we should make neigh_table_init() return some kind of
error code to handle cases like this, but that's too large a change
for so close to 2.6.17-final.

Thanks again Simon.

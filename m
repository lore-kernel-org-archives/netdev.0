From: Michal Kubecek <mkubecek@suse.cz>
Subject: RTM_DELROUTE on interface going down - when to send?
Date: Tue, 17 Dec 2013 12:05:12 +0100
Message-ID: <20131217110512.GA11216@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52088 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751410Ab3LQLFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 06:05:13 -0500
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 9A368AC16
	for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 11:05:12 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

one of our customers noticed that when an interface is switched down, no
RTM_DELROUTE message is sent for IPv4 routes being deleted (but there
are RTM_NEWROUTE messages when the interface is switched up). This is
because rather than deleting the routes with fib_table_delete(), they
are flagged with RTNH_F_DEAD in fib_sync_down_dev() and then deleted in
trie_flush_list().

Before I start with the patch, I would like to ask: would it be more
appropriate to send the message when the route is marked as dead or when
it is actually deleted from the trie?

                                                          Michal Kubecek

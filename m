From: David Miller <davem@davemloft.net>
Subject: using rhashtable in inethash
Date: Mon, 25 Aug 2014 16:12:24 -0700 (PDT)
Message-ID: <20140825.161224.1108200625385309828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39047 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755133AbaHYXM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 19:12:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


During the Networking Workshop I mentioned converting the inet hash
tables over to rhashtable so that we don't allocate this insanely
large hash table at boot time which goes largely unused.

I took a quick look at this last night and the only thing we really
need is the addition of a set of rhashtable interfaces which use
NULLs lists, as the inet hashtables currently require.

Also, I noticed in the netlink changes this really expensive
synchronize_net() added to netlink_release(), is that _really_
necessary?

That's really expensive and my impression was that such a sync is only
needed during hash table resizing, not when getting rid of objects
that we in an rhashtable.

Thomas?

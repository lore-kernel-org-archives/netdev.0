From: David Miller <davem@davemloft.net>
Subject: Re: using rhashtable in inethash
Date: Mon, 25 Aug 2014 16:36:45 -0700 (PDT)
Message-ID: <20140825.163645.1024070177356241101.davem@davemloft.net>
References: <20140825.161224.1108200625385309828.davem@davemloft.net>
	<20140825233346.GF30140@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39335 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344AbaHYXgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 19:36:46 -0400
In-Reply-To: <20140825233346.GF30140@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 26 Aug 2014 00:33:46 +0100

> The reason I added added the sync is because I could not see how
> else to prevent the sock_put() in netlink_release() to release
> socket memoray, specifically the embedded rhash_head, that is
> possibly being accessed in a RCU protected reader traversing the
> bucket. Such a reader would not hold a reference to the socket.
> I may be missing something though and I'm happy to change this for
> something better.

Ok, this is going to be a tree-wide issue where we try to use
rhashtable with sockets of any type.

Perhaps we're overdue for RCU freeing of sockets, but that added
noticable latency last time I tried it.

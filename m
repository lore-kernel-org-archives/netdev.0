From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/2] rhashtable updates
Date: Wed, 25 Feb 2015 16:31:52 +0100
Message-ID: <cover.1424877322.git.daniel@iogearbox.net>
Cc: tgraf@suug.ch, pablo@netfilter.org, johunt@akamai.com,
	kaber@trash.net, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50434 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576AbbBYPcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 10:32:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As discussed, I'm sending out rhashtable fixups for -net.

I have a couple of more patches I was working on last week pending,
i.e. to get rid of ht->nelems and ht->shift atomic operations which
speed-up pure insertions/deletions, e.g. on my laptop I have 2 threads,
inserting 7M entries each, that will reduce insertion time from ~1,450 ms
to 865 ms (performance should even be better after removing the
grow/shrink indirections). I guess that however is rather something
for net-next.

Thanks,
Daniel

Daniel Borkmann (2):
  rhashtable: unconditionally grow when max_shift is not specified
  rhashtable: remove indirection for grow/shrink decision functions

 include/linux/rhashtable.h | 13 -----------
 lib/rhashtable.c           | 58 ++++++++++++++--------------------------------
 lib/test_rhashtable.c      |  3 +--
 net/netfilter/nft_hash.c   |  2 --
 net/netlink/af_netlink.c   |  2 --
 net/tipc/socket.c          |  2 --
 6 files changed, 19 insertions(+), 61 deletions(-)

-- 
1.9.3

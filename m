From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 0/5] rcu_barrier: Resubmitting the the networking bits
Date: Fri, 26 Jun 2009 22:30:56 +0200
Message-ID: <20090626202800.10520.2082.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:51753 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbZFZUax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 16:30:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is a resubmit of the network related part of a patchseries
titled "We must use rcu_barrier() on module unload".  Just to make it
easier for DaveM to pick it up.

If an unloadable module uses RCU callbacks, it need to use
rcu_barrier() so that the module may be safely unloaded.

For documentation see:

 Paul E. McKenney's Blog
 http://paulmck.livejournal.com/7314.html

 http://lwn.net/Articles/217484/

 Documentation/RCU/rcubarrier.txt

Patchset is made on top of Linus'es tree, 4075ea8c54a7506844a69f674990241e7766357b.
But I have testet is applies to net-next-2.6.

(resubmit this time hoping vger will not eat my mails due to missing double quotes)
---

Jesper Dangaard Brouer (5):
      decnet: Use rcu_barrier() on module unload.
      ipv6: Use rcu_barrier() on module unload.
      sunrpc: Use rcu_barrier() on unload.
      mac80211: Use rcu_barrier() on unload.
      bridge: Use rcu_barrier() instead of syncronize_net() on unload.


 net/bridge/br.c          |    2 +-
 net/decnet/af_decnet.c   |    2 ++
 net/ipv6/af_inet6.c      |    2 ++
 net/mac80211/mesh.c      |    2 +-
 net/sunrpc/sunrpc_syms.c |    1 +
 5 files changed, 7 insertions(+), 2 deletions(-)

-- 
Best regards,
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


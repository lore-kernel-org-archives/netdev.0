From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/5] rtcache remove respin
Date: Sun, 01 Jul 2012 05:02:43 -0700 (PDT)
Message-ID: <20120701.050243.908285695895815999.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48338 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932239Ab2GAMCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 08:02:45 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 4872A583757
	for <netdev@vger.kernel.org>; Sun,  1 Jul 2012 05:02:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's been a while and there were of course a lot of merge hassles with
the most recent set I posted, so I respun these patches tonight
because I wanted to see the effects of the recent rpfilter hacks on an
rtcache-less system.

On a SPARC T3-1:

1) Output route lookup: ~2800 cycles
2) Input route lookups: ~3000 cycles (rpfilter=0)
                        ~4300 cycles (rpfilter=1)

Another nice part is how small struct rtable is after this patch set:

struct rtable {
	struct dst_entry        dst;
	int                     rt_genid;
	unsigned int            rt_flags;
	__u16                   rt_type;
	__be32                  rt_dst;
	int                     rt_route_iif;
	int                     rt_iif;
	int                     rt_oif;
	__be32                  rt_gateway;
	u32                     rt_peer_genid;
	unsigned long           _peer;
	struct fib_info         *fi;
};

which is about 208 bytes on sparc64.

Signed-off-by: David S. Miller <davem@davemloft.net>

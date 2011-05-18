From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/4] More rt->rt_dst whittling...
Date: Wed, 18 May 2011 18:56:23 -0400 (EDT)
Message-ID: <20110518.185623.1708152032125025285.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754968Ab1ERW4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 18:56:25 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4IMuNl4017348
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 18 May 2011 15:56:24 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


After this patch series all of the real references to rt->rt_dst that
remain are having to do with inetpeer lookups.

Already, rt->rt_src has no fundamental references any longer, and with
the routing cache it can be safely removed.

The last step of detaching the final rt->rt_dst uses will need a little
bit of work, because we currently don't propagate the originating
lookup flow key into the various dst_ops such as ->cow_metrics,
->default_mtu, etc. and those do PEER lookups which need the destination
address in use.

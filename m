From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Fri, 09 May 2008 03:18:09 -0700 (PDT)
Message-ID: <20080509.031809.152974826.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49869
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750928AbYEIKSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 06:18:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The SIT bug fix is, unfortunately, remotely exploitable memory leak.
As long as the SIT module is loaded and SIT packets aren't blocked by
the firewall, it's pretty easy to construct a frame that will be
leaked every single time (IPV4 header, with protocol == SIT, and
length just convering the IPV4 header).

I'm queueing that SIT fix up to -stable in parallel as I type this.

The TIPC fix makes sure the is enough header space for all possible
output devices.

Please pull, thanks a lot!

The following changes since commit e46b66bc42b6b1430b04cc5c207ecb2b2f4553dc:
  Ben Hutchings (1):
        net: Added ASSERT_RTNL() to dev_open() and dev_close().

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Allan Stephens (1):
      tipc: Increase buffer header to support worst-case device

David S. Miller (1):
      sit: Add missing kfree_skb() on pskb_may_pull() failure.

 net/ipv6/sit.c  |    2 +-
 net/tipc/core.h |   11 +++++------
 2 files changed, 6 insertions(+), 7 deletions(-)

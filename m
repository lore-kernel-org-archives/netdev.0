From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [RFC PATCH net-next 0/9] tipc: misc updates for 3.7
Date: Thu, 16 Aug 2012 18:09:05 -0400
Message-ID: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57476 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150Ab2HPWOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 18:14:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series gets some more largely trivial things out of
the way.  Most interesting are:

1) fix lockdep splat from bearer init by pushing the setup
   off to schedule_work.

2) simplification of configuration by removal of a couple of
   tuning knobs which used to have low default values.

The remainder are largely innocuous, I think.  I did wonder
if there was an alternate/better way to handle the splat though.

I've done my own local testing of this series on today's net-next
commit 2ea214929d601 ("Merge branch 'for-davem' ... wireless-next")

I'll wait a couple of days to allow for any possible feedback and
change requests, and then send a pull request after that.

Thanks,
Paul.
---

Ying Xue (9):
  tipc: optimize the initialization of network device notifier
  tipc: fix lockdep warning during bearer initialization
  tipc: remove pointless name sanity check and tipc_alphabet array
  tipc: manually inline single use media_name_valid routine
  tipc: change tipc_net_start routine return value type
  tipc: convert tipc_nametbl_size type from variable to macro
  tipc: add __read_mostly annotations to several global variables
  tipc: eliminate configuration for maximum number of name subscriptions
  tipc: eliminate configuration for maximum number of name publications

 include/linux/tipc_config.h |  8 ++++----
 net/tipc/bearer.c           | 21 ++------------------
 net/tipc/config.c           | 48 +++++----------------------------------------
 net/tipc/core.c             | 22 +++++++--------------
 net/tipc/core.h             | 18 ++++++++---------
 net/tipc/eth_media.c        | 29 +++++++++++++++++++++++----
 net/tipc/handler.c          |  2 +-
 net/tipc/link.c             |  4 +---
 net/tipc/name_table.c       | 14 ++++++-------
 net/tipc/net.c              |  3 +--
 net/tipc/net.h              |  2 +-
 net/tipc/subscr.c           |  4 ++--
 12 files changed, 64 insertions(+), 111 deletions(-)

-- 
1.7.11.1

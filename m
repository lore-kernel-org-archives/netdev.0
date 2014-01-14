From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 0/4] Make flow cache name space aware
Date: Tue, 14 Jan 2014 09:39:43 +0800
Message-ID: <1389663588-29678-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44233 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641AbaANBjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 20:39:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch set aims to make flow cache operating in a per net style
when inserting flow cache entry or flush flow cache. The reason to
do so is not much compelling but reasonable, which is flushing flow
cache in original implementation has global effective, the collateral
damage is netns with only a few flow cache entries has gone.

So this patch make flow cache running in a per net scope. Operation
from different netns won't interfere with each other. And the flushing
operation is worthwhile for the netns which supposed to be.

v2:
  - Pick up newly created file include/net/flowcache.h missed in v1.

Fan Du (4):
  flowcache: Namespacify flowcache global parameters with xfrm
  flowcache: Make flowcache entry inserting/flushing in per-net style
  flowcache: Fixup flow cache part in xfrm policy
  flowcache: Bring net/core/flow.c under IPsec maintain scope

 MAINTAINERS              |    1 +
 include/net/flow.h       |    5 +-
 include/net/flowcache.h  |   25 +++++++++
 include/net/netns/xfrm.h |   11 ++++
 net/core/flow.c          |  127 +++++++++++++++++++++-------------------------
 net/xfrm/xfrm_policy.c   |    7 +--
 6 files changed, 101 insertions(+), 75 deletions(-)
 create mode 100644 include/net/flowcache.h

-- 
1.7.9.5

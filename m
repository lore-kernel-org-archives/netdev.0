From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv4 net-next 0/2] Make flow cache name space aware
Date: Sat, 18 Jan 2014 09:55:26 +0800
Message-ID: <1390010128-15835-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:33237 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212AbaARBzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 20:55:31 -0500
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
v3:
  - I made a mistake by spreading one unified patch into different
    patches, which break bisect operation. So forge into one piece
    patches advised by Cong and Sabrina.
v4:
  - Fix selinux xfrm compiling issue.

Fan Du (2):
  flowcache: Make flow cache name space aware
  flowcache: Bring net/core/flow.c under IPsec maintain scope

 MAINTAINERS                     |    1 +
 include/net/flow.h              |    5 +-
 include/net/flowcache.h         |   25 ++++++++
 include/net/netns/xfrm.h        |   11 ++++
 net/core/flow.c                 |  127 ++++++++++++++++++---------------------
 net/xfrm/xfrm_policy.c          |    7 ++-
 security/selinux/include/xfrm.h |    5 +-
 7 files changed, 104 insertions(+), 77 deletions(-)
 create mode 100644 include/net/flowcache.h

-- 
1.7.9.5

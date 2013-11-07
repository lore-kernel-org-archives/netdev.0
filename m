From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 0/3] Small IPsec fix
Date: Thu, 7 Nov 2013 17:47:47 +0800
Message-ID: <1383817670-5783-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <herbert@gondor.hengli.com.au>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:57470 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753763Ab3KGJrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 04:47:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This patchset made below modifications:
 - Fix setting policy index with "ip xfrm ... index=xx"
   which is currently broken

 - Using correct name space for home agent when migrating
   key info.

 - Put xfrm locks into per namespace to improve scalability.

Changelog:
v2:
  xfrm: Namespacify xfrm state/policy locks
  -Fix compile error when CONFIG_NET_NS is unset, thanks for the lovely build robot.

Fan Du (3):
  xfrm: Try to honor policy index if it's supplied by user
  xfrm: Using the right namespace to migrate key info
  xfrm: Namespacify xfrm state/policy locks

 include/net/netns/xfrm.h |    4 ++
 include/net/xfrm.h       |   13 +++--
 net/key/af_key.c         |   18 ++++---
 net/xfrm/xfrm_policy.c   |  130 +++++++++++++++++++++++++---------------------
 net/xfrm/xfrm_state.c    |  104 +++++++++++++++++++------------------
 net/xfrm/xfrm_user.c     |   27 +++++++---
 6 files changed, 168 insertions(+), 128 deletions(-)

-- 
1.7.9.5

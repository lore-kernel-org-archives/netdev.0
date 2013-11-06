From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next 0/3] Small IPsec fix
Date: Wed, 6 Nov 2013 18:14:13 +0800
Message-ID: <1383732856-18323-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:53431 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756087Ab3KFKOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 05:14:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This patchset made below modifications:
 - Fix setting policy index with "ip xfrm ... index=xx"
   which is currently broken

 - Using correct name space for home agent when migrating
   key info.

 - Put xfrm locks into per namespace to improve scalability.


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

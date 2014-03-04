From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH 0/2] af_key: fixes for sleeping while atomic
Date: Tue,  4 Mar 2014 13:26:22 +0100
Message-ID: <1393935984-8733-1-git-send-email-nikolay@redhat.com>
References: <20140227151954.GA30946@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Paul Moore <paul@paul-moore.com>,
	Dave Jones <davej@redhat.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Fan Du <fan.du@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61914 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756971AbaCDMbI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2014 07:31:08 -0500
In-Reply-To: <20140227151954.GA30946@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
The first patch takes care of the issue on the af_key side, and the second
one fixes it on the selinux side (security_xfrm_policy_alloc).
There're a few lines >80 but they were already long, I'm not sure if breaking
them above the limit would make them more readable than they already are.

Best regards,
 Nikolay Aleksandrov

CC: Paul Moore <paul@paul-moore.com>
CC: Dave Jones <davej@redhat.com>
CC: Steffen Klassert <steffen.klassert@secunet.com>
CC: Fan Du <fan.du@windriver.com>
CC: David S. Miller <davem@davemloft.net>

Nikolay Aleksandrov (2):
  net: af_key: fix sleeping under rcu
  selinux: add gfp argument to security_xfrm_policy_alloc and fix
    callers

 include/linux/security.h        | 10 +++++++---
 net/key/af_key.c                | 19 ++++++++++---------
 net/xfrm/xfrm_user.c            |  6 +++---
 security/capability.c           |  3 ++-
 security/security.c             |  6 ++++--
 security/selinux/include/xfrm.h |  3 ++-
 security/selinux/xfrm.c         | 12 +++++++-----
 7 files changed, 35 insertions(+), 24 deletions(-)

-- 
1.8.5.3

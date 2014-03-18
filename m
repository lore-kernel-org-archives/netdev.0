From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2014-03-18
Date: Tue, 18 Mar 2014 08:43:01 +0100
Message-ID: <1395128583-26274-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54072 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751279AbaCRHnP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:43:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix a sleep in atomic when pfkey_sadb2xfrm_user_sec_ctx()
   is called from pfkey_compile_policy().
   Fix from Nikolay Aleksandrov.

2) security_xfrm_policy_alloc() can be called in process and atomic
   context. Add an argument to let the callers choose the appropriate
   way. Fix from Nikolay Aleksandrov.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit a8d9bc2e9f5d1c5a25e33cec096d2a1652d3fd52:

  bnx2: Fix shutdown sequence (2014-03-09 19:02:27 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 52a4c6404f91f2d2c5592ee6365a8418c4565f53:

  selinux: add gfp argument to security_xfrm_policy_alloc and fix callers (2014-03-10 08:30:02 +0100)

----------------------------------------------------------------
Nikolay Aleksandrov (2):
      net: af_key: fix sleeping under rcu
      selinux: add gfp argument to security_xfrm_policy_alloc and fix callers

 include/linux/security.h            |   10 +++++++---
 net/key/af_key.c                    |   19 ++++++++++---------
 net/xfrm/xfrm_user.c                |    6 +++---
 security/capability.c               |    3 ++-
 security/security.c                 |    6 ++++--
 security/selinux/hooks.c            |   13 +++++++------
 security/selinux/include/security.h |    2 +-
 security/selinux/include/xfrm.h     |    3 ++-
 security/selinux/selinuxfs.c        |   28 ++++++++++++++++++----------
 security/selinux/ss/services.c      |    6 ++++--
 security/selinux/xfrm.c             |   14 ++++++++------
 11 files changed, 66 insertions(+), 44 deletions(-)

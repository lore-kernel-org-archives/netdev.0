From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2014-02-27
Date: Thu, 27 Feb 2014 07:16:34 +0100
Message-ID: <1393481799-20492-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57438 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198AbaB0GQv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 01:16:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Build fix for ip_vti when NET_IP_TUNNEL is not set.
   We need this set to have ip_tunnel_get_stats64()
   available.

2) Fix a NULL pointer dereference on sub policy usage.
   We try to access a xfrm_state from the wrong array.

3) Take xfrm_state_lock in xfrm_migrate_state_find(),
   we need it to traverse through the state lists.

4) Clone states properly on migration, otherwise we crash
   when we migrate a state with aead algorithm attached.

5) Fix unlink race when between thread context and timer
   when policies are deleted.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 960dfc4eb23a28495276b02604d7458e0e1a1ed8:

  Merge branch 'drm-fixes' of git://people.freedesktop.org/~airlied/linux (2014-02-18 16:36:07 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 3a9016f97fdc8bfbb26ff36ba8f3dc9162eb691b:

  xfrm: Fix unlink race when policies are deleted. (2014-02-26 09:52:02 +0100)

----------------------------------------------------------------
Steffen Klassert (5):
      ip6_vti: Fix build when NET_IP_TUNNEL is not set.
      xfrm: Fix NULL pointer dereference on sub policy usage
      xfrm: Take xfrm_state_lock in xfrm_migrate_state_find
      xfrm: Clone states properly on migration
      xfrm: Fix unlink race when policies are deleted.

 include/net/xfrm.h     |   11 +++++++++++
 net/ipv6/Kconfig       |    1 +
 net/xfrm/xfrm_policy.c |    2 +-
 net/xfrm/xfrm_state.c  |   23 +++++++++++++++++------
 net/xfrm/xfrm_user.c   |    5 -----
 5 files changed, 30 insertions(+), 12 deletions(-)

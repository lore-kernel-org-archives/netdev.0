From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2015-05-28
Date: Thu, 28 May 2015 08:25:47 +0200
Message-ID: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49924 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836AbbE1G0L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 02:26:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Remove xfrm_queue_purge as this is the same as skb_queue_purge.

2) Optimize policy and state walk.

3) Use a sane return code if afinfo registration fails.

4) Only check fori a acquire state if the state is not valid.

5) Remove a unnecessary NULL check before xfrm_pol_hold
   as it checks the input for NULL.

6) Return directly if the xfrm hold queue is empty, avoid
   to take a lock as it is nothing to do in this case.

7) Optimize the inexact policy search and allow for matching
   of policies with priority ~0U.

All from Li RongQing.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 04b7fe6a4a231871ef681bc95e08fe66992f7b1f:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide (2015-04-17 16:36:59 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 8faf491e642011f449d6405be52bedb70964aed6:

  xfrm: optimise to search the inexact policy list (2015-05-18 10:31:56 +0200)

----------------------------------------------------------------
Li RongQing (7):
      xfrm: remove the xfrm_queue_purge definition
      xfrm: optimise the use of walk list header in xfrm_policy/state_walk
      xfrm: fix the return code when xfrm_*_register_afinfo failed
      xfrm: slightly optimise xfrm_input
      xfrm: remove the unnecessary checking before call xfrm_pol_hold
      xfrm: move the checking for old xfrm_policy hold_queue to beginning
      xfrm: optimise to search the inexact policy list

 net/xfrm/xfrm_input.c  | 12 ++++++------
 net/xfrm/xfrm_policy.c | 42 ++++++++++++++++++++----------------------
 net/xfrm/xfrm_state.c  |  4 ++--
 3 files changed, 28 insertions(+), 30 deletions(-)

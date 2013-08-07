From: Fan Du <fan.du@windriver.com>
Subject: [RFC PATCHv2 0/3] xfrm: Refactor xfrm_state timer management
Date: Wed, 7 Aug 2013 17:04:53 +0800
Message-ID: <1375866296-15079-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45211 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757266Ab3HGJDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 05:03:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first version of "refactor xfrm_state timer management" has been
flushed into toilet since nobody but only me like it.

Anyway new approach here is updating SAs lifetime timeout whenever
clock_was_set is called, iow, system clock changed or host resume from
suspend state. Rule is simple, force soft expire for any SAs which has
not reach their soft expire limit and hard expire for those has experienced
soft expire timeout but wait for hard expire timeout to come.(If I undestand
Dave advice clearly)

Locking issue:
 - holding rtnl_lock when iterate on all net namespace.
 - holding xfrm_state_lock when iterate all xfrm_state in this net.
 - holding state->lock when changing xfrm_state.

I'm not aware of any other locks other than above ones, so if I'm missing
something obviously, please tell me.

Thanks!

Fan Du (3):
  hrtimer: Add notifer for clock_was_set
  xfrm: Update xfrm_state lifetime expire after clock_was_set
  xfrm: Revert "Fix unexpected SA hard expiration after changing date"

 include/net/xfrm.h    |    4 ----
 kernel/hrtimer.c      |    4 ++++
 net/xfrm/xfrm_state.c |   61 +++++++++++++++++++++++++++++++++++--------------
 3 files changed, 48 insertions(+), 21 deletions(-)

-- 
1.7.9.5

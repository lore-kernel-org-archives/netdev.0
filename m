From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2015-05-28
Date: Thu, 28 May 2015 09:28:03 +0200
Message-ID: <1432798090-20657-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51223 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772AbbE1H23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 03:28:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix a race in xfrm_state_lookup_byspi, we need to take
   the refcount before we release xfrm_state_lock.
   From Li RongQing.

2) Fix IV generation on ESN state. We used just the
   low order sequence numbers for IV generation on
   ESN, as a result the IV can repeat on the same
   state. Fix this by using the  high order sequence
   number bits too and make sure to always initialize
   the high order bits with zero. These patches are
   serious stable candidates. Fixes from Herbert Xu.

3) Fix the skb->mark handling on vti. We don't
   reset skb->mark in skb_scrub_packet anymore,
   so vti must care to restore the original
   value back after it was used to lookup the
   vti policy and state. Fixes from Alexander Duyck.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 39376ccb1968ba9f83e2a880a8bf02ad5dea44e1:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf (2015-04-27 23:12:34 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to d55c670cbc54b2270a465cdc382ce71adae45785:

  ip_vti/ip6_vti: Preserve skb->mark after rcv_cb call (2015-05-28 06:23:32 +0200)

----------------------------------------------------------------
Alexander Duyck (3):
      ip_vti/ip6_vti: Do not touch skb->mark on xmit
      xfrm: Override skb->mark with tunnel->parm.i_key in xfrm_input
      ip_vti/ip6_vti: Preserve skb->mark after rcv_cb call

Herbert Xu (3):
      esp4: Use high-order sequence number bits for IV generation
      esp6: Use high-order sequence number bits for IV generation
      xfrm: Always zero high-order sequence number bits

Li RongQing (1):
      xfrm: fix a race in xfrm_state_lookup_byspi

 net/ipv4/esp4.c        |  3 ++-
 net/ipv4/ip_vti.c      | 14 ++++++++++----
 net/ipv6/esp6.c        |  3 ++-
 net/ipv6/ip6_vti.c     | 13 ++++++++++---
 net/xfrm/xfrm_input.c  | 17 ++++++++++++++++-
 net/xfrm/xfrm_replay.c |  2 ++
 net/xfrm/xfrm_state.c  |  2 +-
 7 files changed, 43 insertions(+), 11 deletions(-)

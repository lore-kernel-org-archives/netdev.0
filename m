From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2014-02-24
Date: Mon, 24 Feb 2014 10:59:48 +0100
Message-ID: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39095 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751716AbaBXKAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 05:00:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Introduce skb_to_sgvec_nomark function to add further data to the sg list
   without calling sg_unmark_end first. Needed to add extended sequence
   number informations. From Fan Du.

2) Add IPsec extended sequence numbers support to the Authentication Header
   protocol for ipv4 and ipv6. From Fan Du.

3) Make the IPsec flowcache namespace aware, from Fan Du.

4) Avoid creating temporary SA for every packet when no key manager is
   registered. From Horia Geanta.

5) Support filtering of SA dumps to show only the SAs that match a
   given filter. From Nicolas Dichtel.

6) Remove caching of xfrm_policy_sk_bundles. The cached socket policy bundles
   are never used, instead we create a new cache entry whenever xfrm_lookup()
   is called on a socket policy. Most protocols cache the used routes to the
   socket, so this caching is not needed.

7)  Fix a forgotten SADB_X_EXT_FILTER length check in pfkey, from Nicolas
    Dichtel.

8) Cleanup error handling of xfrm_state_clone.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 738b52bb9845da183b6ff46a8f685b56a63379d1:

  Merge tag 'microblaze-3.14-rc3' of git://git.monstr.eu/linux-2.6-microblaze (2014-02-11 12:24:35 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to cc9ab60e57964d463ff31b9621c8d7e786aee042:

  xfrm: Cleanup error handling of xfrm_state_clone (2014-02-21 07:53:28 +0100)

----------------------------------------------------------------
Fan Du (8):
      skbuff: Introduce skb_to_sgvec_nomark to map skb without mark new end
      {IPv4,xfrm} Add ESN support for AH egress part
      {IPv4,xfrm} Add ESN support for AH ingress part
      {IPv6,xfrm} Add ESN support for AH egress part
      {IPv6,xfrm} Add ESN support for AH ingress part
      xfrm: Don't prohibit AH from using ESN feature
      flowcache: Make flow cache name space aware
      flowcache: Bring net/core/flow.c under IPsec maintain scope

Horia Geanta (1):
      xfrm: avoid creating temporary SA when there are no listeners

Nicolas Dichtel (2):
      ipsec: add support of limited SA dump
      pfkey: fix SADB_X_EXT_FILTER length check

Steffen Klassert (2):
      xfrm: Remove caching of xfrm_policy_sk_bundles
      xfrm: Cleanup error handling of xfrm_state_clone

 MAINTAINERS                     |    1 +
 include/linux/skbuff.h          |    2 +
 include/net/flow.h              |    5 +-
 include/net/flowcache.h         |   25 ++++++++
 include/net/netns/xfrm.h        |   12 +++-
 include/net/xfrm.h              |   25 ++++++--
 include/uapi/linux/pfkeyv2.h    |   15 ++++-
 include/uapi/linux/xfrm.h       |   10 +++
 net/core/flow.c                 |  127 ++++++++++++++++++---------------------
 net/core/skbuff.c               |   26 ++++++++
 net/ipv4/ah4.c                  |   53 ++++++++++++----
 net/ipv6/ah6.c                  |   56 +++++++++++++----
 net/key/af_key.c                |   39 +++++++++++-
 net/xfrm/xfrm_policy.c          |   35 ++---------
 net/xfrm/xfrm_state.c           |   72 ++++++++++++++++++----
 net/xfrm/xfrm_user.c            |   37 +++++++++++-
 security/selinux/include/xfrm.h |    5 +-
 17 files changed, 396 insertions(+), 149 deletions(-)
 create mode 100644 include/net/flowcache.h

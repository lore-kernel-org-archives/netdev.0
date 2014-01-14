From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2014-01-14
Date: Tue, 14 Jan 2014 07:49:04 +0100
Message-ID: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60050 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750777AbaANGtd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 01:49:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pull request has a merge conflict between commits be7928d20bab
("net: xfrm: xfrm_policy: fix inline not at beginning of declaration") and
da7c224b1baa ("net: xfrm: xfrm_policy: silence compiler warning") from
the net-next tree and commit 2f3ea9a95c58 ("xfrm: checkpatch erros with
inline keyword position") from the ipsec-next tree.

The version from net-next can be used, like it is done in linux-next.

1) Checkpatch cleanups, from Weilong Chen.

2) Fix lockdep complaints when pktgen is used with IPsec,
   from Fan Du.

3) Update pktgen to allow any combination of IPsec transport/tunnel mode
   and AH/ESP/IPcomp type, from Fan Du.

4) Make pktgen_dst_metrics static, Fengguang Wu.

5) Compile fix for pktgen when CONFIG_XFRM is not set,
   from Fan Du.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 852ad5e631967ae2203cb08c5b6b42c26011ed63:

  Merge branch 'bridge_cleanups' (2013-12-19 19:27:34 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 6bae919003602729d6f5920315bf71ca78bd9e48:

  {xfrm,pktgen} Fix compiling error when CONFIG_XFRM is not set (2014-01-10 07:46:24 +0100)

----------------------------------------------------------------
Fan Du (9):
      {pktgen, xfrm} Correct xfrm state lock usage when transforming
      {pktgen, xfrm} Add statistics counting when transforming
      {pktgen, xfrm} Correct xfrm_state_lock usage in xfrm_stateonly_find
      {pktgen, xfrm} Using "pgset spi xxx" to spedifiy SA for a given flow
      {pktgen, xfrm} Construct skb dst for tunnel mode transformation
      {pktgen, xfrm} Introduce xfrm_state_lookup_byspi for pktgen
      {pktgen, xfrm} Show spi value properly when ipsec turned on
      {pktgen, xfrm} Document IPsec usage in pktgen.txt
      {xfrm,pktgen} Fix compiling error when CONFIG_XFRM is not set

Fengguang Wu (1):
      pktgen_dst_metrics[] can be static

Weilong Chen (5):
      xfrm: checkpatch errors with space
      xfrm: checkpatch errors with foo * bar
      xfrm: checkpatch erros with space prohibited
      xfrm: fix checkpatch error
      xfrm: checkpatch erros with inline keyword position

 Documentation/networking/pktgen.txt |   15 +++++++
 include/net/xfrm.h                  |    2 +
 net/core/pktgen.c                   |   80 +++++++++++++++++++++++++++++------
 net/xfrm/xfrm_input.c               |    6 +--
 net/xfrm/xfrm_policy.c              |   38 ++++++++---------
 net/xfrm/xfrm_proc.c                |    2 +-
 net/xfrm/xfrm_state.c               |   44 ++++++++++++++-----
 net/xfrm/xfrm_user.c                |    6 +--
 8 files changed, 142 insertions(+), 51 deletions(-)

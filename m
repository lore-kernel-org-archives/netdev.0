From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2013-01-23
Date: Wed, 23 Jan 2013 09:18:56 +0100
Message-ID: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50701 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751315Ab3AWITU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 03:19:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Add a statistic counter for invalid output states and
   remove a superfluous state valid check, from Li RongQing.

2) Probe for asynchronous block ciphers instead of synchronous block
   ciphers to make the asynchronous variants available even if no
   synchronous block ciphers are found, from Jussi Kivilinna.

3) Make rfc3686 asynchronous block cipher and make use of
   the new asynchronous variant, from Jussi Kivilinna.

4) Replace some rwlocks by rcu, from Cong Wang.

5) Remove some unused defines.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 483f777266f5da205459c290994bd3cda5f1f6bc:

  drivers/net: remove orphaned references to micro channel (2013-01-06 21:13:33 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git testing

for you to fetch changes up to 02bfd8ecf5cf980ede53e30a903b102924fc32f4:

  xfrm: Remove unused defines (2013-01-21 11:19:04 +0100)

----------------------------------------------------------------
Cong Wang (3):
      xfrm: replace rwlock on xfrm_state_afinfo with rcu
      xfrm: replace rwlock on xfrm_km_list with rcu
      xfrm: use separated locks to protect pointers of struct xfrm_state_afinfo

Jussi Kivilinna (3):
      xfrm_algo: probe asynchronous block ciphers instead of synchronous
      crypto: ctr - make rfc3686 asynchronous block cipher
      crypto: aesni-intel - remove rfc3686(ctr(aes)), utilize rfc3686 from ctr-module instead

Li RongQing (1):
      xfrm: removes a superfluous check and add a statistic

Steffen Klassert (1):
      xfrm: Remove unused defines

 arch/x86/crypto/aesni-intel_glue.c |   37 --------
 crypto/ctr.c                       |  173 +++++++++++++++++++++++-------------
 crypto/tcrypt.c                    |    4 +
 crypto/tcrypt.h                    |    1 +
 include/net/xfrm.h                 |    4 -
 include/uapi/linux/snmp.h          |    1 +
 net/xfrm/xfrm_algo.c               |    3 +-
 net/xfrm/xfrm_output.c             |    6 ++
 net/xfrm/xfrm_proc.c               |    1 +
 net/xfrm/xfrm_state.c              |  131 +++++++++++++--------------
 10 files changed, 185 insertions(+), 176 deletions(-)

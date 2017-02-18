From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 18 Feb 2017 00:15:39 -0500 (EST)
Message-ID: <20170218.001539.2105604714350392158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54894 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750759AbdBRFQY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 00:16:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix leak in dpaa_eth error paths, from Dan Carpenter.

2) Use after free when using IPV6_RECVPKTINFO, from Andrey Konovalov.

3) fanout_release() cannot be invoked from atomic contexts, from
   Anoob Soman.

4) Fix bogus attempt at lockdep annotation in IRDA.

5) dev_fill_metadata_dst() can OOP on a NULL dst cache pointer, from
   Paolo Abeni.

Please pull, thanks a lot!

The following changes since commit 4695daefba8df8a11fa0b0edd595eedae9ea59ae:

  Merge tag 'media/v4.10-5' of git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/linux-media (2017-02-16 10:22:41 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 4c03b862b12f980456f9de92db6d508a4999b788:

  irda: Fix lockdep annotations in hashbin_delete(). (2017-02-17 16:19:39 -0500)

----------------------------------------------------------------
Andrey Konovalov (1):
      dccp: fix freeing skb too early for IPV6_RECVPKTINFO

Anoob Soman (1):
      packet: Do not call fanout_release from atomic contexts

Dan Carpenter (1):
      dpaa_eth: small leak on error

David S. Miller (1):
      irda: Fix lockdep annotations in hashbin_delete().

Paolo Abeni (1):
      vxlan: fix oops in dev_fill_metadata_dst

 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c |  2 +-
 drivers/net/vxlan.c                            |  6 ++++--
 net/dccp/input.c                               |  3 ++-
 net/irda/irqueue.c                             | 34 ++++++++++++++++------------------
 net/packet/af_packet.c                         | 31 ++++++++++++++++++++++---------
 5 files changed, 45 insertions(+), 31 deletions(-)

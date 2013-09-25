From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 0/2] bonding: modify the current and add new hash functions
Date: Wed, 25 Sep 2013 17:19:56 +0200
Message-ID: <1380122398-7370-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41890 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755819Ab3IYPXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 11:23:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
This is a complete remake of my old patch that modified the bonding hash
functions to use skb_flow_dissect which was suggested by Eric Dumazet.
This time around I've left the old modes although using a new hash function
again suggested by Eric, which is the same for all modes. The only
difference is the way the headers are obtained. The old modes obtain them
as before in order to address concerns about speed, but the 2 new ones use
skb_flow_dissect. The unification of the hash function allows to remove a
pointer from struct bonding and also a few extra functions that dealt with
it. Two new functions are added which take care of the hashing based on
bond->params.xmit_policy only:
bond_xmit_hash() - global function, used by XOR and 3ad modes
bond_flow_dissect() - used by bond_xmit_hash() to obtain the necessary
headers and combine them according to bond->params.xmit_policy.


Best regards,
 Nikolay Aleksandrov

Nikolay Aleksandrov (2):
  bonding: modify the old and add new xmit hash functions
  bonding: document the new xmit policy modes and update the changed
    ones

 Documentation/networking/bonding.txt |  66 ++++++-----
 drivers/net/bonding/bond_3ad.c       |   2 +-
 drivers/net/bonding/bond_main.c      | 211 ++++++++++++++---------------------
 drivers/net/bonding/bond_sysfs.c     |   2 -
 drivers/net/bonding/bonding.h        |   3 +-
 include/uapi/linux/if_bonding.h      |   2 +
 6 files changed, 122 insertions(+), 164 deletions(-)

-- 
1.8.1.4

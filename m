From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 0/3] remove nl_sk_hash_lock from netlink socket
Date: Mon, 12 Jan 2015 14:52:21 +0800
Message-ID: <1421045544-13670-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:64309 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbbALGw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 01:52:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After tipc socket successfully avoids the involvement of an extra lock
with rhashtable_lookup_insert(), it's possible for netlink socket to
remove its hash socket lock now. But as netlink socket needs a compare
function to look for an object, we first introduce a new function
called rhashtable_lookup_compare_insert() in commit #1 which is
implemented based on original rhashtable_lookup_insert(). We
subsequently remove nl_sk_hash_lock from netlink socket with the new
introduced function in commit #2. Lastly, as Thomas requested, we add
commit #3 to indicate the implementation of what the grow and shrink
decision function must enforce min/max shift.

v2:
 As Thomas pointed out, there was a race between checking portid and
 then setting it in commit #2. Now use socket lock to make the process
 of both checking and setting portid atomic, and then eliminate the
 race.

Ying Xue (3):
  rhashtable: involve rhashtable_lookup_compare_insert routine
  netlink: eliminate nl_sk_hash_lock
  rhashtable: add a note for grow and shrink decision functions

 include/linux/rhashtable.h |    9 +++++++++
 lib/rhashtable.c           |   42 ++++++++++++++++++++++++++++++++++++++++--
 net/netlink/af_netlink.c   |   33 ++++++++++++++++++++-------------
 net/netlink/af_netlink.h   |    1 -
 net/netlink/diag.c         |   10 +++++-----
 5 files changed, 74 insertions(+), 21 deletions(-)

-- 
1.7.9.5

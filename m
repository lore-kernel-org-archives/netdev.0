From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 1/2] [IPV4] fib_hash: fix duplicated route issue
Date: Wed, 16 Jan 2008 20:13:25 +0900
Message-ID: <12004820052610-git-send-email-joonwpark81@gmail.com>
Cc: Joonwoo Park <joonwpark81@gmail.com>,
	linux-netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Alexander Zubkov <green@msu.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:35361 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbYAPLNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 06:13:32 -0500
Received: by rv-out-0910.google.com with SMTP id k20so187700rvb.1
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 03:13:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

http://bugzilla.kernel.org/show_bug.cgi?id=9493

The fib allows making identical routes with 'ip route replace'.
This patch makes the fib return -EEXIST if replacement would cause duplication.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 net/ipv4/fib_hash.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 527a6e0..99071d7 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -444,6 +444,9 @@ static int fn_hash_insert(struct fib_table *tb, struct fib_config *cfg)
 			struct fib_info *fi_drop;
 			u8 state;
 
+			if (fi->fib_treeref > 1)
+				goto out;
+
 			write_lock_bh(&fib_hash_lock);
 			fi_drop = fa->fa_info;
 			fa->fa_info = fi;
-- 
1.5.3.rc5


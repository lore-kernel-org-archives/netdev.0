From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 1/7] af_ieee802154: setsockopt optlen arg isn't __user
Date: Wed, 16 Sep 2009 02:12:59 +0400
Message-ID: <1253052785-26190-2-git-send-email-dbaryshkov@gmail.com>
References: <1253052785-26190-1-git-send-email-dbaryshkov@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net,
	Sergey Lapin <slapin@ossfans.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:42420 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917AbZIOWNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 18:13:54 -0400
Received: by ewy2 with SMTP id 2so922680ewy.17
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 15:13:57 -0700 (PDT)
In-Reply-To: <1253052785-26190-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove __user annotation from optlen arg as it's bogus.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/dgram.c |    2 +-
 net/ieee802154/raw.c   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 77ae685..51593a4 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -414,7 +414,7 @@ static int dgram_getsockopt(struct sock *sk, int level, int optname,
 }
 
 static int dgram_setsockopt(struct sock *sk, int level, int optname,
-		    char __user *optval, int __user optlen)
+		    char __user *optval, int optlen)
 {
 	struct dgram_sock *ro = dgram_sk(sk);
 	int val;
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index 4681501..1319885 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -244,7 +244,7 @@ static int raw_getsockopt(struct sock *sk, int level, int optname,
 }
 
 static int raw_setsockopt(struct sock *sk, int level, int optname,
-		    char __user *optval, int __user optlen)
+		    char __user *optval, int optlen)
 {
 	return -EOPNOTSUPP;
 }
-- 
1.6.3.3


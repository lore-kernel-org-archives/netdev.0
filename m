From: akpm@linux-foundation.org
Subject: [patch 2/2] net/bridge/netfilter: move a dereference below a NULL test
Date: Fri, 09 Jan 2009 12:22:22 -0800
Message-ID: <200901092022.n09KMNE5019522@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, julia@diku.dk
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55162 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752430AbZAIUW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 15:22:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

In each case, if the NULL test is necessary, then the dereference should be
moved below the NULL test.

The semantic patch that makes this change is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
type T;
expression E;
identifier i,fld;
statement S;
@@

- T i = E->fld;
+ T i;
  ... when != E
      when != i
  if (E == NULL) S
+ i = E->fld;
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/bridge/netfilter/ebtables.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN net/bridge/netfilter/ebtables.c~net-bridge-netfilter-move-a-dereference-below-a-null-test net/bridge/netfilter/ebtables.c
--- a/net/bridge/netfilter/ebtables.c~net-bridge-netfilter-move-a-dereference-below-a-null-test
+++ a/net/bridge/netfilter/ebtables.c
@@ -85,12 +85,13 @@ static inline int ebt_do_match (struct e
 static inline int ebt_dev_check(char *entry, const struct net_device *device)
 {
 	int i = 0;
-	const char *devname = device->name;
+	const char *devname;
 
 	if (*entry == '\0')
 		return 0;
 	if (!device)
 		return 1;
+	devname = device->name;
 	/* 1 is the wildcard token */
 	while (entry[i] != '\0' && entry[i] != 1 && entry[i] == devname[i])
 		i++;
_

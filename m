From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/6 v2 net-next] rhashtable fixes
Date: Thu,  5 Feb 2015 02:03:30 +0100
Message-ID: <cover.1423097592.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	ying.xue@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:41000 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756151AbbBEBDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:03:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes all remaining known issues with rhashtable that
have been reported. In particular the race condition reported by
Ying Xue.

---
Dave/Herbert: I'm posting this now as it fixes real issues. I'm
fine with taking Herbert's rehash patches instead if they resolve
all the reported issues as well.

v2:
 - Rebased on top of Herbert Xu's iterator code
 - Fixed last remaining race that remained. Special thanks
   to Daniel Borkmann for assistance while debugging.

Thomas Graf (6):
  rhashtable: key_hashfn() must return full hash value
  rhashtable: Use a single bucket lock for sibling buckets
  rhashtable: Wait for RCU readers after final unzip work
  rhashtable: Dump bucket tables on locking violation under
    PROVE_LOCKING
  rhashtable: Add more lock verification
  rhashtable: Avoid bucket cross reference after removal

 lib/rhashtable.c | 305 ++++++++++++++++++++++++++++++-------------------------
 1 file changed, 167 insertions(+), 138 deletions(-)

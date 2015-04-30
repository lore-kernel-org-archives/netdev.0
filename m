From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 0/2] rhashtable: Quick initial table growth
Date: Thu, 30 Apr 2015 22:46:43 +0000
Message-ID: <1430434005-6143-1-git-send-email-tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35585 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbbD3WrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 18:47:03 -0400
Received: by pdbqd1 with SMTP id qd1so74461367pdb.2
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 15:47:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Besides a trivial cleanup. This proposes to introduce a quicker growth
algorithm for very small table sizes to avoid a large number of resize
cycles to go through. I experienced up to 15 chained resizes when
growing from small table sizes. A typical use case where this matters
is the nft set restore if no hint for the table size is given.

Thomas Graf (2):
  rhashtable: Simplify iterator code
  rhashtable: Quick initial growth of tables

 lib/rhashtable.c | 45 +++++++++++++++++++++++++++++++++++++--------
 1 file changed, 37 insertions(+), 8 deletions(-)

-- 
1.9.3

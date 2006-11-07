From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] don't use highmem in tcp hash size calculation
Date: Mon, 06 Nov 2006 20:06:45 -0500
Message-ID: <454FDC25.6090801@psc.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060209020305050509010508"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:33258 "EHLO mailer2.psc.edu")
	by vger.kernel.org with ESMTP id S1753863AbWKGBGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 20:06:47 -0500
Received: from [128.182.160.132] (ice.psc.edu [128.182.160.132])
	by mailer2.psc.edu (8.13.8/8.13.3) with ESMTP id kA716kaB019901
	for <netdev@vger.kernel.org>; Mon, 6 Nov 2006 20:06:46 -0500 (EST)
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060209020305050509010508
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------060209020305050509010508
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="tcp_no_highmem.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcp_no_highmem.patch"

This patch removes consideration of high memory when determining TCP hash
table sizes.  Taking into account high memory results in tcp_mem values that
are too large.

Signed-off-by: John Heffner <jheffner@psc.edu>

---
commit ea55b7c31b47edf90132baea9a088da3bbe2bb5c
tree 82311e12d4e4e006fba1688cb537de06cf7a4e4b
parent 4f6f9ba021f8a2149238f7c081cd7cf55c70c775
author John Heffner <jheffner@psc.edu> Mon, 06 Nov 2006 20:03:01 -0500
committer John Heffner <jheffner@psc.edu> Mon, 06 Nov 2006 20:03:01 -0500

 net/ipv4/tcp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 66e9a72..4322318 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2270,7 +2270,7 @@ void __init tcp_init(void)
 					thash_entries,
 					(num_physpages >= 128 * 1024) ?
 					13 : 15,
-					HASH_HIGHMEM,
+					0,
 					&tcp_hashinfo.ehash_size,
 					NULL,
 					0);
@@ -2286,7 +2286,7 @@ void __init tcp_init(void)
 					tcp_hashinfo.ehash_size,
 					(num_physpages >= 128 * 1024) ?
 					13 : 15,
-					HASH_HIGHMEM,
+					0,
 					&tcp_hashinfo.bhash_size,
 					NULL,
 					64 * 1024);

--------------060209020305050509010508--

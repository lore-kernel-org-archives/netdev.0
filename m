From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net 2/2] samples: bpf: relax test_maps check
Date: Thu, 22 Jan 2015 17:11:09 -0800
Message-ID: <1421975469-13035-3-git-send-email-ast@plumgrid.com>
References: <1421975469-13035-1-git-send-email-ast@plumgrid.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:39537 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754980AbbAWBLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 20:11:21 -0500
Received: by mail-pd0-f181.google.com with SMTP id g10so2515988pdj.12
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 17:11:20 -0800 (PST)
In-Reply-To: <1421975469-13035-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hash map is unordered, so get_next_key() iterator shouldn't
rely on particular order of elements. So relax this test.

Fixes: ffb65f27a155 ("bpf: add a testsuite for eBPF maps")
Reported-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/test_maps.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/samples/bpf/test_maps.c b/samples/bpf/test_maps.c
index e286b42..6299ee9 100644
--- a/samples/bpf/test_maps.c
+++ b/samples/bpf/test_maps.c
@@ -69,9 +69,9 @@ static void test_hashmap_sanity(int i, void *data)
 
 	/* iterate over two elements */
 	assert(bpf_get_next_key(map_fd, &key, &next_key) == 0 &&
-	       next_key == 2);
+	       (next_key == 1 || next_key == 2));
 	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == 0 &&
-	       next_key == 1);
+	       (next_key == 1 || next_key == 2));
 	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == -1 &&
 	       errno == ENOENT);
 
-- 
1.7.9.5

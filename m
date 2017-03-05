From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net] bpf: add get_next_key callback to LPM map
Date: Sun, 5 Mar 2017 09:41:08 -0800
Message-ID: <1488735668-2296008-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        Dmitry Vyukov <dvyukov@google.com>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:35871 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750864AbdCERlN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 12:41:13 -0500
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v25HXj9p002782
        for <netdev@vger.kernel.org>; Sun, 5 Mar 2017 09:41:11 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28yv6kkk2c-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 05 Mar 2017 09:41:11 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 eab29b2601ca11e7944824be05956610-a6bfba00 for <netdev@vger.kernel.org>;        Sun,
 05 Mar 2017 09:41:09 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

map_get_next_key callback is mandatory. Supply dummy handler.

Fixes: b95a5c4db09b ("bpf: add a longest prefix match trie map implementation")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/lpm_trie.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
index 8bfe0afaee10..b37bd9ab7f57 100644
--- a/kernel/bpf/lpm_trie.c
+++ b/kernel/bpf/lpm_trie.c
@@ -500,9 +500,15 @@ static void trie_free(struct bpf_map *map)
 	raw_spin_unlock(&trie->lock);
 }
 
+static int trie_get_next_key(struct bpf_map *map, void *key, void *next_key)
+{
+	return -ENOTSUPP;
+}
+
 static const struct bpf_map_ops trie_ops = {
 	.map_alloc = trie_alloc,
 	.map_free = trie_free,
+	.map_get_next_key = trie_get_next_key,
 	.map_lookup_elem = trie_lookup_elem,
 	.map_update_elem = trie_update_elem,
 	.map_delete_elem = trie_delete_elem,
-- 
2.8.0

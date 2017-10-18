From: John Fastabend <john.r.fastabend@gmail.com>
Subject: [net PATCH 5/5] bpf: require CAP_NET_ADMIN when using devmap
Date: Wed, 18 Oct 2017 07:11:44 -0700
Message-ID: <150833590435.3588.5261586304462625374.stgit@john-XPS-13-9360>
References: <150833522977.3588.14633565129152334098.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, borkmann@iogearbox.net
To: alexei.starovoitov@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:50088 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751504AbdJROL7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 10:11:59 -0400
Received: by mail-pg0-f65.google.com with SMTP id g6so4378168pgn.6
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 07:11:59 -0700 (PDT)
In-Reply-To: <150833522977.3588.14633565129152334098.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>

Devmap is used with XDP which requires CAP_NET_ADMIN so lets also
make CAP_NET_ADMIN required to use the map.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/devmap.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
index e093d9a..7d9f32f 100644
--- a/kernel/bpf/devmap.c
+++ b/kernel/bpf/devmap.c
@@ -78,6 +78,9 @@ static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
 	int err = -EINVAL;
 	u64 cost;
 
+	if (!capable(CAP_NET_ADMIN))
+		return ERR_PTR(-EPERM);
+
 	/* check sanity of attributes */
 	if (attr->max_entries == 0 || attr->key_size != 4 ||
 	    attr->value_size != 4 || attr->map_flags & ~BPF_F_NUMA_NODE)

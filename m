From: John Fastabend <john.r.fastabend@gmail.com>
Subject: [net PATCH 4/5] bpf: require CAP_NET_ADMIN when using sockmap maps
Date: Wed, 18 Oct 2017 07:11:22 -0700
Message-ID: <150833588223.3588.4249180141887196078.stgit@john-XPS-13-9360>
References: <150833522977.3588.14633565129152334098.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, borkmann@iogearbox.net
To: alexei.starovoitov@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:56124 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752056AbdJROLi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 10:11:38 -0400
Received: by mail-pf0-f196.google.com with SMTP id 17so4045239pfn.12
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 07:11:38 -0700 (PDT)
In-Reply-To: <150833522977.3588.14633565129152334098.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>

Restrict sockmap to CAP_NET_ADMIN.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/sockmap.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
index beaabb2..2b6eb35 100644
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c
@@ -486,6 +486,9 @@ static struct bpf_map *sock_map_alloc(union bpf_attr *attr)
 	int err = -EINVAL;
 	u64 cost;
 
+	if (!capable(CAP_NET_ADMIN))
+		return ERR_PTR(-EPERM);
+
 	/* check sanity of attributes */
 	if (attr->max_entries == 0 || attr->key_size != 4 ||
 	    attr->value_size != 4 || attr->map_flags & ~BPF_F_NUMA_NODE)

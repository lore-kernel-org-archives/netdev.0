From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH] bpf: devmap: remove unnecessary value size check
Date: Tue, 15 Aug 2017 23:35:12 -0700
Message-ID: <20170816063512.14925.40390.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35420 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751552AbdHPGfY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 02:35:24 -0400
Received: by mail-pg0-f65.google.com with SMTP id l64so4501797pge.2
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 23:35:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the devmap alloc map logic we check to ensure that the sizeof the
values are not greater than KMALLOC_MAX_SIZE. But, in the dev map case
we ensure the value size is 4bytes earlier in the function because all
values should be netdev ifindex values.

The second check is harmless but is not needed so remove it.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 kernel/bpf/devmap.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
index 7192fb6..18a72a8 100644
--- a/kernel/bpf/devmap.c
+++ b/kernel/bpf/devmap.c
@@ -83,12 +83,6 @@ static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
 	    attr->value_size != 4 || attr->map_flags)
 		return ERR_PTR(-EINVAL);
 
-	/* if value_size is bigger, the user space won't be able to
-	 * access the elements.
-	 */
-	if (attr->value_size > KMALLOC_MAX_SIZE)
-		return ERR_PTR(-E2BIG);
-
 	dtab = kzalloc(sizeof(*dtab), GFP_USER);
 	if (!dtab)
 		return ERR_PTR(-ENOMEM);

From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: make struct request_sock_ops::obj_size unsigned
Date: Tue, 23 May 2017 00:21:39 +0300
Message-ID: <20170522212139.GB28769@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33928 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933876AbdEVVVn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 17:21:43 -0400
Received: by mail-lf0-f65.google.com with SMTP id q24so6451715lfb.1
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 14:21:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This field is sizeof of corresponding kmem_cache so it can't be negative.

Space will be saved after 32-bit kmem_cache_create() patch.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/request_sock.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -29,7 +29,7 @@ struct proto;
 
 struct request_sock_ops {
 	int		family;
-	int		obj_size;
+	unsigned int	obj_size;
 	struct kmem_cache	*slab;
 	char		*slab_name;
 	int		(*rtx_syn_ack)(const struct sock *sk,

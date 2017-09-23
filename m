From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 1/2] neigh: make struct neigh_table::entry_size unsigned int
Date: Sat, 23 Sep 2017 23:01:06 +0300
Message-ID: <20170923200106.GA24928@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36990 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbdIWUBL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 16:01:11 -0400
Received: by mail-wm0-f68.google.com with SMTP id f4so3962538wmh.4
        for <netdev@vger.kernel.org>; Sat, 23 Sep 2017 13:01:10 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neigh entry size can't be negative.

Space savings:

	add/remove: 0/0 grow/shrink: 0/5 up/down: 0/-7 (-7)
	function                                     old     new   delta
	lowpan_neigh_construct                        25      24      -1
	clip_seq_sub_iter                            152     151      -1
	clip_ioctl                                  1475    1474      -1
	clip_constructor                              93      92      -1
	__neigh_create                              2455    2452      -3

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/neighbour.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -190,7 +190,7 @@ struct neigh_hash_table {
 
 struct neigh_table {
 	int			family;
-	int			entry_size;
+	unsigned int		entry_size;
 	int			key_len;
 	__be16			protocol;
 	__u32			(*hash)(const void *pkey,

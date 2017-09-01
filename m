From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] bpf: Collapse offset checks in sock_filter_is_valid_access
Date: Fri,  1 Sep 2017 08:18:07 -0700
Message-ID: <1504279087-11379-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37728 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751039AbdIAPST (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 11:18:19 -0400
Received: by mail-pg0-f66.google.com with SMTP id t193so293668pgc.4
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 08:18:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sock_filter_is_valid_access consistent with other is_valid_access
helpers.

Requested-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/core/filter.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 9dad3e7e2e10..f9add024d92f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3468,9 +3468,7 @@ static bool sock_filter_is_valid_access(int off, int size,
 	if (type == BPF_WRITE) {
 		switch (off) {
 		case offsetof(struct bpf_sock, bound_dev_if):
-			break;
 		case offsetof(struct bpf_sock, mark):
-			break;
 		case offsetof(struct bpf_sock, priority):
 			break;
 		default:
-- 
2.1.4

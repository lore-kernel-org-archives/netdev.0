From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [RFC PATCH 4/5] netlink: mmap: update tx type check
Date: Wed, 22 Jul 2015 22:22:30 +0900
Message-ID: <20150722132230.GE18037@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:33864 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756659AbbGVNWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 09:22:36 -0400
Received: by pdbbh15 with SMTP id bh15so93140671pdb.1
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 06:22:35 -0700 (PDT)
Received: from gmail.com (softbank220009032004.bbtec.net. [220.9.32.4])
        by smtp.gmail.com with ESMTPSA id pn6sm3395719pdb.72.2015.07.22.06.22.34
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 06:22:34 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to accept msg_iter.type 1(WRITE) which is set in sendto/sendmsg.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
---
 net/netlink/af_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index a6fba4c..7e1610e 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2394,7 +2394,7 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	 * sendmsg(), but that's what we've got...
 	 */
 	if (netlink_tx_is_mmaped(sk) &&
-	    msg->msg_iter.type == ITER_IOVEC &&
+	    !(msg->msg_iter.type & (ITER_KVEC | ITER_BVEC)) &&
 	    msg->msg_iter.nr_segs == 1 &&
 	    msg->msg_iter.iov->iov_base == NULL) {
 		err = netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group,
-- 
1.7.10.4


----- End forwarded message -----

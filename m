From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [PATCHv1 net-next 4/5] netlink: mmap: update tx type check
Date: Wed, 12 Aug 2015 17:35:26 +0900
Message-ID: <20150812083526.GE13385@gmail.com>
References: <20150722131730.GA18037@gmail.com>
 <20150812082824.GA13385@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:32770 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933733AbbHLIfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 04:35:31 -0400
Received: by pabyb7 with SMTP id yb7so9956165pab.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 01:35:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150812082824.GA13385@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to accept msg_iter.type 1(WRITE) which is set in sendto/sendmsg.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
---
 net/netlink/af_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c03fad0..d8f5151 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2451,7 +2451,7 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
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

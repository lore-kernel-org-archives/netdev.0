From: Daniel Borkmann <dxchgb@gmail.com>
Subject: [PATCH net-next] packet: minor: remove unused err assignment
Date: Wed, 24 Oct 2012 15:27:24 +0200
Message-ID: <20121024132723.GA21528@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f194.google.com ([209.85.212.194]:46378 "EHLO
	mail-wi0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755194Ab2JXN12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 09:27:28 -0400
Received: by mail-wi0-f194.google.com with SMTP id hr7so329261wib.1
        for <netdev@vger.kernel.org>; Wed, 24 Oct 2012 06:27:27 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This tiny patch removes two unused err assignments. In those two cases the
err variable is either overwritten with another value at a later point in
time without having read the previous assigment, or it is assigned and the
function returns without using/reading err after the assignment.

Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
---
 net/packet/af_packet.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 94060ed..9034f52 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1907,7 +1907,6 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		to_write -= dev->hard_header_len;
 	}
 
-	err = -EFAULT;
 	offset = offset_in_page(data);
 	len_max = PAGE_SIZE - offset;
 	len = ((to_write > len_max) ? len_max : to_write);
@@ -1957,7 +1956,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 
 	mutex_lock(&po->pg_vec_lock);
 
-	err = -EBUSY;
 	if (saddr == NULL) {
 		dev = po->prot_hook.dev;
 		proto	= po->num;

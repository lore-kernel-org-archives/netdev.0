From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next] tun: return proper error code from tun_do_read
Date: Thu, 25 Dec 2014 23:22:49 -0800
Message-ID: <1419578569-13132-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>, Alex Gartrell <agartrell@fb.com>
To: <davem@davemloft.net>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:30400 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751078AbaLZHW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2014 02:22:58 -0500
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id sBQ7MvLj007085
	for <netdev@vger.kernel.org>; Thu, 25 Dec 2014 23:22:57 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1rgyph0scj-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 25 Dec 2014 23:22:57 -0800
Received: from facebook.com (2401:db00:20:7017:face:0:13:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 01d965a48cd011e49dd80002c95209d8-57dd3390 for <netdev@vger.kernel.org>;	Thu,
 25 Dec 2014 23:22:54 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of -1 with EAGAIN, read on a O_NONBLOCK tun fd will return 0.  This
fixes this by properly returning the error code from __skb_recv_datagram.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 drivers/net/tun.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a5cbf67..2f65d6c 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1378,7 +1378,7 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 	skb = __skb_recv_datagram(tfile->socket.sk, noblock ? MSG_DONTWAIT : 0,
 				  &peeked, &off, &err);
 	if (!skb)
-		return 0;
+		return err;
 
 	ret = tun_put_user(tun, tfile, skb, to);
 	if (unlikely(ret < 0))
-- 
Alex Gartrell <agartrell@fb.com>

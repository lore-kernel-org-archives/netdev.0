From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] fix limited slow start bug
Date: Thu, 22 Feb 2007 13:56:22 -0500
Message-ID: <45DDE756.20001@psc.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000001070208050306070105"
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:51136 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751765AbXBVS42 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 13:56:28 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000001070208050306070105
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------000001070208050306070105
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="lss_order_bug.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lss_order_bug.patch"

Fix arithmetic order bug in limited slow start.  The subtraction needs to be
done before snd_cwnd is incremented.

Signed-off-by: John Heffner <jheffner@psc.edu>

---
commit 244e7411d99443df7b7ae849ba6ebbec4c2342bc
tree e6d5985a22448f59f8bef393542e1d5497ee5684
parent 97033fa201705e6cfc68ce66f34ede3277c3d645
author John Heffner <jheffner@psc.edu> Thu, 22 Feb 2007 13:54:01 -0500
committer John Heffner <jheffner@psc.edu> Thu, 22 Feb 2007 13:54:01 -0500

 net/ipv4/tcp_cong.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 7fd2910..a0c894f 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -303,9 +303,9 @@ void tcp_slow_start(struct tcp_sock *tp)
 	
 	tp->snd_cwnd_cnt += cnt;
 	while (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
+		tp->snd_cwnd_cnt -= tp->snd_cwnd;
 		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
 			tp->snd_cwnd++;
-		tp->snd_cwnd_cnt -= tp->snd_cwnd;
 	}
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);

--------------000001070208050306070105--

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] sctp: fix oops while removed transport still using as retran
 path
Date: Wed, 13 Apr 2011 09:22:22 +0800
Message-ID: <4DA4FACE.5060706@cn.fujitsu.com>
References: <4DA4FA70.50506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62954 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932099Ab1DMBWL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 21:22:11 -0400
In-Reply-To: <4DA4FA70.50506@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we can not update retran path to unconfirmed transports,
when we remove a peer, the retran path may not be update if the
other transports are all unconfirmed, and we will still using
the removed transport as the retran path. This may cause panic
if retrasnmit happen.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/associola.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 922fdd7..1a21c57 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -569,6 +569,8 @@ void sctp_assoc_rm_peer(struct sctp_association *asoc,
 		sctp_assoc_set_primary(asoc, transport);
 	if (asoc->peer.active_path == peer)
 		asoc->peer.active_path = transport;
+	if (asoc->peer.retran_path == peer)
+		asoc->peer.retran_path = transport;
 	if (asoc->peer.last_data_from == peer)
 		asoc->peer.last_data_from = transport;
 
-- 
1.6.5.2



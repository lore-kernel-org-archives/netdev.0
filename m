From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: tr: fix leakage of device in net/802/tr.c
Date: Thu, 09 Apr 2009 15:27:28 +0800
Message-ID: <49DDA360.1010402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53772 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753950AbZDIH2z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2009 03:28:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add dev_put() after dev_get_by_index() to avoid leakage
of device.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/802/tr.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/802/tr.c b/net/802/tr.c
index e7eb130..e874447 100644
--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -561,6 +561,9 @@ static int rif_seq_show(struct seq_file *seq, void *v)
 				}
 				seq_putc(seq, '\n');
 			}
+
+		if (dev)
+			dev_put(dev);
 		}
 	return 0;
 }
-- 
1.5.3.8





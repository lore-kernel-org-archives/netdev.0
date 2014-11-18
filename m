From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/1] net: pktgen: Deletion of an unnecessary check before
 the function call "proc_remove"
Date: Tue, 18 Nov 2014 20:16:05 +0100
Message-ID: <546B9AF5.9050809@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org, Coccinelle <cocci@systeme.lip6.fr>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 18 Nov 2014 20:10:34 +0100

The proc_remove() function tests whether its argument is NULL and then
returns immediately. Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/core/pktgen.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8b849dd..35046a8 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3698,8 +3698,7 @@ static int pktgen_remove_device(struct pktgen_thread *t,
 	/* Remove proc before if_list entry, because add_device uses
 	 * list to determine if interface already exist, avoid race
 	 * with proc_create_data() */
-	if (pkt_dev->entry)
-		proc_remove(pkt_dev->entry);
+	proc_remove(pkt_dev->entry);
 
 	/* And update the thread if_list */
 	_rem_dev_from_if_list(t, pkt_dev);
-- 
2.1.3

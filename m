From: Bernard Pidoux <bpidoux@free.fr>
Subject: [PATCH] ax25.h unsigned long type for ax25 timers
Date: Tue, 17 Jun 2008 15:04:38 +0200
Message-ID: <200806171504.38702.bpidoux@free.fr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	"linux-hams" <linux-hams@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:59623 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756488AbYFQNEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 09:04:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In linux/include/linux/ax25.h
ax25_info_struct timers types remain unsigned

struct ax25_info_struct {
	unsigned int	n2, n2count;
	unsigned int	t1, t1timer;
	unsigned int	t2, t2timer;
	unsigned int	t3, t3timer;
	unsigned int	idle, idletimer;
        .....
};

while in linux/include/net/ax25.h timers are unsigned long according
to kernel 2.6 timers.

typedef struct ax25_cb {
        .....
        struct timer_list       t1timer, t2timer, t3timer, idletimer;
        unsigned long           t1, t2, t3, idle, rtt;
        ....

Although ax25_info_struct is not much used it is refered at least
into libax25 and xfbb BBS application program.

It seems thus reasonable to make the change.

Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
---
 include/linux/ax25.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/ax25.h b/include/linux/ax25.h
index 56c11f0..75282bb 100644
--- a/include/linux/ax25.h
+++ b/include/linux/ax25.h
@@ -97,10 +97,10 @@ struct ax25_info_struct_deprecated {
 
 struct ax25_info_struct {
 	unsigned int	n2, n2count;
-	unsigned int	t1, t1timer;
-	unsigned int	t2, t2timer;
-	unsigned int	t3, t3timer;
-	unsigned int	idle, idletimer;
+	unsigned long	t1, t1timer;
+	unsigned long	t2, t2timer;
+	unsigned long	t3, t3timer;
+	unsigned long	idle, idletimer;
 	unsigned int	state;
 	unsigned int	rcv_q, snd_q;
 	unsigned int	vs, vr, va, vs_max;
-- 
1.5.5


From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH 1/2] irda: return -ENOMEM upon failure to allocate new
 ias_obj
Date: Sun, 13 Jan 2008 01:34:13 +0100 (CET)
Message-ID: <alpine.LNX.1.00.0801130101510.2235@dragon.funnycrock.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dag Brattli <dagb@cs.uit.no>, Jean Tourrilhes <jt@hpl.hp.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Jesper Juhl <jesper.juhl@gmail.com>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753818AbYAMAjo@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


irias_new_object() can fail its memory allocation and will return NULL in 
that case. I believe the proper thing to do is to catch this, free the 
ias_opt that was allocated earlier but won't be used and then return 
-ENOMEM.
There are assertions further on that check for a NULL ias_obj, but I think 
it's a lot nicer to simply return -ENOMEM to the caller here where we know 
a memory allocation failed, rather than hitting an assertion later.

note: I don't have any means of actually testing this, so it has been 
compile tested only.


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 af_irda.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index d5e4dd7..e33f0a5 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1881,6 +1881,10 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 			/* Create a new object */
 			ias_obj = irias_new_object(ias_opt->irda_class_name,
 						   jiffies);
+			if (!ias_obj) {
+				kfree(ias_opt);
+				return -ENOMEM;
+			}
 		}
 
 		/* Do we have the attribute already ? */




From: Patrick McHardy <kaber@trash.net>
Subject: Re: HTB and ingress scheduler SMP Soft Lockup in 2.6.23-2.6.25-rc8
Date: Mon, 14 Apr 2008 09:51:00 +0200
Message-ID: <48030CE4.10506@trash.net>
References: <47FFAFFA.7070802@superclick.com> <4801BB96.5010406@trash.net> <48025CE3.7080807@superclick.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050706040303080400010307"
Cc: netdev@vger.kernel.org
To: Enrico Demarin <enrico@superclick.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65209 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759638AbYDNHvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 03:51:06 -0400
In-Reply-To: <48025CE3.7080807@superclick.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050706040303080400010307
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Enrico Demarin wrote:
> Hi Patrick,
> 
> here it is, hope it will work out this time

I can't figure out the problem. Could you retry using
this patch? It should hopefully show us on which class
qdisc_decrease_qlen is looping.


--------------050706040303080400010307
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 66148cc..40d05c5 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1171,6 +1171,7 @@ static void htb_qlen_notify(struct Qdisc *sch, unsigned long arg)
 {
 	struct htb_class *cl = (struct htb_class *)arg;
 
+	printk("htb_qlen_notify classid=%x\n", cl->classid);
 	if (cl->un.leaf.q->q.qlen == 0)
 		htb_deactivate(qdisc_priv(sch), cl);
 }

--------------050706040303080400010307--

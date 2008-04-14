From: Patrick McHardy <kaber@trash.net>
Subject: Re: HTB and ingress scheduler SMP Soft Lockup in 2.6.23-2.6.25-rc8
Date: Mon, 14 Apr 2008 09:14:14 +0200
Message-ID: <48030446.1090103@trash.net>
References: <47FFAFFA.7070802@superclick.com> <4801BB96.5010406@trash.net> <48025CE3.7080807@superclick.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090805020307030601080506"
Cc: netdev@vger.kernel.org
To: Enrico Demarin <enrico@superclick.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63969 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbYDNHOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 03:14:19 -0400
In-Reply-To: <48025CE3.7080807@superclick.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090805020307030601080506
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Enrico Demarin wrote:
> Hi Patrick,
> 
> here it is, hope it will work out this time

Thanks. Could you try whether this patch fixes it please?


--------------090805020307030601080506
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 66148cc..4c7ffb1 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1398,7 +1398,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		/* create leaf qdisc early because it uses kmalloc(GFP_KERNEL)
 		   so that can't be used inside of sch_tree_lock
 		   -- thanks to Karlis Peisenieks */
-		new_q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid);
+		new_q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, parent);
 		sch_tree_lock(sch);
 		if (parent && !parent->level) {
 			unsigned int qlen = parent->un.leaf.q->q.qlen;

--------------090805020307030601080506--

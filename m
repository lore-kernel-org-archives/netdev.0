From: Patrick McHardy <kaber@trash.net>
Subject: Re: HTB and ingress scheduler SMP Soft Lockup in 2.6.23-2.6.25-rc8
Date: Mon, 14 Apr 2008 09:15:06 +0200
Message-ID: <4803047A.2070408@trash.net>
References: <47FFAFFA.7070802@superclick.com> <4801BB96.5010406@trash.net> <48025CE3.7080807@superclick.com> <48030446.1090103@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010403080509000405030000"
Cc: netdev@vger.kernel.org
To: Enrico Demarin <enrico@superclick.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63997 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758193AbYDNHPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 03:15:11 -0400
In-Reply-To: <48030446.1090103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010403080509000405030000
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Enrico Demarin wrote:
>> Hi Patrick,
>>
>> here it is, hope it will work out this time
> 
> Thanks. Could you try whether this patch fixes it please?


That one was broken, this one should work.



--------------010403080509000405030000
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 66148cc..fa6b1ad 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1398,7 +1398,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		/* create leaf qdisc early because it uses kmalloc(GFP_KERNEL)
 		   so that can't be used inside of sch_tree_lock
 		   -- thanks to Karlis Peisenieks */
-		new_q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid);
+		new_q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+					  parent->classid);
 		sch_tree_lock(sch);
 		if (parent && !parent->level) {
 			unsigned int qlen = parent->un.leaf.q->q.qlen;

--------------010403080509000405030000--

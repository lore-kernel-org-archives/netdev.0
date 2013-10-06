From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] netem: update backlog after drop
Date: Sun, 6 Oct 2013 15:15:33 -0700
Message-ID: <20131006151533.52988624@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:38271 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754834Ab3JIVT5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 17:19:57 -0400
Received: by mail-pb0-f44.google.com with SMTP id xa7so1515340pbc.17
        for <netdev@vger.kernel.org>; Wed, 09 Oct 2013 14:19:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When packet is dropped from rb-tree netem the backlog statistic should
also be updated.

Reported-by: =D0=A1=D0=B5=D1=80=D0=B3=D0=B5=D0=B5=D0=B2 =D0=A1=D0=B5=D1=
=80=D0=B3=D0=B5=D0=B9 <adron@yapic.net>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
Should be reviewed by Eric (he added the rb-tree stuff), and added to s=
table
as well.

--- a/net/sched/sch_netem.c	2013-10-06 15:06:50.675250833 -0700
+++ b/net/sched/sch_netem.c	2013-10-06 15:10:03.957219532 -0700
@@ -520,6 +520,7 @@ static unsigned int netem_drop(struct Qd
 			skb->next =3D NULL;
 			skb->prev =3D NULL;
 			len =3D qdisc_pkt_len(skb);
+			sch->qstats.backlog -=3D len;
 			kfree_skb(skb);
 		}
 	}

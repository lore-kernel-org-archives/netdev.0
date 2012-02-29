From: "Anton 'EvilMan' Danilov" <littlesmilingcloud@gmail.com>
Subject: [PATCH] tc action: pedit, fix header offset calculation
Date: Wed, 29 Feb 2012 19:45:07 +0300
Message-ID: <CAEzD07LUMu+SEy7YM=Wi=ZEihE6SWZxbh3qjUCYBxFGiC40uwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38746 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755932Ab2B2QpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 11:45:09 -0500
Received: by wibhm11 with SMTP id hm11so2817486wib.19
        for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 08:45:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix header offset calculation in pedit action.
Header offset feature can be used for calculation offset of next
header, if options is presented in ipv4 header.

diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 10d3aed..4678a77 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -151,7 +151,7 @@ static int tcf_pedit(struct sk_buff *skb, const
struct tc_action *a,
							&_d);
				if (!d)
					goto bad;
-				offset += (*d & tkey->offmask) >> tkey->shift;
+				offset += ntohl(*d & tkey->offmask) >> tkey->shift;
			}

			if (offset % 4) {

-- 
Anton.

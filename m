From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 11571] New: u32_classify Kernel Panic
Date: Thu, 18 Sep 2008 00:08:11 +0200
Message-ID: <20080917220811.GA10893@ami.dom.local>
References: <20080916091508.a0cd830e.akpm@linux-foundation.org> <20080917193832.GA2623@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	m0sia@plotinka.ru
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:63300 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbYIQWHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 18:07:00 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1883747nfc.21
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2008 15:06:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080917193832.GA2623@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2008 at 09:38:32PM +0200, Jarek Poplawski wrote:
...
> >> http://bugzilla.kernel.org/show_bug.cgi?id=11571
> Does this happen while creating or deleting something and is this
> easy to reproduce?

If accidentally there is any deleting around try this patch, please.

Jarek P.

---

 net/sched/cls_u32.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 246f906..9912ad5 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -433,7 +433,9 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
 
 	if (ht->refcnt == 1) {
 		ht->refcnt--;
+		tcf_tree_lock(tp);
 		u32_destroy_hnode(tp, ht);
+		tcf_tree_unlock(tp);
 	} else {
 		return -EBUSY;
 	}

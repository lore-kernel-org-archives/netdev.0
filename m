From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sun, 17 Aug 2008 23:47:52 +0200
Message-ID: <20080817214752.GA2546@ami.dom.local>
References: <20080815190905.M56388@visp.net.lb> <200808171603.22151.denys@visp.net.lb> <20080817133608.GA3584@ami.dom.local> <200808172236.17857.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:20999 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbYHQVrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 17:47:21 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1053806nfc.21
        for <netdev@vger.kernel.org>; Sun, 17 Aug 2008 14:47:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808172236.17857.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2008 at 10:36:17PM +0300, Denys Fedoryshchenko wrote:
> I am lost in patches :-)
> When you will be back, let me know if order and set of patches is correct.
> Here is what i am using:
> 
> http://www.nuclearcat.com/patches/00-prevfixes1.patch
> http://www.nuclearcat.com/patches/00-prevfixes2.patch
> http://www.nuclearcat.com/patches/01-take3.patch
> http://www.nuclearcat.com/patches/02-fix1.patch
> http://www.nuclearcat.com/patches/03-fix_patch_2.patch
> 
> And thanks for your help!
> I cannot take risk and put to wide production, since it is crashing sometimes, 
> but i guess in few days we can make it ready for production.
> 

OK, so please try to test with all these patches above plus one new
patch below.

Thanks,
Jarek P.

(04-fix_patch_3.patch)
---

 net/sched/sch_api.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c25465e..c8dc72e 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -638,9 +638,9 @@ static void notify_and_destroy(struct sk_buff *skb, struct nlmsghdr *n, u32 clid
 		qdisc_notify(skb, n, clid, old, new);
 
 	if (old) {
-		spin_lock_bh(&old->q.lock);
+		sch_tree_lock(old);
 		qdisc_destroy(old);
-		spin_unlock_bh(&old->q.lock);
+		sch_tree_unlock(old);
 	}
 }
 

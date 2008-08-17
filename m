From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sun, 17 Aug 2008 15:16:35 +0200
Message-ID: <20080817131635.GA3535@ami.dom.local>
References: <20080815190905.M56388@visp.net.lb> <200808171506.06292.denys@visp.net.lb> <20080817123825.GE2907@ami.dom.local> <200808171550.01154.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:48237 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbYHQNPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 09:15:16 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1015091nfc.21
        for <netdev@vger.kernel.org>; Sun, 17 Aug 2008 06:15:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808171550.01154.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2008 at 03:50:01PM +0300, Denys Fedoryshchenko wrote:
> On Sunday 17 August 2008, Jarek Poplawski wrote:
> 
> > Denys, I would like to be sure: do you mean here the last patch
> > attached below? So, the alternative shaper works with previous
> > patches, but not this one? If so, than no need to test this patch
> > anymore, only confirm this, please.
> No.
> Alternative shaper didn't work without applying latest patch (just i had old 
> kernel, and i decide just to try alternative shaper).
> 
> Latest warning with all patches applied. I will test alternative shaper with 
> all patches applied now.
> 

I think it would be better to test first only with patches:
take #3, patch #1, patch #2 (and of these 2 from earlier thread).

This last patch, let's call it patch #4, can wait.

If there are oopses please try to add to them this one:

Jarek P.

--- (patch #5)

 net/sched/sch_api.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c25465e..5fdd1e2 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -694,6 +694,9 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 
 		err = -EINVAL;
 
+		if (dev->flags & IFF_UP)
+			dev_deactivate(dev);
+
 		if (cops) {
 			unsigned long cl = cops->get(parent, classid);
 			if (cl) {
@@ -703,6 +706,9 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 		}
 		if (!err)
 			notify_and_destroy(skb, n, classid, old, new);
+
+		if (dev->flags & IFF_UP)
+			dev_activate(dev);
 	}
 	return err;
 }

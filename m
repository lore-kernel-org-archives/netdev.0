From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (possibly
	caused by netem)
Date: Thu, 2 Jul 2009 09:30:31 +0000
Message-ID: <20090702093031.GC4954@ff.dom.local>
References: <4A4A9DD6.8060800@anarazel.de> <4A4BAD5F.7050908@gmail.com> <4A4BD384.3090407@anarazel.de> <4A4C0144.5070203@anarazel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Andres Freund <andres@anarazel.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:64254 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993AbZGBJag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 05:30:36 -0400
Content-Disposition: inline
In-Reply-To: <4A4C0144.5070203@anarazel.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 02, 2009 at 02:37:24AM +0200, Andres Freund wrote:
...
> So I tried - and I did not catch any lockdep output before the crash.  
> Unfortunately I do not have another machine on the same local network to  
> catch any messages after the crash... So I could be missing some warning  
> (I did synchronous logging though).
> Will check with netconsole tomorrow.

Could you try if this patch changes anything?

Thanks,
Jarek P.
---

 net/sched/sch_netem.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 2b88295..6001ad9 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -176,8 +176,6 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	}
 
-	skb_orphan(skb);
-
 	/*
 	 * If we need to duplicate packet, then re-insert at top of the
 	 * qdisc tree, since parent queuer expects that only one

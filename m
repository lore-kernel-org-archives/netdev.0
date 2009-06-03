From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Wed, 3 Jun 2009 09:54:12 +0000
Message-ID: <20090603095412.GC5644@ff.dom.local>
References: <298f5c050906020445n3941b4ceic1167a4a028005bf@mail.gmail.com> <20090602123635.GC4239@ff.dom.local> <4A251EEE.4060903@trash.net> <20090602130857.GA7690@ff.dom.local> <4A252714.2020008@trash.net> <20090602213723.GB2850@ami.dom.local> <4A259EB2.5010500@gmail.com> <4A2620FD.8030708@trash.net> <20090603074049.GA5254@ff.dom.local> <4A262BE7.4090807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Antonio Almeida <vexwek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:12964 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbZFCJyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 05:54:16 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1098708fga.17
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2009 02:54:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A262BE7.4090807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2009 at 09:53:11AM +0200, Patrick McHardy wrote:
...
> The necessary changes are
> really trivial, all you need to do when changing the scaling factors
> is to increase SM_MASK and decrease ISM_MASK accordingly.

OK, looks like it's really enough and I was confused with some
rounding, thanks Patrick.

Antonio, could you give this patch a try (with all the previous) and
repeat those HFSC tests you did before (plus maybe a few tries with
lower rates)?

Thanks,
Jarek P.
---

 net/sched/sch_hfsc.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 5022f9c..7c53a36 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -384,8 +384,9 @@ cftree_update(struct hfsc_class *cl)
  *
  *  1.024us/byte  78.125     7.8125     0.78125    0.078125   0.0078125
  */
-#define	SM_SHIFT	20
-#define	ISM_SHIFT	18
+#define	PSCHED_SHIFT	6	/* TODO: move to pkt_sched.h */
+#define	SM_SHIFT	(30 - PSCHED_SHIFT)
+#define	ISM_SHIFT	(8 + PSCHED_SHIFT)
 
 #define	SM_MASK		((1ULL << SM_SHIFT) - 1)
 #define	ISM_MASK	((1ULL << ISM_SHIFT) - 1)

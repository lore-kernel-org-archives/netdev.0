From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH 1/4] net: sched: consolidate offload decision in
 cls_u32
Date: Wed, 24 Feb 2016 09:49:01 +0100
Message-ID: <20160224084901.GE2151@nanopsycho.orion>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com, davem@davemloft.net, jhs@mojatatu.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34575 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758194AbcBXItD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 03:49:03 -0500
Received: by mail-wm0-f49.google.com with SMTP id b205so24943862wmb.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 00:49:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 23, 2016 at 08:02:33PM CET, john.fastabend@gmail.com wrote:
>The offload decision was originally very basic and tied to if the dev
>implemented the appropriate ndo op hook. The next step is to allow
>the user to more flexibly define if any paticular rule should be
>offloaded or not. In order to have this logic in one function lift
>the current check into a helper routine tc_should_offload().
>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>---
> net/sched/cls_u32.c |   13 +++++++++----
> 1 file changed, 9 insertions(+), 4 deletions(-)
>
>diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
>index d54bc94..1f31929 100644
>--- a/net/sched/cls_u32.c
>+++ b/net/sched/cls_u32.c
>@@ -425,6 +425,11 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
> 	return 0;
> }
> 
>+static bool u32_should_offload(struct net_device *dev)
>+{
>+	return dev->netdev_ops->ndo_setup_tc;
>+}
>+

This should be done in generic "dev_should_offload_tc" helper

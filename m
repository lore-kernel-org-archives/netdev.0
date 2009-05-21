From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cls_cgroup: read classid atomically in classifier
Date: Thu, 21 May 2009 15:22:36 -0700 (PDT)
Message-ID: <20090521.152236.101174595.davem@davemloft.net>
References: <20090521183100.12678.28835.stgit@menage.mtv.corp.google.com>
	<20090521194447.GA3388@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: menage@google.com, lizf@cn.fujitsu.com, akpm@linux-foundation.org,
	tgraf@suug.ch, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42391
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755264AbZEUWWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 18:22:38 -0400
In-Reply-To: <20090521194447.GA3388@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 21 May 2009 21:44:48 +0200

> Thu, May 21, 2009 at 08:31:26PM CEST, menage@google.com wrote:
>>cls_cgroup: read classid atomically in classifier
>>
>>Avoid reading the unsynchronized value cs->classid multiple times,
>>since it could change concurrently from non-zero to zero; this would
>>result in the classifier returning a positive result with a bogus
>>(zero) classid.
>>
>>Signed-off-by: Paul Menage <menage@google.com>
>>Reviewed-by: Li Zefan <lizf@cn.fujitsu.com>
>>
>>---
>>
>>Resending to cc netdev@vger.kernel.org as requested by DaveM
>>
>> net/sched/cls_cgroup.c |   22 +++++++++++-----------
>> 1 files changed, 11 insertions(+), 11 deletions(-)
>>
>>diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
>>index 1ab4542..4ece6e0 100644
>>--- a/net/sched/cls_cgroup.c
>>+++ b/net/sched/cls_cgroup.c
>>@@ -98,8 +98,7 @@ static int cls_cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
>> 			       struct tcf_result *res)
>> {
>> 	struct cls_cgroup_head *head = tp->root;
>>-	struct cgroup_cls_state *cs;
>>-	int ret = 0;
>>+        u32 classid;
>   ^^^^^^^^ How about using TAB instead?

Agreed, please use proper formatting.

From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v1 03/11] net: flow_table: add apply action
 argument to tables
Date: Thu, 8 Jan 2015 18:41:51 +0100
Message-ID: <20150108174151.GE1898@nanopsycho.orion>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
 <20141231194642.31070.14445.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, sfeldma@gmail.com, jhs@mojatatu.com,
	simon.horman@netronome.com, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38725 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756240AbbAHRlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 12:41:53 -0500
Received: by mail-wi0-f170.google.com with SMTP id bs8so4524057wib.1
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 09:41:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141231194642.31070.14445.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 31, 2014 at 08:46:44PM CET, john.fastabend@gmail.com wrote:
>Actions may not always be applied after exiting a table. For example
>some pipelines may accumulate actions and then apply them at the end
>of a pipeline.
>
>To model this we use a table type called APPLY. Tables who share an
>apply identifier have their actions applied in one step.

Why this is a separate patch? Perhaps this can be squashed to one of the
previous ones?

>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>---
> include/linux/if_flow.h      |    1 +
> include/uapi/linux/if_flow.h |    1 +
> net/core/flow_table.c        |    1 +
> 3 files changed, 3 insertions(+)
>
>diff --git a/include/linux/if_flow.h b/include/linux/if_flow.h
>index 20fa752..a042a3d 100644
>--- a/include/linux/if_flow.h
>+++ b/include/linux/if_flow.h
>@@ -67,6 +67,7 @@ struct net_flow_table {
> 	char name[NET_FLOW_NAMSIZ];
> 	int uid;
> 	int source;
>+	int apply_action;
> 	int size;
> 	struct net_flow_field_ref *matches;
> 	int *actions;
>diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
>index 125cdc6..3c1a860 100644
>--- a/include/uapi/linux/if_flow.h
>+++ b/include/uapi/linux/if_flow.h
>@@ -265,6 +265,7 @@ enum {
> 	NET_FLOW_TABLE_ATTR_NAME,
> 	NET_FLOW_TABLE_ATTR_UID,
> 	NET_FLOW_TABLE_ATTR_SOURCE,
>+	NET_FLOW_TABLE_ATTR_APPLY,
> 	NET_FLOW_TABLE_ATTR_SIZE,
> 	NET_FLOW_TABLE_ATTR_MATCHES,
> 	NET_FLOW_TABLE_ATTR_ACTIONS,
>diff --git a/net/core/flow_table.c b/net/core/flow_table.c
>index f4cf293..97cdf92 100644
>--- a/net/core/flow_table.c
>+++ b/net/core/flow_table.c
>@@ -223,6 +223,7 @@ static int net_flow_put_table(struct net_device *dev,
> 	if (nla_put_string(skb, NET_FLOW_TABLE_ATTR_NAME, t->name) ||
> 	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_UID, t->uid) ||
> 	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SOURCE, t->source) ||
>+	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_APPLY, t->apply_action) ||
> 	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SIZE, t->size))
> 		return -EMSGSIZE;
> 
>

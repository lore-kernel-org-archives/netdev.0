From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC rocker-net-next 6/6] net: flow: Limit checking of
 ndo_flow_{set,del}_flows
Date: Tue, 6 Jan 2015 10:07:24 +0900
Message-ID: <20150106010722.GC14077@vergenet.net>
References: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
 <1420440610-20621-7-git-send-email-simon.horman@netronome.com>
 <54AACA92.5030800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:37947 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754101AbbAFBHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 20:07:33 -0500
Received: by mail-pa0-f50.google.com with SMTP id bj1so29697322pad.23
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 17:07:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54AACA92.5030800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 05, 2015 at 09:32:02AM -0800, John Fastabend wrote:
> On 01/04/2015 10:50 PM, Simon Horman wrote:
> >Only check for availability of ndo_flow_{set,del}_flows when
> >they are to be be used.
> >
> 
> I went ahead and merged this but, I'm not sure does it make
> sense to allow a user to add a flow that can't be deleted? Or
> delete a flow that wasn't ever added? I guess if the driver has
> a reason to do this it doesn't hurt to allow it and I think the
> code looks neater this way.
> 
> Also thanks for the other fixes I pulled the other 5 in as well
> I'll re-submit the series after running some basic tests.

I don't have any strong opinions on this but it
sounds like policy that doesn't belong in flow_table.c.

> >Signed-off-by: Simon Horman <simon.horman@netronome.com>
> >---
> >  net/core/flow_table.c | 15 +++++++++++++--
> >  1 file changed, 13 insertions(+), 2 deletions(-)
> >
> >diff --git a/net/core/flow_table.c b/net/core/flow_table.c
> >index bfc984f..6d620d4 100644
> >--- a/net/core/flow_table.c
> >+++ b/net/core/flow_table.c
> >@@ -1206,9 +1206,20 @@ static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
> >  	if (!dev)
> >  		return -EINVAL;
> >
> >-	if (!dev->netdev_ops->ndo_flow_set_flows ||
> >-	    !dev->netdev_ops->ndo_flow_del_flows)
> >+	switch (cmd) {
> >+	case NET_FLOW_TABLE_CMD_SET_FLOWS:
> >+		if (!dev->netdev_ops->ndo_flow_set_flows)
> >+			goto out;
> >+		break;
> >+
> >+	case NET_FLOW_TABLE_CMD_DEL_FLOWS:
> >+		if (!dev->netdev_ops->ndo_flow_del_flows)
> >+			goto out;
> >+		break;
> >+
> >+	default:
> >  		goto out;
> >+	}
> >
> >  	if (!info->attrs[NET_FLOW_IDENTIFIER_TYPE] ||
> >  	    !info->attrs[NET_FLOW_IDENTIFIER] ||
> >
> 
> 
> -- 
> John Fastabend         Intel Corporation

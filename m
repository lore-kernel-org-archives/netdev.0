From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC] rtnetlink: add new RTM_GETSTATS to dump
 link stats
Date: Wed, 24 Feb 2016 20:59:33 -0800
Message-ID: <56CE8A35.4090503@cumulusnetworks.com>
References: <1456207293-36903-1-git-send-email-roopa@cumulusnetworks.com> <9B0331B6EBBD0E4684FBFAEDA55776F92CB7E894@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>
To: "Rosen, Rami" <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:32866 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758564AbcBYE7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 23:59:35 -0500
Received: by mail-pf0-f178.google.com with SMTP id q63so25930405pfb.0
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 20:59:35 -0800 (PST)
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F92CB7E894@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/23/16, 1:26 AM, Rosen, Rami wrote:
> Hi,
>
> +	if (!dev)
> +		return -ENODEV;
> +
> +	nskb = nlmsg_new(if_nlmsg_stats_size(dev), GFP_KERNEL);
> +	if (!nskb)
> +		return -ENOBUFS;
> +
> +	err = rtnl_fill_statsinfo(nskb, dev, RTM_NEWSTATS,
> +				  NETLINK_CB(skb).portid, nlh->nlmsg_seq, 0, 0);
> +	if (err < 0) {
>
> It should be here:  -EMSGSIZE implies BUG in if_nlmsg_stats_size  (instead of if_nlmsg_size)
>
> +		/* -EMSGSIZE implies BUG in if_nlmsg_size */
> +		WARN_ON(err == -EMSGSIZE);
> +		kfree_skb(nskb);
> +	} else {
> +		err = rtnl_unicast(nskb, net, NETLINK_CB(skb).portid);
> +	}
>
>
> Other than that, it seems ok, thanks for this patch!
>
>
will fix it, thanks for the review.

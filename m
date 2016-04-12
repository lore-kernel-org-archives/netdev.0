From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Tue, 12 Apr 2016 15:21:51 +0200
Message-ID: <20160412132151.GA16560@pox.localdomain>
References: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com>
 <20160410081650.GB22873@pox.localdomain>
 <570A9B4D.80104@cumulusnetworks.com>
 <570C7133.8070109@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36286 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933794AbcDLNVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 09:21:54 -0400
Received: by mail-wm0-f45.google.com with SMTP id v188so126948305wme.1
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 06:21:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <570C7133.8070109@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/16 at 08:53pm, roopa wrote:
> Top level stats attributes can be netdev or global attributes: We can include string "LINK" in
> the names of all stats belonging to a netdev to make it easier to recognize the netdev stats (example):
>  IFLA_STATS_LINK64,           (netdev)
>  IFLA_STATS_LINK_INET6,    (netdev)
>  IFLA_STATS_TCP,                (non-netdev, global tcp stats)

This is fine as well. It means that we cant mix netdev and non-netdev
stats or stats for multiple netdevs in the same request which would
not be the case if you nest it and have a top level attribute which
is a list of requests. That may be borderline to overengineering
though so I'm fine this as well.

> We will need a field in netlink_callback to indicate global or netdev stats when the stats
> crosses skb boundaries. A single nlmsg cannot have both netdev and global stats.

I would treat each IFLA_STATS_ as its own nlmsg in the reply and
enforce an NLM_F_DUMP request for any multi request message.

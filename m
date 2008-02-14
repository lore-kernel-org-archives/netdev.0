From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: Network namespace and tc?
Date: Thu, 14 Feb 2008 11:07:50 +0300
Message-ID: <1202976470.7894.8.camel@iris.sw.ru>
References: <20080213155903.4ab6e454@extreme>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19062 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752845AbYBNIKt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 03:10:49 -0500
In-Reply-To: <20080213155903.4ab6e454@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Stephen!

Namespaces are not fully implemented yet :) Right now we we have only
basic infrastructure in the mainstream and, currently, we can't even run
TCP in different namespace :( We hope this will be changed very soon.

These marks (net != &init_net) are used to
- mark places we need to modify
- ensure that we do not break initial namespace.

Regards,
	Den

On Wed, 2008-02-13 at 15:59 -0800, Stephen Hemminger wrote:
> It looks like tc filter won't work on alternate namespaces:
> /* Add/change/delete/get a filter node */
> 
> static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
> {
> ...
> 
> 	if (net != &init_net)
> 		return -EINVAL;
> 
> 
> Haven't played with namespace virtualization yet, but what else is
> not supported?  Where is this documented?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


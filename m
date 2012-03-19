From: Joe Perches <joe@perches.com>
Subject: Re: Improve rds_sendmsg printk
Date: Mon, 19 Mar 2012 16:08:25 -0700
Message-ID: <1332198505.7847.5.camel@joe2Laptop>
References: <20120319224008.GA23036@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: venkat.x.venkatsubra@oracle.com, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38907 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758465Ab2CSXI1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 19:08:27 -0400
In-Reply-To: <20120319224008.GA23036@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-03-19 at 18:40 -0400, Dave Jones wrote:
> - Given this can be called by any user, prevent them from flooding
>   the logs by using printk_ratelimited
> - Also add a rds: prefix, so it's clear where the message is coming from.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>
> 
> --- linux/net/rds/send.c	2011-11-07 12:00:32.000000000 -0500
> +++ linux/net/rds/send.c	2012-03-19 18:36:21.804991923 -0400
> @@ -935,7 +935,7 @@ int rds_sendmsg(struct kiocb *iocb, stru
>  	/* Mirror Linux UDP mirror of BSD error message compatibility */
>  	/* XXX: Perhaps MSG_MORE someday */
>  	if (msg->msg_flags & ~(MSG_DONTWAIT | MSG_CMSG_COMPAT)) {
> -		printk(KERN_INFO "msg_flags 0x%08X\n", msg->msg_flags);
> +		printk_ratelimited(KERN_INFO "rds: msg_flags 0x%08X\n", msg->msg_flags);

It might be better to use net_ratelimit
for all the rds printk_ratelimited calls.

That's a bit more standardized across net/

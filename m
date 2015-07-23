From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] bridge: stp: when using userspace stp stop kernel
 hello and hold timers
Date: Thu, 23 Jul 2015 09:59:45 -0700
Message-ID: <20150723095945.2b4dd59e@urahara>
References: <1437667657-16954-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, Satish Ashok <sashok@cumulusnetworks.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33496 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753845AbbGWQ7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 12:59:41 -0400
Received: by padck2 with SMTP id ck2so160008050pad.0
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 09:59:40 -0700 (PDT)
In-Reply-To: <1437667657-16954-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jul 2015 09:07:37 -0700
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> +		/* Stop hello and hold timer */
> +		spin_lock_bh(&br->lock);
> +		del_timer(&br->hello_timer);
> +		list_for_each_entry(p, &br->port_list, list)
> +			del_timer(&p->hold_timer);
> +		spin_unlock_bh(&br->lock);

Wouldn't it be easier to use del_timer_sync here?

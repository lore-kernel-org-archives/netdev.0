From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6 v2] net: factorize sync-rcu call in
 unregister_netdevice_many
Date: Mon, 13 Dec 2010 15:32:59 -0800
Message-ID: <20101213153259.1bfedb15@nehalam>
References: <1292277293-6565-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55299 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755758Ab0LMXdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 18:33:07 -0500
In-Reply-To: <1292277293-6565-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Dec 2010 23:54:53 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> +		/*
> +		 *	Tell people we are going down, so that they can
> +		 *	prepare to death, when device is still operating.
> +		 */
> +		call_netdevice_notifiers(NETDEV_GOING_DOWN, dev);

Never liked the repeated notifier. It was a dumb idea, there is
no reason to believe that repeatedly whacking a notifier is going
to make device get released.

-- 

From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] Scm: Remove unnecessary pid & credential references in
 Unix socket's send and receive path
Date: Mon, 22 Aug 2011 17:40:13 -0700 (PDT)
Message-ID: <20110822.174013.353730308624819543.davem@davemloft.net>
References: <1313625374.2576.2908.camel@schen9-DESK>
	<20110818.220432.1711182086933489213.davem@davemloft.net>
	<1313772298.2576.2916.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, viro@zeniv.linux.org.uk,
	ebiederm@xmission.com, ak@linux.intel.com,
	matt.fleming@linux.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: tim.c.chen@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60660 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183Ab1HWAkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 20:40:16 -0400
In-Reply-To: <1313772298.2576.2916.camel@schen9-DESK>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Fri, 19 Aug 2011 09:44:58 -0700

> -		/* Only send the fds in the first buffer */
> -		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent);
> +		/* Only send the fds and no ref to pid in the first buffer */
> +		if (fds_sent)
> +			err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, true);
> +		else
> +			err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, false);

Just set this final boolean the way the third argument is, there is no
reason to replicate the entire function call twice just to set the
final argument to what "fds_sent" evaluates to as a boolean.

		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, fds_sent);

ought to suffice.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netlink: Fix handling of error from netlink_dump().
Date: Wed, 09 Jul 2014 14:34:07 -0700 (PDT)
Message-ID: <20140709.143407.1195581161703049798.davem@davemloft.net>
References: <1404927082-8647-1-git-send-email-blp@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: blp@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbaGIVeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 17:34:08 -0400
In-Reply-To: <1404927082-8647-1-git-send-email-blp@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Pfaff <blp@nicira.com>
Date: Wed,  9 Jul 2014 10:31:22 -0700

> netlink_dump() returns a negative errno value on error.  Until now,
> netlink_recvmsg() directly recorded that negative value in sk->sk_err, but
> that's wrong since sk_err takes positive errno values.  (This manifests as
> userspace receiving a positive return value from the recv() system call,
> falsely indicating success.) This bug was introduced in the commit that
> started checking the netlink_dump() return value, commit b44d211 (netlink:
> handle errors from netlink_dump()).
> 
> Multithreaded Netlink dumps are one way to trigger this behavior in
> practice, as described in the commit message for the userspace workaround
> posted here:
>     http://openvswitch.org/pipermail/dev/2014-June/042339.html
> 
> This commit also fixes the same bug in netlink_poll(), introduced in commit
> cd1df525d (netlink: add flow control for memory mapped I/O).
> 
> Signed-off-by: Ben Pfaff <blp@nicira.com>
> ---
> v1->v2: Fix same bug in another place, as requested by Dave Miller.

Applied, thank you.

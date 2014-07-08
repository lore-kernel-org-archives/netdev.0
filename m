From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: Fix netlink_recvmsg() handling of error from
 netlink_dump().
Date: Mon, 07 Jul 2014 19:37:35 -0700 (PDT)
Message-ID: <20140707.193735.766947638929765410.davem@davemloft.net>
References: <1404167704-22408-1-git-send-email-blp@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: blp@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48369 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbaGHChg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 22:37:36 -0400
In-Reply-To: <1404167704-22408-1-git-send-email-blp@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Pfaff <blp@nicira.com>
Date: Mon, 30 Jun 2014 15:35:04 -0700

> netlink_dump() returns a negative errno value on error.  Until now,
> netlink_recvmsg() directly recorded that negative value in sk->sk_err,
> but that's wrong since sk_err takes positive errno values.  (This manifests
> as userspace receiving a positive return value from the recv() system call,
> falsely indicating success.)
> 
> This bug was introduced in the commit that started checking the
> netlink_dump() return value, commit b44d211 (netlink: handle errors from
> netlink_dump()).
> 
> Multithreaded Netlink dumps are one way to trigger this behavior in
> practice, as described in the commit message for the userspace workaround
> posted here:
>     http://openvswitch.org/pipermail/dev/2014-June/042339.html
> 
> Signed-off-by: Ben Pfaff <blp@nicira.com>

There's another place, later in this file, doing the same exact thing.

Please respin this patch, fixing that location too.

Thanks.

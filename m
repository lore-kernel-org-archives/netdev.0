From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnl: Add support for netdev event to link
 messages
Date: Mon, 27 Mar 2017 15:58:35 -0700 (PDT)
Message-ID: <20170327.155835.1930829109806331326.davem@davemloft.net>
References: <1490493587-25819-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52762 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752972AbdC0W73 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 18:59:29 -0400
In-Reply-To: <1490493587-25819-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Sat, 25 Mar 2017 21:59:47 -0400

> RTNL currently generates notifications on some netdev notifier events.
> However, user space has no idea what changed.  All it sees is the
> data and has to infer what has changed.  For some events that is not
> possible.
> 
> This patch adds a new field to RTM_NEWLINK message called IFLA_EVENT
> that would have an encoding of the which event triggered this
> notification.  Currectly, only 2 events (NETDEV_NOTIFY_PEERS and
> NETDEV_MTUCHANGED) are supported.  These events could be interesting
> in the virt space to trigger additional configuration commands to VMs.
> Other events of interest may be added later.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

At what point do we start providing the metadata for the changed
values as well?  You'd probably need to provide both the old and
new values to cover all cases.

> @@ -4044,6 +4076,7 @@ static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
>  	return skb->len;
>  }
>  
> +
>  /* Process one rtnetlink message. */
>  
>  static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)

Please don't add more empty lines between functions, one is enough.

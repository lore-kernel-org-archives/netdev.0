From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH 3/6] netpoll: Don't allow on devices that perform their
 own xmit locking
Date: Tue, 18 Mar 2014 11:26:54 -0700
Message-ID: <CAHA+R7OhTQGmi+0NyWZqC+qmp_SQWAipe=+n1YjvhaHqkv31yw@mail.gmail.com>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com>
	<877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com>
	<87wqfsf2fk.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>, mpm@selenic.com,
	satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:46638 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757308AbaCRS04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 14:26:56 -0400
Received: by mail-lb0-f180.google.com with SMTP id 10so4999058lbg.39
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 11:26:54 -0700 (PDT)
In-Reply-To: <87wqfsf2fk.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 11:25 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> There are strong and reasonable assumptions in the netpoll code that the
> transmit code for network devices will not perform their own locking,
> that can easily lead to deadlock if the assumptions are violated.
>
> Document those assumptions by verifying the network device on which
> netpoll is enabled does not have NETIF_F_LLTX set in netdev->features.
>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  net/core/netpoll.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 825200fcb0ff..a9abb195a2c3 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -606,6 +606,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
>         INIT_WORK(&np->cleanup_work, netpoll_async_cleanup);
>
>         if ((ndev->priv_flags & IFF_DISABLE_NETPOLL) ||
> +           (ndev->features & NETIF_F_LLTX) ||
>             !ndev->netdev_ops->ndo_poll_controller) {
>                 np_err(np, "%s doesn't support polling, aborting\n",
>                        np->dev_name);

Hmm? This basically disables netpoll on a lots of devices, such as vlan.

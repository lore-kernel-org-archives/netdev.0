From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] rtnetlink: release net refcnt on error in do_setlink()
Date: Thu, 27 Nov 2014 09:48:39 -0600
Message-ID: <871toozlt4.fsf@x220.int.ebiederm.org>
References: <1417079775-9287-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52953 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830AbaK0Pt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 10:49:57 -0500
In-Reply-To: <1417079775-9287-1-git-send-email-nicolas.dichtel@6wind.com>
	(Nicolas Dichtel's message of "Thu, 27 Nov 2014 10:16:15 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> rtnl_link_get_net() holds a reference on the 'struct net', we need to release
> it in case of error.
>
> CC: Eric W. Biederman <ebiederm@xmission.com>
> Fixes: b51642f6d77b ("net: Enable a userns root rtnl calls that are safe for unprivilged users")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Doh!
Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>

> ---
>  net/core/rtnetlink.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index b9b7dfaf202b..76321ea442c3 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1498,6 +1498,7 @@ static int do_setlink(const struct sk_buff *skb,
>  			goto errout;
>  		}
>  		if (!netlink_ns_capable(skb, net->user_ns, CAP_NET_ADMIN)) {
> +			put_net(net);
>  			err = -EPERM;
>  			goto errout;
>  		}

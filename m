From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH stable 3.11] sit: amend "allow to use rtnl ops on fb
 tunnel"
Date: Tue, 22 Oct 2013 17:56:27 +0200
Message-ID: <20131022155627.GD25497@redhat.com>
References: <1382453958-32376-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	nicolas.dichtel@6wind.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40816 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753404Ab3JVP6l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 11:58:41 -0400
Content-Disposition: inline
In-Reply-To: <1382453958-32376-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 22, 2013 at 10:59:18AM -0400, Willem de Bruijn wrote:
>Amend backport to 3.11.y of
>
> [ Upstream commit 205983c43700ac3a81e7625273a3fa83cd2759b5 ]
>
>The discussion thread in the upstream commit mentions that in
>backports to stable-* branches, the line
>
>  - unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
>
>must be omitted if that branch does not have commit 5e6700b3bf98
>("sit: add support of x-netns"). This line has correctly been omitted
>in the backport to 3.10, which indeed does not have that commit.
>
>It was also removed in the backport to 3.11.y, which does have that
>commit.
>
>This causes the following steps to hit a BUG at net/core/dev.c:5039:
>
>  `modprobe sit; rmmod sit`
>
>The bug demonstrates that it causes a device to be unregistered twice.
>The simple fix is to apply the one line in the upstream commit that
>was dropped in the backport to 3.11 (3783100374653e2e7fbdf68c710f5).
>This brings the logic in line with upstream linux, net and net-next
>branches.

Also seen that in stable, fixes it for me.

FWIW...

Reviewed-by: Veaceslav Falico <vfalico@redhat.com>

>
>Signed-off-by: Willem de Bruijn <willemb@google.com>
>
>---
>
>The policy for networking patches is to queue stable patches up for
>the davem/stable queue.
>
>Since this patch only applies to one specific branch, I assumed
>that creating it directly against 3.11.y is the right process. I
>did *not* directly cc: the stable list. David, please let me know
>if this should not go through your queue at all and I should
>resubmit to stable.
>---
> net/ipv6/sit.c | 1 -
> 1 file changed, 1 deletion(-)
>
>diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
>index 86f639b..a51ad07 100644
>--- a/net/ipv6/sit.c
>+++ b/net/ipv6/sit.c
>@@ -1708,7 +1708,6 @@ static void __net_exit sit_exit_net(struct net *net)
>
> 	rtnl_lock();
> 	sit_destroy_tunnels(sitn, &list);
>-	unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
> 	unregister_netdevice_many(&list);
> 	rtnl_unlock();
> }
>-- 
>1.8.4
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

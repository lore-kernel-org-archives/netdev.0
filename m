From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [Patch net-next] audit: remove useless synchronize_net()
Date: Wed, 30 Nov 2016 04:16:43 -0500
Message-ID: <20161130091643.GA32562@madcap2.tricolour.ca>
References: <1480439696-21818-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-audit@redhat.com, pmoore@redhat.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33542 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757646AbcK3JQr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 04:16:47 -0500
Content-Disposition: inline
In-Reply-To: <1480439696-21818-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-11-29 09:14, Cong Wang wrote:
> netlink kernel socket is protected by refcount, not RCU.
> Its rcv path is neither protected by RCU. So the synchronize_net()
> is just pointless.

If I understand correctly, xfrm_user_net_exit() usage of
RCU_INIT_POINTER() and synchronize_net() is similarly pointless?  Also
net/phonet/socket.c?  I probably modelled things based on the former...

> Cc: Richard Guy Briggs <rgb@redhat.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  kernel/audit.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/kernel/audit.c b/kernel/audit.c
> index 92c463d..67b9fbd8 100644
> --- a/kernel/audit.c
> +++ b/kernel/audit.c
> @@ -1172,9 +1172,8 @@ static void __net_exit audit_net_exit(struct net *net)
>  		audit_sock = NULL;
>  	}
>  
> -	RCU_INIT_POINTER(aunet->nlsk, NULL);
> -	synchronize_net();
>  	netlink_kernel_release(sock);
> +	aunet->nlsk = NULL;
>  }
>  
>  static struct pernet_operations audit_net_ops __net_initdata = {
> -- 
> 2.1.0
> 

- RGB

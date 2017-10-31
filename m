From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net-next] ppp: Destroy the mutex when cleanup
Date: Tue, 31 Oct 2017 16:48:49 +0100
Message-ID: <20171031154849.nzi2rtx33iteyhbj@alphalink.fr>
References: <1509445537-39319-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulus@samba.org, davem@davemloft.net, linux-ppp@vger.kernel.org,
        netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:34523 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751524AbdJaPsy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 11:48:54 -0400
Content-Disposition: inline
In-Reply-To: <1509445537-39319-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 06:25:37PM +0800, gfree.wind@vip.163.com wrote:
> From: Gao Feng <gfree.wind@vip.163.com>
> 
> The mutex_destroy only makes sense when enable DEBUG_MUTEX. For the
> good readbility, it's better to invoke it in exit func when the init
> func invokes mutex_init.
> 
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
> ---
>  drivers/net/ppp/ppp_generic.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
> index af7f93e..4489133 100644
> --- a/drivers/net/ppp/ppp_generic.c
> +++ b/drivers/net/ppp/ppp_generic.c
> @@ -960,6 +960,7 @@ static __net_exit void ppp_exit_net(struct net *net)
>  	unregister_netdevice_many(&list);
>  	rtnl_unlock();
>  
> +	mutex_destroy(&pn->all_ppp_mutex);
>  	idr_destroy(&pn->units_idr);
>  }
>  

Acked-by: Guillaume Nault <g.nault@alphalink.fr>

Thanks!

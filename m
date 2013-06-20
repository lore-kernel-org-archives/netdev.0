From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/8] vxlan: Fix error handling while creating
 device.
Date: Thu, 20 Jun 2013 08:47:48 -0700
Message-ID: <20130620084748.2c79809f@nehalam.linuxnetplumber.net>
References: <1371713185-8076-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:54596 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758090Ab3FTPrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 11:47:51 -0400
Received: by mail-pa0-f53.google.com with SMTP id tj12so6451247pac.12
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 08:47:51 -0700 (PDT)
In-Reply-To: <1371713185-8076-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Jun 2013 00:26:25 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> Delete vxlan-sock list entry from list before freeing the memory.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  drivers/net/vxlan.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 284c6c0..173705f 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1606,9 +1606,11 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
>  	err = register_netdevice(dev);
>  	if (err) {
>  		if (--vs->refcnt == 0) {
> +			hlist_del_rcu(&vs->hlist);
>  			rtnl_unlock();
> +
>  			sk_release_kernel(vs->sock->sk);
> -			kfree(vs);
> +			kfree_rcu(vs, rcu);
>  			rtnl_lock();
>  		}
>  		return err;

This will not be necessary with my next patch set, that code all changes.

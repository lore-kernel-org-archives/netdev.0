From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net:  Resend IGMP memberships upon peer notification.
Date: Tue, 14 Mar 2017 18:36:22 +0200
Message-ID: <20170314183318-mutt-send-email-mst@kernel.org>
References: <1489496288-24139-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jasowang@redhat.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38012 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751211AbdCNQgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 12:36:25 -0400
Content-Disposition: inline
In-Reply-To: <1489496288-24139-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 08:58:08AM -0400, Vladislav Yasevich wrote:
> When we notify peers of potential changes,  it's also good to update
> IGMP memberships.  For example, during VM migration, updating IGMP
> memberships will redirect existing multicast streams to the VM at the
> new location.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Seems to make sense

Acked-by: Michael S. Tsirkin <mst@redhat.com>

but I also think there's another problem: source does not
leave the groups on migration. So I think we should add code on the
host - it's snooping IGMPs so it should be able to leave groups on the
source when VM is disconnected.



> ---
>  net/core/dev.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a229bf0..1ed927d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1272,6 +1272,7 @@ void netdev_notify_peers(struct net_device *dev)
>  {
>  	rtnl_lock();
>  	call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, dev);
> +	call_netdevice_notifiers(NETDEV_RESEND_IGMP, dev);
>  	rtnl_unlock();
>  }
>  EXPORT_SYMBOL(netdev_notify_peers);
> -- 
> 2.7.4

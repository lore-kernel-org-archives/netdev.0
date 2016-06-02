From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 1/2] net: Add function to allow configuration of RPS
Date: Wed, 1 Jun 2016 18:23:07 -0700
Message-ID: <CAKgT0UdXqzAPWwtn7z=2LEaiKvPNEjpd++MwNvytpqfUSQZoeg@mail.gmail.com>
References: <20160602010741.9319.56926.stgit@localhost.localdomain>
	<20160602011718.9319.31286.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33740 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbcFBBXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 21:23:08 -0400
Received: by mail-it0-f65.google.com with SMTP id v125so980972itc.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 18:23:08 -0700 (PDT)
In-Reply-To: <20160602011718.9319.31286.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 1, 2016 at 6:17 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch gives drivers the ability to set their own default RPS
> configuration.  The general idea is to allow drivers that might benefit
> from enabling RPS an opportunity to configure it for themselves.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
>  include/linux/netdevice.h |    9 ++++++++
>  net/core/dev.c            |   51 ++++++++++++++++++++++++++++++++++++++++++++-
>  net/core/net-sysfs.c      |   45 +++++++---------------------------------
>  3 files changed, 67 insertions(+), 38 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index f45929ce8157..329d554c9219 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -684,6 +684,15 @@ static inline void rps_record_sock_flow(struct rps_sock_flow_table *table,
>  bool rps_may_expire_flow(struct net_device *dev, u16 rxq_index, u32 flow_id,
>                          u16 filter_id);
>  #endif
> +int netif_set_rps_cpus(struct net_device *dev, const struct cpumask *mask,
> +                      u16 index);
> +#else
> +static inline int netif_set_rps_cpus(struct net_device *dev,
> +                                    const struct cpumask *mask,
> +                                    u16 index)
> +{
> +       return 0;
> +}
>  #endif /* CONFIG_RPS */
>
>  /* This structure contains an instance of an RX queue. */
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 904ff431d570..efdcc917cf02 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1934,7 +1934,7 @@ static void netif_setup_tc(struct net_device *dev, unsigned int txq)
>                 return;
>         }
>
> -       /* Invalidated prio to tc mappings set to TC0 */
> +       /* Invaldated prio to tc mappings set to TC0 */
>         for (i = 1; i < TC_BITMASK + 1; i++) {
>                 int q = netdev_get_prio_tc_map(dev, i);
>

I just noticed that I fat fingered this when doing some last edits on
the patch.  So I will be submitting a v2.

For now I will leave this out here for review, and I will wait to see
if there are any other changes needed after others have had a chance
to look over the rest of this patch set.

- Alex

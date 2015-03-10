From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] switchdev: add netlink flags to IPv4 FIB add op
Date: Mon, 9 Mar 2015 19:27:46 -0700
Message-ID: <CAJieiUgE7zwrBJY7zft6aS93uX7ijLF-H9wDjg2zu_Kgrsgq3w@mail.gmail.com>
References: <1425934749-18567-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:41771 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbbCJC1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 22:27:46 -0400
Received: by pdjy10 with SMTP id y10so29582562pdj.8
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 19:27:46 -0700 (PDT)
In-Reply-To: <1425934749-18567-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 9, 2015 at 1:59 PM,  <sfeldma@gmail.com> wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Pass in the netlink flags (NLM_F_*) into switchdev driver for IPv4 FIB add op
> to allow driver to 1) optimize hardware updates, 2) handle ip route prepend
> and append commands correctly.
>
> Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Suggested-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

>  drivers/net/ethernet/rocker/rocker.c |    3 ++-
>  include/linux/netdevice.h            |    3 ++-
>  include/net/switchdev.h              |    6 ++++--
>  net/ipv4/fib_trie.c                  |    5 ++++-
>  net/switchdev/switchdev.c            |    7 +++++--
>  5 files changed, 17 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index 65e1403..223348d 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -4152,7 +4152,8 @@ static int rocker_port_switch_port_stp_update(struct net_device *dev, u8 state)
>  static int rocker_port_switch_fib_ipv4_add(struct net_device *dev,
>                                            __be32 dst, int dst_len,
>                                            struct fib_info *fi,
> -                                          u8 tos, u8 type, u32 tb_id)
> +                                          u8 tos, u8 type,
> +                                          u32 nlflags, u32 tb_id)
>  {
>         struct rocker_port *rocker_port = netdev_priv(dev);
>         int flags = 0;
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 4541378..1354ae8 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1035,7 +1035,7 @@ struct fib_info;
>   *     state change.
>   * int (*ndo_sw_parent_fib_ipv4_add)(struct net_device *dev, __be32 dst,
>   *                                  int dst_len, struct fib_info *fi,
> - *                                  u8 tos, u8 type, u32 tb_id);
> + *                                  u8 tos, u8 type, u32 nlflags, u32 tb_id);
>   *     Called to add/modify IPv4 route to switch device.
>   * int (*ndo_sw_parent_fib_ipv4_del)(struct net_device *dev, __be32 dst,
>   *                                  int dst_len, struct fib_info *fi,
> @@ -1207,6 +1207,7 @@ struct net_device_ops {
>                                                            int dst_len,
>                                                            struct fib_info *fi,
>                                                            u8 tos, u8 type,
> +                                                          u32 nlflags,
>                                                            u32 tb_id);
>         int                     (*ndo_switch_fib_ipv4_del)(struct net_device *dev,
>                                                            __be32 dst,
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index 933fac4..1a9382f 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -1,6 +1,7 @@
>  /*
>   * include/net/switchdev.h - Switch device API
>   * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
> + * Copyright (c) 2014-2015 Scott Feldman <sfeldma@gmail.com>
>   *
>   * This program is free software; you can redistribute it and/or modify
>   * it under the terms of the GNU General Public License as published by
> @@ -52,7 +53,7 @@ int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
>  int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
>                                                struct nlmsghdr *nlh, u16 flags);
>  int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
> -                              u8 tos, u8 type, u32 tb_id);
> +                              u8 tos, u8 type, u32 nlflags, u32 tb_id);
>  int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
>                                u8 tos, u8 type, u32 tb_id);
>  void netdev_switch_fib_ipv4_abort(struct fib_info *fi);
> @@ -117,7 +118,8 @@ static inline int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *
>
>  static inline int netdev_switch_fib_ipv4_add(u32 dst, int dst_len,
>                                              struct fib_info *fi,
> -                                            u8 tos, u8 type, u32 tb_id)
> +                                            u8 tos, u8 type,
> +                                            u32 nlflags, u32 tb_id)
>  {
>         return 0;
>  }
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index 9095545..fcfa982 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -1155,6 +1155,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>                         err = netdev_switch_fib_ipv4_add(key, plen, fi,
>                                                          new_fa->fa_tos,
>                                                          cfg->fc_type,
> +                                                        cfg->fc_nlflags,
>                                                          tb->tb_id);
>                         if (err) {
>                                 netdev_switch_fib_ipv4_abort(fi);
> @@ -1201,7 +1202,9 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>
>         /* (Optionally) offload fib entry to switch hardware. */
>         err = netdev_switch_fib_ipv4_add(key, plen, fi, tos,
> -                                        cfg->fc_type, tb->tb_id);
> +                                        cfg->fc_type,
> +                                        cfg->fc_nlflags,
> +                                        tb->tb_id);
>         if (err) {
>                 netdev_switch_fib_ipv4_abort(fi);
>                 goto out_free_new_fa;
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 19e4e72..c9f6200 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -1,6 +1,7 @@
>  /*
>   * net/switchdev/switchdev.c - Switch device API
>   * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
> + * Copyright (c) 2014-2015 Scott Feldman <sfeldma@gmail.com>
>   *
>   * This program is free software; you can redistribute it and/or modify
>   * it under the terms of the GNU General Public License as published by
> @@ -294,12 +295,13 @@ static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
>   *     @fi: route FIB info structure
>   *     @tos: route TOS
>   *     @type: route type
> + *     @nlflags: netlink flags passed in (NLM_F_*)
>   *     @tb_id: route table ID
>   *
>   *     Add IPv4 route entry to switch device.
>   */
>  int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
> -                              u8 tos, u8 type, u32 tb_id)
> +                              u8 tos, u8 type, u32 nlflags, u32 tb_id)
>  {
>         struct net_device *dev;
>         const struct net_device_ops *ops;
> @@ -324,7 +326,8 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
>
>         if (ops->ndo_switch_fib_ipv4_add) {
>                 err = ops->ndo_switch_fib_ipv4_add(dev, htonl(dst), dst_len,
> -                                                  fi, tos, type, tb_id);
> +                                                  fi, tos, type, nlflags,
> +                                                  tb_id);
>                 if (!err)
>                         fi->fib_flags |= RTNH_F_EXTERNAL;
>         }
> --
> 1.7.10.4
>

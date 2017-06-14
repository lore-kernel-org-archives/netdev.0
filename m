From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next,v2] openvswitch: add macro MODULE_ALIAS_VPORT_TYPE for
 vport type alias
Date: Wed, 14 Jun 2017 13:43:09 -0700
Message-ID: <CAOrHB_C9B138Y38QBZTiYN8kwxFh2+=GyGix00Dp75jA01fbcA@mail.gmail.com>
References: <1497337257-2533-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Pravin Shelar <pshelar@nicira.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:50126 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752080AbdFNUnN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 16:43:13 -0400
Received: from mfilter11-d.gandi.net (mfilter11-d.gandi.net [217.70.178.131])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id EE3ADFB87E
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 22:43:11 +0200 (CEST)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter11-d.gandi.net (mfilter11-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id IWj1hXR_gh2U for <netdev@vger.kernel.org>;
        Wed, 14 Jun 2017 22:43:10 +0200 (CEST)
Received: from mail-wr0-f177.google.com (mail-wr0-f177.google.com [209.85.128.177])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 8E729FB8B8
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 22:43:10 +0200 (CEST)
Received: by mail-wr0-f177.google.com with SMTP id q97so16644209wrb.2
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 13:43:10 -0700 (PDT)
In-Reply-To: <1497337257-2533-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 13, 2017 at 12:00 AM, Zhang Shengju
<zhangshengju@cmss.chinamobile.com> wrote:
> Add a new macro MODULE_ALIAS_VPORT_TYPE to unify and simplify the
> declaration of vport type alias.
>
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  net/openvswitch/vport-geneve.c | 2 +-
>  net/openvswitch/vport-gre.c    | 2 +-
>  net/openvswitch/vport-vxlan.c  | 2 +-
>  net/openvswitch/vport.h        | 3 +++
>  4 files changed, 6 insertions(+), 3 deletions(-)
>
The change looks fine. But I do not see value in it. This is compat
tunnel code, there should not be any more vports added to OVS. So
adding this new API does not help for future code changes either.


> diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
> index 5aaf3ba..0ebf023 100644
> --- a/net/openvswitch/vport-geneve.c
> +++ b/net/openvswitch/vport-geneve.c
> @@ -141,4 +141,4 @@ static void __exit ovs_geneve_tnl_exit(void)
>
>  MODULE_DESCRIPTION("OVS: Geneve switching port");
>  MODULE_LICENSE("GPL");
> -MODULE_ALIAS("vport-type-5");
> +MODULE_ALIAS_VPORT_TYPE(5);
> diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
> index 0e72d95..97fc4d5 100644
> --- a/net/openvswitch/vport-gre.c
> +++ b/net/openvswitch/vport-gre.c
> @@ -113,4 +113,4 @@ static void __exit ovs_gre_tnl_exit(void)
>
>  MODULE_DESCRIPTION("OVS: GRE switching port");
>  MODULE_LICENSE("GPL");
> -MODULE_ALIAS("vport-type-3");
> +MODULE_ALIAS_VPORT_TYPE(3);
> diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
> index 869acb3..0375b6a 100644
> --- a/net/openvswitch/vport-vxlan.c
> +++ b/net/openvswitch/vport-vxlan.c
> @@ -179,4 +179,4 @@ static void __exit ovs_vxlan_tnl_exit(void)
>
>  MODULE_DESCRIPTION("OVS: VXLAN switching port");
>  MODULE_LICENSE("GPL");
> -MODULE_ALIAS("vport-type-4");
> +MODULE_ALIAS_VPORT_TYPE(4);
> diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
> index cda66c2..1d1584f 100644
> --- a/net/openvswitch/vport.h
> +++ b/net/openvswitch/vport.h
> @@ -199,4 +199,7 @@ static inline const char *ovs_vport_name(struct vport *vport)
>  void ovs_vport_ops_unregister(struct vport_ops *ops);
>  void ovs_vport_send(struct vport *vport, struct sk_buff *skb, u8 mac_proto);
>
> +#define MODULE_ALIAS_VPORT_TYPE(type) \
> +       MODULE_ALIAS("vport-type-" __stringify(type))
> +
>  #endif /* vport.h */
> --
> 1.8.3.1
>
>
>

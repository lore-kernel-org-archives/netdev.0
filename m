From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next] openvswitch: add macro MODULE_ALIAS_VPORT_TYPE for
 vport type alias
Date: Sat, 3 Jun 2017 22:58:22 -0700
Message-ID: <CAOrHB_CjkyEoWVJFT5Q+vPOvcg4rd9cY+z5gRi7JEQscG6-dNg@mail.gmail.com>
References: <1496497655-24810-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Pravin Shelar <pshelar@nicira.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:34866 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750852AbdFDF61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 01:58:27 -0400
Received: from mfilter17-d.gandi.net (mfilter17-d.gandi.net [217.70.178.145])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 15ACF1720A4
        for <netdev@vger.kernel.org>; Sun,  4 Jun 2017 07:58:25 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter17-d.gandi.net (mfilter17-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id v4542t9yKjcE for <netdev@vger.kernel.org>;
        Sun,  4 Jun 2017 07:58:23 +0200 (CEST)
Received: from mail-wr0-f176.google.com (mail-wr0-f176.google.com [209.85.128.176])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id A7E4017209D
        for <netdev@vger.kernel.org>; Sun,  4 Jun 2017 07:58:23 +0200 (CEST)
Received: by mail-wr0-f176.google.com with SMTP id v111so17115347wrc.3
        for <netdev@vger.kernel.org>; Sat, 03 Jun 2017 22:58:23 -0700 (PDT)
In-Reply-To: <1496497655-24810-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 3, 2017 at 6:47 AM, Zhang Shengju
<zhangshengju@cmss.chinamobile.com> wrote:
> Add a new macro MODULE_ALIAS_VPORT_TYPE to unify and simplify the
> declaration of vport type alias, and replace magic numbers with
> symbolic constants.
>
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  net/openvswitch/vport-geneve.c | 2 +-
>  net/openvswitch/vport-gre.c    | 2 +-
>  net/openvswitch/vport-vxlan.c  | 2 +-
>  net/openvswitch/vport.h        | 3 +++
>  4 files changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
> index 5aaf3ba..1c068d6 100644
> --- a/net/openvswitch/vport-geneve.c
> +++ b/net/openvswitch/vport-geneve.c
> @@ -141,4 +141,4 @@ static void __exit ovs_geneve_tnl_exit(void)
>
>  MODULE_DESCRIPTION("OVS: Geneve switching port");
>  MODULE_LICENSE("GPL");
> -MODULE_ALIAS("vport-type-5");
> +MODULE_ALIAS_VPORT_TYPE(OVS_VPORT_TYPE_GENEVE);
> diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
> index 0e72d95..48a5852 100644
> --- a/net/openvswitch/vport-gre.c
> +++ b/net/openvswitch/vport-gre.c
> @@ -113,4 +113,4 @@ static void __exit ovs_gre_tnl_exit(void)
>
>  MODULE_DESCRIPTION("OVS: GRE switching port");
>  MODULE_LICENSE("GPL");
> -MODULE_ALIAS("vport-type-3");
> +MODULE_ALIAS_VPORT_TYPE(OVS_VPORT_TYPE_GRE);

This is user visible change. For example this is changing the gre
module alias from "vport-type-3" to "vport-type-OVS_VPORT_TYPE_GRE".
This could break userspace application.

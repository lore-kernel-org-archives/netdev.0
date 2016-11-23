From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next 1/2] openvswitch: Add a missing break statement.
Date: Wed, 23 Nov 2016 11:23:46 -0800
Message-ID: <CAOrHB_B8Zo59f1i8F1RiobBBf=V5mvC2CJ0uRrmFy1C9_G7Ekw@mail.gmail.com>
References: <1479874174-75329-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:59960 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932754AbcKWTZF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 14:25:05 -0500
Received: from mfilter41-d.gandi.net (mfilter41-d.gandi.net [217.70.178.173])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id 65553A80DC
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 20:23:52 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter41-d.gandi.net (mfilter41-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id hz5PT2jyWBv8 for <netdev@vger.kernel.org>;
        Wed, 23 Nov 2016 20:23:51 +0100 (CET)
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 009DCA80BE
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 20:23:50 +0100 (CET)
Received: by mail-io0-f175.google.com with SMTP id c21so37427513ioj.1
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 11:23:50 -0800 (PST)
In-Reply-To: <1479874174-75329-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 8:09 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
> Add a break statement to prevent fall-through from
> OVS_KEY_ATTR_ETHERNET to OVS_KEY_ATTR_TUNNEL.  Without the break
> actions setting ethernet addresses fail to validate with log messages
> complaining about invalid tunnel attributes.
>
> Fixes: 0a6410fbde ("openvswitch: netlink: support L3 packets")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
>  net/openvswitch/flow_netlink.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index d19044f..c87d359 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -2195,6 +2195,7 @@ static int validate_set(const struct nlattr *a,
>         case OVS_KEY_ATTR_ETHERNET:
>                 if (mac_proto != MAC_PROTO_ETHERNET)
>                         return -EINVAL;
> +               break;
>
>         case OVS_KEY_ATTR_TUNNEL:
>                 if (masked)

Thanks for tracking it down.

Acked-by: Pravin B Shelar <pshelar@ovn.org>

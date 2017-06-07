From: Greg Rose <gvrose8192@gmail.com>
Subject: Re: [PATCH net] net: Zero ifla_vf_info in rtnl_fill_vfinfo()
Date: Wed, 7 Jun 2017 16:10:41 -0700
Message-ID: <8b3edfcb-a278-a847-432e-8fe898cbe6ab@gmail.com>
References: <20170607180033.19747-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michal Schmidt <mschmidt@redhat.com>, davem@davemloft.net,
        netdev@vger.kernel.org
To: Yuval Mintz <yuval.mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36776 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752772AbdFGXKo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 19:10:44 -0400
Received: by mail-pg0-f68.google.com with SMTP id v18so2651078pgb.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 16:10:44 -0700 (PDT)
In-Reply-To: <20170607180033.19747-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2017 11:00 AM, Yuval Mintz wrote:
> Some of the structure's fields are not initialized by the
> rtnetlink. If driver doesn't set those in ndo_get_vf_config(),
> they'd leak memory to user.
>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
> CC: Michal Schmidt <mschmidt@redhat.com>
> ---
>   net/core/rtnetlink.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 9e2c0a7..5e61456 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1124,6 +1124,8 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
>       struct ifla_vf_mac vf_mac;
>       struct ifla_vf_info ivi;
>
> +    memset(&ivi, 0, sizeof(ivi));
> +
>       /* Not all SR-IOV capable drivers support the
>        * spoofcheck and "RSS query enable" query.  Preset to
>        * -1 so the user space tool can detect that the driver
> @@ -1132,7 +1134,6 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
>       ivi.spoofchk = -1;
>       ivi.rss_query_en = -1;
>       ivi.trusted = -1;
> -    memset(ivi.mac, 0, sizeof(ivi.mac));
>       /* The default value for VF link state is "auto"
>        * IFLA_VF_LINK_STATE_AUTO which equals zero
>        */
>
It's been a few years since I worked in this code but I do recall this portion.  Good idea...

Thanks!

Reviewed-by: Greg Rose <gvrose8192@gmail.com>

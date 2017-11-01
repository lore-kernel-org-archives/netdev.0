From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] net: vrf: correct FRA_L3MDEV encode type
Date: Wed, 1 Nov 2017 13:30:58 -0600
Message-ID: <4720426f-065f-bd61-2dad-55ddb6fe18ee@gmail.com>
References: <20171101145809.2362-1-0xeffeff@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Jeff Barnhill <0xeffeff@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:48100 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdKATbF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 15:31:05 -0400
Received: by mail-pf0-f193.google.com with SMTP id z11so2702450pfk.4
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 12:31:05 -0700 (PDT)
In-Reply-To: <20171101145809.2362-1-0xeffeff@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/1/17 8:58 AM, Jeff Barnhill wrote:
> FRA_L3MDEV is defined as U8, but is being added as a U32 attribute. On
> big endian architecture, this results in the l3mdev entry not being
> added to the FIB rules.
> 
> Fixes: 1aa6c4f6b8cd8 ("net: vrf: Add l3mdev rules on first device create")
> Signed-off-by: Jeff Barnhill <0xeffeff@gmail.com>
> ---
>  drivers/net/vrf.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
> index 9b243e6f3008..7dc3bcac3506 100644
> --- a/drivers/net/vrf.c
> +++ b/drivers/net/vrf.c
> @@ -1165,7 +1165,7 @@ static int vrf_fib_rule(const struct net_device *dev, __u8 family, bool add_it)
>  	frh->family = family;
>  	frh->action = FR_ACT_TO_TBL;
>  
> -	if (nla_put_u32(skb, FRA_L3MDEV, 1))
> +	if (nla_put_u8(skb, FRA_L3MDEV, 1))
>  		goto nla_put_failure;
>  
>  	if (nla_put_u32(skb, FRA_PRIORITY, FIB_RULE_PREF))
> 

Acked-by: David Ahern <dsahern@gmail.com>

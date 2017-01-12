From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [Patch] Fixing order of trinary operator when assigning the
 ifindex in XFRM Decode Session
Date: Thu, 12 Jan 2017 13:28:52 -0700
Message-ID: <b6ffee14-c5ef-cec7-344a-331c142ed79c@cumulusnetworks.com>
References: <BY1PR0701MB12228231F8BCD74FC473284A9A790@BY1PR0701MB1222.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "steffen.klassert@secunet.com" <steffen.klassert@secunet.com>
To: "Chacon, Carlos A" <carlos.chacon@gatech.edu>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36234 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbdALU2z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 15:28:55 -0500
Received: by mail-pf0-f181.google.com with SMTP id 189so18287345pfu.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 12:28:54 -0800 (PST)
In-Reply-To: <BY1PR0701MB12228231F8BCD74FC473284A9A790@BY1PR0701MB1222.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Carlos:

patches sent to netdev should be plain text only. Using git send-email would be best.

Also, the Subject line should start with the area affected (e.g., net: xfrm:) and really should be a bit shorter. e.g., something like this:

[PATCH] net: xfrm: fix flow oif in decode_session


On 1/12/17 1:01 PM, Chacon, Carlos A wrote:
> 
> Author: Carlos Chacon <carlos.chacon@gatech.edu>
> Date:   Thu Jan 12 11:42:32 2017 -0800
> 
>     Fixing order of trinary operator when assigning the ifindex in XFRM Decode Session
> 
>     For xfrm4_policy.c:_decode_session4 and xfrm6_policy.c:_decode_session6 the line
>         fl4->flowi4_oif = reverse ? skb->skb_iif : oif;
>         fl6->flowi6_oif = reverse ? skb->skb_iif : oif;
>     is assigning the incorrect oif to the flow_oif. It should read:
>         reverse ? oif : skb->skb_iif;
>     The "reverse" variable is defined in  net/xfrm/xfrm_policy.c:__xfrm_policy_check
>     when it checks if the dir is above the XFRM_POLICY_MASK if this returns false
>     it reverses the ifindex, but it should only reverse if it returns true.

The above explanation suggests the reverse flag in __xfrm_policy_check should be fixed. Can you check that and maybe __xfrm_policy_check2 as well?

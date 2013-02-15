From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] GRE: Add TCP segmentation offload for GRE
Date: Thu, 14 Feb 2013 17:39:49 -0800
Message-ID: <1360892389.6884.74.camel@edumazet-glaptop>
References: <1360871101-2086-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com,
	bhutchings@solarflare.com, mirqus@gmail.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:45937 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932261Ab3BOBjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 20:39:52 -0500
Received: by mail-pa0-f49.google.com with SMTP id kp6so1528278pab.8
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 17:39:52 -0800 (PST)
In-Reply-To: <1360871101-2086-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-14 at 11:45 -0800, Pravin B Shelar wrote:
> Following patch adds GRE protocol offload handler so that
> skb_gso_segment() can segment GRE packets.
> SKB GSO CB is added to keep track of total header length so that
> skb_segment can push entire header. e.g. in case of GRE, skb_segment
> need to push inner and outer headers to every segment.
> New NETIF_F_GRE_GSO feature is added for devices which support HW
> GRE TSO offload. Currently none of devices support it therefore GRE GSO
> always fall backs to software GSO.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> Fixed according to comments from Jesse and Eric.
> v2-v3:
>  - Use device features to segment inner packet.
>  - Moved skb_mac_gso_segment to separate patch.
>  - simplified gre_gso_segment().
>  - Added NETIF_F_GRE_GSO feature.
> 
> v1-v2:
>  - Factored a MAC layer handler out of skb_gso_segment().
>  - Eliminated copy operation from gre_gso_segment().
>  - Refresh header pointer after pskb_may_pull().
> ---

Seems very good to me, thanks !

The only thing that puzzles me is the ip_select_ident() in
ipgre_tunnel_xmit()

Do we care of the IP identifiers being 0, 1, 2, 3, ... on the outer
headers ?

Without TSO, we are using 0 IP identifiers (DF being set)

Also if we can't unclone the skb in handle_offloads(), we should
increment tx_dropped or tx_errors.

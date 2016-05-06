From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3 net-next 01/11] gso: Remove arbitrary checks for
 unsupported GSO
Date: Fri, 6 May 2016 15:34:09 -0700
Message-ID: <572D1BE1.80702@gmail.com>
References: <1462572726-566137-1-git-send-email-tom@herbertland.com>
 <1462572726-566137-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35178 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758568AbcEFWeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 18:34:11 -0400
Received: by mail-pf0-f169.google.com with SMTP id 77so53898206pfv.2
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 15:34:11 -0700 (PDT)
In-Reply-To: <1462572726-566137-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2016 03:11 PM, Tom Herbert wrote:
> In several gso_segment functions there are checks of gso_type against
> a seemingly arbitrary list of SKB_GSO_* flags. This seems like an
> attempt to identify unsupported GSO types, but since the stack is
> the one that set these GSO types in the first place this seems
> unnecessary to do. If a combination isn't valid in the first
> place that stack should not allow setting it.
>
> This is a code simplication especially for add new GSO types.
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>   net/ipv4/af_inet.c     | 18 ------------------
>   net/ipv4/gre_offload.c | 14 --------------
>   net/ipv4/tcp_offload.c | 19 -------------------
>   net/ipv4/udp_offload.c | 10 ----------
>   net/ipv6/ip6_offload.c | 18 ------------------
>   net/ipv6/udp_offload.c | 13 -------------
>   net/mpls/mpls_gso.c    |  9 ---------
>   7 files changed, 101 deletions(-)
>

This is a nice clean-up since tunnels have essentially made things like 
trying to filter TSOV4 or TSOV6 pointless for the network layer.

Acked-by: Alexander Duyck <aduyck@mirantis.com>

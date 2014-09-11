From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] udp: Fix inverted NAPI_GRO_CB(skb)->flush test
Date: Wed, 10 Sep 2014 22:13:48 -0700
Message-ID: <1410412428.7106.52.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410402198-30811-1-git-send-email-scottwood@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Tom Herbert <therbert@google.com>
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:59418 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbaIKFNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 01:13:49 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq14so6167628pab.39
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 22:13:49 -0700 (PDT)
In-Reply-To: <1410402198-30811-1-git-send-email-scottwood@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-10 at 21:23 -0500, Scott Wood wrote:
> Commit 2abb7cdc0d ("udp: Add support for doing checksum unnecessary
> conversion") caused napi_gro_cb structs with the "flush" field zero to
> take the "udp_gro_receive" path rather than the "set flush to 1" path
> that they would previously take.  As a result I saw booting from an NFS
> root hang shortly after starting userspace, with "server not
> responding" messages.
> 
> This change to the handling of "flush == 0" packets appears to be
> incidental to the goal of adding new code in the case where
> skb_gro_checksum_validate_zero_check() returns zero.  Based on that and
> the fact that it breaks things, I'm assuming that it is unintentional.
> 
> Fixes: 2abb7cdc0d ("udp: Add support for doing checksum unnecessary conversion")
> Cc: Tom Herbert <therbert@google.com>
> Signed-off-by: Scott Wood <scottwood@freescale.com>
> ---
>  net/ipv4/udp_offload.c | 2 +-
>  net/ipv6/udp_offload.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)

Good catch, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>

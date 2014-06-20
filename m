From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net]tg3: Clear NETIF_F_TSO6 flag before doing software
 GSO
Date: Thu, 19 Jun 2014 20:56:57 -0700 (PDT)
Message-ID: <20140619.205657.498263585409423061.davem@davemloft.net>
References: <1403141893-21735-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: prashant@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932480AbaFTD5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 23:57:04 -0400
In-Reply-To: <1403141893-21735-1-git-send-email-prashant@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant@broadcom.com>
Date: Wed, 18 Jun 2014 18:38:13 -0700

> Commit d3f6f3a1d818410c17445bce4f4caab52eb102f1 "tg3: Prevent page
> allocation failure during TSO workaround" modified driver logic
> to use tg3_tso_bug() for any TSO fragment that hits hardware bug
> conditions thus the patch increased the scope of work for tg3_tso_bug()
> to cover devices that support NETIF_F_TSO6 as well. Prior to the
> patch, tg3_tso_bug() would only be used on devices supporting
> NETIF_F_TSO.
> 
> A regression was introduced for IPv6 packets requiring the workaround.
> To properly perform GSO on SKBs with TCPV6 gso_type, we need to call
> skb_gso_segment() with NETIF_F_TSO6 feature flag cleared, or the
> function will return NULL and cause a kernel oops as tg3 is not handling
> a NULL return value. This patch fixes the problem.
> 
> Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied and queued up for -stable, thanks.

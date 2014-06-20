From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH net]tg3: Clear NETIF_F_TSO6 flag before doing software
 GSO
Date: Thu, 19 Jun 2014 22:11:25 -0700
Message-ID: <1403241085.2488.53.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1403141893-21735-1-git-send-email-prashant@broadcom.com>
	 <20140619.205657.498263585409423061.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <prashant@broadcom.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:9495 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933600AbaFTFL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 01:11:27 -0400
In-Reply-To: <20140619.205657.498263585409423061.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-06-19 at 20:56 -0700, David Miller wrote: 
> From: Prashant Sreedharan <prashant@broadcom.com>
> Date: Wed, 18 Jun 2014 18:38:13 -0700
> 
> > Commit d3f6f3a1d818410c17445bce4f4caab52eb102f1 "tg3: Prevent page
> > allocation failure during TSO workaround" modified driver logic
> > to use tg3_tso_bug() for any TSO fragment that hits hardware bug
> > conditions thus the patch increased the scope of work for tg3_tso_bug()
> > to cover devices that support NETIF_F_TSO6 as well. Prior to the
> > patch, tg3_tso_bug() would only be used on devices supporting
> > NETIF_F_TSO.
> > 
> > A regression was introduced for IPv6 packets requiring the workaround.
> > To properly perform GSO on SKBs with TCPV6 gso_type, we need to call
> > skb_gso_segment() with NETIF_F_TSO6 feature flag cleared, or the
> > function will return NULL and cause a kernel oops as tg3 is not handling
> > a NULL return value. This patch fixes the problem.
> > 
> > Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Applied and queued up for -stable, thanks.

David, the regression is only in the net tree.  It doesn't hurt to send
the patch to -stable, but not necessary.

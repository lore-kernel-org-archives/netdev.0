From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/4] e1000: disable TSO workaround on 82544
Date: Wed, 25 Jun 2008 01:50:40 -0700
Message-ID: <9929d2390806250150v75965ff6k6773288fe1b28089@mail.gmail.com>
References: <20080619211836.GC22981@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: "Andy Gospodarek" <andy@greyhouse.net>,
	"Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:52281 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844AbYFYIun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 04:50:43 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1038264waf.23
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2008 01:50:41 -0700 (PDT)
In-Reply-To: <20080619211836.GC22981@gospo.rdu.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 19, 2008 at 2:18 PM, Andy Gospodarek <andy@greyhouse.net> wrote:
>
> It appears that the 82544 does not need the TSO workaround needed on
> other chips.  This seems to resolve excessive messages that appear to be
> Tx Unit Hangs when a system is under heavy stress.
>
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
>  drivers/net/e1000/e1000_main.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 59579b1..af6846d 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -3479,7 +3479,8 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>        }
>
>        if (likely(tso)) {
> -               tx_ring->last_tx_tso = 1;
> +               if (likely(adapter->hw.mac_type != e1000_82544))
> +                       tx_ring->last_tx_tso = 1;
>                tx_flags |= E1000_TX_FLAGS_TSO;
>        } else if (likely(e1000_tx_csum(adapter, tx_ring, skb)))
>                tx_flags |= E1000_TX_FLAGS_CSUM;
> --
> 1.5.2.1
>

ACK - patches 1-4
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

-- 
Cheers,
Jeff

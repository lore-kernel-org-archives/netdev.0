From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/9][TG3]: Add basic 5906 support.
Date: Wed, 27 Sep 2006 16:08:36 -0700 (PDT)
Message-ID: <20060927.160836.74560378.davem@davemloft.net>
References: <1159389299.3411.23.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:62189
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031216AbWI0XIh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 19:08:37 -0400
To: mchan@broadcom.com
In-Reply-To: <1159389299.3411.23.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 27 Sep 2006 13:34:59 -0700

> [TG3]: Add basic 5906 support.
> 
> Add support for the new 5709 device.  This is a new 10/100 Mbps chip.
> The mailbox access and firmware interface are quite different from
> all other tg3 chips.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Looks fine, applied.

Quick question:

> @@ -491,6 +513,9 @@ static inline void tg3_cond_int(struct t
>  	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) &&
>  	    (tp->hw_status->status & SD_STATUS_UPDATED))
>  		tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
> +	else
> +		tw32(HOSTCC_MODE, tp->coalesce_mode |
> +		     (HOSTCC_MODE_ENABLE | HOSTCC_MODE_NOW));
>  }
>  
>  static void tg3_enable_ints(struct tg3 *tp)

Why are we forcing a coalescing event here now?  This seems
to apply in quite a large number of cases.  It will trigger
if either:

1) using tagged status
2) SD_STATUS_UPDATED is not indicated in the status block

In particular, how is this a 5906 specific support change
when there are no 5906 or other chipset conditionals guarding
the logic here?

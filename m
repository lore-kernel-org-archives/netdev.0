From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH 1/5] cxgb4: Add T4 filter support
Date: Thu, 29 Nov 2012 19:51:46 +0000
Message-ID: <1354218706.2586.36.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354200745-23598-1-git-send-email-vipul@chelsio.com>
	 <1354200745-23598-2-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>, <abhishek-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1354200745-23598-2-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-11-29 at 20:22 +0530, Vipul Pandya wrote:
> The T4 architecture is capable of filtering ingress packets at line rate
> using the rule in TCAM. If packet hits a rule in the TCAM then it can be either
> dropped or passed to the receive queues based on a rule settings.
> 
> This patch adds framework for managing filters and to use T4's filter
> capabilities. It constructs a Firmware Filter Work Request which writes the
> filter at a specified index to get the work done. It hosts shadow copy of
> ingress filter entry to check field size limitations and save memory in the
> case where the filter table is large.
> 
> Signed-off-by: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
> ---
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  141 +++++++++++
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  309 ++++++++++++++++++++++-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    2 +
>  drivers/net/ethernet/chelsio/cxgb4/l2t.c        |   34 +++
>  drivers/net/ethernet/chelsio/cxgb4/l2t.h        |    3 +
>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   23 ++-
>  drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |    1 +
>  drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  279 ++++++++++++++++++++
>  8 files changed, 787 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
> index 378988b..8cfc1ba 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
> @@ -545,6 +545,139 @@ struct adapter {
>  	spinlock_t stats_lock;
>  };
>  
> +/**
[...]

'/**' introduces a kernel-doc comment; please don't use it for any
comments not in that format.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

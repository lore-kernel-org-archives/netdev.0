From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC 2/2] ethtool: Add support for DMA Coalescing feature config to ethtool.
Date: Tue, 14 Jun 2011 19:51:53 +0100
Message-ID: <20110614185153.GC12002@solarflare.com>
References: <1308071606-6333-1-git-send-email-carolyn.wyborny@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Carolyn Wyborny <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26697 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145Ab1FNSv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 14:51:57 -0400
Content-Disposition: inline
In-Reply-To: <1308071606-6333-1-git-send-email-carolyn.wyborny@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Carolyn Wyborny wrote:
> This RFC patch adds functions to get and set DMA Coalescing feature
> configuration.
> 
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> ---
>  include/linux/ethtool.h |   15 ++++++++++++++-
>  net/core/ethtool.c      |   32 ++++++++++++++++++++++++++++++++
>  2 files changed, 46 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index c6a850a..efed754 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -703,6 +703,14 @@ enum ethtool_sfeatures_retval_bits {
>  	ETHTOOL_F_COMPAT__BIT,
>  };
>  
> +/* for configuring DMA coalescing parameters of chip */
> +struct ethtool_dmac {
> +	__u32	cmd;	/* ETHTOOL_{G,S}DMAC */
> +
> +	/* tune setting, options and validation determined by device. */
> +	__u32	tune;
> +};
[...]

I don't think we should be adding operations that have no generic
semantics at all.  Further, we will not add any operations without at
least one implementation as an example.

Secondly, ethtool operations that only get/set a 32-bit value should
use struct ethtool_value for the parameter.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

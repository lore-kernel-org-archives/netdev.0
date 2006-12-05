From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/5] ipw2100: Make ipw2100 depends on known working platforms
Date: Tue, 5 Dec 2006 10:36:07 +0000
Message-ID: <20061205103607.GB10312@infradead.org>
References: <20061205064052.GA18227@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:58276 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968077AbWLEKgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 05:36:09 -0500
To: Zhu Yi <yi.zhu@intel.com>
Content-Disposition: inline
In-Reply-To: <20061205064052.GA18227@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 05, 2006 at 02:40:52PM +0800, Zhu Yi wrote:
> 
> [ Resubmit, if you still don't like it, I'll drop. ]
> 
> ipw2100 driver doesn't support big endian by now.
> 
> Signed-off-by: Karol Lewandowski <kl@jasmine.eu.org>
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> 
> ---
> 
>  drivers/net/wireless/Kconfig |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> d664c6332284edba4278a1f3b18b453ef4d39faf
> diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
> index aefa4cb..c2495c5 100644
> --- a/drivers/net/wireless/Kconfig
> +++ b/drivers/net/wireless/Kconfig
> @@ -146,7 +146,7 @@ comment "Wireless 802.11b ISA/PCI cards 
>  
>  config IPW2100
>  	tristate "Intel PRO/Wireless 2100 Network Connection"
> -	depends on NET_RADIO && PCI
> +	depends on NET_RADIO && PCI && (X86 || X86_64 || IA64 || BROKEN)

Once again, there's a lot more little endian than just you employers
hardware.  And once again the right thing for a maintained driver is
to fix the endianess bugs.  We should probably just mark it broken for
every platform given that intel doesn't care (And neither cares about
offers to fix endianess bugs if they send hardware..)


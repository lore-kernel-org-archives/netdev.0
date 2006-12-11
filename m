From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 03/22] ixgb: Write RA register high word first, increment
 version
Date: Mon, 11 Dec 2006 09:37:36 -0500
Message-ID: <457D6D30.60803@pobox.com>
References: <20061208230209.30109.49157.stgit@gitlost.site> <20061208230250.30109.60518.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46296 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936072AbWLKOhj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 09:37:39 -0500
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20061208230250.30109.60518.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> We need to disable the AV bit before flushing the low register.
> 
> Signed-off-by: <aaron.k.salter@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/ixgb/ixgb_hw.c   |    3 ++-
>  drivers/net/ixgb/ixgb_main.c |    2 +-
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
> index 02089b6..ecbf458 100644
> --- a/drivers/net/ixgb/ixgb_hw.c
> +++ b/drivers/net/ixgb/ixgb_hw.c
> @@ -399,8 +399,9 @@ ixgb_init_rx_addrs(struct ixgb_hw *hw)
>  	/* Zero out the other 15 receive addresses. */
>  	DEBUGOUT("Clearing RAR[1-15]\n");
>  	for(i = 1; i < IXGB_RAR_ENTRIES; i++) {
> -		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
> +		/* Write high reg first to disable the AV bit first */
>  		IXGB_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
> +		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);

Are you sure the order is guaranteed even after this code change, when 
considering all manner of CPU and bus posted writes?

ACK if yes



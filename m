From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 07/22] e1000: omit stats for broken counter in 82543
Date: Mon, 11 Dec 2006 09:42:50 -0500
Message-ID: <457D6E6A.8010001@pobox.com>
References: <20061208230209.30109.49157.stgit@gitlost.site> <20061208230259.30109.29745.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46351 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936250AbWLKOmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 09:42:52 -0500
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20061208230259.30109.29745.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> 82543 does not count tx_carrier_errors properly in FD mode.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index dc76e01..7639b4d 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -3592,7 +3592,12 @@ e1000_update_stats(struct e1000_adapter 
>  	adapter->net_stats.tx_errors = adapter->stats.txerrc;
>  	adapter->net_stats.tx_aborted_errors = adapter->stats.ecol;
>  	adapter->net_stats.tx_window_errors = adapter->stats.latecol;
> -	adapter->net_stats.tx_carrier_errors = adapter->stats.tncrs;
> +	if (adapter->hw.mac_type == e1000_82543 &&
> +	    adapter->link_duplex == FULL_DUPLEX) {
> +		adapter->net_stats.tx_carrier_errors = 0;
> +		adapter->stats.tncrs = 0;
> +	} else
> +		adapter->net_stats.tx_carrier_errors = adapter->stats.tncrs;

test a feature bit (really a quirk bit, in this case)



From: Jakub Kicinski <moorray3@wp.pl>
Subject: Re: [PATCH 3/4] ethtool: can't set combined and tx/rx channel
 counts at the same time
Date: Mon, 8 Feb 2016 20:52:47 +0000
Message-ID: <20160208205247.74aaaee8@jkicinski-Precision-T1700>
References: <1454961965-15116-1-git-send-email-jacob.e.keller@intel.com>
	<1454961965-15116-4-git-send-email-jacob.e.keller@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jacob Keller <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:45327 "EHLO mx4.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754159AbcBHUwv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 15:52:51 -0500
In-Reply-To: <1454961965-15116-4-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  8 Feb 2016 12:06:04 -0800, Jacob Keller wrote:
> +	/* can't set combined and separate channels at the same time */
> +	if ((channels.combined_count &&
> +	     (channels.rx_count || channels.tx_count))
> +	    return -EINVAL;
> +
>  	/* ensure the new Rx count fits within the configured Rx flow
>  	 * indirection table settings */
>  	if (netif_is_rxfh_configured(dev) &&

My understanding is that unsymmetrical rx/tx queue configuration with
combined IRQ vectors should be expressed as:

combined = min(tx, rx);
num_tx = tx - combined;
num_rx = rx - combined;

Please see:

https://www.mail-archive.com/netdev@vger.kernel.org/msg93977.html

Patches which I cooked up for this are rotting in my queue blocked by
other things, unfortunately.

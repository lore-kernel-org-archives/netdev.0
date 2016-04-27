From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: Provide CPU port statistics to master
 netdev
Date: Wed, 27 Apr 2016 21:03:08 +0200
Message-ID: <20160427190308.GE29024@lunn.ch>
References: <1461782714-13471-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50892 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750753AbcD0TDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 15:03:11 -0400
Content-Disposition: inline
In-Reply-To: <1461782714-13471-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	if (stringset == ETH_SS_STATS && ds->drv->get_strings) {
> +		ndata = data + mcount * len;
> +		/* This function copies ETH_GSTRINGS_LEN bytes, we will mangle
> +		 * the output after to prepend our CPU port prefix we
> +		 * constructed earlier
> +		 */
> +		ds->drv->get_strings(ds, cpu_port, ndata);
> +		count = ds->drv->get_sset_count(ds);
> +		for (i = 0; i < count; i++) {
> +			memmove(ndata + (i * len + sizeof(pfx)),
> +				ndata + i * len, len - sizeof(pfx));
> +			memcpy(ndata + i * len, pfx, sizeof(pfx));

Hi Florian

Did you check what happens if this causes the NULL terminator to be
discarded? Does ethtool handle that? As i said before, it is unclear
if one is required.

	   Andrew

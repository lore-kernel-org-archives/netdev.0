From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: add mac_pton() for parsing MAC address
Date: Wed, 4 May 2011 08:12:25 -0700
Message-ID: <20110504081225.267a0833@nehalam>
References: <20110504061551.GA12297@p183>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50595 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754424Ab1EDPM1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 11:12:27 -0400
In-Reply-To: <20110504061551.GA12297@p183>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 May 2011 09:15:51 +0300
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> +int mac_pton(const char *s, u8 *mac)
> +{
> +	int i;
> +
> +	/* XX:XX:XX:XX:XX:XX */
> +	if (strlen(s) < 3 * ETH_ALEN - 1)
> +		return 0;
> +
> +	/* Don't half dirty result. */
Shouldn't this be "Don't allow dirty result."?

> +	for (i = 0; i < ETH_ALEN; i++) {
> +		if (!strchr("0123456789abcdefABCDEF", s[i * 3]))
> +			return 0;
> +		if (!strchr("0123456789abcdefABCDEF", s[i * 3 + 1]))
> +			return 0;

		if (!isxdigit(s[i*3]) || !isxdigit(s[i*3+1]))
			return 0;

> +		if (i != ETH_ALEN - 1 && s[i * 3 + 2] != ':')
> +			return 0;
> +	}
> +	for (i = 0; i < ETH_ALEN; i++) {
> +		mac[i] = (hex_to_bin(s[i * 3]) << 4) | hex_to_bin(s[i * 3 + 1]);
		hex2bin(&mac[i], &s[i*3], 1);
> +	}
> +	return 1;
> +}
> +EXPORT_SYMBOL(mac_pton);

Also don't need two loops, okay to parse partial result.

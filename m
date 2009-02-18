From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [kernel] Add support for RX packet classification
 in a network device
Date: Tue, 17 Feb 2009 20:28:38 -0800 (PST)
Message-ID: <20090217.202838.66382200.davem@davemloft.net>
References: <49999FA3.7040300@Sun.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	gkernel-commit@lists.sourceforge.net, Matheos.Worku@Sun.COM,
	Mehdi.Bonyadi@Sun.COM
To: Santwona.Behera@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57828
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751319AbZBRE2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 23:28:54 -0500
In-Reply-To: <49999FA3.7040300@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santwona.Behera@Sun.COM
Date: Mon, 16 Feb 2009 09:17:23 -0800

> -struct ethtool_rxnfc {
> -	__u32		cmd;
> +/* The following structures are for supporting RX network flow
> + * classification configuration. Note, all multibyte fields, e.g.,
> + * ip4src, ip4dst, psrc, pdst, spi, etc. are expected to be in network
> + * byte order.
> + */
> +struct ethtool_tcpip4_spec {
> +	__u32	ip4src;
> +	__u32	ip4dst;
> +	__u16	psrc;
> +	__u16	pdst;
> +	__u8    tos;
> +};

We have specific types for this, "__be32" et al.

Please use them.

And once you do that properly, checking the code with sparse via "make
C=1" will warn for you if these data items are not accessed as
big-endian items.

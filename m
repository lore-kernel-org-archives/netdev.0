From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [ethtool] Add support for RX packet classification
 in a network device
Date: Mon, 09 Feb 2009 18:03:06 -0800 (PST)
Message-ID: <20090209.180306.156744968.davem@davemloft.net>
References: <4990B855.30905@Sun.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gkernel-commit@lists.sourceforge.net,
	jeff@garzik.org, Matheos.Worku@Sun.COM, Mehdi.Bonyadi@Sun.COM
To: Santwona.Behera@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33228
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752957AbZBJCDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 21:03:12 -0500
In-Reply-To: <4990B855.30905@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santwona.Behera@Sun.COM
Date: Mon, 09 Feb 2009 15:12:21 -0800

> +struct ethtool_tcpip4_spec {
> +	__u32	ip4src;
> +	__u32	ip4dst;
> +	__u16	psrc;
> +	__u16	pdst;
> +	__u8    tos;
> +};

The IP addresses and ports in these new interfaces, are
they to be specified in network or cpu byte order?

That's usually the first thing a person will wonder when
trying to use to implement support for these interfaces.

My guess is that the specification is cpu endianness,
however note that this flies in the face with how this
is handled in pretty much every other networking interface
in the kernel.  The standard is to use network endianness
when passing ports and IP addressing information into the
kernel.

I wouldn't reject this patch series just for this reason,
in fact I'm ready to apply this stuff, but just thought I'd
mention it just in case you hadn't considered the issue
yourself.

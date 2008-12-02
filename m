From: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Subject: Re: [PATCH] enc28j60: Fix sporadic packet loss
Date: Tue, 02 Dec 2008 15:11:26 +0100
Message-ID: <4935420E.1010809@eptar.com>
References: <20081202125046.GD24490@diamond.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.acantho.net ([213.174.182.196]:60206 "EHLO mx3.acantho.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755646AbYLBQx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 11:53:29 -0500
Received: (from root@localhost)
	by mx3.acantho.net (8.13.4/8.13.4/Debian-3sarge1) id mB2EBldQ000652
	for <netdev@vger.kernel.org>; Tue, 2 Dec 2008 15:11:47 +0100
In-Reply-To: <20081202125046.GD24490@diamond.tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Baruch Siach wrote:
> +/*
> + * Calculate wrap arround when reading beyond the end of the RX buffer
                      ^
> + */
> +static u16 rx_packet_start(u16 ptr)
> +{
> +	if (ptr + RSV_SIZE > RXEND_INIT)
> +		return (ptr + RSV_SIZE) - (RXEND_INIT - RXSTART_INIT + 1);
> +	else
> +		return ptr;
> +}

should be
...
	else
		return ptr + RSV_SIZE;

With this change you can add the line
Acked-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>


Cheers,
Claudio


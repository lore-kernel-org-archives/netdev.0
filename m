From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v4 5/6] net: fec: Add Scatter/gather support
Date: Tue, 10 Jun 2014 11:10:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725A303@AcuExch.aculab.com>
References: <1402392744-24368-1-git-send-email-b38611@freescale.com>
 <1402392744-24368-6-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"b20596@freescale.com" <b20596@freescale.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: 'Fugang Duan' <b38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:32798 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750978AbaFJLLb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 07:11:31 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 29615-09 for <netdev@vger.kernel.org>;
 Tue, 10 Jun 2014 12:11:22 +0100 (BST)
In-Reply-To: <1402392744-24368-6-git-send-email-b38611@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan
> Add Scatter/gather support for FEC.
> This feature allows to improve outbound throughput performance.
...
> +static int fec_enet_get_free_txdesc_num(struct fec_enet_private *fep)
> +{
> +	int entries;
> +
> +	entries = ((const char *)fep->dirty_tx -
> +			(const char *)fep->cur_tx) / fep->bufdesc_size;
> +
> +	return (fep->cur_tx >= fep->dirty_tx) ?
> +		entries += fep->tx_ring_size : entries;
> +}

That is a strange return statement - why += ??

You could also check the sign of 'entries'.
Say:
	return entries > 0 ? entries : entries + fep->tx_ring_size;

Actually do you ever use the last entry?
If you do then the full and empty conditions are not separated.

	David

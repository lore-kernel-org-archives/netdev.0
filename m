From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 16/17] netfilter: nft_byteorder: provide 64bit le/be
 conversion
Date: Fri, 8 Jan 2016 14:26:31 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCC043B@AcuExch.aculab.com>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
 <1452261737-7475-17-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Pablo Neira Ayuso' <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:62645 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932201AbcAHO3Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 09:29:16 -0500
In-Reply-To: <1452261737-7475-17-git-send-email-pablo@netfilter.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso
> Sent: 08 January 2016 14:02
> From: Florian Westphal <fw@strlen.de>
> 
> Needed to convert the (64bit) conntrack counters to BE ordering.
> 
...
>  	switch (priv->size) {
> +	case 8: {
> +		u64 src64;
> +
> +		switch (priv->op) {
> +		case NFT_BYTEORDER_NTOH:
> +			for (i = 0; i < priv->len / 8; i++) {
> +				src64 = get_unaligned_be64(&src[i]);
> +				src64 = be64_to_cpu((__force __be64)src64);
> +				put_unaligned_be64(src64, &dst[i]);
> +			}
> +			break;
> +		case NFT_BYTEORDER_HTON:
> +			for (i = 0; i < priv->len / 8; i++) {
> +				src64 = get_unaligned_be64(&src[i]);
> +				src64 = (__force u64)cpu_to_be64(src64);
> +				put_unaligned_be64(src64, &dst[i]);
> +			}
> +			break;
> +		}
> +		break;

That is horrid.
On a little-endian system you are byteswapping the data 3 times.
Image the code on a cpu that doesn't support misaligned transfers
and doesn't have a byteswap instruction.

	David

From: David Miller <davem@davemloft.net>
Subject: Re: [RFC TRY#2][PATCH] bgmac: pass received packet to the netif
 instead of copying it
Date: Mon, 28 Oct 2013 16:28:58 -0400 (EDT)
Message-ID: <20131028.162858.1940229138245324914.davem@davemloft.net>
References: <1382982142-16876-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, openwrt-devel@lists.openwrt.org
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37095 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755810Ab3J1U3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 16:29:02 -0400
In-Reply-To: <1382982142-16876-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Mon, 28 Oct 2013 18:42:22 +0100

> Copying whole packets with skb_copy_from_linear_data_offset is a pret=
ty
> bad idea. CPU was spending time in __copy_user_common and network
> performance was lower. With the new solution iperf-measured speed
> increased from 116Mb/s to 134Mb/s.
>=20
> Another way to improve performance could be switching to build_skb. I=
t
> is cache-specific, so will require testing of various devices.
>=20
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Semantically this looks good but it needs some coding style fixes:

The following is indented correctly:

> +				dma_sync_single_for_device(dma_dev,
> +							   slot->dma_addr,
> +							   BGMAC_RX_BUF_SIZE,
> +							   DMA_FROM_DEVICE);
> +				break;
>  			}

However, this is not:

> +			/* Unmap old skb, we'll pass it to the netfif */
> +			dma_unmap_single(dma_dev, old_dma_addr,
> +						BGMAC_RX_BUF_SIZE,
> +						DMA_FROM_DEVICE);
> +

Like the first case, please align the arguments on the second and subse=
quently
line to start at the first column after the openning parenthesis on the
first line.

Every time I see this not done correctly, it's because the person doing=
 it
is trying to use TAB characters only to indent.  You should be using th=
e
appropriate number of TAB _and_ SPACE characters necessary to get thing=
s
lines up properly.

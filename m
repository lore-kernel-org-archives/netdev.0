From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4] bgmac: driver for GBit MAC core on BCMA bus
Date: Mon, 07 Jan 2013 19:40:11 -0800 (PST)
Message-ID: <20130107.194011.1849511206295563088.davem@davemloft.net>
References: <1357431609-27981-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, joe@perches.com
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339Ab3AHDkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 22:40:12 -0500
In-Reply-To: <1357431609-27981-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Sun,  6 Jan 2013 01:20:09 +0100

> V4: stop queue when ring is full

You're still not doing it right.

> +	if (free_slots =3D=3D 1) { /* Should never happen (netif_stop_queue=
) */
> +		bgmac_err(bgmac, "TX after stopping queue!\n");
> +		return NETDEV_TX_BUSY;
> +	}

You need to call netif_stop_queue() in this code path too.

Look more carefully at the drivers we asked you to use as
a model, they all do this properly.

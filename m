From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,stable] net: cdc_ncm: avoid changing RX/TX buffers
 on MTU changes
Date: Wed, 23 Dec 2015 22:52:40 -0500 (EST)
Message-ID: <20151223.225240.1999351612611929837.davem@davemloft.net>
References: <1450874563-21311-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	mrkiko.rs@gmail.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbbLXDwm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 22:52:42 -0500
In-Reply-To: <1450874563-21311-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Wed, 23 Dec 2015 13:42:43 +0100

> NCM buffer sizes are negotiated with the device independently of
> the network device MTU.  The RX buffers are allocated by the
> usbnet framework based on the rx_urb_size value set by cdc_ncm. A
> single RX buffer can hold a number of MTU sized packets.
>=20
> The default usbnet change_mtu ndo only modifies rx_urb_size if it
> is equal to hard_mtu.  And the cdc_ncm driver will set rx_urb_size
> and hard_mtu independently of each other, based on dwNtbInMaxSize
> and dwNtbOutMaxSize respectively. It was therefore assumed that
> usbnet_change_mtu() would never touch rx_urb_size.  This failed to
> consider the case where dwNtbInMaxSize and dwNtbOutMaxSize happens
> to be equal.
>=20
> Fix by implementing an NCM specific change_mtu ndo, modifying the
> netdev MTU without touching the buffer size settings.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied and queued up for -stable, thanks!

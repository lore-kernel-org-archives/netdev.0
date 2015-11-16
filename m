From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: use netdev name in warning if no parent
Date: Mon, 16 Nov 2015 16:22:21 -0500 (EST)
Message-ID: <20151116.162221.1821905374061673605.davem@davemloft.net>
References: <1447697800-6959-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41705 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbbKPVWX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 16:22:23 -0500
In-Reply-To: <1447697800-6959-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Mon, 16 Nov 2015 19:16:40 +0100

> A recent flaw in the netdev feature setting resulted in warnings
> like this one from VLAN interfaces:
>=20
>  WARNING: CPU: 1 PID: 4975 at net/core/dev.c:2419 skb_warn_bad_offloa=
d+0xbc/0xcb()
>  : caps=3D(0x00000000001b5820, 0x00000000001b5829) len=3D2782 data_le=
n=3D0 gso_size=3D1348 gso_type=3D16 ip_summed=3D3
>=20
> The ":" is supposed to be preceded by a driver name, but in this
> case it is an empty string since the device has no parent.
>=20
> There are many types of network devices without a parent. The
> anonymous warnings for these devices can be hard to debug.  Log
> the network device name instead in these cases to assist further
> debugging.
>=20
> This is mostly similar to how __netdev_printk() handles orphan
> devices.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Yeah that seems reasonable, applied, thanks!

I wonder if we open-code this in a lot of other places, and
therefore this deserves a helper and some auditing.

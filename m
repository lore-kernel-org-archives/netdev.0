From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: usbnet: fix tx_dropped statistics
Date: Mon, 04 Feb 2013 13:07:41 -0500 (EST)
Message-ID: <20130204.130741.1626636131644599032.davem@davemloft.net>
References: <1359657365-2879-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	oliver@neukum.org, alexey.orishko@gmail.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43729 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755041Ab3BDSHn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 13:07:43 -0500
In-Reply-To: <1359657365-2879-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu, 31 Jan 2013 19:36:05 +0100

> It is normal for minidrivers accumulating frames to return NULL
> from their tx_fixup function. We do not want to count this as a
> drop, or log any debug messages.  A different exit path is
> therefore chosen for such drivers, skipping the debug message
> and the tx_dropped increment.
>=20
> The test for accumulating drivers was however completely bogus,
> making the exit path selection depend on whether the user had
> enabled tx_err logging or not. This would arbitrarily mess up
> accounting for both accumulating and non-accumulating minidrivers,
> and would result in unwanted debug messages for the accumulating
> drivers.
>=20
> Fix by testing for FLAG_MULTI_PACKET instead, which probably was
> the intention from the beginning.  This usage match the documented
> behaviour of this flag:
>=20
>  Indicates to usbnet, that USB driver accumulates multiple IP packets=
=2E
>  Affects statistic (counters) and short packet handling.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied.

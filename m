From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: add locking to
 phy_read_mmd_indirect()/phy_write_mmd_indirect()
Date: Tue, 25 Aug 2015 16:31:16 -0700 (PDT)
Message-ID: <20150825.163116.1229705242506716827.davem@davemloft.net>
References: <E1ZU9vP-0004nN-LW@rmk-PC.arm.linux.org.uk>
	<55DC76D8.4090500@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rmk+kernel@arm.linux.org.uk, netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60364 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755922AbbHYXbR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:31:17 -0400
In-Reply-To: <55DC76D8.4090500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 25 Aug 2015 07:08:24 -0700

> Le 08/25/15 01:49, Russell King a =E9crit :
>> The phy layer is missing locking for the above two functions - it
>> has been observed that two threads (userspace and the phy worker
>> thread) can race, entering the bus ->write or ->read functions
>> simultaneously.
>>=20
>> This causes the FEC driver to initialise a completion while another
>> thread is waiting on it or while the interrupt is calling complete()
>> on it, which causes spinlock unlock-without-lock, spinlock lockups,
>> and completion timeouts.
>>=20
>> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
>=20
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>
> Fixes: a59a4d192 ("phy: add the EEE support and the way to access to =
the
> MMD registers.")
> Fixes: 0c1d77dfb ("net: libphy: Add phy specific function to access m=
md
> phy registers")

Applied, thanks.

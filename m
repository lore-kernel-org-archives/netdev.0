From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] net: ethernet: bcmgenet: use
 phy_ethtool_{get|set}_link_ksettings
Date: Mon, 4 Jul 2016 21:30:04 -0700
Message-ID: <577B37CC.80807@gmail.com>
References: <1467560037-21784-1-git-send-email-tremyfr@gmail.com>
 <1467560037-21784-2-git-send-email-tremyfr@gmail.com>
 <20160704.160300.953705748553101659.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33970 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbcGEEaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 00:30:08 -0400
In-Reply-To: <20160704.160300.953705748553101659.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/07/2016 16:03, David Miller a =E9crit :
> From: Philippe Reynes <tremyfr@gmail.com>
> Date: Sun,  3 Jul 2016 17:33:57 +0200
>=20
>> There are two generics functions phy_ethtool_{get|set}_link_ksetting=
s,
>> so we can use them instead of defining the same code in the driver.
>>
>> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
>=20
> Applied.
>=20

The transformation is not equivalent, we lost the checks on
netif_running() in the process, and those are here for a reason, if the
interface is down and therefore clock gated, MDIO accesses to the PHY
will simply fail outright and cause bus errors.

Philippe, have you tested this?
--=20
=46lorian

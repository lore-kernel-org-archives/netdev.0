From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/3] mdio: Parse DT nodes for auto-probed PHYs
Date: Mon, 12 May 2014 21:33:10 -0700
Message-ID: <5371A086.4040402@gmail.com>
References: <1399739875-16434-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, mugunthanvnm@ti.com,
	ujhelyi.m@gmail.com
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:57064 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbaEMEdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 00:33:13 -0400
Received: by mail-oa0-f52.google.com with SMTP id eb12so9159416oac.25
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 21:33:13 -0700 (PDT)
In-Reply-To: <1399739875-16434-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

Le 10/05/2014 09:37, Daniel Mack a =C3=A9crit :
> Hi Florian,
>
> here's another aproach of solving the issue with auto-probed buses an=
d
> DT device nodes. In short, this patch set introduces a new hook which
> sets the of_node pointer of a phy device to a subnode of the bus, if
> there is any which matches the phy's address. This function is called
> from mdiobus_scan(), and is a no-op for !CONFIG_OF.
>
> Unlike with with the 1st version, dev->of_node is now available in th=
e
> PHY driver's probe() callback already.
>
> Let me know what you think, I'm open to other ideas :)

I like it so far, I will give this a try on some of my quirky hardware.=
=20
Thanks!

>
>
> Daniel
>
>
> Daniel Mack (3):
>    net: of_mdio: factor out code to parse a phy's 'reg' property
>    net: of_mdio: add of_mdiobus_link_phydev()
>    net: of_mdio: don't store the length of a property if we don't nee=
d to
>
>   drivers/net/phy/mdio_bus.c |  6 ++++
>   drivers/of/of_mdio.c       | 74 +++++++++++++++++++++++++++++++++++=
++---------
>   include/linux/of_mdio.h    |  8 +++++
>   3 files changed, 74 insertions(+), 14 deletions(-)
>

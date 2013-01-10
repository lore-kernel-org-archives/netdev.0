From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 2/2] Fix phy_attach - forward dev_flags for phy_attach
Date: Thu, 10 Jan 2013 18:12:53 +0100
Message-ID: <50EEF695.9060001@openwrt.org>
References: <1357819234-27752-1-git-send-email-konszert@marvell.com> <1357819234-27752-3-git-send-email-konszert@marvell.com> <50EED2E4.80008@openwrt.org> <BC373419EB4337418B2B595BAEDC155F015896370062@IL-MB01.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"zertsekel@gmail.com" <zertsekel@gmail.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Eran Ben-Avi <benavi@marvell.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Lior Amsalem <alior@marvell.com>
To: Kosta Zertsekel <konszert@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:54348 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276Ab3AJRP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 12:15:27 -0500
Received: by mail-lb0-f178.google.com with SMTP id l5so666933lbo.9
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 09:15:26 -0800 (PST)
In-Reply-To: <BC373419EB4337418B2B595BAEDC155F015896370062@IL-MB01.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/10/13 16:57, Kosta Zertsekel a =C3=A9crit :
>> By the way, most, if not all of the phy_connect() users in drivers/n=
et/ethernet/ also do not ensure they pass the phy device flags, so you =
might
> want to fix this globally and not just for Marvell driver.
> Indeed, phy_connect() mostly just pass zero intead of phy_dev->dev_fl=
ags.
> But, I think, the guy that calls phy_connect() in its driver should k=
now what he does, and,
> probably, we should rely on him knowing his stuff.
> The only evidence of the bug is when phy_dev->dev_flags was actually =
changed by PHY fixup callback
> (see dns323-setup.c for example) and was *not* propagated to phy_conn=
ect() or phy_attach() as in pxa168_eth.c phy_init().
> The code conforming to the former should be fixed IMHO.

Actually, I wonder if we should not rather remove entirely the flags=20
argument, let the phy_connect() or phy_attach() callers modify the phy=20
device dev_flags like it does today (e.g: tg3) and modify phy_connect()=
=20
and phy_attach() to pass phy->dev_flags to phy_attach_direct().
--
=46lorian

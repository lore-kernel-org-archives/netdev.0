From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 0/8] b44: add support for external PHY
Date: Thu, 19 Dec 2013 18:02:49 -0800
Message-ID: <CAGVrzcYyMK=2QbtgTedc=DHkrfH6MgsLj-FyR4czVN=coGADKw@mail.gmail.com>
References: <1387502173-21743-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, zambrano@broadcom.com,
	netdev <netdev@vger.kernel.org>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:60610 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932079Ab3LTCDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 21:03:30 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so1890807pdj.17
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 18:03:30 -0800 (PST)
In-Reply-To: <1387502173-21743-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/12/19 Hauke Mehrtens <hauke@hauke-m.de>:
> This adds support for an external phy connected to the mac controlled
> by b44. This is used on home routers of the BCM47xx line where this MAC
> core was used and is contended to an external switch core through MII.
> These patches are in OpenWrt for some time and are tested by different
> users with different devices.
>
> The publicly available Programmer's Reference Guide for some of these
> chips help making this patch it would be nice to have such a
> documentation for more Broadcom Chips like some SoCs.
> https://www.broadcom.com/collateral/pg/440X-PG02-R.pdf
>
> v3:
>  - remove changes to the fixed phy driver
>  - call fixed_phy_add() in arch/mips/bcm47xx/setup.c before the fixed
>    phy gets registered

Thanks Hauke, this looks great now!

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

>
> v2:
>  - add fixed phy driver patch
>  - use fixed phy driver in b44
>  - some smaller changes and typos
>
> Hauke Mehrtens (8):
>   b44: check register instead of PHY address to detect external PHY
>   b44: rename B44_PHY_ADDR_NO_PHY to B44_PHY_ADDR_NO_LOCAL_PHY
>   b44: abort when no PHY is available at all
>   b44: rename b44_mii_{read,write} to b44_mdio_{read,write}_mii
>   b44: add phylib support
>   b44: activate PHY when MAC is off
>   b44: do not set PHY address to 30 for every ext PHY
>   b44: use fixed PHY device if we do not find any
>
>  arch/mips/bcm47xx/setup.c             |   10 ++
>  drivers/net/ethernet/broadcom/Kconfig |    1 +
>  drivers/net/ethernet/broadcom/b44.c   |  250 ++++++++++++++++++++++++++++++---
>  drivers/net/ethernet/broadcom/b44.h   |   15 +-
>  4 files changed, 250 insertions(+), 26 deletions(-)
>
> --
> 1.7.10.4
>



-- 
Florian

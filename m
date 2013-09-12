From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: XGMII support
Date: Thu, 12 Sep 2013 10:09:45 +0100
Message-ID: <CAGVrzcYLN0gJh8jU4j-BQa2gOq7bughKwpk30CgJY2+sL_m29A@mail.gmail.com>
References: <CAJ3bTp5kc-4eqQObCJ7xyCBTrBGp3yGLRGQZZMXdhTvsYahLFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36293 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285Ab3ILJK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 05:10:26 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so834755pab.1
        for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 02:10:25 -0700 (PDT)
In-Reply-To: <CAJ3bTp5kc-4eqQObCJ7xyCBTrBGp3yGLRGQZZMXdhTvsYahLFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

2013/9/12 Rayagond K <rayagond@vayavyalabs.com>:
> Hi All,
>
> I was going through include/linux/phy.h file to check what all phy
> interface Linux supports. The enum "phy_interface_t" has entry for
> MII, GMII, TBI, SGMII, RMII etc but I didn't find entry for XGMII
> interface.  So my questions are following,
>
> 1. How to support XGMII using phylib ?

phylib only needs to know about a phy_interface_t that is going to be
used by your Ethernet MAC adjust_link() callback to properly configure
the physical link between the MAC and the PHY. From a phylib
perspective there is no knowledge of how to configure based on the
*MII interface, this is the reponsibility of the Ethernet MAC driver
based on the "phydev->interface".

> 2. What are PHY_INTERFACE_MODE_RGMII_ID, PHY_INTERFACE_MODE_RGMII_RXID
> and PHY_INTERFACE_MODE_RGMII_TXID ?

They respectively stand for: "Reduced GMII with TX and RX internal
delay", "Reduced GMII with RX internal delay" and "Reduced GMII with
TX internal delay". In practice this is used when either the TX/RX or
both clocks and data lines needs to have a different phases (90
degrees in general).
-- 
Florian

From: Sebastian Frias <sf84@laposte.net>
Subject: Is Documentation/networking/phy.txt still up-to-date?
Date: Wed, 9 Nov 2016 14:24:56 +0100
Message-ID: <582323A8.20706@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: afleming@freescale.com, jgarzik@pobox.com,
        =?UTF-8?B?TcOlbnMgUnVsbGc=?= =?UTF-8?Q?=c3=a5rd?=
        <mans@mansr.com>, Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz299.laposte.net ([178.22.154.199]:38232 "EHLO
        smtpoutz2.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932992AbcKINZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 08:25:02 -0500
Received: from smtpoutz2.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout011 (Postfix) with ESMTP id E4A1752A0EC
        for <netdev@vger.kernel.org>; Wed,  9 Nov 2016 14:24:59 +0100 (CET)
Received: from smtpoutz2.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout011 (Postfix) with ESMTP id D67AF52BAF6
        for <netdev@vger.kernel.org>; Wed,  9 Nov 2016 14:24:59 +0100 (CET)
Received: from lpn-prd-vrin004 (lpn-prd-vrin004.laposte [10.128.63.5])
        by lpn-prd-vrout011 (Postfix) with ESMTP id D0EF252BB79
        for <netdev@vger.kernel.org>; Wed,  9 Nov 2016 14:24:59 +0100 (CET)
Received: from lpn-prd-vrin004 (localhost [127.0.0.1])
        by lpn-prd-vrin004 (Postfix) with ESMTP id BEAE6710207
        for <netdev@vger.kernel.org>; Wed,  9 Nov 2016 14:24:59 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Documentation/networking/phy.txt discusses phy_connect and states that:

 "...

 interface is a u32 which specifies the connection type used
 between the controller and the PHY.  Examples are GMII, MII,
 RGMII, and SGMII.  For a full list, see include/linux/phy.h

 Now just make sure that phydev->supported and phydev->advertising have any
 values pruned from them which don't make sense for your controller (a 10/100
 controller may be connected to a gigabit capable PHY, so you would need to
 mask off SUPPORTED_1000baseT*).  See include/linux/ethtool.h for definitions
 for these bitfields. Note that you should not SET any bits, or the PHY may
 get put into an unsupported state.

 ..."

However, 'drivers/net/ethernet/aurora/nb8800.c' for example, does SETs some
bits (in function 'nb8800_pause_adv').

I checked 'drivers/net/ethernet/broadcom/genet/bcmmii.c' and that one CLEARs
bits (as per the documentation).

Does anybody knows what is the correct/recommended approach?

Best regards,

Sebastian

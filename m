From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: why phy_state_machine changes phydev->state from PHY_NOLINK to PHY_RUNNING
Date: Mon, 14 Apr 2014 15:59:32 +0530
Message-ID: <CAHPKR9LB=mMjs2ZVbnU4VRO=RqYCh-qy+4USqY8HBf0DjGP1TQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37571 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154AbaDNK3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 06:29:33 -0400
Received: by mail-wi0-f169.google.com with SMTP id hm4so5144982wib.2
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 03:29:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

When phydev->state is PHY_NOLINK, phy_state_machine checks whether the
link becomes ready. And if the link is ready, it changes phydev->state
to PHY_RUNNING.

Without performing auto-negotiation or checking the state of
auto-negotiation, changing phydev->state to PHY_RUNNING is correct?

My understanding is,
1. At boot time, phydev->state comes to PHY_UP
2. phy_state_machine calls phy_start_aneg to start aneg as the state is PHY_UP
3. phy_start_aneg initiates auto-negotiation and changes the state to PHY_AN
4. While state is PHY_AN, phy_state_machine checks whether
auto-negotiatin completed. If completed, it changes the state to
PHY_RUNNING. If in case link is down, it makes the state to PHY_NOLINK
5. When state is PHY_NOLINK, phy_state_machine checks whether link
becomes ready. If link is ready it changes state to PHY_RUNNING

Without checking the state of auto-negotiation, phy_state_machine
changes phydev->state to PHY_RUNNING. Is this correct approach?

But if we consider PHY_RESUMING case, it checks for completion of
auto-negotiation in case AUTONEG_ENABLE is set. If it is completed
only, phydev->state is set to PHY_RUNNING.

Kindly correct me if I'm wrong.

Regards,
K.Balakumaran

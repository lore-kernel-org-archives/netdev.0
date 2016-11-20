From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v2] net: phy: phy drivers should not set SUPPORTED_[Asym_]Pause
Date: Sun, 20 Nov 2016 10:08:44 -0600
Message-ID: <CAOZdJXX5j9EVB8UtJK7u4-q4yFFtPBdWnWhL5aO_gGvL7fLTUg@mail.gmail.com>
References: <1478821561-26498-1-git-send-email-timur@codeaurora.org> <cf18464c-e225-af5d-9251-f2553b93b9ff@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, jon.mason@broadcom.com,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:47118 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753077AbcKTQIr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 11:08:47 -0500
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        (Authenticated sender: timur@smtp.codeaurora.org)
        by smtp.codeaurora.org (Postfix) with ESMTPSA id 198B8614DE
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 16:08:46 +0000 (UTC)
Received: by mail-io0-f180.google.com with SMTP id x94so22260147ioi.3
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 08:08:46 -0800 (PST)
In-Reply-To: <cf18464c-e225-af5d-9251-f2553b93b9ff@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2016 at 12:35 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> if (!(drv->features & (SUPPORTED_Pause | SUPPORTED_AsymPause))
>         phydev->supported |= SUPPORTED_Pause | SUPPORTED_AsymPause;

How about, if either bit is set in drv->features, then assume the phy
driver really knows what it's doing, and just copy those bits to
phydev->supported?

if (drv->features & (SUPPORTED_Pause | SUPPORTED_AsymPause)) {
    phydev->supported &= ~(SUPPORTED_Pause | SUPPORTED_AsymPause);
    phydev->supported |= drv->features & (SUPPORTED_Pause |
SUPPORTED_AsymPause);
} else
    phydev->supported |= SUPPORTED_Pause | SUPPORTED_AsymPause;

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.

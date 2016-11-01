From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [RFC] net: phy: phy drivers should not set
 SUPPORTED_Pause or SUPPORTED_Asym_Pause
Date: Tue, 1 Nov 2016 11:35:43 -0700
Message-ID: <aa0224f1-814a-d281-ad26-6c8086e40658@gmail.com>
References: <1478020715-25578-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35537 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752077AbcKASfq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 14:35:46 -0400
Received: by mail-pf0-f195.google.com with SMTP id i88so968780pfk.2
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 11:35:46 -0700 (PDT)
In-Reply-To: <1478020715-25578-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2016 10:18 AM, Timur Tabi wrote:
> Pause frames are a feature that is supported by the MAC.  It is the MAC
> that generates the frames and that processes them.  Thy PHY can only be
> configured to allow them to pass.  Therefore, pause frame support in the
> PHY should only be enabled if the MAC wants it enabled.  It should not be
> forced on all the time.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

So in premise, this is good, and is exactly what I have in mind for the
series that I am cooking, but if we apply this alone, without a change
in drivers/net/phy/phy.c which adds SUPPORTED_Pause |
SUPPORTED_AsymPause to phydev->features, we are basically breaking the
Ethernet MAC drivers that don't explicitly override phydev->features and
yet rely on that to get flow control to work.
-- 
Florian

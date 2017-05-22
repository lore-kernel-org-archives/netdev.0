From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Mon, 22 May 2017 14:10:20 -0700
Message-ID: <0528e1fa-2924-1286-578d-060419bfee49@gmail.com>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
 <20170522210215.GQ29447@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org,
        David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Andrew Lunn <andrew@lunn.ch>, Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33965 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932935AbdEVVKY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 17:10:24 -0400
Received: by mail-pf0-f194.google.com with SMTP id w69so22466323pfk.1
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 14:10:24 -0700 (PDT)
In-Reply-To: <20170522210215.GQ29447@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2017 02:02 PM, Andrew Lunn wrote:
>> 2. I'm preparing a patch that adds a command-line parameter to at803x that
>> makes this code conditional.
> 
> FYI:
> 
> A patch with a command line argument, i think you actually mean a
> module argument, is very likely to be rejected.

Even a module argument would be rejected. If you need platform/SoC
specific behavior propagated down to the PHY driver, several options exist:

- pass an agreed upon value for phy_flags to of_phy_connect() see
drivers/net/ethernet/broadcom/tg3.c and
drivers/net/ethernet/broadcom/genet/bcmgenet.c for instance and update
the driver to act on that "flags" see drivers/net/phy/broadcom.c and
drivers/net/phy/bcm7xxx.c

- register a PHY fixup which is specific to the board/SoC, and have the
PHY fixup do whatever is necessary for your platform (like setting
specific registers)

Preference goes for the first solution, but phy_flags is just a 32-bits
integer, so you could run out of bits.
-- 
Florian

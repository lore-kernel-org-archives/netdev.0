From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: dsa: bcm_sf2: Prevent GPHY shutdown for kexec'd
 kernels
Date: Thu, 20 Oct 2016 11:47:53 -0700
Message-ID: <605285c4-bc92-0a0d-87b9-5066e39078a3@gmail.com>
References: <1476981139-28889-1-git-send-email-f.fainelli@gmail.com>
 <20161020.144431.1484493400918018326.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35678 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933863AbcJTSr4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 14:47:56 -0400
Received: by mail-pf0-f195.google.com with SMTP id s8so6274334pfj.2
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:47:56 -0700 (PDT)
In-Reply-To: <20161020.144431.1484493400918018326.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2016 11:44 AM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Thu, 20 Oct 2016 09:32:19 -0700
> 
>> For a kernel that is being kexec'd we re-enable the integrated GPHY in
>> order for the subsequent MDIO bus scan to succeed and properly bind to
>> the bcm7xxx PHY driver. If we did not do that, the GPHY would be shut
>> down by the time the MDIO driver is probing the bus, and it would fail
>> to read the correct PHY OUI and therefore bind to an appropriate PHY
>> driver. Later on, this would cause DSA not to be able to successfully
>> attach to the PHY, and the interface would not be created at all.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Applied, but I have to wonder...
> 
> If enabling the GPHY is necessary for proper probing, why isn't the
> kexec kernel enabling it properly?

The GPHY enable control is unfortunately located in the switch register
block space and is dependent upon the switch port to be
enabled/accessible, which the DSA layer won't create if the GPHY is not
successfully probed and bound to a PHY driver. It did not appear that
probe deferral could help solve that problem, since MDIO and switch are
reasonable independent from each other.

This was the easiest way I could come up with, without requiring DT
changes and references to register blocks that are not quite relevant to
each other.

HTH
-- 
Florian

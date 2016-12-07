From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [v3] net: phy: phy drivers should not set
 SUPPORTED_[Asym_]Pause
Date: Tue, 6 Dec 2016 17:57:59 -0800
Message-ID: <f62595d4-2dd7-9cc3-7537-2ff186dadc8c@gmail.com>
References: <1481070443-15118-1-git-send-email-timur@codeaurora.org>
 <2c2aaf1d-05a5-d2bc-d04a-79224a4c6b43@gmail.com>
 <58476ACB.3030206@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, jon.mason@broadcom.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34193 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbcLGB6C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 20:58:02 -0500
Received: by mail-pf0-f194.google.com with SMTP id y68so19538220pfb.1
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 17:58:01 -0800 (PST)
In-Reply-To: <58476ACB.3030206@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2016 05:50 PM, Timur Tabi wrote:
> Florian Fainelli wrote:
>>> +    if (phydrv->features & (SUPPORTED_Pause | SUPPORTED_Asym_Pause)) {
>>> >+        phydev->supported &= ~(SUPPORTED_Pause |
>>> SUPPORTED_Asym_Pause);
>>> >+        phydev->supported |= phydrv->features &
>>> >+                     (SUPPORTED_Pause | SUPPORTED_Asym_Pause);
>> Is not the & (SUPPORTED_Pause | SUPPORTED_Asym_Pause) redundant here
>> anyway?
> 
> I'm just trying to be safe.  Can I be certain that those bits are
> already zero?

The bits are most likely not zero, since we have all the
PHY_GBIT_FEATURES bits defined in there as well, but I don't think that
is a real problem though, because we did this before:

        /* Start out supporting everything. Eventually,
         * a controller will attach, and may modify one
         * or both of these values
         */
        phydev->supported = phydrv->features;
        of_set_phy_supported(phydev);
        phydev->advertising = phydev->supported;

which is why this made me think the & (SUPPORTED_Pause |
SUPPPORTED_Asym_Pause) here is most likely redundant?

Thanks!
-- 
Florian

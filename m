From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v2 net-next 1/2] include: linux: Add helper function to
 check phy interface mode
Date: Thu, 18 May 2017 21:34:42 -0700
Message-ID: <CAKh23F=4+ecy07ODCtrTe1jAXN8e2wde52=uVau9-eyj7hBrMQ@mail.gmail.com>
References: <1495145624-29463-1-git-send-email-isubramanian@apm.com>
 <1495145624-29463-2-git-send-email-isubramanian@apm.com> <0c55a097-564d-58ea-8e64-d642a1d8fad7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>, patches <patches@apm.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f182.google.com ([209.85.217.182]:34176 "EHLO
        mail-ua0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750729AbdESEen (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 00:34:43 -0400
Received: by mail-ua0-f182.google.com with SMTP id u10so19613622uaf.1
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 21:34:43 -0700 (PDT)
In-Reply-To: <0c55a097-564d-58ea-8e64-d642a1d8fad7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 3:19 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 05/18/2017 03:13 PM, Iyappan Subramanian wrote:
>> Added helper function that checks phy_mode is RGMII (all variants)
>> 'bool phy_interface_mode_is_rgmii(phy_interface_t mode)'
>>
>> Changed the following function, to use the above.
>> 'bool phy_interface_is_rgmii(struct phy_device *phydev)'
>>
>> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
>> Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
>> Suggested-by: Andrew Lunn <andrew@lunn.ch>
>
> Not sure why you have chosen include: linux as the subject since all
> changes done to that file typically had the "phy: " prefix, but the code
> changes are fine, thanks!

Thanks Florian.  I'll keep that in mind for future header file patches.  :-)

For now, if David Miller requests for the subject line change, I'll
re-post the patch.

>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>
>> ---
>>  include/linux/phy.h | 14 ++++++++++++--
>>  1 file changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/phy.h b/include/linux/phy.h
>> index 54ef458..5a808a2 100644
>> --- a/include/linux/phy.h
>> +++ b/include/linux/phy.h
>> @@ -716,14 +716,24 @@ static inline bool phy_is_internal(struct phy_device *phydev)
>>  }
>>
>>  /**
>> + * phy_interface_mode_is_rgmii - Convenience function for testing if a
>> + * PHY interface mode is RGMII (all variants)
>> + * @mode: the phy_interface_t enum
>> + */
>> +static inline bool phy_interface_mode_is_rgmii(phy_interface_t mode)
>> +{
>> +     return mode >= PHY_INTERFACE_MODE_RGMII &&
>> +             mode <= PHY_INTERFACE_MODE_RGMII_TXID;
>> +};
>> +
>> +/**
>>   * phy_interface_is_rgmii - Convenience function for testing if a PHY interface
>>   * is RGMII (all variants)
>>   * @phydev: the phy_device struct
>>   */
>>  static inline bool phy_interface_is_rgmii(struct phy_device *phydev)
>>  {
>> -     return phydev->interface >= PHY_INTERFACE_MODE_RGMII &&
>> -             phydev->interface <= PHY_INTERFACE_MODE_RGMII_TXID;
>> +     return phy_interface_mode_is_rgmii(phydev->interface);
>>  };
>>
>>  /*
>>
>
>
> --
> Florian

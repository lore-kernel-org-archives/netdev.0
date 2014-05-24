From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH 2/3] net: of_mdio: add of_mdiobus_link_phydev()
Date: Sat, 24 May 2014 09:25:57 +0200
Message-ID: <53804985.7030204@gmail.com>
References: <1399739875-16434-1-git-send-email-zonque@gmail.com> <1399739875-16434-3-git-send-email-zonque@gmail.com> <CAGVrzcbPd8c9Q3njGX=YutZyrP+y5BSUS-bZeJje-_AaSy_tqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	mugunthanvnm <mugunthanvnm@ti.com>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:53058 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaEXH0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 03:26:00 -0400
Received: by mail-wi0-f171.google.com with SMTP id cc10so1820442wib.16
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 00:25:59 -0700 (PDT)
In-Reply-To: <CAGVrzcbPd8c9Q3njGX=YutZyrP+y5BSUS-bZeJje-_AaSy_tqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2014 09:35 PM, Florian Fainelli wrote:
> 2014-05-10 9:37 GMT-07:00 Daniel Mack <zonque@gmail.com>:

>> +/**
>> + * of_mdiobus_link_phydev - Find a device node for a phy
>> + * @mdio: pointer to mii_bus structure
>> + * @phydev: phydev for which the of_node pointer should be set
>> + *
>> + * Walk the list of subnodes of a mdio bus and look for a node that matches the
>> + * phy's address with its 'reg' property. If found, set the of_node pointer for
>> + * the phy. This allows auto-probed pyh devices to be supplied with information
>> + * passed in via DT.
>> + */
>> +void of_mdiobus_link_phydev(struct mii_bus *mdio,
>> +                           struct phy_device *phydev)
>> +{
>> +       struct device *dev = &phydev->dev;
>> +       struct device_node *child;
>> +
>> +       if (dev->of_node)
>> +               return;
> 
> This should be:
> 
>             if (dev->of_node || !mdio->dev_of_node)
>                     return;
> 
> a system with for instance non-DT probed MDIO busses such as the
> special fixed MDIO bus will not have such an of_node pointer and we
> will have a null pointer during the first iteration of the for_each_*
> loop.
> 
> arguably of_get_next_available_child() could be updated to handle a
> NULL parent device_node, but I think it clearer to add this check
> here.

Good catch! I'll change that, add your Reviewed-by and resend!


Thanks,
Daniel

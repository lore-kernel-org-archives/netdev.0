From: Jeroen Hofstee <jhofstee@victronenergy.com>
Subject: Re: [PATCH] net: cpsw: fix obtaining mac address for am3517
Date: Fri, 21 Oct 2016 09:36:22 +0200
Message-ID: <b713c697-3e42-4621-5d65-ab69c979d8be@victronenergy.com>
References: <1476993351-23065-1-git-send-email-jhofstee@victronenergy.com>
 <20161021063851.6frul6pemo52i7ot@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0100.outbound.protection.outlook.com ([104.47.2.100]:31616
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751260AbcJUHga (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 03:36:30 -0400
In-Reply-To: <20161021063851.6frul6pemo52i7ot@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Tony,

On 21-10-16 08:38, Tony Lindgren wrote:
> * Jeroen Hofstee <jhofstee@victronenergy.com> [161020 12:57]:
>> Commit b6745f6e4e63 ("drivers: net: cpsw: davinci_emac: move reading mac
>> id to common file") did not only move the code for an am3517, it also
>> added the slave parameter, resulting in a invalid (all zero) mac address
>> being returned. So change it back to always read from slave zero, so it
>> works again.
> Hmm doesn't this now break it for cpsw with two instances?
>

Yes, well, they get the same mac address at least. But does it matter?
This changes davinci_emac_3517_get_macid, the only way to get there
is:

     if (of_device_is_compatible(dev->of_node, "ti,am3517-emac"))
         return davinci_emac_3517_get_macid(dev, 0x110, slave, mac_addr)

and the only user of ti,am3517-emac is arch/arm/boot/dts/am3517.dtsi,
which only has one emac. So the change is already am3517 specific.

> We may need am3517 specific quirk flag instead?

Given above, it is already am3517 specific. Let me know if you prefer this
route then I will have a look at it.

Regards,
Jeroen

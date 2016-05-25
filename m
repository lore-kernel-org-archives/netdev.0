From: Amr Bekhit <amrbekhit@gmail.com>
Subject: Re: Davicom DM9162 PHY supported in the kernel?
Date: Wed, 25 May 2016 14:20:58 +0100
Message-ID: <CAOLz05ryCqYboVLN7aFKTj6r0H54gNCu43063mS9y+GY8T30Gw@mail.gmail.com>
References: <CAOLz05qgn2-9Qxm1cR7mXa67GAwD2SGbMnbeeEBrYeSPsBexuw@mail.gmail.com>
 <5717C45F.30205@gmail.com> <CAOLz05pidfdJXR58a+xjvp02EyPhUJnz9odpM-VFtkCQ2bhtNQ@mail.gmail.com>
 <20160503153659.GA29815@lunn.ch> <CAOLz05r-JEk2JV7PONsPhkaxCUankB6XThFgo4DO+gCf1p9c4g@mail.gmail.com>
 <20160509120634.GQ7972@lunn.ch> <CAOLz05o5SELBH6LovChQrFXQWXOZANhrYrTNcuktM_nKnp10VQ@mail.gmail.com>
 <20160524163047.GF8897@lunn.ch> <CAOLz05rwjEUpeSgUxc9oJYsPaYvmTV96YESc5=yxQtwHRFww6w@mail.gmail.com>
 <20160525123941.GA21924@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37028 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753623AbcEYNVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 09:21:20 -0400
Received: by mail-wm0-f48.google.com with SMTP id z87so62434271wmh.0
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 06:21:19 -0700 (PDT)
In-Reply-To: <20160525123941.GA21924@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

I've uploaded the device tree to http://pastebin.com/tNp2PnW4.

On 25 May 2016 at 13:39, Andrew Lunn <andrew@lunn.ch> wrote:
> On Wed, May 25, 2016 at 11:28:37AM +0100, Amr Bekhit wrote:
>> Hi Andrew,
>>
>> I added the following line to genphy_read_status to print out the value of BMCR:
>>
>>  phydev->lp_advertising = 0;
>>
>> +printk(KERN_DEBUG "MII_BMCR: 0x%04X\n", phy_read(phydev, MII_BMCR));
>>
>>  if (AUTONEG_ENABLE == phydev->autoneg) {
>>
>> After booting up the kernel and running ifconfig eth0 up, I get the
>> following in kernel log:
>>
>> [   83.890625] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
>> [   85.328125] MII_BMCR: 0x1000
>> [   86.328125] MII_BMCR: 0x1000
>> [   87.328125] MII_BMCR: 0x3100
>> [   87.328125] macb f802c000.ethernet eth0: link up (100/Full)
>> [   87.328125] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>> [   88.328125] MII_BMCR: 0x3100
>> [   89.328125] MII_BMCR: 0x3100
>> [   90.328125] MII_BMCR: 0x3100
>>
>> So it appears that after bringing the interface up, the PHY is
>> configured for 100Mbps, autoneg enabled and duplex mode. The PHY is
>> not isolated or powered down.
>
> So this all looks good. So it suggests your problem is between the MAC
> and the PHY, since the PHY is able to talk to the PHY on the other end
> of the cable.
>
> What do you have in device tree?
>
>      Andrew

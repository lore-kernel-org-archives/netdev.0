From: Amr Bekhit <amrbekhit@gmail.com>
Subject: Re: Davicom DM9162 PHY supported in the kernel?
Date: Wed, 25 May 2016 11:28:37 +0100
Message-ID: <CAOLz05rwjEUpeSgUxc9oJYsPaYvmTV96YESc5=yxQtwHRFww6w@mail.gmail.com>
References: <CAOLz05qgn2-9Qxm1cR7mXa67GAwD2SGbMnbeeEBrYeSPsBexuw@mail.gmail.com>
 <5717C45F.30205@gmail.com> <CAOLz05pidfdJXR58a+xjvp02EyPhUJnz9odpM-VFtkCQ2bhtNQ@mail.gmail.com>
 <20160503153659.GA29815@lunn.ch> <CAOLz05r-JEk2JV7PONsPhkaxCUankB6XThFgo4DO+gCf1p9c4g@mail.gmail.com>
 <20160509120634.GQ7972@lunn.ch> <CAOLz05o5SELBH6LovChQrFXQWXOZANhrYrTNcuktM_nKnp10VQ@mail.gmail.com>
 <20160524163047.GF8897@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37145 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100AbcEYK26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 06:28:58 -0400
Received: by mail-wm0-f50.google.com with SMTP id z87so56622481wmh.0
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 03:28:57 -0700 (PDT)
In-Reply-To: <20160524163047.GF8897@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

I added the following line to genphy_read_status to print out the value of BMCR:

 phydev->lp_advertising = 0;

+printk(KERN_DEBUG "MII_BMCR: 0x%04X\n", phy_read(phydev, MII_BMCR));

 if (AUTONEG_ENABLE == phydev->autoneg) {

After booting up the kernel and running ifconfig eth0 up, I get the
following in kernel log:

[   83.890625] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   85.328125] MII_BMCR: 0x1000
[   86.328125] MII_BMCR: 0x1000
[   87.328125] MII_BMCR: 0x3100
[   87.328125] macb f802c000.ethernet eth0: link up (100/Full)
[   87.328125] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   88.328125] MII_BMCR: 0x3100
[   89.328125] MII_BMCR: 0x3100
[   90.328125] MII_BMCR: 0x3100

So it appears that after bringing the interface up, the PHY is
configured for 100Mbps, autoneg enabled and duplex mode. The PHY is
not isolated or powered down.

On 24 May 2016 at 17:30, Andrew Lunn <andrew@lunn.ch> wrote:
> On Tue, May 24, 2016 at 05:09:35PM +0100, Amr Bekhit wrote:
>> Hi Andrew,
>>
>> > How about adding a printk() in genphy_read_status().
>>
>> Would you be able to point me to some more information about these
>> status bits, please?
>
> You can get the datasheet from here:
>
> http://www.davicom.com.tw/userfile/24247/DM9162_DM9162I-12-MCO-DS-F01_08062014.pdf
>
> I would start by looking at the BMCR register. The
> genphy_read_status() function should get called about once per second,
> so that is an O.K. place to add debug prints, and there is example
> code for reading MII_BMCR.
>
>      Andrew

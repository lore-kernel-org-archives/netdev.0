From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: sky2: allow mac to come from dt
Date: Wed, 05 Mar 2014 21:15:51 +0300
Message-ID: <531769D7.80507@cogentembedded.com>
References: <1394000535-25559-1-git-send-email-tharvey@gateworks.com>	<5317318B.5020406@cogentembedded.com> <CAJ+vNU2Uzsriq6e1ef6iH7omTkGGSxz=ox=XquUTw5MFvQDFCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: Tim Harvey <tharvey@gateworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:47613 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755236AbaCERPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 12:15:48 -0500
Received: by mail-lb0-f177.google.com with SMTP id z11so886347lbi.8
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 09:15:46 -0800 (PST)
In-Reply-To: <CAJ+vNU2Uzsriq6e1ef6iH7omTkGGSxz=ox=XquUTw5MFvQDFCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/05/2014 06:38 PM, Tim Harvey wrote:

>>> The driver reads the mac address from the device registers which would
>>> need to have been programmed by the bootloader.  This patch adds
>>> the ability to pull the mac from devicetree via the pci device dt node.

>>     I highly doubt that "[local-]mac-address" prop would be added to
>> (autodiscovered) PCI device node.

> I wouldn't have done this if I didn't need it ;)

> The u-boot bootloader will do this for boards supporting devicetree.
> Specifically, it will take the ethaddr/eth<n<addr/etc env vars and
> apply a local-mac-address property to the devicetree using ethernet<n>
> devicetree aliases.  This is to support MAC addresses coming from
> EEPROM, eFUSE, etc.  The key here is that it doesn't need to know
> where in the tree the eth devices are because it makes use of the
> aliases node.

> This of course requires that you do have an ethernet<n> alias to your
> PCI based network device in your dt which I agree may seem strange for
> an auto-probed bus, but in the case of a bootloader without PCI
> support and/or sky2 support this seems the proper way to get the MAC
> address from the bootloader to the driver.

    Ah, thanks for the explanation.

>> [...]

>>> @@ -4805,8 +4808,27 @@ static struct net_device *sky2_init_netdev(struct
>>> sky2_hw *hw, unsigned port,
>>>
>>>          dev->features |= dev->hw_features;
>>>
>>> +       /* try to get mac address in the following order:
>>> +        * 1) from device tree data
>>> +        * 2) from internal registers set by bootloader
>>> +        */
>>> +       iap = NULL;
>>> +       if (IS_ENABLED(CONFIG_OF)) {
>>> +               struct device_node *np = hw->pdev->dev.of_node;
>>> +               if (np)
>>> +                       iap = (unsigned char *) of_get_mac_address(np);
>>> +       }
>>> +
>>> +       /* 2) mac registers set by bootloader
>>> +        */

    Why not make it one-line? And it's kind of repetitive.

>>> +       if (!iap || !is_valid_ether_addr(iap)) {
>>> +               memcpy_fromio(&tmpaddr, hw->regs + B2_MAC_1 + port * 8,
>>> +                       ETH_ALEN);

>>     This line should start right under & on the previous line.

> agreed - not sure why checkpatch.pl didn't catch that

    It catches this only with --strict option.

>> WBR, Sergei

> Thanks for the review!

    Not at all.

> Tim

WBR, Sergei

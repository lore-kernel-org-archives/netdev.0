From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: DSA and underlying 802.1Q encapsulation
Date: Wed, 27 May 2015 14:02:34 -0700
Message-ID: <556630EA.7060707@roeck-us.net>
References: <1183592753.514019.1432679397515.JavaMail.zimbra@savoirfairelinux.com> <20150526225142.GB26454@roeck-us.net> <1250227394.1145458.1432759717091.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Chris Healy <cphealy@gmail.com>,
	=?UTF-8?B?SsOpcm9tZSBPdWZlbGxh?=
	<jerome.oufella@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:35270 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbbE0VCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 17:02:39 -0400
In-Reply-To: <1250227394.1145458.1432759717091.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2015 01:48 PM, Vivien Didelot wrote:
> Hi Guenter,
>
>> Interesting question. Does the underlying network device support VLAN HW
>> acceleration (NETIF_F_HW_VLAN_CTAG_RX, NETIF_F_HW_VLAN_CTAG_TX) ?
>
> Yes, in our case, it's an IGB device.
>
> I also set the DSA slave_dev->features and slave_dev->vlan_features to
> master->vlan_features | NETIF_F_VLAN_FEATURES | NETIF_F_HW_SWITCH_OFFLOAD,
> not sure if it is good or not.
>
I have experimented with NETIF_F_HW_VLAN_CTAG_FILTER, with associated code
in the switch driver, to provide vlan filtering in the switch, but so far
I think I am doing something wrong.

Do you have lock debugging enabled in your code ? I am getting a recursive
lock warning due to a recursive call to dev_mc_sync(). I think we may have
to implement lock nesting for dsa, similar to how it id done for vlan
support, but I have not been able to figure out how exactly it works yet.

>> If yes, the dsa code may need to move the tag into the header.
>> If we are lucky, a call to vlan_hwaccel_push_inside() might do it.
>
> Thanks, I'm currently looking into it and doing some tests, I'm coming back to
> you asap.
>
>> Do you have some vlan dsa code to share, by any chance ? That might
>> save me some time, as I am looking into it as well.
>
> Yes, I am about the send an RFC for fully integrated 802.1q VLAN support on
> Marvell 88E6352 devices.
>

Excellent, that is going to safe me a lot of work! If you don't mind,
please Cc: me as I am not subscribed to the network mailing list.

Thanks,
Guenter

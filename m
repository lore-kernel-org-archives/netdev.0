From: Bhadram Varka <vbhadram@nvidia.com>
Subject: RE: netdev carrier changes is one even after ethernet link up.
Date: Thu, 31 Aug 2017 06:03:10 +0000
Message-ID: <ec9b998eae874abf96ec8f378aea2610@bgmail102.nvidia.com>
References: <974898714b3e4e59b933983ded977ce2@bgmail102.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: linux-netdev <netdev@vger.kernel.org>
To: "andrew@lunn.ch" <andrew@lunn.ch>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate15.nvidia.com ([216.228.121.64]:7089 "EHLO
        hqemgate15.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750711AbdHaGE3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 02:04:29 -0400
In-Reply-To: <974898714b3e4e59b933983ded977ce2@bgmail102.nvidia.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ netdev

From: Bhadram Varka 
Sent: Thursday, August 31, 2017 11:24 AM
To: 'andrew@lunn.ch' <andrew@lunn.ch>; 'f.fainelli@gmail.com' <f.fainelli@gmail.com>
Cc: linux-netdev <netdev@vger.kernel.org>
Subject: netdev carrier changes is one even after ethernet link up.

Hi,

I have observed that carrier_changes is one even in case of the ethernet link is up.
 
After investigating the code below is my observation -

ethernet_driver_probe()
+--->phy_connect()
|     +--->phy_attach_direct()
|           +---> netif_carrier_off()    : which increments carrier_changes to one.
+--->register_netdevice() : will the carrier_changes becomes zero here ?
+--->netif_carrier_off(): not increment the carrier_changes since __LINK_STATE_NOCARRIER already set.
 
>From ethernet driver open will start the PHY and trigger the phy_state_machine. 
Phy_state_machine workqueue calling netif_carrier_on() once the link is UP.
netif_carrier_on() increments the carrier_changes by one.
 
After link is UP if we check the carrier_changes sysfs node - it will be one only.
 
$ cat /sys/class/net/eth0/carrier_changes
1
 
After reverting the change - https://lkml.org/lkml/2016/1/9/173 (net: phy: turn carrier off on phy attach) then I could see the carrier changes incremented to 2 after Link UP.
$ cat /sys/class/net/eth0/carrier_changes
2

Thanks,
Bhadram.
-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------

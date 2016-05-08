From: Philippe Reynes <tremyfr@gmail.com>
Subject: Re: [PATCH v2 2/3] net: ethernet: fec: use phydev from struct net_device
Date: Mon, 09 May 2016 00:47:38 +0200
Message-ID: <572FC20A.5030805@gmail.com>
References: <1462743877-31738-1-git-send-email-tremyfr@gmail.com>  <1462743877-31738-3-git-send-email-tremyfr@gmail.com> <1462746137.2634.67.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, davem@davemloft.net, kan.liang@intel.com,
	decot@googlers.com, aduyck@mirantis.com, jiri@mellanox.com,
	jacob.e.keller@intel.com, tom@herbertland.com, andrew@lunn.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36057 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbcEHWrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 18:47:47 -0400
In-Reply-To: <1462746137.2634.67.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/16 00:22, Ben Hutchings wrote:
> On Sun, 2016-05-08 at 23:44 +0200, Philippe Reynes wrote:
>> The private structure contain a pointer to phydev, but the structure
>> net_device already contain such pointer. So we can remove the pointer
>> phydev in the private structure, and update the driver to use the one
>> contained in struct net_device.
>
> But there is no central code that updates the pointer, so:

The function phy_attach_direct and phy_detach update the pointer
phydev in the struct net_device.

>
> [...]
>> @@ -1928,7 +1926,6 @@ static int fec_enet_mii_probe(struct net_device *ndev)
>>
>>   	phy_dev->advertising = phy_dev->supported;
>>
>> -	fep->phy_dev = phy_dev;
>
> you need to assign ndev->phydev here

The function fec_enet_mii_probe call of_phy_connect,
which call phy_connect_direct, which call phy_attach_direct.
This last function update the pointer phydev of struct net_device.

> [...]
>> @@ -2875,8 +2869,7 @@ fec_enet_close(struct net_device *ndev)
>>   		fec_stop(ndev);
>>   	}
>>
>> -	phy_disconnect(fep->phy_dev);
>> -	fep->phy_dev = NULL;
>> +	phy_disconnect(ndev->phydev);
> [...]
>
> and you need to set it to NULL here.

The function fec_enet_close call phy_disconnect, which call phy_detach.
This last function set the pointer phydev in the struct net_device to NULL.


So from my understanding, those two lines aren't usefull.
May you confirm that I'm on the right way please ?

  
> Ben.
>

Philippe

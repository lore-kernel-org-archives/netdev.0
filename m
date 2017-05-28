From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [patch net-next 0/9] mlxsw: Support firmware flash
Date: Sun, 28 May 2017 10:26:49 +0300
Message-ID: <0daa5c5a-377c-767f-ea19-26c1f22bd30c@mellanox.com>
References: <ea7cf005-1f6c-aa87-db90-03d7c77c7d56@mellanox.com>
 <BLUPR0701MB2004EB2F32B4C8C42C5020458DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
 <fba5a440-ba1e-84bd-d2d2-d011406d3a4a@mellanox.com>
 <20170523.113859.1803057381093280239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <Yuval.Mintz@cavium.com>, <jiri@resnulli.us>,
        <netdev@vger.kernel.org>, <idosch@mellanox.com>,
        <mlxsw@mellanox.com>, <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50064.outbound.protection.outlook.com ([40.107.5.64]:30014
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750794AbdE1H1D (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 28 May 2017 03:27:03 -0400
In-Reply-To: <20170523.113859.1803057381093280239.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2017 06:38 PM, David Miller wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> Date: Tue, 23 May 2017 18:14:15 +0300
>
>> Sorry, I am not sure I understand. You think that drivers should not implement
>> ethtool's flash_device callback anymore? do you have an alternative for firmware
>> flash?
> As stated, export an MTD device.

So, after we have been going over MTD, it seems like it does not fit our needs
at all.

MTD device provides (erasable-)block access to a flash storage, where in our
case the firmware burn process is just pouring a binary BLOB into the device.
The driver is not aware of the internal storage used for storing the firmware as
it is not defined in our driver-hardware API.

Needless to say that block access has no meaning in our case, so any solution
that will involve MTD device to burn our firmware (if there is a solution at
all) will be a workaround and will not fit MTD purpose.

Apart for boot time firmware flash, which we have already pushed we would really
like to allow the user to ask for a specific firmware version. Do you have any
other solution for us apart from "ethtool -f"?

This problem is even more relevant in the Mellanox HCA driver team, which would
like to use that code in order to burn the HCA firmware, but not intend to
trigger it on boot time, which means that must have a way for the user to
trigger it.

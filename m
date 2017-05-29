From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [patch net-next 0/9] mlxsw: Support firmware flash
Date: Sun, 28 May 2017 17:17:35 -0700
Message-ID: <20170528171735.0e44878d@cakuba.lan>
References: <ea7cf005-1f6c-aa87-db90-03d7c77c7d56@mellanox.com>
        <BLUPR0701MB2004EB2F32B4C8C42C5020458DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
        <fba5a440-ba1e-84bd-d2d2-d011406d3a4a@mellanox.com>
        <20170523.113859.1803057381093280239.davem@davemloft.net>
        <0daa5c5a-377c-767f-ea19-26c1f22bd30c@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <Yuval.Mintz@cavium.com>,
        <jiri@resnulli.us>, <netdev@vger.kernel.org>,
        <idosch@mellanox.com>, <mlxsw@mellanox.com>,
        <bhutchings@solarflare.com>
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:41527 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750823AbdE2ARn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 28 May 2017 20:17:43 -0400
In-Reply-To: <0daa5c5a-377c-767f-ea19-26c1f22bd30c@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 28 May 2017 10:26:49 +0300, Yotam Gigi wrote:
> On 05/23/2017 06:38 PM, David Miller wrote:
> > From: Yotam Gigi <yotamg@mellanox.com>
> > Date: Tue, 23 May 2017 18:14:15 +0300
> >  
> >> Sorry, I am not sure I understand. You think that drivers should not implement
> >> ethtool's flash_device callback anymore? do you have an alternative for firmware
> >> flash?  
> > As stated, export an MTD device.  
> 
> So, after we have been going over MTD, it seems like it does not fit our needs
> at all.
> 
> MTD device provides (erasable-)block access to a flash storage, where in our
> case the firmware burn process is just pouring a binary BLOB into the device.
> The driver is not aware of the internal storage used for storing the firmware as
> it is not defined in our driver-hardware API.
> 
> Needless to say that block access has no meaning in our case, so any solution
> that will involve MTD device to burn our firmware (if there is a solution at
> all) will be a workaround and will not fit MTD purpose.
> 
> Apart for boot time firmware flash, which we have already pushed we would really
> like to allow the user to ask for a specific firmware version. Do you have any
> other solution for us apart from "ethtool -f"?

Could you elaborate on what the requirements are for "allowing users to
ask for a specific firmware version"?  How do the FWs differ?  I'm
asking because we are currently lacking ABI for selecting device
"modes".  Netronome has this problem.  Cavium has recently posted a
patch which used module parameter to flip between "OvS" and "basic NIC"
firmwares.

For Netronome we will definitely want a way to switch between at least
three applications so far - basic, OvS and eBPF - but I also feel like
we shouldn't limit that list, since anyone can write their own FW for
programmable NICs.

I think you were primarily concerned with writing persistent storage so
far.  Does "allowing the user to ask..." means write flash and reboot or
also a runtime switch?  I think we probably need both?

> This problem is even more relevant in the Mellanox HCA driver team, which would
> like to use that code in order to burn the HCA firmware, but not intend to
> trigger it on boot time, which means that must have a way for the user to
> trigger it.

What would the requirements for the HCA team be?  Is it about loading
different code or loading HW settings?

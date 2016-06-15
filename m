From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH] net: smsc911x: If PHY doesn't have an interrupt then POLL
Date: Wed, 15 Jun 2016 10:50:47 -0500
Message-ID: <57617957.9070201@arm.com>
References: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
 <46b56679-e92a-a8f9-f290-f67495169bdc@cogentembedded.com>
 <5760701F.6000204@arm.com> <20160614222615.GK12832@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, steve.glendinning@shawell.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:38584 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932700AbcFOPut (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 11:50:49 -0400
In-Reply-To: <20160614222615.GK12832@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2016 05:26 PM, Andrew Lunn wrote:
>> 	This was DT as well with a recent fedora/NetworkManager. It
>> actually seems to be timing related to how fast the device gets
>> configured after the initial phy probe. There is something like a 1
>> second window or so where it will work, but if network manager takes
>> longer than that, the link state drops and cannot be brought back up
>> unless the cable is pulled, replugged while the netdevice is being
>> restarted.
>
> Ah!
>
> There is another bug in the driver. The phy is connected to the netdev
> after calling register_netdev(). You are supposed to do it before,
> because the interface is usable, and can be used, directly after the
> register.
>
> Move the call to smsc911x_mii_init() before the register_netdev().

	Yah, I buy that, and will move it an see what happens.

	But it doesn't solve the problem of the module use count being bumped 
in the probe rather than the ndo_open(). The users of 
phy_connect_direct() seem to be split between using it in the probe, and 
using it in the ndo_open (pxa168, and ax88796 for two examples of using 
it in the open).
	

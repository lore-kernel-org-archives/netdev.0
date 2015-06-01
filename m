From: Arun Parameswaran <aparames@broadcom.com>
Subject: Re: [PATCH 0/2] Fix couple of issues with 'ethtool' get/set API's
Date: Mon, 1 Jun 2015 14:00:45 -0700
Message-ID: <556CC7FD.6060002@broadcom.com>
References: <1432334609-3971-1-git-send-email-aparames@broadcom.com>		 <1433102379.6319.110.camel@decadent.org.uk>	 <556C92E3.3030707@broadcom.com> <1433182033.6319.178.camel@decadent.org.uk>	 <556CAEA9.5090003@broadcom.com> <1433186963.6319.195.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bwh@kernel.org>, <netdev@vger.kernel.org>,
	<jdzheng@broadcom.com>, <aparames@broadcom.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:19476 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbbFAVA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 17:00:57 -0400
In-Reply-To: <1433186963.6319.195.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-06-01 12:29 PM, Ben Hutchings wrote:
> On Mon, 2015-06-01 at 12:12 -0700, Arun Parameswaran wrote:
>> On 15-06-01 11:07 AM, Ben Hutchings wrote:
>>> On Mon, 2015-06-01 at 10:14 -0700, Arun Parameswaran wrote:
>>>> On 15-05-31 12:59 PM, Ben Hutchings wrote:
>>>>> On Fri, 2015-05-22 at 15:43 -0700, Arun Parameswaran wrote:
>>>>>> Hi,
>>>>>> The patch fixes 2 issues with 'ethtool' getting/setting parametres in
>>>>>> the do_gset() do_sset() API's.
>>>>>>
>>>>>> I have pushed a patch to the Kernel to fix an issue in the handling of
>>>>>> the 'ethtool' commands which got accepted.
>>>>>> This Kernel patch was based on Linux v4.1-rc4 and is available in:
>>>>>> https://github.com/Broadcom/cygnus-linux/tree/net-core-ethtool-fix-v1
>>>>>>
>>>>>> The Kernel was always clearing the command from the 'ethtool' resulting
>>>>>> in all operations to deal with PHY0. This prevents querying/setting
>>>>>> PHY 1's settings.
>>>>> [...]
>>>>>
>>>>> Each net device can be associated with a single PHY at a time, and the
>>>>> ETHTOOL_GSET implementation should fill in the PHY address in the
>>>>> ethtool_cmd::phy_address field.  Where there are multiple PHYs that can
>>>>> be connected to the net device's MAC, an ETHTOOL_SSET operation can be
>>>>> used to change that PHY address.
>>>>>
>>>> The above can be done by the driver when there is one PHY per MAC. In our
>>>> case we have multiple PHYs controlled by the same MAC. I should have
>>>> clarified this earlier, I apologize.
>>>
>>> I understand that you can have multiple PHYs on the same MDIO bus, but
>>> not how the MAC can use them at the same time.  Is this hardware level
>>> bonding?  Or are multiple PHYs needed for a single link?
>>>
>> We have an internal switch which manages the traffic to the PHY's (ports).
>> There is 1 PHY per external port.
>> The MAC is connected to the internal port of the switch.
> 
> Then you should create net devices for those external ports as well as
> the internal port.
We can only have one MAC address as we have only one MAC. So we prefer to
have a single net device which reflects the hardware better.

> 
> If I understand the switchdev API rightly, the external port devices
> should implement the ethtool {get,set}_settings operations and the
> ndo_switch_parent_id_get operation.  The existing net device should
> expose only the internal link to the switch (which presumably isn't
> configurable at all).
I agree, there can be an implementation like the above.
The switch can be handled in multiple ways, in our case we use one net
device as we are limited by the MAC.

Since the 'ethtool' provides the 'phyad' parameter to specifically
address a particular PHY, I think the 'ethtool' should allow for this,
irrespective of the net implementation. Wouldn't this make the 'ethtool'
flexible and detached from the network driver implementation.

> 
> [...]
>> But this prevents the 'ethtool' from being used to get/set data of
>> specific PHY's.
> 
> That is fine because it is meant to manage the net device's own link (in
> this case, the internal port), not other switch ports.
> 
> Ben.
> 

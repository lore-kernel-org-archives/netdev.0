From: Arun Parameswaran <aparames@broadcom.com>
Subject: Re: [PATCH 0/2] Fix couple of issues with 'ethtool' get/set API's
Date: Mon, 1 Jun 2015 12:12:41 -0700
Message-ID: <556CAEA9.5090003@broadcom.com>
References: <1432334609-3971-1-git-send-email-aparames@broadcom.com>	 <1433102379.6319.110.camel@decadent.org.uk> <556C92E3.3030707@broadcom.com> <1433182033.6319.178.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bwh@kernel.org>, <netdev@vger.kernel.org>,
	<jdzheng@broadcom.com>, <aparames@broadcom.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:28012 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541AbbFATMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 15:12:45 -0400
In-Reply-To: <1433182033.6319.178.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-06-01 11:07 AM, Ben Hutchings wrote:
> On Mon, 2015-06-01 at 10:14 -0700, Arun Parameswaran wrote:
>> On 15-05-31 12:59 PM, Ben Hutchings wrote:
>>> On Fri, 2015-05-22 at 15:43 -0700, Arun Parameswaran wrote:
>>>> Hi,
>>>> The patch fixes 2 issues with 'ethtool' getting/setting parametres in
>>>> the do_gset() do_sset() API's.
>>>>
>>>> I have pushed a patch to the Kernel to fix an issue in the handling of
>>>> the 'ethtool' commands which got accepted.
>>>> This Kernel patch was based on Linux v4.1-rc4 and is available in:
>>>> https://github.com/Broadcom/cygnus-linux/tree/net-core-ethtool-fix-v1
>>>>
>>>> The Kernel was always clearing the command from the 'ethtool' resulting
>>>> in all operations to deal with PHY0. This prevents querying/setting
>>>> PHY 1's settings.
>>> [...]
>>>
>>> Each net device can be associated with a single PHY at a time, and the
>>> ETHTOOL_GSET implementation should fill in the PHY address in the
>>> ethtool_cmd::phy_address field.  Where there are multiple PHYs that can
>>> be connected to the net device's MAC, an ETHTOOL_SSET operation can be
>>> used to change that PHY address.
>>>
>> The above can be done by the driver when there is one PHY per MAC. In our
>> case we have multiple PHYs controlled by the same MAC. I should have
>> clarified this earlier, I apologize.
> 
> I understand that you can have multiple PHYs on the same MDIO bus, but
> not how the MAC can use them at the same time.  Is this hardware level
> bonding?  Or are multiple PHYs needed for a single link?
> 
We have an internal switch which manages the traffic to the PHY's (ports).
There is 1 PHY per external port.
The MAC is connected to the internal port of the switch.

>> When we specify the 'phyad', in the command line, we were expecting the
>> 'ethtool' to fetch/set data for that 'phyad'. This is the intend of the
>> patch.
>>
>> With the patch (in 'ethtool' and Kernel), if 'phyad' is not specified, it
>> will still function as you described above, it will be up to the driver to
>> return the proper 'phyad' and related settings.
> [...]
> 
> But without the patch in ethtool and other programs calling this API
> (it's not just the ethtool command!), you get random junk as the
> phy_address.  How will you tell whether it's valid or not?
Yes, if other programs make use of the 'ethtool' commands, they will
have to clear the data structure. I think that the clearing of the command
data structure should be the responsibility of the programs calling it.
I understand that the programs didn't have to do it as Kernel was clearing
the command structure for them.

But this prevents the 'ethtool' from being used to get/set data of
specific PHY's.

> 
> Ben.
> 

Thanks
Arun

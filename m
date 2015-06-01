From: Arun Parameswaran <aparames@broadcom.com>
Subject: Re: [PATCH 0/2] Fix couple of issues with 'ethtool' get/set API's
Date: Mon, 1 Jun 2015 10:14:11 -0700
Message-ID: <556C92E3.3030707@broadcom.com>
References: <1432334609-3971-1-git-send-email-aparames@broadcom.com> <1433102379.6319.110.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bwh@kernel.org>, <netdev@vger.kernel.org>,
	<jdzheng@broadcom.com>, <aparames@broadcom.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:51332 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbbFAROQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 13:14:16 -0400
In-Reply-To: <1433102379.6319.110.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-05-31 12:59 PM, Ben Hutchings wrote:
> On Fri, 2015-05-22 at 15:43 -0700, Arun Parameswaran wrote:
>> Hi,
>> The patch fixes 2 issues with 'ethtool' getting/setting parametres in
>> the do_gset() do_sset() API's.
>>
>> I have pushed a patch to the Kernel to fix an issue in the handling of
>> the 'ethtool' commands which got accepted.
>> This Kernel patch was based on Linux v4.1-rc4 and is available in:
>> https://github.com/Broadcom/cygnus-linux/tree/net-core-ethtool-fix-v1
>>
>> The Kernel was always clearing the command from the 'ethtool' resulting
>> in all operations to deal with PHY0. This prevents querying/setting
>> PHY 1's settings.
> [...]
> 
> Each net device can be associated with a single PHY at a time, and the
> ETHTOOL_GSET implementation should fill in the PHY address in the
> ethtool_cmd::phy_address field.  Where there are multiple PHYs that can
> be connected to the net device's MAC, an ETHTOOL_SSET operation can be
> used to change that PHY address.
> 
The above can be done by the driver when there is one PHY per MAC. In our
case we have multiple PHYs controlled by the same MAC. I should have
clarified this earlier, I apologize.

When we specify the 'phyad', in the command line, we were expecting the
'ethtool' to fetch/set data for that 'phyad'. This is the intend of the
patch.

With the patch (in 'ethtool' and Kernel), if 'phyad' is not specified, it
will still function as you described above, it will be up to the driver to
return the proper 'phyad' and related settings.

> The ethtool API is not meant for controlling other PHYs that aren't
> connected to the MAC; if you want to do that then create more net
> devices for them or use the MDIO ioctls.
> 
In the SoC, there are multiple PHYs (in our case there are 2) controlled
by the same MAC. We are trying to use 'ethtool' to control both the PHYs
connected to the same MAC.

> 
> Ben.
> 

Thanks
Arun

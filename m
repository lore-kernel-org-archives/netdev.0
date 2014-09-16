From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] of: mdio: honor flags passed to of_phy_connect
Date: Tue, 16 Sep 2014 13:47:08 -0700
Message-ID: <5418A1CC.9090704@gmail.com>
References: <1410889776-11107-1-git-send-email-f.fainelli@gmail.com> <20140916.163951.1456738615389200706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:48088 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817AbaIPUr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:47:26 -0400
In-Reply-To: <20140916.163951.1456738615389200706.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/2014 01:39 PM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Tue, 16 Sep 2014 10:49:36 -0700
> 
>> Commit f9a8f83b04e0 ("net: phy: remove flags argument from phy_{attach,
>> connect, connect_direct}") removed the flags argument to the PHY library
>> calls to: phy_{attach,connect,connect_direct}.
>>
>> Most Device Tree aware drivers call of_phy_connect() with the flag
>> argument set to 0, but some of them might want to set a different value
>> there in order for the PHY driver to key a specific behavior based on
>> the phy_device::dev_flags value.
>>
>> Allow such drivers to set custom dev_flags as part of the
>> of_phy_connect() call since of_phy_connect() does start the PHY state
>> machine, it will call into the PHY driver config_init() callback which
>> is usually where a specific phy_flags value is important.
>>
>> Fixes: f9a8f83b04e0 ("net: phy: remove flags argument from phy_{attach, connect, connect_direct}")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> I do not see anyone passing non-zero in as the flags argument.

Right, I have a follow-up patch that will pass non-zero, I will just
submit everything at once so it is clear in what context and purpose
this gets used.

Thanks!

> 
> It is difficult for me to determine the impact of this patch,
> whether it should really go to 'net' and/or 'stable', etc.
> if you don't tell me who this could possibly break.
> 
> It's even worse when I do all of the searching around and
> cannot find a breakage case myself. :-/
> 

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vlan: Propagate MAC address changes properly
Date: Tue, 03 May 2016 00:16:51 -0400 (EDT)
Message-ID: <20160503.001651.132843090236435270.davem@davemloft.net>
References: <5723D930.6040004@brocade.com>
	<572489C5.3020502@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mmanning@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39813 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbcECEQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 00:16:55 -0400
In-Reply-To: <572489C5.3020502@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Manning <mmanning@brocade.com>
Date: Sat, 30 Apr 2016 11:32:37 +0100

> The MAC address of the physical interface is only copied to the VLAN
> when it is first created, resulting in an inconsistency after MAC
> address changes of only newly created VLANs having an up-to-date MAC.
> 
> Continuing to inherit the MAC address unless explicitly changed for
> the VLAN allows IPv6 EUI64 addresses for the VLAN to reflect the change
> and thus for DAD to behave as expected for the given MAC.
> 
> Signed-off-by: Mike Manning <mmanning@brocade.com>

What is this code really trying to achieve?

Is it "Propagate real device MAC changes to undelying vlan device,
but not if the user set the vlan MAC explicitly."?

If so, implement that instead of all of these confusing tests.

If the vlan device's set_mac_address operation is ever called,
set a boolean value in the vlan device private to true and test
it here.

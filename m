From: David Miller <davem@davemloft.net>
Subject: Re: =?iso-2022-jp-3?B?GyRCRXobJChQJTsbKEI6?= Re: [Patch]
 netxen_nic: Bugfix for wrong RUNNING status of NX3031 NICs with no link
Date: Thu, 02 Jan 2014 12:33:31 -0500 (EST)
Message-ID: <20140102.123331.611627665684699985.davem@davemloft.net>
References: <20140102.032423.2130522873875479421.davem@davemloft.net>
	<OFB91B6321.D74C0B57-ON48257C54.00308F8C-48257C54.0030D7E7@zte.com.cn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: li.fengmao@zte.com.cn, manish.chopra@qlogic.com,
	netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	sony.chacko@qlogic.com
To: jiang.biao2@zte.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51750 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274AbaABRdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 12:33:35 -0500
In-Reply-To: <OFB91B6321.D74C0B57-ON48257C54.00308F8C-48257C54.0030D7E7@zte.com.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jiang.biao2@zte.com.cn
Date: Thu, 2 Jan 2014 16:53:17 +0800

>> You cannot do this, because at the very exact moment you call
>> register_netdevice() the device can be brought up and once the
>> device is up the link can be brought up.
> 
>> Therefore if you invoke netif_carrier_off() right after
>> register_netdevice(), it can cancel out a legitimate
>> netif_carrier_on() call.
> 
> register_netdevice() should be call in probe(), at that time, is
> it impossible to bring up device because the driver loading has
> not finished?

Scripts in userspace listen for device events, such as registry, and
in response can immediately open the device.

That can occur before register_netdevice() returns, it is completely
and %100 asynchronous.

From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
Date: Mon, 28 Dec 2015 17:19:01 +0800
Message-ID: <5680FE85.60200@gmail.com>
References: <1450339417-31254-1-git-send-email-zyjzyj2000@gmail.com>
 <1586.1450389436@famine> <20151228084331.GA22747@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org, Boris.Shteinbock@windriver.com
To: Michal Kubecek <mkubecek@suse.cz>,
	Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34399 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbbL1JTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 04:19:07 -0500
Received: by mail-pf0-f194.google.com with SMTP id 65so6437039pff.1
        for <netdev@vger.kernel.org>; Mon, 28 Dec 2015 01:19:06 -0800 (PST)
In-Reply-To: <20151228084331.GA22747@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/28/2015 04:43 PM, Michal Kubecek wrote:
> On Thu, Dec 17, 2015 at 01:57:16PM -0800, Jay Vosburgh wrote:
>> <zyjzyj2000@gmail.com> wrote:
>>> In 802.3ad mode, the speed and duplex is needed. But in some NIC,
>>> there is a time span between NIC up state and getting speed and duplex.
>>> As such, sometimes a slave in 802.3ad mode is in up state without
>>> speed and duplex. This will make bonding in 802.3ad mode can not
>>> work well.
>>> To make bonding driver be compatible with more NICs, it is
>>> necessary to restrict the up state in 802.3ad mode.
>> 	What device is this?  It seems a bit odd that an Ethernet device
>> can be carrier up but not have the duplex and speed available.
> ...
>> 	In general, though, bonding expects a speed or duplex change to
>> be announced via a NETDEV_UPDATE or NETDEV_UP notifier, which would
>> propagate to the 802.3ad logic.
>>
>> 	If the device here is going carrier up prior to having speed or
>> duplex available, then maybe it should call netdev_state_change() when
>> the duplex and speed are available, or delay calling netif_carrier_on().
> I have encountered this problem (NIC having carrier on before being able
> to detect speed/duplex and driver not notifying when speed/duplex
> becomes available) with netxen cards earlier. But it was eventually
> fixed in the driver by commit 9d01412ae76f ("netxen: Fix link event
> handling.") so this example rather supports what you said.
>
>                                                            Michal Kubecek
Thanks a lot.
I checked the commit 9d01412ae76f ("netxen: Fix link event
handling."). The symptoms are the same with mine.

The root cause is different. In my problem, the root cause is that LINKS 
register
can not provide link_up and link_speed at the same time. There is a time 
span between
link_up and link_speed. My solution is to force to synchronize link_up 
and link_speed in
ixgbe X540 NIC.

Best Regards!
Zhu Yanjun

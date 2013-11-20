From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH RFC v1 0/7] net: phy: Ethernet PHY powerdown optimization
Date: Wed, 20 Nov 2013 21:54:19 +0100
Message-ID: <528D217B.5020500@gmail.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com> <20131120.153642.2045230991917379052.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:40991 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755140Ab3KTUyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 15:54:23 -0500
In-Reply-To: <20131120.153642.2045230991917379052.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2013 09:36 PM, David Miller wrote:
> From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> Date: Wed, 20 Nov 2013 21:21:46 +0100
>
>> Ethernet PHYs consume a significant amount of power when link is detected.
>> Especially, for embedded systems it can be easily 20-40% of total system
>> power. Now, currently most likely all ethernet drivers leave PHYs powered
>> on, even if the device is taken down. Also, some stupid boot loaders power
>> on all PHYs available.
>>
>> This RFC deals with saving power consumed by ethernet PHYs, that have no
>> corresponding ethernet device driver or are attached to ethernet devices
>> which are taken down by user request, i.e. ifconfig ethN down. Ports with
>> no link, i.e. cable removed, are already quite good at power saving due to
>> PHY internal link detection.
>
> The idea is sound and the goal is of course valuable, but it brings up
> a chronically reoccurring issue as of late.
>
> You cannot reset the PHY or take it down without somehow retaining the
> settings the PHY had when you bring it back up.

Right, as far as I understand BMCR powerdown, i.e. what is called in
genphy_suspend/resume, powers down the PHY but _does_ retain PHY config.
It is not resetting the device.

I haven't checked a lot of datasheets but [1] notes that "registers will
preserve their configuration". Even if we have PHYs that do not preserve
it, they should have a device specific callback for suspend/resume that
takes care of preserving it.

[1] http://www.ti.com/lit/an/snoa463a/snoa463a.pdf

> If I ifdown/ifup a device, my ethtool link configuration better be
> retained.
>
> This means the PHY layer must have a way to reprogram the device when
> it is brought back up, with whatever settings the software state
> things are there.
>

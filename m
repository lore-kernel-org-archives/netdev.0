From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net-next 0/4] net: dsa: mv88e6xxx: fix hardware bridging
Date: Wed, 14 Oct 2015 20:16:27 -0700
Message-ID: <561F1A8B.1040904@roeck-us.net>
References: <1444601318-20561-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20151014224617.GA10146@lunn.ch> <20151015012854.GA10868@ketchup.lan>
 <20151015025250.GA12436@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:53733 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbbJODQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 23:16:30 -0400
In-Reply-To: <20151015025250.GA12436@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/2015 07:52 PM, Andrew Lunn wrote:
> On Wed, Oct 14, 2015 at 09:28:55PM -0400, Vivien Didelot wrote:
>> On Oct. Thursday 15 (42) 12:46 AM, Andrew Lunn wrote:
>>> On Sun, Oct 11, 2015 at 06:08:34PM -0400, Vivien Didelot wrote:
>>>> DSA and its drivers currently hook the NETDEV_CHANGEUPPER net_device event in
>>>> order to configure the VLAN map of every port.
>>>>
>>>> This VLAN map is a feature of these switch chips to hardcode and restrict which
>>>> output ports a given input port can egress frames to.
>>>>
>>>> A Linux bridge is a simple untagged VLAN propagated by the bridge code itself.
>>>> With a proper 802.1Q support, a driver does not need this hook anymore, and
>>>> will simply program the related VLAN object.
>>>>
>>>> This patchset improves the hardware bridging code in the mv88e6xxx driver with
>>>> a strict 802.1Q mode.
>>>
>>> Hi Vivien
>>>
>>> I just tested this as part of net-next/master, and found a problem....
>>>
>>> If i do:
>>>
>>> ip link set lan0 up
>>> ip addr add 192.168.10.2/24 dev lan0
>>>
>>> It will not ping. Looking in sys/kernel/debug/dsa0/stats i see
>>> broadcast packets, probably ARP, being received at the port.
>>> But they are not being forwarded out the CPU port.
>>>
>>> If however i do
>>>
>>> brctl addbr br0
>>> brctl addif br0 lan0
>>> ip addr add 192.168.10.2/24 dev br0
>>> ip link set br0 up
>>>
>>> i can ping.
>>>
>>> So it looks like we are too restrictive by default. You should be able
>>> to use interfaces as they are, without a bridge.
>>
>> Correct, if the ports are not in a VLAN by default, they cannot talk.
>
> Hi Vivien
>
> This is a regression. Ports of the switch should work like normal
> Linux interfaces. And up until now, they did. This patchset changed
> that.
>
> As Florian pointed out, these interfaces are separated from each
> other. So you need something like a bridge per port by default, which
> then gets removed and replaced when a port is added to a Linux bridge.
>
> We also need to take care of VLANs. When the port is not a member of a
> linux bridge, i expect all VLAN tagged frames to be received, as well
> as untagged frames. This is normal Linux behaviour. But i never got
> around to testing this with DSA.
>

There was a reason for the original code. I had wondered how it is now
supposed to work. Guess this exchange explains it. Looking forward to see
how it is going to be fixed, and too bad I don't have time to be more
involved.

Guenter

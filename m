From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC 0/3] DSA and Marvell 88E6352 802.1q support
Date: Fri, 29 May 2015 15:42:29 -0700
Message-ID: <5568EB55.9090700@roeck-us.net>
References: <556723FF.7030606@roeck-us.net>	<1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com> <CAE4R7bA43Jg5e+DSySvG4X2ka0CXEk9K6eVv5fdN37EcLBoF_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>, Jiri Pirko <jiri@resnulli.us>
To: Scott Feldman <sfeldma@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:36959 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757050AbbE2Wmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 18:42:31 -0400
In-Reply-To: <CAE4R7bA43Jg5e+DSySvG4X2ka0CXEk9K6eVv5fdN37EcLBoF_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott,

On 05/28/2015 10:02 PM, Scott Feldman wrote:
> On Thu, May 28, 2015 at 2:37 PM, Vivien Didelot
> <vivien.didelot@savoirfairelinux.com> wrote:
>> This RFC is based on v4.1-rc3.
>>
>> It is meant to get a glance to the commits responsible to implement the
>> necessary NDOs between DSA and the Marvell 88E6352 switch driver.
>>
>> With this support, I am able to create VLANs with (un)tagged ports, setting
>> their default VID, from a bridge.
>>
>> To create a bridge containing all switch ports, with a VLAN ID 400, swp2 and
>> swp3 untagged (pvid), and swp4 tagged, the userspace commands look like this:
>>
>>      ip link add name br0 type bridge
>>      [...]
>>      ip link set dev swp2 up master br0
>>      [...]
>>      bridge vlan add vid 400 pvid untagged dev swp2
>>      bridge vlan add vid 400 pvid untagged dev swp3
>>      bridge vlan add vid 400 dev swp4
>>      [...]
>>      ip link add link br0 name br0.400 type vlan id 400
>>      [...]
>>      bridge vlan add dev br0 vid 400 self
>>
>> The code is currently being rebased to the latest net-next/master.
>>
>> Seems like the way to go now is through switchdev attr getter/setter...
>
> Indeed, for dsa_slave you should be able to port this to switchdev and
> set your ndo_bridge_setlink/dellink handlers to
> switchdev_port_bridge_setlink/dellink.  (And also implement the
> switchdev ops for vlans).
>
> If you use switchdev_port_bridge_setlink/dellink, you shouldn't need
> to implement ndo_vlan_rx_add_vid/ndo_vlan_rx_kill_vid at all.  The

Those functions are called from net/8021q/vlan_core.c if a vlan is configured
on or removed from an interface. Does that result in a call to setlink/dellink
as well, even if a switch port is not a member of a bridge group ?

Thanks,
Guenter

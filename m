From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 3/3] net: dsa: Allow configuration of CPU & DSA port
 speeds/duplex
Date: Fri, 19 Jun 2015 11:05:14 -0400 (EDT)
Message-ID: <2144581324.52952.1434726314482.JavaMail.zimbra@savoirfairelinux.com>
References: <1434129537-15252-1-git-send-email-andrew@lunn.ch> <1434129537-15252-3-git-send-email-andrew@lunn.ch> <557F0CD5.4070705@gmail.com> <536480200.118000.1434564592107.JavaMail.zimbra@savoirfairelinux.com> <20150618011159.GA22072@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	David <davem@davemloft.net>, Guenter Roeck <linux@roeck-us.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:58428 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752AbbFSPFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 11:05:22 -0400
In-Reply-To: <20150618011159.GA22072@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Jun 17, 2015, at 9:11 PM, Andrew Lunn andrew@lunn.ch wrote:
> On Wed, Jun 17, 2015 at 02:09:52PM -0400, Vivien Didelot wrote:
>> Hi Andrew, All,
>> 
>> On 12/06/15 10:18, Andrew Lunn wrote:
>> > By default, DSA and CPU ports are configured to the maximum speed the
>> > switch supports. However there can be use cases where the peer device
>> > port is slower. Allow a fixed-link property to be used with the DSA
>> > and CPU port in the device tree, and use this information to configure
>> > the port.
>> 
>> Would it be a good idea for DSA to expose the "cpu" port to userspace as well?
>> That way, it'd be possible to use ethtool to set the port speed and duplex
>> mode, or dump registers (this would have saved me quite some time in dev).
> 
> I have code which expose these via debugfs. So far, i have all
> registers, stats, ATU, and the scratch registers. For the patches to
> apply cleanly, they depend on these patches, so i've not posted them
> yet.

Yes I do have debug too, but via sysfs (with eventually write access) for:
GLOBAL1, GLOBAL2, cpu port registers, SerDes registers, PVIDs, and VTU.
Not really standard though.

> I'm not strongly against having a CPU port, but i don't particularly
> like having the CPU port as an interface. And when you get to cascaded
> switches, the DSA ports are also interesting, so should we also have a
> netdev for them? But they are equally useless for transferring frames
> from the host as the CPU port. This is why i went for debugfs.
> 
>> Also, in my RFC for 802.1Q support [1], I assume the CPU port to be a tagged
>> member of each VLAN. But someone may want to add a VLAN with swp3 and swp4
>> only, and another VLAN with swp0, swp1 and the CPU port. Am I correct?
> 
> The DSA concept is that switch ports are separate interfaces. So
> adding a VLAN to two ports does to automatically bridge those ports
> together. You need to add them to a bridge as well before VLAN tagged
> frames are bridged between ports.

My point was to expose all configurable ports with the same standard interface
(netdev, like any other virtual switch port). But indeed, their uselessness for
data transfer can be a good reason not to do it.

Thanks,
-v

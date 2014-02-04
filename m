From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 0/5] net: phy: Ethernet PHY powerdown optimization
Date: Tue, 4 Feb 2014 14:51:27 -0800
Message-ID: <CAGVrzcYxcSL+Lrc=ueU6ARtxJ6MhhfHtSMEUeaMXQJEfjByVUA@mail.gmail.com>
References: <1386513631-11284-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1386926429-28818-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <20131217.144313.1563516273987934449.davem@davemloft.net> <52F141AE.8010402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	mugunthanvnm <mugunthanvnm@ti.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Lunn <andrew@lunn.ch>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52F141AE.8010402@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sebastian,

2014-02-04 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>:
> On 12/17/2013 08:43 PM, David Miller wrote:
>>
>> From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
>> Date: Fri, 13 Dec 2013 10:20:24 +0100
>>
>>> This is v2 of the ethernet PHY power optimization patches to reduce
>>> power consumption of network PHYs with link that are either unused or
>>> the corresponding netdev is down.
>>>
>>> Compared to the last version, this patch set drops a patch to disable
>>> unused PHYs after late initcall, as it is not compatible with a modular
>>> mdio bus [1]. I'll investigate different ways to have a modular mdio bus
>>> driver get notified when driver loading is done.
>>>
>>> Again, a branch with v2 applied to v3.13-rc2 can also be found at
>>> https://github.com/shesselba/linux-dove.git topic/ethphy-power-v2
>>>
>>> [1] http://www.spinics.net/lists/arm-kernel/msg293028.html
>>
>>
>> Series applied, thanks.
>>
>
> David, Mungunthan, Florian,
>
> as expected the above patches create a Linux to bootloader dependency
> that surfaces dumb bootloaders not initializing PHYs correctly.
>
> Andrew has a Kirkwood based board that does not power-up and restart
> auto-negotiation on the powered down PHY after a warm restart. While
> this specific bootloader allows a soft-workaround by issuing the
> required PHY writes before accessing the interface, others may not.
>
> I think we should allow the user to soft-disable the automatic
> power-down of PHYs, i.e. by exploiting a kernel parameter.
>
> Do you have any preference for naming it? My call would be something
> like libphy.suspend_halted = [0,1] with 1 being the default.

The name looks good to me, and it would avoid having to clear the
BMCR_PWRDOWN bit during the MDIO bus remove callback to workaround
such bootloaders.

BTW, it looks like we are omitting a 0.5 seconds delay after clearing
the BMCR_PWRDOWN bit:

"
22.2.4.1.5 Power Down
...
A PHY is not required to meet the RX_CLK and TX_CLK signal functional
requirements when either bit
0.11 or bit 0.10 is set to a logic one. A PHY shall meet the RX_CLK
and TX_CLK signal functional require-
ments defined in 22.2.2 within 0.5 s after both bit 0.11 and 0.10 are
cleared to zero."
-- 
Florian

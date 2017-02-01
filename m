From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: dp83867: Port mirroring support in the DP83867
 TI's PHY driver
Date: Wed, 1 Feb 2017 13:12:13 -0800
Message-ID: <a287bc1e-3693-02d3-4c58-f1369144efd1@gmail.com>
References: <1485960215-5148-1-git-send-email-lukma@denx.de>
 <20170201171610.GC7395@lunn.ch>
 <2f3766f0-42df-6aab-dda1-14022c57fb30@gmail.com>
 <20170201220500.29d478aa@jawa>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Karicheri Muralidharan <m-karicheri2@ti.com>,
        linux-kernel@vger.kernel.org, Eric Engestrom <eric@engestrom.ch>,
        netdev@vger.kernel.org, Kishon Vijay Abraham I <kishon@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        devicetree@vger.kernel.org
To: Lukasz Majewski <lukma@denx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170201220500.29d478aa@jawa>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/01/2017 01:05 PM, Lukasz Majewski wrote:
> Dear All,
> 
> Thanks for prompt reply.
> 
>> On 02/01/2017 09:16 AM, Andrew Lunn wrote:
>>> On Wed, Feb 01, 2017 at 03:43:35PM +0100, Lukasz Majewski wrote:
>>>> This patch adds support for enabling or disabling the port
>>>> mirroring feature of the DP83867 TI's PHY device.
>>>>
>>>> One use case is when bootstrap configuration enables this feature
>>>> (because of e.g. LED wiring) so then one needs to disable it in
>>>> software (u-boot/Linux).
>>>
>>> Hi Lukasz
>>>
>>> How does this differ from "enet-phy-lane-swap"?
>>
>> Same here, I am confused about what port mirroring could be meaning
>> here
> 
> The "net-phy-lane-swap" when defined indicates that the "lane swap"
> needs to be enabled. This is a simple bool variable. In my case it
> would mean: "please enable port mirroring -> write 1 to CFG4 register's
> PORT_MIRROR_EN field"
> 
> My use case is unfortunately different:
> 
> - Due to HW design - during the bootstrap PHY phase - the PHY enables
>   "port mirroring", which is incorrect. 
> 
> Then, in SW I do need to explicitly disable port mirroring (write 0 to
> PORT_MIRROR_EN field in CFG4 register). 

You did not really explain whether port mirroring meant the same thing
as swapping the PHY lanes or not, but based on your paragraph later on,
it does sound like this is the case.

What a poorly chosen name though... in Ethernet world, port mirroring
means the ability to capture traffic from a vector of ports and copying
it verbatim (or sampled) towards a capture port, aka the mirror port...

> 
> 
>> and if we can find a better way to describe what is being added.
>> Thanks!
> 
> We would need a tri-state device tree properly:
> 
> 1. Not defined - do nothing
> 2. Defined as 0 -> explicitly disable port mirroring
> 3. Defined as 1 -> explicitly enable port mirriring
> 
> The "net-phy-lane-swap" only fulfills points 1 and 3 above.
> 
> In my use case I do need point 2.

You can define another boolean property:

net-phy-lane-no-swap?

-- 
Florian

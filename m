From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2] net: dsa: make "label" property optional for
 dsa2
Date: Tue, 10 Jan 2017 10:55:24 +0100
Message-ID: <20170110095524.GA1827@nanopsycho>
References: <20170108231552.26995-1-vivien.didelot@savoirfairelinux.com>
 <20170109073236.GA1862@nanopsycho>
 <877f6446lp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170109151131.GC1862@nanopsycho>
 <87y3yk2q5e.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170109160632.GD1862@nanopsycho>
 <89492624-84f2-ca73-75dd-7fa10819ad09@gmail.com>
 <20170109175842.GH1862@nanopsycho>
 <3897e83d-83a6-7bb1-311d-ae228390f757@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe@kleine-koenig.org>,
        Andrey Smirnov <andrew.smirnov@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3897e83d-83a6-7bb1-311d-ae228390f757@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Jan 09, 2017 at 07:06:39PM CET, f.fainelli@gmail.com wrote:
>On 01/09/2017 09:58 AM, Jiri Pirko wrote:
>> Mon, Jan 09, 2017 at 06:42:07PM CET, f.fainelli@gmail.com wrote:
>>> On 01/09/2017 08:06 AM, Jiri Pirko wrote:
>>>> Mon, Jan 09, 2017 at 04:45:33PM CET, vivien.didelot@savoirfairelinux.com wrote:
>>>>> Hi Jiri,
>>>>>
>>>>> Jiri Pirko <jiri@resnulli.us> writes:
>>>>>
>>>>>>> Extra question: shouldn't phys_port_{id,name} be switchdev attributes in
>>>>>>
>>>>>> Again, phys_port_id has nothing to do with switches. Should be removed
>>>>>> from dsa because its use there is incorrect.
>>>>>
>>>>> Florian, since 3a543ef just got in, can it be reverted?
>>>>
>>>> Yes, please revert it. It is only in net-next.
>>>
>>> Maybe the use case can be understood before reverting the change. How do
>>> we actually the physical port number of an Ethernet switch per-port
>>> network device? The name is not enough, because there are plenty of
>>> cases where we need to manipulate a physical port number (be it just for
>>> informational purposes).
>> 
>> Like what?
>
>Specifying the physical port number (and derive a queue number
>eventually) for some ethtool (e.g: rxnfc)/tc (queue mapping) operations
>where there is an action/queue/port destination argument that gets
>programmed into the hardware.

Could you point me to a real example? User command?


>
>You already have the originating port number from the interface you call
>the method against, but you also need the destination port number since
>that is what the HW understands.

This is internal to kernel? I fail to understand what you mean exactly.


>
>Aside from that, it is useful for allowing interface naming in user
>space if you don't want to use labels.
>
>> 
>> Why the name is not enough? This is something propagated to userspace
>> and never used internally in kernel.
>
>Because the name is not reflective of the port number in some switches.
>In my case for instance, we have 5 ports that are named after the
>entities they connect to (an integrated Gigabit PHY, two RGMII pads, one
>MoCA interface, and the CPU)
>

Again, I'm missing why you need a portnumber as a Integer to userspace.
>From driver, you can expose phys_port_name:

>0 -> gphy

"p0" or "gphy"

>1 -> rgmii_1

"p1" or "rgmii_1"

>2 -> rgmii_2

...

>7 -> moca
>8 -> cpu
>
>> 
>> Btw, ndo_get_phys_port_id does not give you number, but arbitrary binary.
>
>It's not entirely arbitrary for DSA switches since the port number is
>stored in an u8 whose value is the port number in hexadecimal (as shown
>by sysfs at least).

In mlxsw, we also have port number stored in u8. It is used to
communicate with hw of course. But outside the driver, this is exposed
as phys_port_name "pX".

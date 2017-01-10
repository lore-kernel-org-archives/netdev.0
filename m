From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2] net: dsa: make "label" property optional for
 dsa2
Date: Tue, 10 Jan 2017 09:58:18 -0800
Message-ID: <3c7e5102-cef7-c909-a192-6238103e444e@gmail.com>
References: <20170108231552.26995-1-vivien.didelot@savoirfairelinux.com>
 <20170109073236.GA1862@nanopsycho>
 <877f6446lp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170109151131.GC1862@nanopsycho>
 <87y3yk2q5e.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170109160632.GD1862@nanopsycho>
 <89492624-84f2-ca73-75dd-7fa10819ad09@gmail.com>
 <20170109175842.GH1862@nanopsycho>
 <3897e83d-83a6-7bb1-311d-ae228390f757@gmail.com>
 <20170110095524.GA1827@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <uwe@kleine-koenig.org>,
        Andrey Smirnov <andrew.smirnov@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170110095524.GA1827@nanopsycho>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/10/2017 01:55 AM, Jiri Pirko wrote:
> Mon, Jan 09, 2017 at 07:06:39PM CET, f.fainelli@gmail.com wrote:
>> On 01/09/2017 09:58 AM, Jiri Pirko wrote:
>>> Mon, Jan 09, 2017 at 06:42:07PM CET, f.fainelli@gmail.com wrote:
>>>> On 01/09/2017 08:06 AM, Jiri Pirko wrote:
>>>>> Mon, Jan 09, 2017 at 04:45:33PM CET, vivien.didelot@savoirfairelinux.com wrote:
>>>>>> Hi Jiri,
>>>>>>
>>>>>> Jiri Pirko <jiri@resnulli.us> writes:
>>>>>>
>>>>>>>> Extra question: shouldn't phys_port_{id,name} be switchdev attributes in
>>>>>>>
>>>>>>> Again, phys_port_id has nothing to do with switches. Should be removed
>>>>>>> from dsa because its use there is incorrect.
>>>>>>
>>>>>> Florian, since 3a543ef just got in, can it be reverted?
>>>>>
>>>>> Yes, please revert it. It is only in net-next.
>>>>
>>>> Maybe the use case can be understood before reverting the change. How do
>>>> we actually the physical port number of an Ethernet switch per-port
>>>> network device? The name is not enough, because there are plenty of
>>>> cases where we need to manipulate a physical port number (be it just for
>>>> informational purposes).
>>>
>>> Like what?
>>
>> Specifying the physical port number (and derive a queue number
>> eventually) for some ethtool (e.g: rxnfc)/tc (queue mapping) operations
>> where there is an action/queue/port destination argument that gets
>> programmed into the hardware.
> 
> Could you point me to a real example? User command?

ethtool --config-nfc moca flow-type udp4 src-ip 192.168.1.20 dst-ip \
        192.168.1.10 src-port 49884 dst-port 5001 action 2

Where 2 here designates a port number, users need to be able to look up
the physical port number corresponding to an interface to know which
value to put in this command.

Yes I know we can do the same thing with cls_flower, possibly by
referencing network devices directly.

> 
> 
>>
>> You already have the originating port number from the interface you call
>> the method against, but you also need the destination port number since
>> that is what the HW understands.
> 
> This is internal to kernel? I fail to understand what you mean exactly.

See the command above, from using the "moca" netdev here, we can access
the DSA private network device (dsa_slave_priv) structure and get the
port number from there, and pass this down to the switch driver. The
switch driver also takes another port number (and eventually a queue
number) to program classification filters.

> 
> 
>>
>> Aside from that, it is useful for allowing interface naming in user
>> space if you don't want to use labels.
>>
>>>
>>> Why the name is not enough? This is something propagated to userspace
>>> and never used internally in kernel.
>>
>> Because the name is not reflective of the port number in some switches.
>> In my case for instance, we have 5 ports that are named after the
>> entities they connect to (an integrated Gigabit PHY, two RGMII pads, one
>> MoCA interface, and the CPU)
>>
> 
> Again, I'm missing why you need a portnumber as a Integer to userspace.
> From driver, you can expose phys_port_name:

If we are exposing the port name here, we may as well expose the DSA
"label" instead of the physical port number number?

I don't deny my change may be misusing what phys_port_id was originally
designed for, but providing "p0" instead of "0" to user-space, what
value is there in adding the "p" in front really?
-- 
Florian

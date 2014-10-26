From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 06/14] net: dsa: Add support for hardware monitoring
Date: Sun, 26 Oct 2014 08:57:16 -0700
Message-ID: <544D19DC.9050807@roeck-us.net>
References: <20141023134706.GB25190@lunn.ch> <20141023162754.GA21343@roeck-us.net> <20141023165459.GE25190@lunn.ch> <20141023173847.GA22988@roeck-us.net> <20141023180357.GG25190@lunn.ch> <20141023184322.GA24281@roeck-us.net> <20141023195526.GH25190@lunn.ch> <20141024161919.GA29600@roeck-us.net> <20141025140116.GA12051@lunn.ch> <544BDC8F.2030308@gmail.com> <20141025180016.GA13191@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141025180016.GA13191@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/25/2014 11:00 AM, Andrew Lunn wrote:
> On Sat, Oct 25, 2014 at 10:23:27AM -0700, Florian Fainelli wrote:
>> On 10/25/14 07:01, Andrew Lunn wrote:
>>>> Here is another naming option:
>>>>
>>>> em1dsa0-virtual-0
>>>
>>> I prefer this over isa.
>>>
>>> However, i think there should be some sort of separator between the
>>> network device name and dsa.
>>
>> Considering that network devices can be renamed, do we want it to be
>> included in the sensor name at all?
>
> Well, we need something which identifies the "DSA collection". In
> that, you could have two or more collections, connected to different
> network devices.
>
> I once came across a PCI board with two Intel ethernet chipsets and
> two 10 port Marvell switches. Each switch had one host cpu port, 3
> ports interconnected to the other switch, and 6 going to the back
> panel.  You would want to describe that as two separate DSA entities,
> not one DSA with two switches. So the name needs something to indicate
> the DSA collection.
>

I agree. I could use the dsa instance index, so we would have
names such as dsa0-isa-0000, dsa1-isa-0000, dsa0-isa-0001, dsa1-isa-0001,
and so on, but that looks awkward (I can't do the index with virtual
names because they don't have a parent and thus no index).

Using the ethernet interface name seems like a good idea to me.
Sure it can change, but the name is typically chosen before the
dsa device is instantiated, and if it is changed manually later
we just can not help it.

So, if people want a delimiter between network device name and dsa,
what should it be ? Unless I hear otherwise, I'll choose '_'.

Guenter

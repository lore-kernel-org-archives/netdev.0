From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Ethernet: how to disable gigabit support
Date: Thu, 12 Feb 2015 06:12:26 -0800
Message-ID: <CAGVrzcY-euCPuU6QkpV=dYVk0CALPjngDVMbRrOt16+9AP81Lg@mail.gmail.com>
References: <20150205202527.GA7917@amd> <54D3F267.3000908@gmail.com> <20150206135706.GB25683@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150206135706.GB25683@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2015-02-06 5:57 GMT-08:00 Pavel Machek <pavel@ucw.cz>:
> On Thu 2015-02-05 14:44:55, Florian Fainelli wrote:
>> On 05/02/15 12:25, Pavel Machek wrote:
>> > Hi!
>> >
>> > This happened on more than one project: there's gigabit-capable chip,
>> > but the connector is not designed for gigabit speed.
>> >
>> > I'd like to have speed autonegotiation, but not offer gigabit (as it
>> > will not work).
>> >
>> > Is there way to do that without hacking the kernel? Should mii-tool do
>> > that?
>>
>> Since you use the PHY library, you should be able to do something like
>> this in your PHY driver prior to starting the PHY state machine:
>>
>> phydev->supported &= PHY_BASIC_FEATURES (effectively masking Gigabit
>> capability)
>
> Thanks, that did the trick.
>                                                                 Pavel
> (But still it would be nice to have a generic way of doing this,
> using something like mii-tool.)

You can also force that by setting the "max-speed" property in the
Ethernet PHY node, the PHY library will populate the supported bitmask
accordingly and remove speeds which are not supposed to be supported.

I have to admit it has been a while since I used mii-tool, so the
ioctl() side on the PHY library might be off.
--
Florian

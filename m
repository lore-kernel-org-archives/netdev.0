From: Olof Johansson <olof@lixom.net>
Subject: Re: [BISECTED] v4.5-rc1 phylib regression
Date: Tue, 26 Jan 2016 13:48:07 -0800
Message-ID: <CAOesGMiEzhN9sGBTq57xnti_Fy1J4rO=djehNHwj47ZhetymXw@mail.gmail.com>
References: <20160125154520.GI22974@ak-desktop.emea.nsn-net.net>
	<20160126044624.GH3880@lunn.ch>
	<20160126121435.GK22974@ak-desktop.emea.nsn-net.net>
	<20160126133417.GI3880@lunn.ch>
	<CAOesGMgaB8R+7jGyLNgQ-M+2nVRhOsEp7LUbiApEEw+dscfL0w@mail.gmail.com>
	<20160126175353.GG27473@lunn.ch>
	<CAOesGMhYU4NOeGRJoF4bcELCFfSsvBVp2du7ZgVjC3QuCv637w@mail.gmail.com>
	<CAOesGMi+ymn_FdDfgTjwgyO-MsEJNGBDU9ayRJvGkjJ7T_ExfA@mail.gmail.com>
	<56A7DB27.6080203@gmail.com>
	<20160126213600.GJ27473@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Aaro Koskinen <aaro.koskinen@nokia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:35276 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbcAZVsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 16:48:08 -0500
Received: by mail-yk0-f177.google.com with SMTP id u68so88957520ykd.2
        for <netdev@vger.kernel.org>; Tue, 26 Jan 2016 13:48:07 -0800 (PST)
In-Reply-To: <20160126213600.GJ27473@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 26, 2016 at 1:36 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Tue, Jan 26, 2016 at 12:46:31PM -0800, Florian Fainelli wrote:
>> On 26/01/16 10:14, Olof Johansson wrote:
>> > +devicetree@vger.kernel.org instead.
>> >
>> > On Tue, Jan 26, 2016 at 10:08 AM, Olof Johansson <olof@lixom.net> wrote:
>> >> On Tue, Jan 26, 2016 at 9:53 AM, Andrew Lunn <andrew@lunn.ch> wrote:
>> >>>> I hate to bikeshed, but I'm not sure if "generic-mdio" is too...
>> >>>> generic? Will someone writing a DT be thinking "well, this is a
>> >>>> generic mdio PHY, I should set it"?  "mdio-device"?
>> >>>> "generic-nonphy-mdio"? Neither of those seem much better.
>> >>>
>> >>> How about 'not-a-phy'?
>> >>
>> >> "mdio,not-a-phy" or "mdio,non-phy" will scope it a bit, especially if
>> >> you expect other generic mdio properties that can do with a namespace.
>>
>> Really not a fan of having to add an additional boolean property to
>> differentiate an Ethernet PHY from something else, the proper solution
>> would really be to enforce the use of the c22 or c45 compatible string
>> as the least compatible string to be used, but I am assuming this is not
>> necessarily an option here with DTBs out there.
>
> Nope, not an option. Only a small number of DTB actually use c22 or
> c45. The majority of devices have no compatible at all. Why should
> they, the binding documentation says it is optional!

So one thing that can be done is to just have a whitelist in the
driver that we add the known phy compatibles to, with a nice comment
above that this should only be for legacy device trees. I.e. in
addition to the c22 or c45 strings.

You can even fix up existing trees, and do a pr_warn() for these cases
to ask people to update their DT. There's no strict requirement to do
so though, so the kernel still *has* to work with the old ones.

>> What plays in favor of this boolean property is that the very concept of
>> MDIO devices has been recently introduced, so presumably, there are not
>> that many DTBs out there which would be affected...
>
> In kernel, 0. I have one out of kernel, which i hope to contribute
> once we decide on the new binding for DSA.
>
>> The only other idea I had was to force the MDIO device creation to be
>> dependent on finding a matching compatible string provided by a driver
>> (yikes).
>
> Complex. There are ordering issues, since the driver can be loaded a
> long time after of_mdiobus_register() is called, yet it needs to be
> of_mdiobus_register() which decides if a device is a PHY or not.
>
> I think the bool is the only practical solution.


-Olof

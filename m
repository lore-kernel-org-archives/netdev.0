From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH v5 0/2] Add support for the ethernet switch on the ESPRESSObin
Date: Fri, 20 Jan 2017 18:08:30 +0100
Message-ID: <87a8al64mp.fsf@free-electrons.com>
References: <20170119214934.27442-1-gregory.clement@free-electrons.com>
        <20170119220607.GA25907@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>,
        Jon Pannell <jpannell@marvell.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47591 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751315AbdATRIf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:08:35 -0500
In-Reply-To: <20170119220607.GA25907@lunn.ch> (Andrew Lunn's message of "Thu,
        19 Jan 2017 23:06:07 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,
 
 On jeu., janv. 19 2017, Andrew Lunn <andrew@lunn.ch> wrote:

>> While comparing the datasheet and the ops functions used, some
>> question came to me. They should not prevent applying this series,
>> but their answer would help me to have a better understanding of the
>> dsa subsystem.
>> 
>> - Are the temperature related operation still useful with dsa2 ?
>
> No. I'm in the process of moving the code into the Marvell PHY driver,
> since the sensor is in the embedded PHYs.
>
> What ID does the embedded PHY use? The 6390 has a blank ID, where as
> older device have a real ID.

Actually I didn't find anything related to the temperature measurement
in the datasheet I have. For the 6390 there is a dedicated datsheet for
the PHY part for the 6352 it is part of the same datasheet.

After a second look I think I don't have anything related to the PHY
part in the datasheets.

What I wanted to do was to test 6390 and 6352 temperature related
functions and to see if one of them worked. That's how I realized it was
not possible to do it with dsa2.

>
>> - Why the setup is done differently between the 6390 and the 6352
>>   families when the have exactly the same register?
>
> EDSA on 6390 works differently to 6352, meaning it breaks. So we need
> to run the 6390 with DSA tagging, not EDSA. Maybe this is the source
> of the differences?
>
> It should also be noted that the 6390 support is not yet complete. I
> have a few more patches in my tree to post.
>
>>   - On the Port Controller 2, the bit PORT_CONTROL_2_MAP_DA is set for
>>     6352 and not for 6390 whereas the same bit exists in 6360 and the
>>     description for this bit is the same for both datasheet.
>
> Humm, it does look like it is missing mv88e6xxx_6390_family(chip).
>  
>> 
>>   - Register PORT_ATU_CONTROL and PORT_PRI_OVERRIDE are reset on 6352
>>     and not on 6390. While here again the registers description are
>>     the same.
>
> And the same here. I've mostly been working on where the 6390 is
> different. Where it is the same i've mostly ignored it so far :-)
>
> There is also an ongoing effort to remove all these big if statements
> with a list of families.

Thanks for this answers I understand it a little better now.

Gregory

>
>      Andrew

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com

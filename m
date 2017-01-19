From: Jon Pannell <jpannell@marvell.com>
Subject: RE: [EXT] Re: [PATCH v5 0/2] Add support for the ethernet switch on
 the ESPRESSObin
Date: Thu, 19 Jan 2017 23:41:28 +0000
Message-ID: <af59fcdd27754934a8149eda2098d601@SC-EXCH01.marvell.com>
References: <20170119214934.27442-1-gregory.clement@free-electrons.com>
 <20170119220607.GA25907@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        "Sebastian Hesselbarth" <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Bob Bernstein <robertb@marvell.com>,
        Christine Qiu <cqiu@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170119220607.GA25907@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+ Bob + Christine

Jon Pannell


-----Original Message-----
From: Andrew Lunn [mailto:andrew@lunn.ch] 
Sent: Thursday, January 19, 2017 2:06 PM
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>; Florian Fainelli <f.fainelli@gmail.com>; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; David S. Miller <davem@davemloft.net>; Jason Cooper <jason@lakedaemon.net>; Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>; Thomas Petazzoni <thomas.petazzoni@free-electrons.com>; linux-arm-kernel@lists.infradead.org; Nadav Haklai <nadavh@marvell.com>; Wilson Ding <dingwei@marvell.com>; Kostya Porotchkin <kostap@marvell.com>; Joe Zhou <shjzhou@marvell.com>; Jon Pannell <jpannell@marvell.com>
Subject: [EXT] Re: [PATCH v5 0/2] Add support for the ethernet switch on the ESPRESSObin

External Email

----------------------------------------------------------------------
> While comparing the datasheet and the ops functions used, some 
> question came to me. They should not prevent applying this series, but 
> their answer would help me to have a better understanding of the dsa 
> subsystem.
> 
> - Are the temperature related operation still useful with dsa2 ?

No. I'm in the process of moving the code into the Marvell PHY driver, since the sensor is in the embedded PHYs.

What ID does the embedded PHY use? The 6390 has a blank ID, where as older device have a real ID.

> - Why the setup is done differently between the 6390 and the 6352
>   families when the have exactly the same register?

EDSA on 6390 works differently to 6352, meaning it breaks. So we need to run the 6390 with DSA tagging, not EDSA. Maybe this is the source of the differences?

It should also be noted that the 6390 support is not yet complete. I have a few more patches in my tree to post.

>   - On the Port Controller 2, the bit PORT_CONTROL_2_MAP_DA is set for
>     6352 and not for 6390 whereas the same bit exists in 6360 and the
>     description for this bit is the same for both datasheet.

Humm, it does look like it is missing mv88e6xxx_6390_family(chip).
 
> 
>   - Register PORT_ATU_CONTROL and PORT_PRI_OVERRIDE are reset on 6352
>     and not on 6390. While here again the registers description are
>     the same.

And the same here. I've mostly been working on where the 6390 is different. Where it is the same i've mostly ignored it so far :-)

There is also an ongoing effort to remove all these big if statements with a list of families.

     Andrew

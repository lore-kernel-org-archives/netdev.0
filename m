From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2] net: dsa: make "label" property optional for
 dsa2
Date: Mon, 9 Jan 2017 00:30:19 +0100
Message-ID: <20170108233019.GA25588@lunn.ch>
References: <20170108231552.26995-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe@kleine-koenig.org>,
        Andrey Smirnov <andrew.smirnov@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170108231552.26995-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Until the printing of netdev_phys_item_id structures is fixed in
> net/core/net-sysfs.c, an external helper can be used like this:

Hi Vivien

As Florian pointed out, this cannot be changed. It is now part of the
ABI. We have to live with it printing little endian numbers as big
endian.

>     # cat /etc/udev/rules.d/90-net-dsa.rules
>     SUBSYSTEM=="net", ACTION=="add", ENV{DEVTYPE}=="dsa", PROGRAM="/lib/udev/dsanitizer $attr{phys_switch_id} $attr{phys_port_id}", NAME="$result"
> 
>     # cat /lib/udev/dsanitizer
>     #!/bin/sh
>     echo $1 | sed -e 's,^0*,,' -e 's,0*$,,' | xargs printf sw%d
>     echo $2 | sed -e 's,^0*,,' | xargs printf p%d
> 
>     # ip link | awk '/@eth/ { split($2,a,"@"); print a[1]; }'
>     sw0p0
>     sw0p1
>     sw0p2
>     sw1p0
>     sw1p1
>     sw1p2
>     sw2p0
>     sw2p1
>     sw2p2
>     sw2p3
>     sw2p4

Rather than recommending something, it might be better to point to the
Free Desktop "Predictable Network Interface Names" which is what most
people will end up with, if they rename:

https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/

It would also be good to test on a recent systemd system and see what
happens. What names does it pick?

	Andrew

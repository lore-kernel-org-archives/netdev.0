From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/3] net: dsa: mv88e6xxx: make global2 code
 optional
Date: Fri, 2 Sep 2016 16:55:11 +0200
Message-ID: <20160902145511.GH16864@lunn.ch>
References: <20160902120819.10773-1-vivien.didelot@savoirfairelinux.com>
 <20160902120819.10773-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160902120819.10773-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 02, 2016 at 08:08:19AM -0400, Vivien Didelot wrote:
> Since not every chip has a Global2 set of registers, make its support
> optional, in which case the related functions will return -EOPNOTSUPP.
> 
> This also allows to reduce the size of the mv88e6xxx driver for devices
> such as home routers embedding Ethernet chips without Global2 support.

Hi Vivien

I've no problems with splitting this out.

However, making it optional? I don't think that is a good idea.

1) If you don't have this, and you should, it looks like the PHYs stop
working, and since you cannot set the switch MAC address, maybe Pause
frames are broken.

2) Distros won't build a kernel per target hardware. They probably
build a kernel per SoC vendor. That means, they will have this
optional code built all the time. Very few builds will leave it out.

So the only way i think making this optional, is if it is a kernel
module, and it gets loaded if needed.

	Andrew

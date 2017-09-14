From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 01/10] net: dsa: add debugfs interface
Date: Thu, 14 Sep 2017 23:01:32 +0200
Message-ID: <20170914210132.GC3084@lunn.ch>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828191748.19492-2-vivien.didelot@savoirfairelinux.com>
 <20170907193434.GA11006@kroah.com>
 <87h8wdb8bj.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CAJGZr0KdOPW5_V3kvWutwTY=BJhfd-=yRDPnvbDBOCuMYWj9OQ@mail.gmail.com>
 <CAKgT0Uf8--Yh9tfkTrh9_dfEYMX5jR6j4unxwxM+WD6E4jk9pA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maxim Uvarov <muvarov@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Greg KH <gregkh@linuxfoundation.org>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAKgT0Uf8--Yh9tfkTrh9_dfEYMX5jR6j4unxwxM+WD6E4jk9pA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Can you clarify what type of registers it is you are wanting to read?
> We already have ethtool which is meant to allow reading the device
> registers for a given netdev. As long as the port has a netdev
> associated it then there is no need to be getting into debugfs since
> we should probably just be using ethtool.

Not all ports of a DSA switch have a netdev. This is by design. The
presentation we gave to Netdev 2.1 gives some of the background.

Plus a switch has a lot of registers not associated to port. Often a
switch has more global registers than port registers.
 
> Also as Jiri pointed out there is already devlink which would probably
> be a better way to get the associated information for those pieces
> that don't have a netdev associated with them.

We have looked at the devlink a few times. The current dpipe code is
not generic enough. It makes assumptions about the architecture of the
switch, that it is all match/action based. The niche of top of rack
switches might be like that, but average switches are not.

If dpipe was to support simple generic two dimensional tables, we
probably would use it.

David suggested making a class device for DSA. It is not ideal, but we
are probably going to go that way.

    Andrew

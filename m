From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v5 05/13] net: ethernet: aquantia: Support for
 NIC-specific code
Date: Sun, 15 Jan 2017 02:15:47 +0100
Message-ID: <20170115011547.GA5643@lunn.ch>
References: <cover.1484283610.git.vomlehn@texas.net>
 <5e87af3b0effb96698d0c085366b1ba9320a6305.1484283610.git.vomlehn@texas.net>
 <3dfe11ac-4215-21d0-2242-7a4ad6157e56@gmail.com>
 <CAKoUArkh3gyVSrX1GWRQsrFFBg8B59LjtXK=yG6JWMHan7fW7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Netdev <netdev@vger.kernel.org>,
        David VomLehn <vomlehn@texas.net>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60389 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750738AbdAOBPv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 14 Jan 2017 20:15:51 -0500
Content-Disposition: inline
In-Reply-To: <CAKoUArkh3gyVSrX1GWRQsrFFBg8B59LjtXK=yG6JWMHan7fW7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 15, 2017 at 12:55:02AM +0200, Rami Rosen wrote:
> Hi, Florian,
> 
> > +}
> > +
> > +static int aq_ndev_change_mtu(struct net_device *ndev, int new_mtu)
> > +{
> > +     struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
> > +     int err = 0;
> > +
> > +     if (new_mtu == ndev->mtu) {
> > +             err = 0;
> > +             goto err_exit;
> > +     }
> > +     if (new_mtu < 68) {
> > +             err = -EINVAL;
> > +             goto err_exit;
> > +     }

Actually, the core will already impose min/max of ETH_MIN_MTU and
ETH_DATA_LEN. See 

commit a52ad514fdf3b8a57ca4322c92d2d8d5c6182485
Author: Jarod Wilson <jarod@redhat.com>
Date:   Fri Oct 7 22:04:34 2016 -0400

    net: deprecate eth_change_mtu, remove usage
    
    With centralized MTU checking, there's nothing productive done by
    eth_change_mtu that isn't already done in dev_set_mtu, so mark it as
    deprecated and remove all usage of it in the kernel. All callers have been
    audited for calls to alloc_etherdev* or ether_setup directly, which means
    they all have a valid dev->min_mtu and dev->max_mtu. Now eth_change_mtu
    prints out a netdev_warn about being deprecated, for the benefit of
    out-of-tree drivers that might be utilizing it.
    
    Of note, dvb_net.c actually had dev->mtu = 4096, while using
    eth_change_mtu, meaning that if you ever tried changing it's mtu, you
    couldn't set it above 1500 anymore. It's now getting dev->max_mtu also set
    to 4096 to remedy that.

    Andrew

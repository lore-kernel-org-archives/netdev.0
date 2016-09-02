From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 3/3] net: dsa: mv88e6xxx: make global2 code optional
Date: Fri, 02 Sep 2016 13:13:21 -0400
Message-ID: <87vayens26.fsf@ketchup.mtl.sfl>
References: <20160902120819.10773-1-vivien.didelot@savoirfairelinux.com> <20160902120819.10773-4-vivien.didelot@savoirfairelinux.com> <20160902145511.GH16864@lunn.ch> <87k2eugwcs.fsf@ketchup.mtl.sfl> <20160902161148.GK16864@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160902161148.GK16864@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> What do you think?
>
> I think the probe() needs to fail with a very obvious error message
> saying you need to recompile your kernel with option XYZ enabled in
> order to support this switch, when the optional stuff is not
> optional...

I agree. Does the following snippet looks OK?


    #ifndef CONFIG_NET_DSA_MV88E6XXX_GLOBAL2
            if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_GLOBAL2)) {
                    dev_err(chip->dev, "Missing support for Global 2 registers\n");
                    return -EOPNOTSUPP;
            }
    #endif /* CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 */


Thanks,

        Vivien

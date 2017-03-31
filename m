From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 9/9] net: dsa: mv88e6xxx: add cross-chip bridging
Date: Fri, 31 Mar 2017 13:27:25 -0400
Message-ID: <87mvc19x1e.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com> <20170330213715.9666-10-vivien.didelot@savoirfairelinux.com> <20170331163949.GI12814@lunn.ch> <87d1cxqtco.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <20170331170941.GL12814@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170331170941.GL12814@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> I don't like the idea of leaking frames.

I don't like it neither. That's why this patch series is out there. It
improves the security on PVT-capable Marvell switches by programming the
tables correctly on bridging events.

A next step can be to warn the user about the software or hardware
limitations (s)he is currently experiencing with something roughly like
this in cross-chip bridging operations:

    if (!mv88e6xxx_has_pvt(chip)) {
    #if IS_ENABLED(BRIDGE_VLAN_FILTERING)
        return 0;
    #else
        pr_err("Cross-chip bridging is forbidden on non-PVT hardware and
               non-VLAN-filtering aware systems\n");
        return -EINVAL;
    #endif
    }

But let's keep it simple for the moment and go baby steps. First program
PVT tables correctly as this patchset does, then figure out how to
handle non-PVT systems. That is a good topic for next week ;-)

Thanks,

        Vivien

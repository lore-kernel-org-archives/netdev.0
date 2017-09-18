From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 6/6] Modify tag_ksz.c to support other KSZ switch
 drivers
Date: Tue, 19 Sep 2017 00:51:42 +0200
Message-ID: <20170918225142.GC29615@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121901@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD41121A22@CHN-SV-EXMX02.mchp-main.com>
 <20170907214834.GT11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D2E@CHN-SV-EXMX02.mchp-main.com>
 <20170918195708.GE15606@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D7C@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: muvarov@gmail.com, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41124D7C@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> In the old DSA implementation all the ports are partitioned into its own device
> and the bridge joining them will do all the forwarding.  This is useful for quick
> testing with some protocols like RSTP but it is probably useless for real
> operation.

It is a good minimal driver, to get something into the kernel. You can
then add features to it.

> The new switchdev model tries to use the switch hardware as much as
> possible.  This offload_fwd_mark bit means the frame is forwarded by the
> hardware switch, so the software bridge does not need to do it again.  Without
> this bit there will be duplicated multicast frames coming out the ports if internal
> forwarding is enabled.

Correct. Once you switch driver is clever enough, you can enable
offload_fwd_mark.
 
> When RSTP is used the port can be put in blocked state and so the forwarding
> will stop for that port.   Currently the switch driver will check that membership
> to decide whether to set that bit.

This i don't get. RSTP or STP just break loops. How does RSTP vs STP
mean you need to set offload_fwd_mark differently?

> The KSZ switches never have a built-in MAC controller, so it is always a support
> issue for us.

Not quite right. Once your drivers are in mainline, it becomes a
support issue for the community, with you being part of the community.
I've helped others fix this issue, one of the less well used Marvell
Ethernet drivers had this problem, and i gave somebody pointers how to
fix it.

    Andrew

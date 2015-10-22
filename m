From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: of_mdiobus_register_phy() and deferred probe
Date: Thu, 22 Oct 2015 15:31:34 +0200
Message-ID: <CAMuHMdX+_0Cf0VwmKDtcfMNwaPEN5jvjZQUXg6MKMJa+cvYz3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rob Herring <robh+dt@kernel.org>,
	Frank Rowand <frowand.list@gmail.com>,
	Grant Likely <grant.likely@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Due to a probe deferral of an interrupt controller[1], the Micrel
Ethernet PHY on
r8a7791/koelsch started failing to get its IRQ:

    no irq domain found for /interrupt-controller@e61c0000 !

However, of_mdiobus_register_phy() uses irq_of_parse_and_map(), which plainly
ignores EPROBE_DEFER, and it just continues.

Later I get:

    sh-eth ee700000.ethernet eth0: attached PHY 1 (IRQ -1) to driver
Micrel KSZ8041RNLI

instead of

    sh-eth ee700000.ethernet eth0: attached PHY 1 (IRQ 408) to driver
Micrel KSZ8041RNLI

Ethernet still works, as the interrupt seems to be unneeded(?).

Has anyone already looked into fixing of_mdio to handle deferred probing?

Thanks!

References:
[1] "Re: [PATCH v4 5/5] [RFC] clk: shmobile: r8a7795: Add new CPG/MSSR driver"
     (http://article.gmane.org/gmane.linux.ports.sh.devel/49979)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

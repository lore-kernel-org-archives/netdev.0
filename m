Return-Path: <linux-kernel-owner@vger.kernel.org>
MIME-Version: 1.0
In-Reply-To: <1507194974-12050-1-git-send-email-razvan.stefanescu@nxp.com>
References: <1507194974-12050-1-git-send-email-razvan.stefanescu@nxp.com>
From: Linus Walleij <linus.walleij@linaro.org>
Date: Sat, 14 Oct 2017 11:35:00 +0200
Message-ID: <CACRpkdYJCzu9Ph8XMYXt=SSAX+ZaiwXqUGgWX5UvTabmMxmBNQ@mail.gmail.com>
Subject: Re: [PATCH v3 0/6] staging: Introduce DPAA2 Ethernet Switch driver
To: Razvan Stefanescu <razvan.stefanescu@nxp.com>,
        linux-netdev@vger.kernel.org,
        OpenWrt Development List <openwrt-devel@lists.openwrt.org>
Cc: Greg KH <gregkh@linuxfoundation.org>,
        "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexander Graf <agraf@suse.de>, Arnd Bergmann <arnd@arndb.de>,
        alexandru.marginean@nxp.com, bogdan.purcareata@nxp.com,
        ruxandra.radulescu@nxp.com, laurentiu.tudor@nxp.com,
        stuyoder@gmail.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 5, 2017 at 11:16 AM, Razvan Stefanescu
<razvan.stefanescu@nxp.com> wrote:

> This patchset introduces the Ethernet Switch Driver for Freescale/NXP SoCs
> with DPAA2 (DataPath Acceleration Architecture v2). The driver manages
> switch objects discovered on the fsl-mc bus. A description of the driver
> can be found in the associated README file.
>
> The patchset consists of:
> * A set of libraries containing APIs for configuring and controlling
>   Management Complex (MC) switch objects
> * The DPAA2 Ethernet Switch driver
> * Patch adding ethtool support

So it appears that ethernet switches is a class of device that need their own
subsystem in Linux, before this driver can move out of staging.

I ran into the problem in OpenWRT that has these out-of-tree patches for
off-chip ethernet switches, conveniently placed under net/phy:
https://github.com/openwrt/openwrt/tree/master/target/linux/generic/files/drivers/net/phy

These are some 12 different ethernet switches. It is used in more or
less every home router out there.

It's not really working to have all of this out-of-tree, there must have been
discussions about the requirements for a proper ethernet switch subsystem.

I'm not a good net developers, just a grumpy user having to deal with all
of this out-of-tree code that's not helpful with changing interfaces like
device tree and so on.

Can you people who worked on this over the years pit in with your
requirements for an ethernet switch subsystem so we can house these
drivers in a proper way?

What we need AFAICT:

- Consensus on userspace ABI
- Consensus on ethtool extenstions
- Consensus on where in drivers/net this goes

You can kick me for not knowing what I'm talking about and how complex the
problem is now.

Yours,
Linus Walleij

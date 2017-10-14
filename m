From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [OpenWrt-Devel] [PATCH v3 0/6] staging: Introduce DPAA2 Ethernet Switch driver
Date: Sat, 14 Oct 2017 15:11:09 -0700
Message-ID: <21A90A5D-3AD5-4281-8709-F25BAB6B1602@gmail.com>
References: <1507194974-12050-1-git-send-email-razvan.stefanescu@nxp.com> <CACRpkdYJCzu9Ph8XMYXt=SSAX+ZaiwXqUGgWX5UvTabmMxmBNQ@mail.gmail.com> <CACRpkdazUB_XLv2jYnSiGe9CeVTgjOQ4HfPDL8+CNUVxs-LcLA@mail.gmail.com> <f8b49089-f2db-f7d7-f615-1e4b5082127d@gmail.com> <CACRpkdbyZYP9-CoZA+BZmnaQ+5mz9fZjQ1ApVBp65XB1LmOhaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Razvan Stefanescu <razvan.stefanescu@nxp.com>,
        OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
        ruxandra.radulescu@nxp.com, Arnd Bergmann <arnd@arndb.de>,
        Greg KH <gregkh@linuxfoundation.org>,
        alexandru.marginean@nxp.com,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexander Graf <agraf@suse.de>,
        Stuart Yoder <stuyoder@gmail.com>, bogdan.purcareata@nxp.com,
        laurentiu.tudor@nxp.com, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACRpkdbyZYP9-CoZA+BZmnaQ+5mz9fZjQ1ApVBp65XB1LmOhaw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On October 14, 2017 2:59:22 PM PDT, Linus Walleij <linus=2Ewalleij@linaro=
=2Eorg> wrote:
>On Sat, Oct 14, 2017 at 8:52 PM, Florian Fainelli
><f=2Efainelli@gmail=2Ecom> wrote:
>
>> The most deployed switch device drivers have been converted to DSA
>> already: b53, qca8k (ar83xx in OpenWrt/LEDE) and mtk7530 are all in
>> tree, and now we are getting new submissions from Michrochip to
>support
>> their pretty large KSZ series=2E Converting from swconfig to DSA is
>> actually quite simple, but like anything requires time and testing,
>and
>> access to hardware and ideally datasheet=2E
>
>Hm, I have a Realtek RB8366RB in this router on my desk=2E
>
>I guess that means I should just take the old switchdev-based
>SMI-driver and convert it to DSA=2E
>
>I bet I can do that :D

Yes, it really should not be too hard=2E The OpenWrt/LEDE driver had mostl=
y the same semantics as what is needed for being a proper DSA driver=2E You=
 should of course start simple: get basic switching working, then add stati=
stics, VLAN, FDB, etc=2E OpenWrt/LEDE models switches as PHY device objects=
 which would not work upstream so you should have the driver be probed as a=
 MDIO/SPI/I2C (see b53 for example) and set up fixed-link properties betwee=
n the CPU and the switch=2E

>
>Well, I will try=2E Because it's blocking me to work on the Gemini
>ethernet driver=2E

Well usually the boot loader may leave the switch in a good enough state t=
hat you can work on the CPU controller mostly independently from dealing wi=
th the switch=2E This is not universally true, and a properly working bootl=
oader should actually quiesce/reset both blocks prior to OS control=2E

Don't hesitate if you have questions=2E

Cheers=2E

--=20
Florian

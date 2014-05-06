From: Brian Lilly <brian@crystalfontz.com>
Subject: Re: i.MX28 based system losing eth0 on boot
Date: Tue, 6 May 2014 14:40:31 -0700
Message-ID: <CAOk88B+5CQZ639S_DwprrdBwZCs9m1cN_hr5hDRVkP18DqHd0w@mail.gmail.com>
References: <CAOk88BLR=nwNGdT++39vLdOt=TwZmemF-trSQPY8AdMN9tKtKQ@mail.gmail.com>
 <20140506181151.GU28564@pengutronix.de> <CAOk88BJ+sCtM_cRLuBktUKWYHcPo6KtQ+GAgTJL0zBgQqcQYog@mail.gmail.com>
 <CAGVrzcZs9-f4bCLNv3-s9iubMk8SF8P9+aJaere7rdLbvfo0bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@pengutronix.de>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcZs9-f4bCLNv3-s9iubMk8SF8P9+aJaere7rdLbvfo0bw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PHY on board is the SMSC LAN8720

With the generic PHY driver selected:  http://pastebin.com/A4MH4Ptw

[   28.828761] fec 800f0000.ethernet eth0: Freescale FEC PHY driver
[Generic PHY] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-1)
[   28.840626] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   30.827536] libphy: 800f0000.etherne:00 - Link is Up - 100/Full
[   30.833739] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   32.986999] IPv6: ADDRCONF(NETDEV_UP): usb0: link is not ready
[   37.316421] fec 800f0000.ethernet eth0: Freescale FEC PHY driver
[Generic PHY] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-1)
[   38.345047] fec 800f0000.ethernet eth0: MDIO read timeout
[   39.506210] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   40.374961] fec 800f0000.ethernet eth0: MDIO read timeout

With the SMSC PHY driver selected:  http://pastebin.com/DhdDyrMv

[   28.778974] fec 800f0000.ethernet eth0: Freescale FEC PHY driver
[SMSC LAN8710/LAN8720] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-=
1)
[   28.791742] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   30.773078] libphy: 800f0000.etherne:00 - Link is Up - 100/Full
[   30.779286] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   32.934692] IPv6: ADDRCONF(NETDEV_UP): usb0: link is not ready
[   37.242162] fec 800f0000.ethernet eth0: Freescale FEC PHY driver
[SMSC LAN8710/LAN8720] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-=
1)
[   38.270611] fec 800f0000.ethernet eth0: MDIO read timeout
[   39.415256] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   40.300454] fec 800f0000.ethernet eth0: MDIO read timeout

On Tue, May 6, 2014 at 12:24 PM, Florian Fainelli <f.fainelli@gmail.com=
> wrote:
> 2014-05-06 12:12 GMT-07:00 Brian Lilly <brian@crystalfontz.com>:
>> It is happening during boot up:
>>
>> <snip, kernel 3.12 >
>>
>> Configuring network interfaces... [   35.117114] fec 800f0000.ethern=
et
>> eth0: Freescale FEC PHY driver [SMSC LAN8710/LAN8720]
>
> Note that the SMSC PHY driver is picked up here, and that specific
> driver implements a different phy_read_status() callback due to how
> the PHY operates. The PHY driver also overrides the config_init()
> callback to perform some PHY-specific initialization. See below for
> more.
>
>> (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-1)
>> [   35.129967] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
>> udhcpc (v1.21.1) started
>>
>> Sending discover...
>>
>> [   37.113901] libphy: 800f0000.etherne:00 - Link is Up - 100/Full
>> [   37.120134] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes rea=
dy
>> Sending discover...
>>
>> Sending select for 10.10.10.217...
>> Lease of 10.10.10.217 obtained, lease time 86400
>> /etc/udhcpc.d/50default: Adding DNS 10.10.10.13
>> [   39.319957] IPv6: ADDRCONF(NETDEV_UP): usb0: link is not ready
>> done.
>> Starting rpcbind daemon...done.
>> net.ipv4.conf.default.rp_filter =3D 1
>> net.ipv4.conf.all.rp_filter =3D 1
>> Mon Apr 14 22:40:00 UTC 2014
>> INIT: Entering runlevel: 5
>> Starting Xserver
>> Starting system message bus: dbus.
>> Starting Connection Manager
>> Starting wpa_supplicant
>> Successfully initialized wpa_supplicant
>> Starting Dropbear SSH server
>> [   44.754915] fec 800f0000.ethernet eth0: Freescale FEC PHY driver
>> [SMSC LAN8710/LAN8720] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D=
-1)
>
> The correct PHY driver is selected here...
>
>> [   45.781364] fec 800f0000.ethernet eth0: MDIO read timeout
>> [   46.826170] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
>> [   47.811385] fec 800f0000.ethernet eth0: MDIO read timeout
>
> But we are still seeing MDIO read timeouts, which is not great.
>
>>
>> With a different kernel (3.14):
>>
>> [   28.989897] fec 800f0000.ethernet eth0: Freescale FEC PHY driver
>> [Generic PHY] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-1)
>> [   30.991210] libphy: 800f0000.etherne:00 - Link is Up - 100/Full
>> [   37.369372] fec 800f0000.ethernet eth0: Freescale FEC PHY driver
>> [Generic PHY] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-1)
>
> Here, the Generic PHY driver has been selected, which will use the
> MII_BMSR register contents to determine the Link status and
> parameters. You might want to make sure that your board selects the
> appropriate PHY driver, such that we are not chasing two issues here.
>
>> [   38.398346] fec 800f0000.ethernet eth0: MDIO read timeout
>> [   39.438412] fec 800f0000.ethernet eth0: MDIO read timeout
>> [   39.468419] fec 800f0000.ethernet eth0: MDIO write timeout
>> [   40.498848] fec 800f0000.ethernet eth0: MDIO read timeout
>
> It would also be helpful to print the register that were accessed,
> such that you could correlate this with the exact steps in the PHY
> library state machine. Please also retry the experiment with the SMSC
> PHY driver enabled, as it does some PHY specific initialization that
> seems to be relevant. Then we are hopefully left with only the MDIO
> timeout issue and not the PHY mis-configuration + MDIO timeout.
>
>>
>> Afterward I have to ifdown eth0, ifup eth0 and then it functions
>> normally, without reverting the commit.
>>
>> root@cfa100xx:~# ifdown eth0
>> [ 1154.679658] fec 800f0000.ethernet eth0: Freescale FEC PHY driver
>> [Generic PHY] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-1)
>> root@cfa100xx:~# ifup eth0
>> udhcpc (v1.21.1) started
>> Sending discover...
>> [ 1156.679547] libphy: 800f0000.etherne:00 - Link is Up - 100/Full
>> Sending discover...
>> Sending select for 10.10.10.217...
>> Lease of 10.10.10.217 obtained, lease time 86400
>> ip: RTNETLINK answers: File exists
>>
>> --
>> Brian
>>
>>
>> On Tue, May 6, 2014 at 11:11 AM, Uwe Kleine-K=C3=B6nig
>> <u.kleine-koenig@pengutronix.de> wrote:
>>> Hello Brian,
>>>
>>> On Tue, May 06, 2014 at 09:44:34AM -0700, Brian Lilly wrote:
>>>> With commit a264b981f2c76e281ef27e7232774bf6c54ec865 we're having =
eth0
>>>> come up, then brought right back down with an MDIO rx timeout mome=
nts
>>>> after.  Adding back in the removed code keeps the interface alive =
and
>>>> it's working afterward without trouble.  I've tested the re-insert=
ed
>>>> code in 3.12, 3.14 without issue on our boards.
>>> So you can reliably trigger that problem? You're just doing
>>>
>>>         ifconfig eth0 1.2.3.4 up
>>>
>>> (or equivalent) and the interface goes down without further
>>> interference with the above mentioned commit? The exact error you'r=
e
>>> seeing is
>>>
>>>         MDIO read timeout
>>>
>>> (with some prefix saying something about fec and eth0 I think)?
>>>
>>> This error is also present with a264b981f2 reverted, just doesn't a=
ffect
>>> eth0 being functional? Does the timeout always happen, or only on
>>> specific addresses?
>>>
>>> This is not a proper fix, but does it help to increment FEC_MII_TIM=
EOUT?
>>>
>>>> Is there something else that can be done to prevent the MDIO timeo=
uts?
>>>> We are using basically the same schematic for networking as the
>>>> imx28evk.
>>> Hard to say, but assuming it works just fine on the imx28evk for yo=
u,
>>> too, there seems to be some hardware difference that makes your mac=
hine
>>> fail. (That doesn't mean it's not fixable in software.)
>>>
>>> I don't know if a mdio read error is intended to make the device go
>>> down, maybe one the the netdev guys can answer that.
>>> Assuming that it's not intended, instrument the code, find out how =
that
>>> timeout makes your device go down and find the wrong branch. I'd st=
art
>>> with adding stackdumps when the mdio timeout happens and when
>>> fec_enet_start_xmit is called with fep->link =3D=3D 0.
>>>
>>> Best regards
>>> Uwe
>>>
>>> --
>>> Pengutronix e.K.                           | Uwe Kleine-K=C3=B6nig =
           |
>>> Industrial Linux Solutions                 | http://www.pengutronix=
=2Ede/  |
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>
> --
> Florian

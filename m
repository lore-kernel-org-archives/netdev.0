From: Brian Lilly <brian@crystalfontz.com>
Subject: Re: i.MX28 based system losing eth0 on boot
Date: Wed, 7 May 2014 12:51:36 -0700
Message-ID: <CAOk88BJz3HgQHmYPz9y1i4xn89wjpnGDutLw8wKDguJ1+H3Mjw@mail.gmail.com>
References: <CAOk88BLR=nwNGdT++39vLdOt=TwZmemF-trSQPY8AdMN9tKtKQ@mail.gmail.com>
 <20140506181151.GU28564@pengutronix.de> <CAOk88BJ+sCtM_cRLuBktUKWYHcPo6KtQ+GAgTJL0zBgQqcQYog@mail.gmail.com>
 <CAGVrzcZs9-f4bCLNv3-s9iubMk8SF8P9+aJaere7rdLbvfo0bw@mail.gmail.com>
 <CAOk88B+5CQZ639S_DwprrdBwZCs9m1cN_hr5hDRVkP18DqHd0w@mail.gmail.com>
 <CAGVrzcbdm-owTaz6ENZMCCGDxQsSaHoEVP=5ex9kZj-FprqUxQ@mail.gmail.com>
 <CAOk88BKmoSytTCXrXgsAGQXhUYvXqCPeX7TmYBRST+K8e0bv3w@mail.gmail.com>
 <CAGVrzcaL6817-WQ73srFHC022QY9LOJwQyx=uxqjHBt+Cf7ZRg@mail.gmail.com>
 <CAOk88BLCq4s8Lb4SLpTS9Mmz2Qe2g5+9ENw7h6huQdXBv_Nq0A@mail.gmail.com> <CAGVrzcY0ooeCvu5oQVieW8G4kpzGS6M=d3T8WjxsnZvC8tNXmA@mail.gmail.com>
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
In-Reply-To: <CAGVrzcY0ooeCvu5oQVieW8G4kpzGS6M=d3T8WjxsnZvC8tNXmA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46lorian:

Thank you for your help.

After doubling the timeout length it worked.

I managed to get my hands on a imx28evk board and compared our
component load versus theirs, to find they have a 1.5k pull-up on
ENET_MDIO to +3.3v which wasn't present on our board.  Adding a 1.5k
pull-up resistor on ENET_MDIO solves the problem, and boots as
expected without patching anything.

Sorry for the trouble on this.

Apparently our EE had some question as to whether or not the pull-up
was necessary, and put it in the schematic, and the footprint on the
board, but marked it as a DNP, which of course left it off the board
and out of the BOM.

<facepalm>

On Wed, May 7, 2014 at 12:34 PM, Florian Fainelli <f.fainelli@gmail.com=
> wrote:
> 2014-05-07 12:16 GMT-07:00 Brian Lilly <brian@crystalfontz.com>:
>> Also, in 3.14, commenting out both "return -ETIMEDOUT" instances in
>> fec_main.c results in a working interface.
>> Please let me know if you have any questions.
>
> At this point, you could probably instrument the interrupt handler an=
d
> see if you get FEC_MDIO interrupt causes at all?
>
>>
>> Thank you.
>>
>> Brian Lilly
>> Crystalfontz America, Incorporated
>> 12412 East Saltese Road
>> Spokane Valley, WA 99216
>> brian@crystalfontz.com http://www.crystalfontz.com
>> Twitter: @Crystalfontz
>> US toll-free (888) 206-9720 voice (509) 892-1200
>>
>>
>> On Tue, May 6, 2014 at 8:07 PM, Florian Fainelli <f.fainelli@gmail.c=
om> wrote:
>>> 2014-05-06 15:27 GMT-07:00 Brian Lilly <brian@crystalfontz.com>:
>>>> It would appear that I don't have that commit.  I could move to 3.=
14
>>>> to see if it makes a difference, but the last couple of responses =
have
>>>> been on 3.12.18 -- or perhaps I'm missing something else.
>>>
>>> I did miss that you were also seeing the problem in 3.12. At that
>>> point, I believe that the driver was working around a potential PHY
>>> bug that is not covered by the SMSC PHY driver, or that the MDIO
>>> timeout is simply not long enough, or that your MDIO interrupts fir=
e
>>> much longer than what the timeout allows, or that these interrupts =
are
>>> not reliable.
>>>
>>> You could probably try to ignore the timeout and see if you get
>>> sensible data out of the MDIO bus regardless.
>>>
>>>> Please let me know if you have any questions.
>>>>
>>>> Thank you.
>>>>
>>>> Brian Lilly
>>>> Crystalfontz America, Incorporated
>>>> 12412 East Saltese Road
>>>> Spokane Valley, WA 99216
>>>> brian@crystalfontz.com http://www.crystalfontz.com
>>>> Twitter: @Crystalfontz
>>>> US toll-free (888) 206-9720 voice (509) 892-1200
>>>>
>>>>
>>>> On Tue, May 6, 2014 at 3:06 PM, Florian Fainelli <f.fainelli@gmail=
=2Ecom> wrote:
>>>>> 2014-05-06 14:40 GMT-07:00 Brian Lilly <brian@crystalfontz.com>:
>>>>>> The PHY on board is the SMSC LAN8720
>>>>>>
>>>>>> With the generic PHY driver selected:  http://pastebin.com/A4MH4=
Ptw
>>>>>>
>>>>>> [   28.828761] fec 800f0000.ethernet eth0: Freescale FEC PHY dri=
ver
>>>>>> [Generic PHY] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-1)
>>>>>> [   28.840626] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not read=
y
>>>>>> [   30.827536] libphy: 800f0000.etherne:00 - Link is Up - 100/Fu=
ll
>>>>>> [   30.833739] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes=
 ready
>>>>>> [   32.986999] IPv6: ADDRCONF(NETDEV_UP): usb0: link is not read=
y
>>>>>> [   37.316421] fec 800f0000.ethernet eth0: Freescale FEC PHY dri=
ver
>>>>>> [Generic PHY] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-1)
>>>>>> [   38.345047] fec 800f0000.ethernet eth0: MDIO read timeout
>>>>>> [   39.506210] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not read=
y
>>>>>> [   40.374961] fec 800f0000.ethernet eth0: MDIO read timeout
>>>>>>
>>>>>> With the SMSC PHY driver selected:  http://pastebin.com/DhdDyrMv
>>>>>>
>>>>>> [   28.778974] fec 800f0000.ethernet eth0: Freescale FEC PHY dri=
ver
>>>>>> [SMSC LAN8710/LAN8720] (mii_bus:phy_addr=3D800f0000.etherne:00, =
irq=3D-1)
>>>>>> [   28.791742] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not read=
y
>>>>>> [   30.773078] libphy: 800f0000.etherne:00 - Link is Up - 100/Fu=
ll
>>>>>> [   30.779286] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes=
 ready
>>>>>> [   32.934692] IPv6: ADDRCONF(NETDEV_UP): usb0: link is not read=
y
>>>>>> [   37.242162] fec 800f0000.ethernet eth0: Freescale FEC PHY dri=
ver
>>>>>> [SMSC LAN8710/LAN8720] (mii_bus:phy_addr=3D800f0000.etherne:00, =
irq=3D-1)
>>>>>> [   38.270611] fec 800f0000.ethernet eth0: MDIO read timeout
>>>>>> [   39.415256] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not read=
y
>>>>>> [   40.300454] fec 800f0000.ethernet eth0: MDIO read timeout
>>>>>
>>>>> Thanks for trying this, at least this is consistent no matter whi=
ch
>>>>> PHY driver we are using. Just to rule out a potential PHY power-d=
own
>>>>> issue, could you try to revert the following commit
>>>>> be9dad1f9f26604fb71c0d53ccb39a8f1d425807 ("net: phy: suspend phyd=
ev
>>>>> when going to HALTED") and see if that works better for you?
>>>>>
>>>>> Thanks!
>>>>>
>>>>>>
>>>>>> On Tue, May 6, 2014 at 12:24 PM, Florian Fainelli <f.fainelli@gm=
ail.com> wrote:
>>>>>>> 2014-05-06 12:12 GMT-07:00 Brian Lilly <brian@crystalfontz.com>=
:
>>>>>>>> It is happening during boot up:
>>>>>>>>
>>>>>>>> <snip, kernel 3.12 >
>>>>>>>>
>>>>>>>> Configuring network interfaces... [   35.117114] fec 800f0000.=
ethernet
>>>>>>>> eth0: Freescale FEC PHY driver [SMSC LAN8710/LAN8720]
>>>>>>>
>>>>>>> Note that the SMSC PHY driver is picked up here, and that speci=
fic
>>>>>>> driver implements a different phy_read_status() callback due to=
 how
>>>>>>> the PHY operates. The PHY driver also overrides the config_init=
()
>>>>>>> callback to perform some PHY-specific initialization. See below=
 for
>>>>>>> more.
>>>>>>>
>>>>>>>> (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-1)
>>>>>>>> [   35.129967] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not re=
ady
>>>>>>>> udhcpc (v1.21.1) started
>>>>>>>>
>>>>>>>> Sending discover...
>>>>>>>>
>>>>>>>> [   37.113901] libphy: 800f0000.etherne:00 - Link is Up - 100/=
=46ull
>>>>>>>> [   37.120134] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becom=
es ready
>>>>>>>> Sending discover...
>>>>>>>>
>>>>>>>> Sending select for 10.10.10.217...
>>>>>>>> Lease of 10.10.10.217 obtained, lease time 86400
>>>>>>>> /etc/udhcpc.d/50default: Adding DNS 10.10.10.13
>>>>>>>> [   39.319957] IPv6: ADDRCONF(NETDEV_UP): usb0: link is not re=
ady
>>>>>>>> done.
>>>>>>>> Starting rpcbind daemon...done.
>>>>>>>> net.ipv4.conf.default.rp_filter =3D 1
>>>>>>>> net.ipv4.conf.all.rp_filter =3D 1
>>>>>>>> Mon Apr 14 22:40:00 UTC 2014
>>>>>>>> INIT: Entering runlevel: 5
>>>>>>>> Starting Xserver
>>>>>>>> Starting system message bus: dbus.
>>>>>>>> Starting Connection Manager
>>>>>>>> Starting wpa_supplicant
>>>>>>>> Successfully initialized wpa_supplicant
>>>>>>>> Starting Dropbear SSH server
>>>>>>>> [   44.754915] fec 800f0000.ethernet eth0: Freescale FEC PHY d=
river
>>>>>>>> [SMSC LAN8710/LAN8720] (mii_bus:phy_addr=3D800f0000.etherne:00=
, irq=3D-1)
>>>>>>>
>>>>>>> The correct PHY driver is selected here...
>>>>>>>
>>>>>>>> [   45.781364] fec 800f0000.ethernet eth0: MDIO read timeout
>>>>>>>> [   46.826170] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not re=
ady
>>>>>>>> [   47.811385] fec 800f0000.ethernet eth0: MDIO read timeout
>>>>>>>
>>>>>>> But we are still seeing MDIO read timeouts, which is not great.
>>>>>>>
>>>>>>>>
>>>>>>>> With a different kernel (3.14):
>>>>>>>>
>>>>>>>> [   28.989897] fec 800f0000.ethernet eth0: Freescale FEC PHY d=
river
>>>>>>>> [Generic PHY] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-=
1)
>>>>>>>> [   30.991210] libphy: 800f0000.etherne:00 - Link is Up - 100/=
=46ull
>>>>>>>> [   37.369372] fec 800f0000.ethernet eth0: Freescale FEC PHY d=
river
>>>>>>>> [Generic PHY] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-=
1)
>>>>>>>
>>>>>>> Here, the Generic PHY driver has been selected, which will use =
the
>>>>>>> MII_BMSR register contents to determine the Link status and
>>>>>>> parameters. You might want to make sure that your board selects=
 the
>>>>>>> appropriate PHY driver, such that we are not chasing two issues=
 here.
>>>>>>>
>>>>>>>> [   38.398346] fec 800f0000.ethernet eth0: MDIO read timeout
>>>>>>>> [   39.438412] fec 800f0000.ethernet eth0: MDIO read timeout
>>>>>>>> [   39.468419] fec 800f0000.ethernet eth0: MDIO write timeout
>>>>>>>> [   40.498848] fec 800f0000.ethernet eth0: MDIO read timeout
>>>>>>>
>>>>>>> It would also be helpful to print the register that were access=
ed,
>>>>>>> such that you could correlate this with the exact steps in the =
PHY
>>>>>>> library state machine. Please also retry the experiment with th=
e SMSC
>>>>>>> PHY driver enabled, as it does some PHY specific initialization=
 that
>>>>>>> seems to be relevant. Then we are hopefully left with only the =
MDIO
>>>>>>> timeout issue and not the PHY mis-configuration + MDIO timeout.
>>>>>>>
>>>>>>>>
>>>>>>>> Afterward I have to ifdown eth0, ifup eth0 and then it functio=
ns
>>>>>>>> normally, without reverting the commit.
>>>>>>>>
>>>>>>>> root@cfa100xx:~# ifdown eth0
>>>>>>>> [ 1154.679658] fec 800f0000.ethernet eth0: Freescale FEC PHY d=
river
>>>>>>>> [Generic PHY] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-=
1)
>>>>>>>> root@cfa100xx:~# ifup eth0
>>>>>>>> udhcpc (v1.21.1) started
>>>>>>>> Sending discover...
>>>>>>>> [ 1156.679547] libphy: 800f0000.etherne:00 - Link is Up - 100/=
=46ull
>>>>>>>> Sending discover...
>>>>>>>> Sending select for 10.10.10.217...
>>>>>>>> Lease of 10.10.10.217 obtained, lease time 86400
>>>>>>>> ip: RTNETLINK answers: File exists
>>>>>>>>
>>>>>>>> --
>>>>>>>> Brian
>>>>>>>>
>>>>>>>>
>>>>>>>> On Tue, May 6, 2014 at 11:11 AM, Uwe Kleine-K=C3=B6nig
>>>>>>>> <u.kleine-koenig@pengutronix.de> wrote:
>>>>>>>>> Hello Brian,
>>>>>>>>>
>>>>>>>>> On Tue, May 06, 2014 at 09:44:34AM -0700, Brian Lilly wrote:
>>>>>>>>>> With commit a264b981f2c76e281ef27e7232774bf6c54ec865 we're h=
aving eth0
>>>>>>>>>> come up, then brought right back down with an MDIO rx timeou=
t moments
>>>>>>>>>> after.  Adding back in the removed code keeps the interface =
alive and
>>>>>>>>>> it's working afterward without trouble.  I've tested the re-=
inserted
>>>>>>>>>> code in 3.12, 3.14 without issue on our boards.
>>>>>>>>> So you can reliably trigger that problem? You're just doing
>>>>>>>>>
>>>>>>>>>         ifconfig eth0 1.2.3.4 up
>>>>>>>>>
>>>>>>>>> (or equivalent) and the interface goes down without further
>>>>>>>>> interference with the above mentioned commit? The exact error=
 you're
>>>>>>>>> seeing is
>>>>>>>>>
>>>>>>>>>         MDIO read timeout
>>>>>>>>>
>>>>>>>>> (with some prefix saying something about fec and eth0 I think=
)?
>>>>>>>>>
>>>>>>>>> This error is also present with a264b981f2 reverted, just doe=
sn't affect
>>>>>>>>> eth0 being functional? Does the timeout always happen, or onl=
y on
>>>>>>>>> specific addresses?
>>>>>>>>>
>>>>>>>>> This is not a proper fix, but does it help to increment FEC_M=
II_TIMEOUT?
>>>>>>>>>
>>>>>>>>>> Is there something else that can be done to prevent the MDIO=
 timeouts?
>>>>>>>>>> We are using basically the same schematic for networking as =
the
>>>>>>>>>> imx28evk.
>>>>>>>>> Hard to say, but assuming it works just fine on the imx28evk =
for you,
>>>>>>>>> too, there seems to be some hardware difference that makes yo=
ur machine
>>>>>>>>> fail. (That doesn't mean it's not fixable in software.)
>>>>>>>>>
>>>>>>>>> I don't know if a mdio read error is intended to make the dev=
ice go
>>>>>>>>> down, maybe one the the netdev guys can answer that.
>>>>>>>>> Assuming that it's not intended, instrument the code, find ou=
t how that
>>>>>>>>> timeout makes your device go down and find the wrong branch. =
I'd start
>>>>>>>>> with adding stackdumps when the mdio timeout happens and when
>>>>>>>>> fec_enet_start_xmit is called with fep->link =3D=3D 0.
>>>>>>>>>
>>>>>>>>> Best regards
>>>>>>>>> Uwe
>>>>>>>>>
>>>>>>>>> --
>>>>>>>>> Pengutronix e.K.                           | Uwe Kleine-K=C3=B6=
nig            |
>>>>>>>>> Industrial Linux Solutions                 | http://www.pengu=
tronix.de/  |
>>>>>>>> --
>>>>>>>> To unsubscribe from this list: send the line "unsubscribe netd=
ev" in
>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.=
html
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> --
>>>>>>> Florian
>>>>>
>>>>>
>>>>>
>>>>> --
>>>>> Florian
>>>
>>>
>>>
>>> --
>>> Florian
>
>
>
> --
> Florian

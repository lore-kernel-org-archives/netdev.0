From: Gabriele Paoloni <gabriele.paoloni@huawei.com>
Subject: RE: [bug discuss] fjes driver call trace warning, "PNP0C02" used in
 fjes	seems like a bug,
Date: Wed, 8 Jun 2016 07:10:39 +0000
Message-ID: <EE11001F9E5DDD47B7634E2F8A612F2E1F7783A9@lhreml507-mbx>
References: <57515004.1080301@huawei.com>
 <EE11001F9E5DDD47B7634E2F8A612F2E1F76DB68@lhreml507-mbx>
 <E86EADE93E2D054CBCD4E708C38D364A7379C541@G01JPEXMBYT01>
 <EE11001F9E5DDD47B7634E2F8A612F2E1F7715BA@lhreml507-mbx>
 <E86EADE93E2D054CBCD4E708C38D364A7379DCD7@G01JPEXMBYT01>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Linuxarm <linuxarm@huawei.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>,
	"liudongdong (C)" <liudongdong3@huawei.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E86EADE93E2D054CBCD4E708C38D364A7379DCD7@G01JPEXMBYT01>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+TO: David Miller
+CC: linux-kernel@vger.kernel.org

> -----Original Message-----
> From: Izumi, Taku [mailto:izumi.taku@jp.fujitsu.com]
> Sent: 08 June 2016 03:27
> To: Gabriele Paoloni; liudongdong (C)
> Cc: Linuxarm; netdev@vger.kernel.org
> Subject: RE: [bug discuss] fjes driver call trace warning, "PNP0C02"
> used in fjes seems like a bug,
> 
> Dear Gab,
> 
> > > > > I think that "PNP0C02" should be used to mark any motherboard
> > > reserved
> > > > > resource and not a specific network driver.
> > > > > It seems like a bug in the "fjes" driver.
> > >
> > >   Extended Socket network device is a shared memory based high-
> speed
> > >   network interface between Extended Partitions of PRIMEQUEST 2000
> E2
> > >   series. To check if firmware supports Extended Socket network
> device,
> > >   we take use of  "PCP0C02" device and special strings in DSDT.
> > >
> > >   "fjes" is not only "platform device driver (mainly act as network
> > >    driver" but also "acpi driver" . If "PCP0C02" found and it is
> for
> > >    Extended Socket network device, platform_device will be created.
> >
> > From my understanding PNP0C02 is not a valid ACPI device HID but it
> is
> > to be used only to reserve motherboard resources.
> >
> > Can you please explain your identifier choice?
> 
>    Sorry for late.
> 
>    Extended Socket network device is not a physical device. This is a
>    kind of virtual device in memory region which firmware provides.

>From a SW perspective it like an acpi driver that uses "PNP0C02"
as driver ids to perform the driver match in the ACPI table.

>From my understanding this is wrong in principle because that identifier
must be used to reserve motherboard resources (see par 4.1.2 of the PCI
Firmware Specifications v3.2)

Therefore such identifier it is used from
http://lxr.free-electrons.com/source/drivers/pnp/system.c
to reserve such resources.

Basically your driver is breaking any other device that
needs to reserve motherboard resources through system.c
driver.

@David Miller, what is your opinion about this?
I think this driver should be reverted...

Thanks

Gab
 

>    This driver retrieves resource information
>    (memory reagion address firmware provides and so on)
>    via PNP0C02. This resource is firmware reserved resources so we use
>    PNP0C02.
> 
>    Sincerely,
>    Taku Izumi
> 
> >
> > Gab
> >
> > >
> > >   Sincerely,
> > >   Taku Izumi
> > >
> > > > >
> > > > > Thanks
> > > > >
> > > > > Dongdong
> > > > >
> > > > >
> > > > >
> > > > >
> > > > > _______________________________________________
> > > > > linuxarm mailing list
> > > > > linuxarm@huawei.com
> > > > > http://rnd-openeuler.huawei.com/mailman/listinfo/linuxarm

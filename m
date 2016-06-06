From: Gabriele Paoloni <gabriele.paoloni@huawei.com>
Subject: RE: [bug discuss] fjes driver call trace warning, "PNP0C02" used in
 fjes	seems like a bug,
Date: Mon, 6 Jun 2016 09:44:36 +0000
Message-ID: <EE11001F9E5DDD47B7634E2F8A612F2E1F7715BA@lhreml507-mbx>
References: <57515004.1080301@huawei.com>
 <EE11001F9E5DDD47B7634E2F8A612F2E1F76DB68@lhreml507-mbx>
 <E86EADE93E2D054CBCD4E708C38D364A7379C541@G01JPEXMBYT01>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: Linuxarm <linuxarm@huawei.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>,
	"liudongdong (C)" <liudongdong3@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dfwrgout.huawei.com ([206.16.17.72]:15913 "EHLO
	dfwrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbcFFKDh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 06:03:37 -0400
In-Reply-To: <E86EADE93E2D054CBCD4E708C38D364A7379C541@G01JPEXMBYT01>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Taku Izumi

> -----Original Message-----
> From: Izumi, Taku [mailto:izumi.taku@jp.fujitsu.com]
> Sent: 06 June 2016 10:34
> To: Gabriele Paoloni; liudongdong (C)
> Cc: Linuxarm; netdev@vger.kernel.org
> Subject: RE: [bug discuss] fjes driver call trace warning, "PNP0C02"
> used in fjes seems like a bug,
> 
> Dear Liu,
> 
> > -----Original Message-----
> > From: Gabriele Paoloni [mailto:gabriele.paoloni@huawei.com]
> > Sent: Friday, June 03, 2016 6:59 PM
> > To: liudongdong (C); Izumi, Taku/泉 拓
> > Cc: Linuxarm; netdev@vger.kernel.org
> > Subject: RE: [bug discuss] fjes driver call trace warning, "PNP0C02"
> used in fjes seems like a bug,
> >
> > Hi Dongdong
> >
> > Thanks for flagging this
> >
> > +to: Taku Izumi <izumi.taku@jp.fujitsu.com>
> >
> > Gab
> >
> > > -----Original Message-----
> > > From: linuxarm-bounces@huawei.com [mailto:linuxarm-
> bounces@huawei.com]
> > > On Behalf Of Dongdong Liu
> > > Sent: 03 June 2016 10:38
> > > To: netdev@vger.kernel.org
> > > Cc: Linuxarm
> > > Subject: [bug discuss] fjes driver call trace warning, "PNP0C02"
> used
> > > in fjes seems like a bug,
> > >
> > > Hi all:
> > >
> > > The bug is recorded in https://bugs.linaro.org/show_bug.cgi?id=2292.
> > >
> > > "PNP0C02" attached two modules drivers/pnp/system.c and
> > > drivers/net/fjes/fjes_main.c .
> > > "fjes" driver lead to the call trace.
> > >
> > > system.c:
> > > static const struct pnp_device_id pnp_dev_table[] = {
> > >          /* General ID for reserving resources */
> > >          {"PNP0c02", 0},
> > >          /* memory controller */
> > >          {"PNP0c01", 0},
> > >          {"", 0}
> > > };
> > >
> > > jes_main.c:
> > > static const struct acpi_device_id fjes_acpi_ids[] = {
> > >          {"PNP0C02", 0},
> > >          {"", 0},
> > > };
> > >
> > > Both of the modules use id "PNP0C02" (case insensitive),
> > >
> > > I used "PNP0C02" to mark motherboard reserved resource as below in
> > > UEFI.
> > > Device (RES1)
> > > {
> > > 	Name (_HID, "HISI0081") // HiSi PCIe RC config baseaddress
> > > 	Name (_CID, "PNP0C02") // Motherboard reserved resource
> > > 		Name (_CRS, ResourceTemplate (){
> > > 			Memory32Fixed (ReadWrite, 0xb0080000 , 0x10000)
> > > 		})
> > > }
> > >
> > > I think that "PNP0C02" should be used to mark any motherboard
> reserved
> > > resource and not a specific network driver.
> > > It seems like a bug in the "fjes" driver.
> 
>   Extended Socket network device is a shared memory based high-speed
>   network interface between Extended Partitions of PRIMEQUEST 2000 E2
>   series. To check if firmware supports Extended Socket network device,
>   we take use of  "PCP0C02" device and special strings in DSDT.
> 
>   "fjes" is not only "platform device driver (mainly act as network
>    driver" but also "acpi driver" . If "PCP0C02" found and it is for
>    Extended Socket network device, platform_device will be created.

>From my understanding PNP0C02 is not a valid ACPI device HID but it is
to be used only to reserve motherboard resources.

Can you please explain your identifier choice?

Thanks

Gab

> 
>   Sincerely,
>   Taku Izumi
> 
> > >
> > > Thanks
> > >
> > > Dongdong
> > >
> > >
> > >
> > >
> > > _______________________________________________
> > > linuxarm mailing list
> > > linuxarm@huawei.com
> > > http://rnd-openeuler.huawei.com/mailman/listinfo/linuxarm

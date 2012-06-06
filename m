From: Bhupesh SHARMA <bhupesh.sharma@st.com>
Subject: RE: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Wed, 6 Jun 2012 11:50:59 +0800
Message-ID: <D5ECB3C7A6F99444980976A8C6D896384FA5EC4E62@EAPEX1MAIL1.st.com>
References: <331ABD5ECB02734CA317220B2BBEABC13E9CB18A@DBDE01.ent.ti.com>
  <4FCE07EE.40003@pengutronix.de>
   <D5ECB3C7A6F99444980976A8C6D896384FA5EC4DFC@EAPEX1MAIL1.st.com>
   <4FC135C6.5030206@grandegger.com> <1677842.Pq7naXsvrI@harkonnen>
   <D5ECB3C7A6F99444980976A8C6D896384FA5EC4B37@EAPEX1MAIL1.st.com>
   <3650428.HarNR9HfNF@harkonnen> <20120605131337.GA15432@mail.gnudd.com>
  <20120605133013.GA16108@mail.gnudd.com>
 <20120605165008.GA21871@mail.gnudd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "mkl@pengutronix.de" <mkl@pengutronix.de>,
	"federico.vaga@gmail.com" <federico.vaga@gmail.com>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"wg@grandegger.com" <wg@grandegger.com>,
	Giancarlo ASNAGHI <giancarlo.asnaghi@st.com>,
	"alan@linux.intel.com" <alan@linux.intel.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "rubini@gnudd.com" <rubini@gnudd.com>,
	"anilkumar@ti.com" <anilkumar@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20120605165008.GA21871@mail.gnudd.com>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> -----Original Message-----
> From: rubini@gnudd.com [mailto:rubini@gnudd.com]
> Sent: Tuesday, June 05, 2012 10:20 PM
> To: anilkumar@ti.com
> Cc: mkl@pengutronix.de; Bhupesh SHARMA; federico.vaga@gmail.com;
> alan@lxorguk.ukuu.org.uk; wg@grandegger.com; Giancarlo ASNAGHI;
> alan@linux.intel.com; linux-can@vger.kernel.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
> 
> > I am late to the discussion, is there any specific reason to maintain
> a
> > separate platform file (c_can_pci.c).
> 
> Because it depends on pci and ifdef is bad.
> 
> > I think 90% of the code is copied from c_can_paltform.c, code
> > changes will be less if you merge to existing c_can platform driver.
> 
> Yes, but then we need to ifdef around, which merges two bad files
> into a single but worse file.
> 
> But since the only current user of c_can is the platform device, why
> not merging the platform with the core and having pci just register a
> platform device?  The only problem I see is that we need cooperation,
> because neither me nor federico have a c_can equipped board besides
> the pci one.
> 

I can see examples of where different platform files are present for SJA CAN controller
as well depending on the underlying bus being used: OpenFirmware, ISA, PCI, etc..,
whilst there is a single core file there as well 'sja1000.c'

[1] Kvaser PCI platform driver, using services exposed by sja1000 core:
	http://lxr.linux.no/linux+v3.4.1/drivers/net/can/sja1000/kvaser_pci.c

[2] EMS PCI platform driver, using services exposed by sja1000 core:
	http://lxr.linux.no/linux+v3.4.1/drivers/net/can/sja1000/ems_pci.c

[3] SJA1000 core:
	http://lxr.linux.no/linux+v3.4.1/drivers/net/can/sja1000/sja1000.c

Here each platform driver has its own version of register read/write routine implementation.
The C_CAN approach is similar to that used by SJA1000. Instead of merging the "platform with the core",
I would instead suggest to have two separate platform drivers (for each bus type) and invoke common
routines kept in say another file 'c_can_platform_common.c', thus insuring that there is no code
duplicity and we have a clean hierarchical structure as well. So we can have:
	- Core file, c_can.c
	- Common platform file, c_can_platform_common.c
	- Platform file, c_can_platform.c, c_can_pci.c, etc..

This ensures that nothing breaks at the end of the existing C_CAN users and we have a clean
file structure as well.

Ofcourse, Wolfgang has a better idea of this structure, as he defined the same for SJA1000 and I 
consulted with him on this, while he was reviewing my initial C_CAN patch set. I will let him and Marc
comment further on my proposal. Your comments are also most welcome :)

Regards,
Bhupesh

From: Bhupesh SHARMA <bhupesh.sharma@st.com>
Subject: RE: [PATCH] ARM: OMAP: AM33XX: CAN: d_can: Add support for Bosch
 D_CAN controller
Date: Wed, 4 Apr 2012 11:43:22 +0800
Message-ID: <D5ECB3C7A6F99444980976A8C6D896384FA301D81D@EAPEX1MAIL1.st.com>
References: <1333456339-9372-1-git-send-email-anilkumar@ti.com>
 <4F7AF0C7.7020506@grandegger.com>
 <331ABD5ECB02734CA317220B2BBEABC1317D85D0@DBDE01.ent.ti.com>
 <4F7AFFEC.1010805@pengutronix.de>
 <331ABD5ECB02734CA317220B2BBEABC1317D86F7@DBDE01.ent.ti.com>
 <4F7B1854.90106@pengutronix.de>
 <331ABD5ECB02734CA317220B2BBEABC1317D88B7@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	"socketcan@hartkopp.net" <socketcan@hartkopp.net>,
	"m.kleine-budde@pengutronix.de" <m.kleine-budde@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Gole, Anant" <anantgole@ti.com>, "Nori,  Sekhar" <nsekhar@ti.com>
To: "AnilKumar, Chimata" <anilkumar@ti.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <331ABD5ECB02734CA317220B2BBEABC1317D88B7@DBDE01.ent.ti.com>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: linux-can-owner@vger.kernel.org [mailto:linux-can-
> owner@vger.kernel.org] On Behalf Of AnilKumar, Chimata
> Sent: Tuesday, April 03, 2012 9:28 PM
> To: Marc Kleine-Budde
> Cc: Wolfgang Grandegger; socketcan@hartkopp.net; m.kleine-
> budde@pengutronix.de; linux-can@vger.kernel.org;
> netdev@vger.kernel.org; linux-omap@vger.kernel.org; linux-
> kernel@vger.kernel.org; Gole, Anant; Nori, Sekhar
> Subject: RE: [PATCH] ARM: OMAP: AM33XX: CAN: d_can: Add support for
> Bosch D_CAN controller
> 
> On Tue, Apr 03, 2012 at 21:03:40, Marc Kleine-Budde wrote:
> > On 04/03/2012 04:29 PM, AnilKumar, Chimata wrote:
> > >>>> Please explain why this CAN controller cannot be handled by the
> existing
> > >>>> C_CAN driver, eventually with some extensions. The register
> layout seems
> > >>>> almost identical, at least.
> > >>>>
> > >>>> Wolfgang.
> > >>>>
> > >>>
> > >>> These are the some of the pointers I can say, why I had gone for
> separate
> > >>> file instead of existing driver:
> > >>> * In case of D_CAN driver we can see all the registers are 32bit
> length
> > >>>   but in case of C_CAN registers are in 16bit length.
> > >>
> > >> How many bits in these 32 bit registers are used?
> > >
> > > In some cases (D_CAN_TXRQ, D_CAN_INTPND, D_CAN_MSGVAL) I have used
> all the
> > > bits, in some cases used few bits.
> > >
> > > Roughly I can say that its (higher 16bits) % of usages is similar
> as compare
> > > to 16bits
> > >
> > > While checking the status of TXRequest registers and INT pending
> register,
> > > which is a hot code path, we have to put if checks for register
> access.
> >
> > The c_can already has a c_can_read_reg32() function. It's for example
> > used in the rx_poll function. You can make it a function pointer
> (i.e.
> > pric->read_reg32()) for easy abstraction.
> 
> This won't fit for D_CAN case because offsets are different in c_can
> compared
> to d_can. For example if I read CONTROL_REG register (0x0) in case of
> d_can,
> which will read only control register. In case of c_can it will read
> CONTROL_REG + STATUS register values in single read

C_CAN core has both 16-bit as well as 32-bit registers.
While the registers like NEWDATA and INTPND are 32-bit the others
like Control and Status are 16-bit.

These cases are handled by the present C_CAN driver already.
If you will see the C_CAN driver then you will see that the normal
read/write operations are 16-bit whereas a special variant is provided
for 32-bit access.

Are you sure you cannot use them as it is?

> >
> > >>> * Some of the registers, bit masks are different, so we have to
> add
> > >>>   checks on every API for differentiating the kind of device
> > >>
> > >> Which registers are this? Can you give us an example?
> > >
> > > I am pointing out some of the resisters
> > > * Single registers in case of D_CAN but multiple register in case
> of C_CAN
> > >   So masks will change MASK, ARB, INTPND
> > > * D_CAN_IFCMD is the combination of COMM request and COMM mask
> registers
> >
> > Maybe you can use the read_reg32 function on both c_can and d_can.
> 
> Above comment applies here as well
> 

This can be easily handled. I have worked on several drivers that do that.
See for example the STMPE multi-function device driver (MFD), here [1]

There are various variants of STMPE devices (like STMPE801 etc..) and they
can be handled by using a common driver and passing different platform data
intelligently that provides specific handling for a specific STMPE device.

Regards,
Bhupesh

[1] http://lxr.linux.no/linux+v3.3.1/drivers/mfd/stmpe.c


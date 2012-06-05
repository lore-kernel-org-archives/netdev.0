From: Bhupesh SHARMA <bhupesh.sharma@st.com>
Subject: RE: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Tue, 5 Jun 2012 21:04:21 +0800
Message-ID: <D5ECB3C7A6F99444980976A8C6D896384FA5EC4DFC@EAPEX1MAIL1.st.com>
References: <4FC135C6.5030206@grandegger.com> <1677842.Pq7naXsvrI@harkonnen>
 <D5ECB3C7A6F99444980976A8C6D896384FA5EC4B37@EAPEX1MAIL1.st.com>
 <3650428.HarNR9HfNF@harkonnen>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Giancarlo ASNAGHI <giancarlo.asnaghi@st.com>,
	Alan Cox <alan@linux.intel.com>,
	Alessandro Rubini <rubini@gnudd.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Federico Vaga <federico.vaga@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <3650428.HarNR9HfNF@harkonnen>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Federico Vaga [mailto:federico.vaga@gmail.com]
> Sent: Tuesday, June 05, 2012 4:49 PM
> To: Bhupesh SHARMA
> Cc: Alan Cox; Wolfgang Grandegger; Marc Kleine-Budde; Giancarlo
> ASNAGHI; Alan Cox; Alessandro Rubini; linux-can@vger.kernel.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
> 
> > In some of these SoC's the C_CAN registers which are essentially
> > 16-bit or 32-bit registers are aligned always to a 32-bit boundary
> > (i.e. even a 16-bit register is aligned to 32-bit boundary).
> >
> > So, I had to implement two variants of the read/write reg routines. I
> > am not sure your SoC implementation needs them. If it does, I will
> > categorize it as flaky as well :)
> 
> My implementation is align to 32, but I'm trying to make a generic PCI
> wrapper (some other could be aligned to 16)

So it means your implementation is also flaky and you are probably wasting HW memory
space while integrating the Bosch C_CAN module in your SoC :)

> > See above. There was a reason for keeping these routines in
> > c_can_platform.c Simply put, every platform having a Bosch C_CAN
> > module can have it's own implementation of the bus (for example you
> > use PCI) and register bank layout (16-bit or 32-bit aligned).
> 
> I don't understand the reason to keep these functions in
> c_can_platform.c . Two generic read/write functions could be written
> into c_can.c by using a shift value (0 if aligned to 16, 1 if aligned
> to
> 32) as I showed in the previous mail:
> 
> > > static u16 c_can_read_reg(struct c_can_priv *priv, enum reg index)
> > > {
> > >
> > > 	return readw(priv->base + (priv->regs[index] << priv->offset));
> > >
> > > }
> > > static void c_can_write_reg(struct c_can_priv *priv, enum reg
> index,
> > >
> > > 						u16 val)
> > >
> > > {
> > >
> > > 	writew(val, priv->base + (priv->regs[index] << priv->offset));
> > >
> > > }
> 
> Every platform having a Bosch C_CAN/D_CAN can specify its shift value
> (0
> or 1) and it's done.
> 

I am not a big fan of adding platform specific flakes in any core file, that why we keep the platform
file separate from the core ones. But I will left Marc and Wolfgang to further comment on the same.

Regards,
Bhupesh

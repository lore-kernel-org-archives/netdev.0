From: Bhupesh SHARMA <bhupesh.sharma@st.com>
Subject: RE: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Tue, 5 Jun 2012 11:42:50 +0800
Message-ID: <D5ECB3C7A6F99444980976A8C6D896384FA5EC4B37@EAPEX1MAIL1.st.com>
References: <4FC135C6.5030206@grandegger.com>
 <1338816766-7089-2-git-send-email-federico.vaga@gmail.com>
 <20120604165619.15ba43bf@pyramind.ukuu.org.uk> <1677842.Pq7naXsvrI@harkonnen>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Giancarlo ASNAGHI <giancarlo.asnaghi@st.com>,
	Alan Cox <alan@linux.intel.com>,
	Alessandro Rubini <rubini@gnudd.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Federico Vaga <federico.vaga@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1677842.Pq7naXsvrI@harkonnen>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: linux-can-owner@vger.kernel.org [mailto:linux-can-
> owner@vger.kernel.org] On Behalf Of Federico Vaga
> Sent: Monday, June 04, 2012 10:16 PM
> To: Alan Cox
> Cc: Wolfgang Grandegger; Marc Kleine-Budde; Giancarlo ASNAGHI; Alan
> Cox; Alessandro Rubini; linux-can@vger.kernel.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
> 
> > > +static u16 c_can_pci_read_reg_aligned_to_16bit(struct c_can_priv
> > > *priv, +						void *reg)
> >
> > I'm a bit worried this function name might be too short ;)
> 
> I know :) I was inspired by the same function in c_can_platform.c

There was a purpose to keeping these long function names when I wrote
the c_can_platform driver initially. These were kept to support the 
SoCs (even the flaky ones) which I could trace at that time and used C_CAN controllers
(e.g. Hynix, ST's SPEAr eMPUs, etc..) and had different register bank layouts.

In some of these SoC's the C_CAN registers which are essentially 16-bit or 32-bit
registers are aligned always to a 32-bit boundary (i.e. even a 16-bit register
is aligned to 32-bit boundary).

So, I had to implement two variants of the read/write reg routines. I am not sure your SoC implementation needs them.
If it does, I will categorize it as flaky as well :)
 
> About these function I suggest to move them into c_can.c because they
> are the same for c_can_platform.c and c_can_pci.c Then add a new field
> c_can_priv->offset which can be used to shift the register offset
> coherently with the memory alignment. Finally, remove c_can_priv-
> >read_reg and c_can_priv->write_reg and use internal c_can.c function
> to
> read and write registers.

See above. There was a reason for keeping these routines in c_can_platform.c
Simply put, every platform having a Bosch C_CAN module can have it's own implementation
of the bus (for example you use PCI) and register bank layout (16-bit or 32-bit aligned).

I would suggest to keep the same arrangement.

> static u16 c_can_read_reg(struct c_can_priv *priv, enum reg index)
> {
> 	return readw(priv->base + (priv->regs[index] << priv->offset));
> }
> static void c_can_write_reg(struct c_can_priv *priv, enum reg index,
> 						u16 val)
> {
> 	writew(val, priv->base + (priv->regs[index] << priv->offset));
> }
> 
> 
> If it's ok, I can made a patch for this in the next days.
> 

[snip..]


Regards,
Bhupesh

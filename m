From: Federico Vaga <federico.vaga@gmail.com>
Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Mon, 04 Jun 2012 18:45:44 +0200
Message-ID: <1677842.Pq7naXsvrI@harkonnen>
References: <4FC135C6.5030206@grandegger.com> <1338816766-7089-2-git-send-email-federico.vaga@gmail.com> <20120604165619.15ba43bf@pyramind.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Giancarlo Asnaghi <giancarlo.asnaghi@st.com>,
	Alan Cox <alan@linux.intel.com>,
	Alessandro Rubini <rubini@gnudd.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20120604165619.15ba43bf@pyramind.ukuu.org.uk>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +static u16 c_can_pci_read_reg_aligned_to_16bit(struct c_can_priv
> > *priv, +						void *reg)
> 
> I'm a bit worried this function name might be too short ;)

I know :) I was inspired by the same function in c_can_platform.c


About these function I suggest to move them into c_can.c because they 
are the same for c_can_platform.c and c_can_pci.c Then add a new field 
c_can_priv->offset which can be used to shift the register offset 
coherently with the memory alignment. Finally, remove c_can_priv-
>read_reg and c_can_priv->write_reg and use internal c_can.c function to 
read and write registers.

static u16 c_can_read_reg(struct c_can_priv *priv, enum reg index)
{
	return readw(priv->base + (priv->regs[index] << priv->offset));
}
static void c_can_write_reg(struct c_can_priv *priv, enum reg index,
						u16 val)
{
	writew(val, priv->base + (priv->regs[index] << priv->offset));
}


If it's ok, I can made a patch for this in the next days.

> > +	 * do not call pci_disable_device on sta2x11 because it
> > +	 * break all other Bus masters on this EP
> > +	 */
> > +	if(pdev->vendor == PCI_VENDOR_ID_STMICRO &&
> > +	   pdev->device == PCI_DEVICE_ID_STMICRO_CAN)
> > +		goto out;
> 
> Is that the disabling or the dropping it into D3. We have a PCI quirk
> flag for the latter. See "quirk_no_ata_d3". That will also avoid any
> accidents elsewhere. Right now the quirk has "ata" in the name but the
> ata is just historically because we had to quirk various disk
> controllers.

We are investigating if this is still necessary on the current version 
of the board.

-- 
Federico Vaga

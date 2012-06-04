From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Mon, 4 Jun 2012 16:56:19 +0100
Message-ID: <20120604165619.15ba43bf@pyramind.ukuu.org.uk>
References: <4FC135C6.5030206@grandegger.com>
	<1338816766-7089-1-git-send-email-federico.vaga@gmail.com>
	<1338816766-7089-2-git-send-email-federico.vaga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Giancarlo Asnaghi <giancarlo.asnaghi@st.com>,
	Alan Cox <alan@linux.intel.com>,
	Alessandro Rubini <rubini@gnudd.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Federico Vaga <federico.vaga@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338816766-7089-2-git-send-email-federico.vaga@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +enum c_can_pci_reg_align {
> +	C_CAN_REG_ALIGN_16,
> +	C_CAN_REG_ALIGN_32,
> +};

Anythign wrong with 

bool aligned32;

> +
> +struct c_can_pci_data {
> +	unsigned int reg_align;	/* Set the register alignment in the memory */

Not the enum .. indeed

> +static u16 c_can_pci_read_reg_aligned_to_16bit(struct c_can_priv *priv,
> +						void *reg)

I'm a bit worried this function name might be too short ;)


> +	dev_info(&pdev->dev, "%s device registered (regs=%p, irq=%d)\n",
> +		 KBUILD_MODNAME, priv->regs, dev->irq);

dev_dbg

> +	 * do not call pci_disable_device on sta2x11 because it
> +	 * break all other Bus masters on this EP
> +	 */
> +	if(pdev->vendor == PCI_VENDOR_ID_STMICRO &&
> +	   pdev->device == PCI_DEVICE_ID_STMICRO_CAN)
> +		goto out;

Is that the disabling or the dropping it into D3. We have a PCI quirk
flag for the latter. See "quirk_no_ata_d3". That will also avoid any
accidents elsewhere. Right now the quirk has "ata" in the name but the
ata is just historically because we had to quirk various disk controllers.

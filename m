From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: A new 10GB Ethernet Driver by Chelsio Communications
Date: Fri, 11 Mar 2005 14:35:24 -0800
Message-ID: <20050311143524.7495f22b@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.58.0503110356340.14213@server.graphe.net>
	<20050311112132.6a3a3b49.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <christoph@graphe.net>, linux-kernel@vger.kernel.org,
        mark@chelsio.com, netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050311112132.6a3a3b49.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Mar 2005 11:21:32 -0800
Andrew Morton <akpm@osdl.org> wrote:

> Christoph Lameter <christoph@graphe.net> wrote:
> >
> > A Linux driver for the Chelsio 10Gb Ethernet Network Controller by
> >  Chelsio (http://www.chelsio.com). This driver supports the Chelsio N210
> >  NIC and is backward compatible with the Chelsio N110 model 10Gb NICs.
> 
> Thanks, Christoph.
> 
> The 400k patch was too large for the vger email server so I have uploaded it to
> 
>  http://www.zip.com.au/~akpm/linux/patches/stuff/a-new-10gb-ethernet-driver-by-chelsio-communications.patch
> 
> for reviewers.

The performance recommendations in cxgb.txt are common to all fast devices,
and should be in one file rather than just for this device. I would rather
see ip-sysctl.txt updated or a new file on tuning recommendations started.
Some of them have consequences that aren't documented well.  
For example, turning off TCP timestamps risks data corruption from sequence wrap.

A new driver shouldn't need so may #ifdef's unless you want to putit on older
vendor versions of 2.4

Some accessor and wrapper functions like:
	t1_pci_read_config_4
	adapter_name
	t1_malloc
are just annoying noise.

Why have useless dead code like:




/* Interrupt handler */
+static int pm3393_interrupt_handler(struct cmac *cmac)
+{
+	u32 master_intr_status;
+/*
+    1. Read master interrupt register.
+    2. Read BLOCK's interrupt status registers.
+    3. Handle BLOCK interrupts.
+*/
+	/* Read the master interrupt status register. */
+	pmread(cmac, SUNI1x10GEXP_REG_MASTER_INTERRUPT_STATUS,
+	       &master_intr_status);
+	CH_DBG(cmac->adapter, INTR, "PM3393 intr cause 0x%x\n",
+	       master_intr_status);
+
+	/* Handle BLOCK's interrupts. */
+
+	if (SUNI1x10GEXP_BITMSK_TOP_PL4IO_INT & master_intr_status) {
+	}
+
+	if (SUNI1x10GEXP_BITMSK_TOP_IRAM_INT & master_intr_status) {
+	}
+
+	if (SUNI1x10GEXP_BITMSK_TOP_ERAM_INT & master_intr_status) {
+	}
+
+	/* SERDES */
+	if (SUNI1x10GEXP_BITMSK_TOP_XAUI_INT & master_intr_status) {
+	}
+
+	/* MSTAT */
+	if (SUNI1x10GEXP_BITMSK_TOP_MSTAT_INT & master_intr_status) {
+	}
+
+	/* RXXG */
+	if (SUNI1x10GEXP_BITMSK_TOP_RXXG_INT & master_intr_status) {
+	}
+
+	/* TXXG */
+	if (SUNI1x10GEXP_BITMSK_TOP_TXXG_INT & master_intr_status) {
+	}
+
+	/* XRF */
+	if (SUNI1x10GEXP_BITMSK_TOP_XRF_INT & master_intr_status) {
+	}
+
+	/* XTEF */
+	if (SUNI1x10GEXP_BITMSK_TOP_XTEF_INT & master_intr_status) {
+	}
+
+	/* MDIO */
+	if (SUNI1x10GEXP_BITMSK_TOP_MDIO_BUSY_INT & master_intr_status) {
+		/* Not used. 8000 uses MDIO through Elmer. */
+	}
+
+	/* RXOAM */
+	if (SUNI1x10GEXP_BITMSK_TOP_RXOAM_INT & master_intr_status) {
+	}
+
+	/* TXOAM */
+	if (SUNI1x10GEXP_BITMSK_TOP_TXOAM_INT & master_intr_status) {
+	}
+
+	/* IFLX */
+	if (SUNI1x10GEXP_BITMSK_TOP_IFLX_INT & master_intr_status) {
+	}
+
+	/* EFLX */
+	if (SUNI1x10GEXP_BITMSK_TOP_EFLX_INT & master_intr_status) {
+	}
+
+	/* PL4ODP */
+	if (SUNI1x10GEXP_BITMSK_TOP_PL4ODP_INT & master_intr_status) {
+	}
+
+	/* PL4IDU */
+	if (SUNI1x10GEXP_BITMSK_TOP_PL4IDU_INT & master_intr_status) {
+	}

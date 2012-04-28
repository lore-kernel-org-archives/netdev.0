From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: [PATCH 01/10] atl1c: add workaround for issue of bit
 INTX-disable for MSI interrupt
Date: Sat, 28 Apr 2012 09:53:41 +0000
Message-ID: <157393863283F442885425D2C454285623D5F96D@nasanexd02a.na.qualcomm.com>
References: <1335578325-21326-1-git-send-email-xiong@qca.qualcomm.com>
 <1335578325-21326-2-git-send-email-xiong@qca.qualcomm.com>
 <20120428020510.GJ14465@tux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>
To: "Rodriguez, Luis" <rodrigue@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:46338 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890Ab2D1Jxn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 05:53:43 -0400
In-Reply-To: <20120428020510.GJ14465@tux>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Luis,  just one question:

I don't know which kernel version contains the updated pci/quirks.c, so, 
if I write the patch file (a 58-drivers-pci-quirks.patch) as:

--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c

+#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,22))
+	pdev->dev_flags |= PCI_DEV_FLAGS_MSI_INTX_DISABLE_BUG;
+#endif


It seems not good for the kernel with updated pci/quirks.c

Any better suggestion ? thanks


-Xiong

> -----Original Message-----
> From: Luis R. Rodriguez [mailto:mcgrof@gmail.com] On Behalf Of Luis R.
> Rodriguez
> Sent: Saturday, April 28, 2012 10:05
> To: Huang, Xiong
> Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; qca-linux-team; nic-devel
> Subject: Re: [PATCH 01/10] atl1c: add workaround for issue of bit INTX-disable
> for MSI interrupt
> 
> On Sat, Apr 28, 2012 at 09:58:36AM +0800, xiong wrote:
> > All supported devices have one issue that msi interrupt doesn't assert
> > if pci command register bit (PCI_COMMAND_INTX_DISABLE) is set.
> > Add workaround in drivers/pci/quirks.c
> >
> > Signed-off-by: xiong <xiong@qca.qualcomm.com>
> > ---
> >  drivers/pci/quirks.c |   12 ++++++++++++
> >  1 files changed, 12 insertions(+), 0 deletions(-)
> >
> > diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c index
> > 4bf7102..953ec3f 100644
> > --- a/drivers/pci/quirks.c
> > +++ b/drivers/pci/quirks.c
> > @@ -2626,6 +2626,18 @@
> DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_ATI,
> > 0x4374,  DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_ATI, 0x4375,
> >  			quirk_msi_intx_disable_bug);
> >
> > +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_ATTANSIC, 0x1062,
> > +			quirk_msi_intx_disable_bug);
> > +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_ATTANSIC, 0x1063,
> > +			quirk_msi_intx_disable_bug);
> > +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_ATTANSIC, 0x2060,
> > +			quirk_msi_intx_disable_bug);
> > +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_ATTANSIC, 0x2062,
> > +			quirk_msi_intx_disable_bug);
> > +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_ATTANSIC, 0x1073,
> > +			quirk_msi_intx_disable_bug);
> > +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_ATTANSIC, 0x1083,
> > +			quirk_msi_intx_disable_bug);
> >  #endif /* CONFIG_PCI_MSI */
> 
> Xiong -- just a heads up, I think to backport these then you can send me patches
> for compat-wireless to do the work around itself on the driver on a patch under
> patches/ you can say create a 58-drivers-pci-quirks.patch which pathces your
> driver there.
> 
>   Luis

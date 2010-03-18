From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netxen: The driver doesn't work on NX_P3_B1 so cause probe to fail.
Date: Thu, 18 Mar 2010 02:43:39 -0700
Message-ID: <m11vfic6d0.fsf@fess.ebiederm.org>
References: <m1y6hqdol4.fsf@fess.ebiederm.org>
	<99737F4847ED0A48AECC9F4A1974A4B80CFEFED04B@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59414 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261Ab0CRJno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 05:43:44 -0400
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80CFEFED04B@MNEXMB2.qlogic.org> (Amit Salecha's message of "Thu\, 18 Mar 2010 03\:55\:35 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amit Salecha <amit.salecha@qlogic.com> writes:

> Sorry for all the problem you faced.
>
> But you shouldn't add support of device which is not supported.
> Netxen is now owned by Qlogic. You should first contact Qlogic to solve your problem.
> Qlogic will take needed action based on problem.

I'm not adding support.  I am sending a patch removing support for cards
that do not work with the current driver and have not worked since 2.6.31.

I have already been though this process once in the beginning of
November 2009, and gave a detailed bug report.  Perhaps things got
lost in the handoff between netxen to qlogic.  The fact of the matter
is I reported this before 2.6.32 came out, and the card still does not
work.  In that process I tried a newer firmware rev that does not even
work on 2.6.31.

If you want to jump on this and find a solution that works on the 0x41
hardware rev that would be great.  Otherwise it is time for me to cut
my losses, and be a good community citizen by documenting the driver
does not work on the hardware I have.

The failure mode is that the driver reports a firmware hang, and
I don't get link.  At which point the card is totally useless.

Eric

Mar 18 00:47:37 localhost kernel: QLogic/NetXen Network Driver v4.0.72
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.0: PCI INT A -> GSI 28 (level, low) -> IRQ 28
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.0: 2MB memory map
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting phanfw.bin
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Mar 18 00:47:37 localhost kernel: netxen_nic: Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.0: using msi-x interrupts
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.0: eth2: XGbE port initialized
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.1: PCI INT A -> GSI 28 (level, low) -> IRQ 28
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.1: 2MB memory map
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.1: using msi-x interrupts
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.1: eth3: XGbE port initialized
Mar 18 00:47:37 localhost kernel: net eth2: firmware hang detected
Mar 18 00:47:37 localhost kernel: net eth3: firmware hang detected
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting phanfw.bin
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Mar 18 00:47:37 localhost kernel: netxen_nic: Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Mar 18 00:47:37 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Mar 18 00:47:37 localhost kernel: net eth3: firmware hang detected
Mar 18 00:47:37 localhost kernel: net eth2: firmware hang detected


> Please write to me, with detail problem description.
>
> -----Original Message-----
> From: Eric W. Biederman [mailto:ebiederm@xmission.com] 
> Sent: Thursday, March 18, 2010 1:55 PM
> To: David Miller
> Cc: netdev@vger.kernel.org; Amit Salecha
> Subject: [PATCH] netxen: The driver doesn't work on NX_P3_B1 so cause probe to fail.
>
>
> I haven't been able to get link up on a NX_P3_B1 since 2.6.31.  The
> driver complains about a firmware hang instead.  When I asked I was
> told rev 0x41 was a preproduction rev.  So disable support in the
> driver so no one is surprised the code doesn't work.
>
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
> ---
>  drivers/net/netxen/netxen_nic_main.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
> index 08780ef..9a7a0f3 100644
> --- a/drivers/net/netxen/netxen_nic_main.c
> +++ b/drivers/net/netxen/netxen_nic_main.c
> @@ -1246,8 +1246,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	int pci_func_id = PCI_FUNC(pdev->devfn);
>  	uint8_t revision_id;
>  
> -	if (pdev->revision >= NX_P3_A0 && pdev->revision < NX_P3_B1) {
> -		pr_warning("%s: chip revisions between 0x%x-0x%x"
> +	if (pdev->revision >= NX_P3_A0 && pdev->revision <= NX_P3_B1) {
> +		pr_warning("%s: chip revisions between 0x%x-0x%x "
>  				"will not be enabled.\n",
>  				module_name(THIS_MODULE), NX_P3_A0, NX_P3_B1);
>  		return -ENODEV;
> -- 
> 1.6.6.1

From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH 2/5] fixing errors handling during pci_driver resume stage [ata]
Date: Fri, 12 Jan 2007 16:50:54 -0700
Message-ID: <20070112235054.GA5074@colo.lackof.org>
References: <87tzz0mv4n.fsf@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	devel@openvz.org, linux-pci@atrey.karlin.mff.cuni.cz,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
To: Dmitriy Monakhov <dmonakhov@openvz.org>
Content-Disposition: inline
In-Reply-To: <87tzz0mv4n.fsf@sw.ru>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 09, 2007 at 12:01:28PM +0300, Dmitriy Monakhov wrote:
> ata pci drivers have to return correct error code during resume stage in
> case of errors.
...
> @@ -6246,8 +6253,10 @@ int ata_pci_device_suspend(struct pci_de
>  int ata_pci_device_resume(struct pci_dev *pdev)
>  {
>  	struct ata_host *host = dev_get_drvdata(&pdev->dev);
> +	int err;
>  
> -	ata_pci_device_do_resume(pdev);
> +	if ((err = ata_pci_device_do_resume(pdev)))
> +		return err;

nit: in every other case I looked at you did:
   err = foo()
   if (err) ...

Can you make that consistent here too?

thanks,
grant

From: Jon Mason <jon.mason@intel.com>
Subject: Re: [PATCH RFC 53/77] ntb: Fix missed call to pci_enable_msix()
Date: Wed, 2 Oct 2013 17:49:28 -0700
Message-ID: <20131003004928.GM6768@jonmason-lab>
References: <cover.1380703262.git.agordeev@redhat.com>
 <0590d63c3432229a3824bada71e07a08fb955498.1380703263.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Michael Ellerman <michael@ellerman.id.au>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Andy King <acking@vmware.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	stable@vger.kernel.org, linux-pci@vger.kernel.org,
	linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org,
	linux390@de.ibm.com, linux-s390@vger.kernel.org, x86@kernel.org,
	linux-ide@vger.kernel.org, iss_storagedev@hp.com,
	linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-driver@qlogic.com,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	"VMware, Inc." <pv-drivers@vmw
To: Alexander Gordeev <agordeev@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0590d63c3432229a3824bada71e07a08fb955498.1380703263.git.agordeev@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 02, 2013 at 12:49:09PM +0200, Alexander Gordeev wrote:
> Current MSI-X enablement code assumes MSI-Xs were successfully
> allocated in case less than requested vectors were available.
> That assumption is wrong, since MSI-Xs should be enabled with
> a repeated call to pci_enable_msix(). This update fixes this.

Good catch, I'll pull it in for my next NTB release.

Thanks,
Jon

> 
> Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
> ---
>  drivers/ntb/ntb_hw.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/ntb/ntb_hw.c b/drivers/ntb/ntb_hw.c
> index 1cb6e51..de2062c 100644
> --- a/drivers/ntb/ntb_hw.c
> +++ b/drivers/ntb/ntb_hw.c
> @@ -1075,6 +1075,10 @@ static int ntb_setup_msix(struct ntb_device *ndev)
>  			 "Only %d MSI-X vectors.  Limiting the number of queues to that number.\n",
>  			 rc);
>  		msix_entries = rc;
> +
> +		rc = pci_enable_msix(pdev, ndev->msix_entries, msix_entries);
> +		if (rc)
> +			goto err1;
>  	}
>  
>  	for (i = 0; i < msix_entries; i++) {
> -- 
> 1.7.7.6
> 

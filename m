From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH 1/2] igb: Teardown SR-IOV before
	unregister_netdev()
Date: Mon, 27 Jul 2015 23:42:09 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D783BF445@FMSMSX113.amr.corp.intel.com>
References: <20150727223753.10121.78169.stgit@gimli.home>
 <20150727231834.10121.62918.stgit@gimli.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Alex Williamson' <alex.williamson@redhat.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150727231834.10121.62918.stgit@gimli.home>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ACK

> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Alex Williamson
> Sent: Monday, July 27, 2015 4:19 PM
> To: intel-wired-lan@lists.osuosl.org; Kirsher, Jeffrey T
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [Intel-wired-lan] [PATCH 1/2] igb: Teardown SR-IOV before
> unregister_netdev()
> 
> When the .remove() callback for a PF is called, SR-IOV support for the
> device is disabled, which requires unbinding and removing the VFs.
> The VFs may be in-use either by the host kernel or userspace, such as
> assigned to a VM through vfio-pci.  In this latter case, the VFs may
> be removed either by shutting down the VM or hot-unplugging the
> devices from the VM.  Unfortunately in the case of a Windows 2012 R2
> guest, hot-unplug is broken due to the ordering of the PF driver
> teardown.  Disabling SR-IOV prior to unregister_netdev() avoids this
> issue.
> 
> Signed-off-by: Alex Williamson <alex.williamson@redhat.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
> b/drivers/net/ethernet/intel/igb/igb_main.c
> index 517746f..606a7ae 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -2805,14 +2805,14 @@ static void igb_remove(struct pci_dev *pdev)
>  	 */
>  	igb_release_hw_control(adapter);
> 
> -	unregister_netdev(netdev);
> -
> -	igb_clear_interrupt_scheme(adapter);
> -
>  #ifdef CONFIG_PCI_IOV
>  	igb_disable_sriov(pdev);
>  #endif
> 
> +	unregister_netdev(netdev);
> +
> +	igb_clear_interrupt_scheme(adapter);
> +
>  	pci_iounmap(pdev, hw->hw_addr);
>  	if (hw->flash_address)
>  		iounmap(hw->flash_address);
> 
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@lists.osuosl.org
> http://lists.osuosl.org/mailman/listinfo/intel-wired-lan

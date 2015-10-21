From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC Patch 01/12] PCI: Add virtfn_index for struct pci_device
Date: Wed, 21 Oct 2015 11:07:22 -0700
Message-ID: <5627D45A.4040502@gmail.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
 <1445445464-5056-2-git-send-email-tianyu.lan@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Lan Tianyu <tianyu.lan@intel.com>, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com,
	yang.z.zhang@intel.com, agraf@suse.de, kvm@vger.kernel.org,
	pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445445464-5056-2-git-send-email-tianyu.lan@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2015 09:37 AM, Lan Tianyu wrote:
> Add "virtfn_index" member in the struct pci_device to record VF sequence
> of PF. This will be used in the VF sysfs node handle.
>
> Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
> ---
>   drivers/pci/iov.c   | 1 +
>   include/linux/pci.h | 1 +
>   2 files changed, 2 insertions(+)
>
> diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
> index ee0ebff..065b6bb 100644
> --- a/drivers/pci/iov.c
> +++ b/drivers/pci/iov.c
> @@ -136,6 +136,7 @@ static int virtfn_add(struct pci_dev *dev, int id, int reset)
>   	virtfn->physfn = pci_dev_get(dev);
>   	virtfn->is_virtfn = 1;
>   	virtfn->multifunction = 0;
> +	virtfn->virtfn_index = id;
>   
>   	for (i = 0; i < PCI_SRIOV_NUM_BARS; i++) {
>   		res = &dev->resource[i + PCI_IOV_RESOURCES];
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index 353db8d..85c5531 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -356,6 +356,7 @@ struct pci_dev {
>   	unsigned int	io_window_1k:1;	/* Intel P2P bridge 1K I/O windows */
>   	unsigned int	irq_managed:1;
>   	pci_dev_flags_t dev_flags;
> +	unsigned int	virtfn_index;
>   	atomic_t	enable_cnt;	/* pci_enable_device has been called */
>   
>   	u32		saved_config_space[16]; /* config space saved at suspend time */
>

Can't you just calculate the VF index based on the VF BDF number 
combined with the information in the PF BDF number and VF 
offset/stride?  Seems kind of pointless to add a variable that is only 
used by one driver and is in a slowpath when you can just calculate it 
pretty quickly.

- Alex

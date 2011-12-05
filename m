From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH net-next V0 19/21] mlx4_core: Modify driver initialization flow to accommodate SRIOV for Ethernet
Date: Mon, 5 Dec 2011 09:19:38 +0200
Message-ID: <201112050919.39280.jackm@dev.mellanox.co.il>
References: <4ED8A636.40901@mellanox.co.il> <201112041629.41466.jackm@dev.mellanox.co.il> <4EDB942F.1020101@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4EDB942F.1020101-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 04 December 2011 17:39, Or Gerlitz wrote:
> On 12/4/2011 4:29 PM, Jack Morgenstein wrote:
> > If the kernel is not configured to support IOV, pci_enable_sriov will 
> > fail.
> Jack,
> 
> If CONFIG_PCI_IOV isn't set, pci_enable_sriov isn't there...
> 
> Or.
> 
Not so.  I checked. If CONFIG_PCI_IOV isn't set, pci_enable_sriov returns -ENODEV
via a static inline function.
Look in kernel file include/linux/pci.h (for the most recent kernel):
 
#ifdef CONFIG_PCI_IOV
extern int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn);
extern void pci_disable_sriov(struct pci_dev *dev);
extern irqreturn_t pci_sriov_migration(struct pci_dev *dev);
extern int pci_num_vf(struct pci_dev *dev);
#else
static inline int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn)
{
        return -ENODEV;
}
static inline void pci_disable_sriov(struct pci_dev *dev)
{
}
static inline irqreturn_t pci_sriov_migration(struct pci_dev *dev)
{
        return IRQ_NONE;
}
static inline int pci_num_vf(struct pci_dev *dev)
{
        return 0;
}
#endif

- Jack
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

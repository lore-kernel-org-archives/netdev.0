From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH 0/4] move pci_assivned_vfs() check (while disabling VFs)
 to pci sub-system
Date: Thu, 20 Nov 2014 15:21:27 -0700
Message-ID: <20141120222127.GB7987@google.com>
References: <1415620410-4937-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	ariel.elior@qlogic.com, linux.nics@intel.com,
	shahed.shaikh@qlogic.com, ddutile@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1415620410-4937-1-git-send-email-sathya.perla@emulex.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[+cc Jeff]

On Mon, Nov 10, 2014 at 05:23:26PM +0530, Sathya Perla wrote:
> A user must not be allowed to disable VFs while they are already assigned to
> a guest. This check is being made in each individual driver that implements
> the sriov_configure PCI method.
> This patch-set fixes this code duplication by moving this check from
> drivers to the sriov_nuvfs_store() routine just before invoking
> sriov_configure() when num_vfs is equal to 0.
> 
> Vasundhara Volam (4):
>   pci: move pci_assivned_vfs() check while disabling VFs to pci
>     sub-system
>   bnx2x: remove pci_assigned_vfs() check while disabling VFs
>   i40e: remove pci_assigned_vfs() check while disabling VFs
>   qlcnic: remove pci_assigned_vfs() check while disabling VFs
> 
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |    2 +-
>  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |    7 +------
>  .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   10 ----------
>  drivers/pci/pci-sysfs.c                            |    5 +++++
>  4 files changed, 7 insertions(+), 17 deletions(-)

I'm dropping these for the reasons Don & Alex outlined -- they don't fix
the problem for VFIO, so this amounts to shuffling around code that's known
to be broken, which seems more confusing than worthwhile.

Jeff, if I were you I would drop the i40e patch.  I don't think it makes
sense to remove the check from i40e before adding it to the PCI core.

Bjorn

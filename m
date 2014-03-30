From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4_core: Handle null return by pci_match_id()
Date: Sun, 30 Mar 2014 21:08:06 +0300
Message-ID: <CAJZOPZ+je04BC8BAoL1i1jAGrMFbHkFSAjypFSd3Kxc6_PC-cw@mail.gmail.com>
References: <1396193215-6863-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Wei Yang <weiyang@linux.vnet.ibm.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:46937 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbaC3SIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2014 14:08:07 -0400
Received: by mail-pd0-f170.google.com with SMTP id v10so7021438pde.29
        for <netdev@vger.kernel.org>; Sun, 30 Mar 2014 11:08:06 -0700 (PDT)
In-Reply-To: <1396193215-6863-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 30, 2014 at 6:26 PM, Amir Vadai <amirv@mellanox.com> wrote:
> Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
> pci_device_id.driver_data to __mlx4_init_one during reset".
>
> pci_match_id() might return NULL if someone binds the driver to a device
> manually using /sys/bus/pci/drivers/.../new_id. Need to check 'id'
> before using it.
>
> Thanks to Bjorn who raised the problem.

Well, that commit was applied to net and is now present in Linus
tree... so assuming it's too late for 3.14, need to queue this for
-stable

Or.

>
> CC: Bjorn Helgaas <bhelgaas@google.com>
> CC: Wei Yang <weiyang@linux.vnet.ibm.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index f0ae95f..a2f6623 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2759,6 +2759,9 @@ static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
>         int ret;
>
>         id = pci_match_id(mlx4_pci_table, pdev);
> +       if (!id)
> +               return PCI_ERS_RESULT_DISCONNECT;
> +
>         ret = __mlx4_init_one(pdev, id->driver_data);
>
>         return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
> --
> 1.8.3.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

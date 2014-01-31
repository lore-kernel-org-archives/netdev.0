From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 18/34] mlx4: Use pci_enable_msix_range()
Date: Fri, 31 Jan 2014 22:22:06 +0300
Message-ID: <52EBF7DE.3080003@cogentembedded.com>
References: <cover.1391172839.git.agordeev@redhat.com> <2f6674dabb90d4cbca3ef4039c3b893f2e5e9ec4.1391172839.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Alexander Gordeev <agordeev@redhat.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <2f6674dabb90d4cbca3ef4039c3b893f2e5e9ec4.1391172839.git.agordeev@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01/31/2014 06:08 PM, Alexander Gordeev wrote:

> As result of deprecation of MSI-X/MSI enablement functions
> pci_enable_msix() and pci_enable_msi_block() all drivers
> using these two interfaces need to be updated to use the
> new pci_enable_msi_range() and pci_enable_msix_range()
> interfaces.

> Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/main.c |   19 ++++---------------
>   1 files changed, 4 insertions(+), 15 deletions(-)

> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index d711158..a9d1249 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
[...]
> @@ -1990,22 +1989,12 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
[...]
> +		nreq = pci_enable_msix_range(dev->pdev, entries, 2, nreq);
> +
> +		if (nreq < 0) {
>   			kfree(entries);
>   			goto no_msi;
> -		}
> -
> -		if (nreq <
> +		} else if (nreq <
>   		    MSIX_LEGACY_SZ + dev->caps.num_ports * MIN_MSIX_P_PORT) {

    Please realign this line to start right under 'nreq'.

WBR, Sergei

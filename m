From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 20/35] myri10ge: Use pci_enable_msix_range()
 instead of pci_enable_msix()
Date: Wed, 19 Feb 2014 19:14:41 +0400
Message-ID: <5304CA61.3020400@cogentembedded.com>
References: <cover.1392717502.git.agordeev@redhat.com> <4174e05e893a4b62b9c39692691b926cec2dc2c3.1392717503.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hyong-Youb Kim <hykim@myri.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Alexander Gordeev <agordeev@redhat.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <4174e05e893a4b62b9c39692691b926cec2dc2c3.1392717503.git.agordeev@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 18-02-2014 14:11, Alexander Gordeev wrote:

> As result of deprecation of MSI-X/MSI enablement functions
> pci_enable_msix() and pci_enable_msi_block() all drivers
> using these two interfaces need to be updated to use the
> new pci_enable_msi_range() and pci_enable_msix_range()
> interfaces.

> Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
> Cc: Hyong-Youb Kim <hykim@myri.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-pci@vger.kernel.org
> ---
>   drivers/net/ethernet/myricom/myri10ge/myri10ge.c |   40 +++++++++++-----------
>   1 files changed, 20 insertions(+), 20 deletions(-)

> diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> index 68026f7..130f6b2 100644
> --- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> +++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> @@ -2329,16 +2329,14 @@ static int myri10ge_request_irq(struct myri10ge_priv *mgp)
>   	status = 0;
>   	if (myri10ge_msi) {
>   		if (mgp->num_slices > 1) {
> -			status =
> -			    pci_enable_msix(pdev, mgp->msix_vectors,
> -					    mgp->num_slices);
> -			if (status == 0) {
> -				mgp->msix_enabled = 1;
> -			} else {
> +			status = pci_enable_msix_range(pdev, mgp->msix_vectors,
> +					mgp->num_slices, mgp->num_slices);

    Networking coding style assumes that you align the function call 
continuation lines under the next character after (.

[...]
> @@ -3895,32 +3893,34 @@ static void myri10ge_probe_slices(struct myri10ge_priv *mgp)
[...]
> +			goto no_msix;
> +		status = pci_enable_msix_range(pdev,
> +					       mgp->msix_vectors,
> +					       mgp->num_slices,
> +					       mgp->num_slices);

    Here you get this right.

WBR, Sergei

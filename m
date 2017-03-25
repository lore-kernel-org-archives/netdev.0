From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] irda: vlsi_ir: fix check for dma mapping errors
Date: Sat, 25 Mar 2017 13:19:49 +0300
Message-ID: <d818142b-b934-c5ff-6ef6-23bfdd836723@cogentembedded.com>
References: <1490395688-3666-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>,
        Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490395688-3666-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 3/25/2017 1:48 AM, Alexey Khoroshilov wrote:

> vlsi_alloc_ring() checks for dma mapping errors by comparison

    DMA. Comparing.

> returned address with zero, while pci_dma_mapping_error() should be used.
>
> Found by Linux Driver Verification project (linuxtesting.org).
>
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
> ---
>  drivers/net/irda/vlsi_ir.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
> index ffedad2a360a..15b920086251 100644
> --- a/drivers/net/irda/vlsi_ir.c
> +++ b/drivers/net/irda/vlsi_ir.c
> @@ -418,8 +418,9 @@ static struct vlsi_ring *vlsi_alloc_ring(struct pci_dev *pdev, struct ring_descr
>  		memset(rd, 0, sizeof(*rd));
>  		rd->hw = hwmap + i;
>  		rd->buf = kmalloc(len, GFP_KERNEL|GFP_DMA);
> -		if (rd->buf == NULL ||
> -		    !(busaddr = pci_map_single(pdev, rd->buf, len, dir))) {
> +		if (rd->buf)
> +			busaddr = pci_map_single(pdev, rd->buf, len, dir);
> +		if (rd->buf == NULL || pci_dma_mapping_error(pdev, busaddr)) {

    '!rd->buf' is preferred in the networking trees.

[...]

MBR, Sergei

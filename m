From: Bing Zhao <bzhao@marvell.com>
Subject: RE: [PATCH] mwifiex: don't return zero on failure paths in
 mwifiex_pcie_init()
Date: Fri, 25 Jan 2013 13:03:30 -0800
Message-ID: <477F20668A386D41ADCC57781B1F70430D1418CA15@SC-VEXCH1.marvell.com>
References: <1359147363-9587-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ldv-project@linuxtesting.org" <ldv-project@linuxtesting.org>
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359147363-9587-1-git-send-email-khoroshilov@ispras.ru>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alexey,

Thanks for the patch.

> If pci_iomap() fails in mwifiex_pcie_init(), it breaks off initialization,
> deallocates all resources, but returns zero.
> The patch adds -EIO as return value in this case.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Acked-by: Bing Zhao <bzhao@marvell.com>

Thanks,
Bing

> ---
>  drivers/net/wireless/mwifiex/pcie.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwifiex/pcie.c
> index 13fbc4e..9d9349c 100644
> --- a/drivers/net/wireless/mwifiex/pcie.c
> +++ b/drivers/net/wireless/mwifiex/pcie.c
> @@ -1739,6 +1739,7 @@ static int mwifiex_pcie_init(struct mwifiex_adapter *adapter)
>  	card->pci_mmap = pci_iomap(pdev, 0, 0);
>  	if (!card->pci_mmap) {
>  		dev_err(adapter->dev, "iomap(0) error\n");
> +		ret = -EIO;
>  		goto err_iomap0;
>  	}
>  	ret = pci_request_region(pdev, 2, DRV_NAME);
> @@ -1749,6 +1750,7 @@ static int mwifiex_pcie_init(struct mwifiex_adapter *adapter)
>  	card->pci_mmap1 = pci_iomap(pdev, 2, 0);
>  	if (!card->pci_mmap1) {
>  		dev_err(adapter->dev, "iomap(2) error\n");
> +		ret = -EIO;
>  		goto err_iomap2;
>  	}
> 
> --
> 1.7.9.5

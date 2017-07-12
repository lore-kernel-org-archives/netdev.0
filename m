From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 02/20] nic/hinic: Initialize hw device components
Date: Wed, 12 Jul 2017 17:34:04 +0200
Message-ID: <20170712153404.GG2557@lunn.ch>
References: <cover.1499865197.git.aviad.krawczyk@huawei.com>
 <dff4e431b9aa6ff69486a82b68b6320fa3f6a7f7.1499865197.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, bc.y@huawei.com, victor.gissin@huawei.com,
        zhaochen6@huawei.com, tony.qu@huawei.com
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <dff4e431b9aa6ff69486a82b68b6320fa3f6a7f7.1499865197.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +/**
> + * get_dev_cap - get device capabilities
> + * @hwdev: the NIC HW device to get capabilities for
> + *
> + * Return 0 - Success, negative - Failure
> + **/
> +static int get_dev_cap(struct hinic_hwdev *hwdev)
> +{
> +	struct hinic_pfhwdev *pfhwdev;
> +	struct hinic_hwif *hwif = hwdev->hwif;
> +	struct pci_dev *pdev = hwif->pdev;
> +	int err;
> +
> +	switch (HINIC_FUNC_TYPE(hwif)) {
> +	case HINIC_PPF:
> +	case HINIC_PF:
> +		pfhwdev = container_of(hwdev, struct hinic_pfhwdev, hwdev);
> +
> +		err = get_cap_from_fw(pfhwdev);
> +		if (err) {
> +			dev_err(&pdev->dev, "Failed to get capability from FW\n");
> +			return err;
> +		}
> +		break;
> +
> +	default:
> +		pr_err("Unsupported PCI Function type\n");

Hi Aviad

more pr_err(). Please go through all the patches and use dev_err(), or
netif_err() if appropriate.

    Thanks
	Andrew

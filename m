From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/9] liquidio CN23XX: VF registration
Date: Mon, 28 Nov 2016 00:04:41 -0500 (EST)
Message-ID: <20161128.000441.620877539663307124.davem@davemloft.net>
References: <1480308702-6261-1-git-send-email-rvatsavayi@caviumnetworks.com>
        <1480308702-6261-3-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@caviumnetworks.com,
        derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41450 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750934AbcK1FEn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 00:04:43 -0500
In-Reply-To: <1480308702-6261-3-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Sun, 27 Nov 2016 20:51:35 -0800

> +static int
> +liquidio_vf_probe(struct pci_dev *pdev,
> +		  const struct pci_device_id *ent __attribute__((unused)))
> +{
> +	struct octeon_device *oct_dev = NULL;
 ...
> +	/* set linux specific device pointer */
> +	oct_dev->pci_dev = (void *)pdev;
> +

This is a terrible cast on several levels.  The type is already
correct, oct_dev->pci_dev and pdev are both "struct pci_dev *"

Furthermore, even if oct_dev->pci_dev was "void *", void pointer
casts are _never_ necessary on assignment from any other pointer
type.

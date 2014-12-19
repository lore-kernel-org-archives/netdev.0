From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet adapters
Date: Fri, 19 Dec 2014 21:44:15 +0100
Message-ID: <54948E1F.2080405@gmx.de>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com> <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:64400 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751821AbaLSUoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2014 15:44:34 -0500
In-Reply-To: <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 19.12.2014 04:25, Raghu Vatsavayi wrote:
> +
> +static int cn6xxx_soft_reset(struct octeon_device *oct)
> +{
> +	octeon_write_csr64(oct, CN66XX_WIN_WR_MASK_REG, 0xFF);
> +
> +	lio_dev_dbg(oct, "BIST enabled for soft reset\n");
> +
> +	OCTEON_PCI_WIN_WRITE(oct, CN66XX_CIU_SOFT_BIST, 1);
> +	octeon_write_csr64(oct, CN66XX_SLI_SCRATCH1, 0x1234ULL);
> +
> +	OCTEON_PCI_WIN_READ(oct, CN66XX_CIU_SOFT_RST);
> +	OCTEON_PCI_WIN_WRITE(oct, CN66XX_CIU_SOFT_RST, 1);
> +
> +	/* Wait for 10ms as Octeon resets. */
> +	mdelay(10);
> +
> +	if (octeon_read_csr64(oct, CN66XX_SLI_SCRATCH1) == 0x1234ULL) {
> +		lio_dev_err(oct, "Soft reset failed\n");
> +		return 1;
> +	}

Before the delay you should probably make sure that the writes are
flushed to avoid pci write posting.

> +
> +static int cn68xx_soft_reset(struct octeon_device *oct)
> +{
> +	octeon_write_csr64(oct, CN68XX_WIN_WR_MASK_REG, 0xFF);
> +
> +	lio_dev_dbg(oct, "BIST enabled for CN68XX soft reset\n");
> +	OCTEON_PCI_WIN_WRITE(oct, CN68XX_CIU_SOFT_BIST, 1);
> +
> +	octeon_write_csr64(oct, CN68XX_SLI_SCRATCH1, 0x1234ULL);
> +
> +	OCTEON_PCI_WIN_READ(oct, CN68XX_CIU_SOFT_RST);
> +	OCTEON_PCI_WIN_WRITE(oct, CN68XX_CIU_SOFT_RST, 1);
> +
> +	/* Wait for 100ms as Octeon resets. */
> +	mdelay(100);
> +
> +	if (octeon_read_csr64(oct, CN68XX_SLI_SCRATCH1) == 0x1234ULL) {
> +		lio_dev_err(oct, "Soft reset failed\n");
> +		return 1;
> +	}

same here.

Regards,
Lino

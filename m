From: Robin Murphy <robin.murphy@arm.com>
Subject: Re: [V2 PATCH 2/5] arm64 : Introduce support for ACPI _CCA object
Date: Wed, 06 May 2015 11:08:52 +0100
Message-ID: <5549E834.1040305@arm.com>
References: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com> <1430838729-21572-3-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: 8BIT
Cc: "al.stone@linaro.org" <al.stone@linaro.org>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"linaro-acpi@lists.linaro.org" <linaro-acpi@lists.linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"leo.duran@amd.com" <leo.duran@amd.com>,
	"hanjun.guo@linaro.org" <hanjun.guo@linaro.org>,
	"msalter@redhat.com" <msalter@redhat.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>
To: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
	"rjw@rjwysocki.net" <rjw@rjwysocki.net>,
	"lenb@kernel.org" <lenb@kernel.org>,
	Catalin Marinas <Catalin.Marinas@arm.com>,
	Will Deacon <Will.Deacon@arm.com>,
	"thomas.lendacky@amd.com" <thomas.lendacky@amd.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1430838729-21572-3-git-send-email-Suravee.Suthikulpanit@amd.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Suravee,

On 05/05/15 16:12, Suravee Suthikulpanit wrote:
>  From http://www.uefi.org/sites/default/files/resources/ACPI_6.0.pdf,
> section 6.2.17 _CCA states that ARM platforms require ACPI _CCA
> object to be specified for DMA-cabpable devices. This patch introduces
> ACPI_MUST_HAVE_CCA in arm64 Kconfig to specify such requirement.
>
> In this case of missing _CCA, arm64 would assign dummy_dma_ops
> to disable DMA capability of the device.
>
> Signed-off-by: Mark Salter <msalter@redhat.com>
> Signed-off-by: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
> ---

[...]
> +static void __dummy_sync_single_for_cpu(struct device *dev,
> +					dma_addr_t dev_addr, size_t size,
> +					enum dma_data_direction dir)
> +{
> +}
> +
> +static void __dummy_sync_single_for_device(struct device *dev,
> +					   dma_addr_t dev_addr, size_t size,
> +					   enum dma_data_direction dir)
> +{
> +}

Minor point, but I don't see the need to have multiple dummy functions 
with identical signatures - just have a generic dummy_sync_single and 
assign it to both ops.

> +static void __dummy_sync_sg_for_cpu(struct device *dev,
> +				    struct scatterlist *sgl, int nelems,
> +				    enum dma_data_direction dir)
> +{
> +}
> +
> +static void __dummy_sync_sg_for_device(struct device *dev,
> +				       struct scatterlist *sgl, int nelems,
> +				       enum dma_data_direction dir)
> +{
> +}

Ditto here with dummy_sync_sg.

I wonder if there's any argument for putting the dummy DMA ops somewhere 
common, like drivers/base/dma-mapping.c?

Robin.


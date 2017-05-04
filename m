From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH v1] ACPI: Switch to use generic UUID API
Date: Thu, 4 May 2017 14:46:05 +0200
Message-ID: <20170504124604.GA14127@8bytes.org>
References: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-acpi@vger.kernel.org, tpmdd-devel@lists.sourceforge.net,
        intel-gfx@lists.freedesktop.org, nouveau@lists.freedesktop.org,
        linux-input@vger.kernel.org, iommu@lists.linux-foundation.org,
        linux-mmc@vger.kernel.org, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, linux-usb@vger.kernel.org,
        alsa-devel@alsa-project.org, linux-kernel@vger.kernel.org,
        "Rafael J . Wysocki" <rjw@rjwysocki.net>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        Borislav Petkov <bp@suse.de>,
        Dan Williams <dan.j.williams@intel.com>,
        Amir Goldstein <amir73il@gmail.com>,
        Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
        Jani Nikula <jani.nikula@linux.intel.com>,
        Ben Skeggs <bskeggs@redhat.com>,
        Benjamin Tissoires <benjamin.tissoires@redhat.com>,
        Adrian Hunter <adrian.hunter@intel.com>,
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 04, 2017 at 12:21:51PM +0300, Andy Shevchenko wrote:
> diff --git a/drivers/iommu/dmar.c b/drivers/iommu/dmar.c
> index cbf7763d8091..420d51b286ad 100644
> --- a/drivers/iommu/dmar.c
> +++ b/drivers/iommu/dmar.c
> @@ -1808,10 +1808,9 @@ IOMMU_INIT_POST(detect_intel_iommu);
>   * for Directed-IO Architecture Specifiction, Rev 2.2, Section 8.8
>   * "Remapping Hardware Unit Hot Plug".
>   */
> -static u8 dmar_hp_uuid[] = {
> -	/* 0000 */    0xA6, 0xA3, 0xC1, 0xD8, 0x9B, 0xBE, 0x9B, 0x4C,
> -	/* 0008 */    0x91, 0xBF, 0xC3, 0xCB, 0x81, 0xFC, 0x5D, 0xAF
> -};
> +static uuid_le dmar_hp_uuid =
> +	UUID_LE(0xD8C1A3A6, 0xBE9B, 0x4C9B,
> +		0x91, 0xBF, 0xC3, 0xCB, 0x81, 0xFC, 0x5D, 0xAF);
>  
>  /*
>   * Currently there's only one revision and BIOS will not check the revision id,
> @@ -1824,7 +1823,7 @@ static u8 dmar_hp_uuid[] = {
>  
>  static inline bool dmar_detect_dsm(acpi_handle handle, int func)
>  {
> -	return acpi_check_dsm(handle, dmar_hp_uuid, DMAR_DSM_REV_ID, 1 << func);
> +	return acpi_check_dsm(handle, &dmar_hp_uuid, DMAR_DSM_REV_ID, 1 << func);
>  }
>  
>  static int dmar_walk_dsm_resource(acpi_handle handle, int func,
> @@ -1843,7 +1842,7 @@ static int dmar_walk_dsm_resource(acpi_handle handle, int func,
>  	if (!dmar_detect_dsm(handle, func))
>  		return 0;
>  
> -	obj = acpi_evaluate_dsm_typed(handle, dmar_hp_uuid, DMAR_DSM_REV_ID,
> +	obj = acpi_evaluate_dsm_typed(handle, &dmar_hp_uuid, DMAR_DSM_REV_ID,
>  				      func, NULL, ACPI_TYPE_BUFFER);
>  	if (!obj)
>  		return -ENODEV;

DMAR part is

	Acked-by: Joerg Roedel <jroedel@suse.de>

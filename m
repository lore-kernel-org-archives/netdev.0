From: Felipe Balbi <balbi@kernel.org>
Subject: Re: [PATCH v1] ACPI: Switch to use generic UUID API
Date: Tue, 09 May 2017 10:56:43 +0300
Message-ID: <87o9v2jwec.fsf@linux.intel.com>
References: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        "Rafael J . Wysocki" <rjw@rjwysocki.net>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        Borislav Petkov <bp@suse.de>,
        Dan Williams <dan.j.williams@intel.com>,
        Amir Goldstein <amir73il@gmail.com>,
        Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
        Jani Nikula <jani.nikula@linux.intel.com>,
        Ben Skeggs <bskeggs@redhat.com>,
        Benjamin Tissoires <benjamin.tissoires@redhat.com>,
        Joerg Roedel <joro@8bytes.org>,
        Adrian Hunter <adrian.hunter@intel.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Zhang Rui <rui.zhang@intel.com>,
        Mathias Nyman <mathias.nyman@intel.com>,
        Heikki Krogerus <heikki.krogerus@linux.intel.com>,
        Liam Girdwood <lgirdwood@gmail.com>,
        Mark Br
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        linux-acpi@vger.kernel.org, tpmdd-devel@lists.sourceforge.net,
        intel-gfx@lists.freedesktop.org, nouveau@lists.freedesktop.org,
        linux-input@vger.kernel.org, iommu@lists.linux-foundation.org,
        linux-mmc@vger.kernel.org, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, linux-usb@vger.kernel.org,
        alsa-devel@alsa-project.org, linux-kernel@vger.kernel.org
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

Andy Shevchenko <andriy.shevchenko@linux.intel.com> writes:
> acpi_evaluate_dsm() and friends take a pointer to a raw buffer of 16
> bytes. Instead we convert them to use uuid_le type. At the same time we
> convert current users.
>
> acpi_str_to_uuid() becomes useless after the conversion and it's safe to
> get rid of it.
>
> The conversion fixes a potential bug in int340x_thermal as well since
> we have to use memcmp() on binary data.
>
> Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
> Cc: Mika Westerberg <mika.westerberg@linux.intel.com>
> Cc: Borislav Petkov <bp@suse.de>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Amir Goldstein <amir73il@gmail.com>
> Cc: Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>
> Cc: Jani Nikula <jani.nikula@linux.intel.com>
> Cc: Ben Skeggs <bskeggs@redhat.com>
> Cc: Benjamin Tissoires <benjamin.tissoires@redhat.com>
> Cc: Joerg Roedel <joro@8bytes.org>
> Cc: Adrian Hunter <adrian.hunter@intel.com>
> Cc: Yisen Zhuang <yisen.zhuang@huawei.com>
> Cc: Bjorn Helgaas <bhelgaas@google.com>
> Cc: Zhang Rui <rui.zhang@intel.com>
> Cc: Felipe Balbi <balbi@kernel.org>
> Cc: Mathias Nyman <mathias.nyman@intel.com>
> Cc: Heikki Krogerus <heikki.krogerus@linux.intel.com>
> Cc: Liam Girdwood <lgirdwood@gmail.com>
> Cc: Mark Brown <broonie@kernel.org>
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> diff --git a/drivers/usb/dwc3/dwc3-pci.c b/drivers/usb/dwc3/dwc3-pci.c
> index a15ec71d0423..6b5284ec76df 100644
> --- a/drivers/usb/dwc3/dwc3-pci.c
> +++ b/drivers/usb/dwc3/dwc3-pci.c
> @@ -56,7 +56,7 @@ struct dwc3_pci {
>  	struct platform_device *dwc3;
>  	struct pci_dev *pci;
>  
> -	u8 uuid[16];
> +	uuid_le uuid;
>  
>  	unsigned int has_dsm_for_pm:1;
>  };
> @@ -118,7 +118,7 @@ static int dwc3_pci_quirks(struct dwc3_pci *dwc)
>  
>  		if (pdev->device == PCI_DEVICE_ID_INTEL_BXT ||
>  				pdev->device == PCI_DEVICE_ID_INTEL_BXT_M) {
> -			acpi_str_to_uuid(PCI_INTEL_BXT_DSM_UUID, dwc->uuid);
> +			uuid_le_to_bin(PCI_INTEL_BXT_DSM_UUID, &dwc->uuid);
>  			dwc->has_dsm_for_pm = true;
>  		}
>  
> @@ -288,7 +288,7 @@ static int dwc3_pci_dsm(struct dwc3_pci *dwc, int param)
>  	tmp.type = ACPI_TYPE_INTEGER;
>  	tmp.integer.value = param;
>  
> -	obj = acpi_evaluate_dsm(ACPI_HANDLE(&dwc->pci->dev), dwc->uuid,
> +	obj = acpi_evaluate_dsm(ACPI_HANDLE(&dwc->pci->dev), &dwc->uuid,
>  			1, PCI_INTEL_BXT_FUNC_PMU_PWR, &argv4);
>  	if (!obj) {
>  		dev_err(&dwc->pci->dev, "failed to evaluate _DSM\n");

Acked-by: Felipe Balbi <felipe.balbi@linux.intel.com>

-- 
balbi

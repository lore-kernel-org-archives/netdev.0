From: Zhang Rui <rui.zhang@intel.com>
Subject: Re: [PATCH v1] ACPI: Switch to use generic UUID API
Date: Wed, 10 May 2017 09:20:51 +0800
Message-ID: <1494379251.2129.15.camel@intel.com>
References: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "Rafael J . Wysocki" <rjw@rjwysocki.net>,
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
        Felipe Balbi <balbi@kernel.org>,
        Mathias Nyman <mathias.nyman@intel.com>,
        Heikki Krogerus <heikki.krogerus@linux.intel.com>,
        Liam Girdwood <lgirdwood@gmail.com>,
        Mark Brown <broonie@kernel.org>
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

On Thu, 2017-05-04 at 12:21 +0300, Andy Shevchenko wrote:
> acpi_evaluate_dsm() and friends take a pointer to a raw buffer of 16
> bytes. Instead we convert them to use uuid_le type. At the same time
> we
> convert current users.
> 
> acpi_str_to_uuid() becomes useless after the conversion and it's safe
> to
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
> ---
> 
> diff --git a/drivers/thermal/int340x_thermal/int3400_thermal.c
> b/drivers/thermal/int340x_thermal/int3400_thermal.c
> index 9413c4abf0b9..c0eb3bb19b23 100644
> --- a/drivers/thermal/int340x_thermal/int3400_thermal.c
> +++ b/drivers/thermal/int340x_thermal/int3400_thermal.c
> @@ -23,7 +23,7 @@ enum int3400_thermal_uuid {
>  	INT3400_THERMAL_MAXIMUM_UUID,
>  };
>  
> -static u8 *int3400_thermal_uuids[INT3400_THERMAL_MAXIMUM_UUID] = {
> +static const char
> *int3400_thermal_uuids[INT3400_THERMAL_MAXIMUM_UUID] = {
>  	"42A441D6-AE6A-462b-A84B-4A8CE79027D3",
>  	"3A95C389-E4B8-4629-A526-C52C88626BAE",
>  	"97C68AE7-15FA-499c-B8C9-5DA81D606E0A",
> @@ -141,10 +141,10 @@ static int int3400_thermal_get_uuids(struct
> int3400_thermal_priv *priv)
>  		}
>  
>  		for (j = 0; j < INT3400_THERMAL_MAXIMUM_UUID; j++) {
> -			u8 uuid[16];
> +			uuid_le u;
>  
> -			acpi_str_to_uuid(int3400_thermal_uuids[j],
> uuid);
> -			if (!strncmp(uuid, objb->buffer.pointer,
> 16)) {
> +			uuid_le_to_bin(int3400_thermal_uuids[j],
> &u);
> +			if (!uuid_le_cmp(*(uuid_le *)objb-
> >buffer.pointer), u) {
>  				priv->uuid_bitmap |= (1 << j);
>  				break;
>  			}
thanks for the fix.

Acked-by: Zhang Rui <rui.zhang@intel.com>

-rui

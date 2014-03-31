From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] pci: Use designated initialization in PCI_VDEVICE
Date: Tue, 01 Apr 2014 02:08:06 +0400
Message-ID: <5339E746.4030503@cogentembedded.com>
References: <1396303119-16766-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Rustad <mark.d.rustad@intel.com>, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, bhelgaas@google.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1396303119-16766-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/01/2014 01:58 AM, Jeff Kirsher wrote:

> From: Mark Rustad <mark.d.rustad@intel.com>

> By using designated initialization in PCI_VDEVICE, like other
> similar macros, many "missing initializer" warnings that appear
> when compiling with W=2 can be silenced.

> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   include/linux/pci.h | 10 +++++-----
>   1 file changed, 5 insertions(+), 5 deletions(-)

> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index fb57c89..49455f9 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
[...]
> @@ -689,9 +689,9 @@ struct pci_driver {
>    * private data.
>    */
>
> -#define PCI_VDEVICE(vendor, device)		\
> -	PCI_VENDOR_ID_##vendor, (device),	\
> -	PCI_ANY_ID, PCI_ANY_ID, 0, 0
> +#define PCI_VDEVICE(vend, dev) \
> +	.vendor = PCI_VENDOR_ID_##vend, .device = (dev), \
> +	.subvendor = PCI_ANY_ID, .subdevice = PCI_ANY_ID, 0, 0

    Initializing the fields to 0 is pointless, as 0 is what should be put into 
them anyway by the compiler. Also, it doesn't look right when you mix 
designated and anonymous initializers.

WBR, Sergei

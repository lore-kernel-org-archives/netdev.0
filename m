From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [net-next 08/15] pci: expose pcie_link_speed and pcix_bus_speed arrays
Date: Mon, 29 Jul 2013 12:44:11 -0600
Message-ID: <CAErSpo5sVTveY54iodDuqLXqsUTqUXTfDLh14k3=okneHB+ikg@mail.gmail.com>
References: <1375102331-23905-1-git-send-email-jeffrey.t.kirsher@intel.com> <1375102331-23905-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	netdev <netdev@vger.kernel.org>, gospo@redhat.com,
	sassmann@redhat.com,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:47546 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab3G2Soc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 14:44:32 -0400
Received: by mail-oa0-f46.google.com with SMTP id h1so13829729oag.19
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 11:44:31 -0700 (PDT)
In-Reply-To: <1375102331-23905-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 29, 2013 at 6:52 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Jacob Keller <jacob.e.keller@intel.com>
>
> pcie_link_speed and pcix_bus_speed are arrays used by probe.c to correctly
> convert lnksta register values into the pci_bus_speed enum. These static arrays
> are useful outside probe for this purpose. This patch makes these defines into
> const arrays and exposes them with an extern header in linux/include/pci.h
>
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/pci/probe.c | 4 ++--
>  include/linux/pci.h | 3 +++
>  2 files changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
> index 46ada5c..496c5b0 100644
> --- a/drivers/pci/probe.c
> +++ b/drivers/pci/probe.c
> @@ -513,7 +513,7 @@ static struct pci_host_bridge *pci_alloc_host_bridge(struct pci_bus *b)
>         return bridge;
>  }
>
> -static unsigned char pcix_bus_speed[] = {
> +const unsigned char pcix_bus_speed[] = {
>         PCI_SPEED_UNKNOWN,              /* 0 */
>         PCI_SPEED_66MHz_PCIX,           /* 1 */
>         PCI_SPEED_100MHz_PCIX,          /* 2 */
> @@ -532,7 +532,7 @@ static unsigned char pcix_bus_speed[] = {
>         PCI_SPEED_133MHz_PCIX_533       /* F */
>  };
>
> -static unsigned char pcie_link_speed[] = {
> +const unsigned char pcie_link_speed[] = {
>         PCI_SPEED_UNKNOWN,              /* 0 */
>         PCIE_SPEED_2_5GT,               /* 1 */
>         PCIE_SPEED_5_0GT,               /* 2 */
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index 0fd1f15..95ff993 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -120,6 +120,9 @@ typedef int __bitwise pci_power_t;
>  /* Remember to update this when the list above changes! */
>  extern const char *pci_power_names[];
>
> +extern const unsigned char pcix_bus_speed[];
> +extern const unsigned char pcie_link_speed[];

As far as I can tell, you didn't actually add anything that uses
pcix_bus_speed[].

You added a pcie_link_speed[] use only in drivers/pci/pci.c; maybe
this extern declaration could go in drivers/pci/pci.h to limit its
visibility?

If you update this patch, note that we conventionally capitalize "PCI:
Expose ..." in the changelog summary, e.g., "git log --oneline
drivers/pci".

>  static inline const char *pci_power_name(pci_power_t state)
>  {
>         return pci_power_names[1 + (int) state];
> --
> 1.7.11.7
>

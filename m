From: Tim Mattox <tmattox@gmail.com>
Subject: Re: [PATCH] forcedeth: jumbo frame support
Date: Sat, 16 Jul 2005 17:09:09 -0400
Message-ID: <ea86ce22050716140987d7ef8@mail.gmail.com>
References: <42D94E95.1060303@colorfullife.com>
Reply-To: Tim Mattox <tmattox@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <42D94E95.1060303@colorfullife.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is just from a simple read of Manfred's patch, but shouldn't one side of
the if-else use the NV_PKTLIMIT_2 value?  If not, why is
np->pkt_limit = NV_PKTLIMIT_1; inside the if-else at all?

On 7/16/05, Manfred Spraul <manfred@colorfullife.com> wrote:
[snip]
> +/* maximum mtu size */
> +#define NV_PKTLIMIT_1  ETH_DATA_LEN    /* hard limit not known */
> +#define NV_PKTLIMIT_2  9100    /* Actual limit according to NVidia: 9202 */
[snip]
> @@ -2007,13 +2093,16 @@
> 
>         /* handle different descriptor versions */
>         if (pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_1 ||
> -               pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_2 ||
> -               pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_3 ||
> -               pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_12 ||
> -               pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_13)
> +                       pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_2 ||
> +                       pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_3 ||
> +                       pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_12 ||
> +                       pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_13) {
>                 np->desc_ver = DESC_VER_1;
> -       else
> +               np->pkt_limit = NV_PKTLIMIT_1;
> +       } else {
>                 np->desc_ver = DESC_VER_2;
> +               np->pkt_limit = NV_PKTLIMIT_1;
> +       }

-- 
Tim Mattox - tmattox@gmail.com
  http://homepage.mac.com/tmattox/
    I'm a bright... http://www.the-brights.net/

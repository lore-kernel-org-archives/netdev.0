From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH 1/5] net: thunderx: switch to pci_alloc_irq_vectors
Date: Mon, 27 Mar 2017 21:33:32 +0530
Message-ID: <CA+sq2CdsGPNwU0kKQUtRgxKvGTDoYE0yLVC+fSgc3DGbjOjWVg@mail.gmail.com>
References: <20170327082936.6830-1-hch@lst.de> <20170327082936.6830-2-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Bjorn Helgaas <bhelgaas@google.com>,
        "David S. Miller" <davem@davemloft.net>, netanel@annapurnalabs.com,
        jcliburn@gmail.com, chris.snook@gmail.com,
        Sunil Goutham <sgoutham@cavium.com>,
        Robert Richter <rric@kernel.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        linux-pci <linux-pci@vger.kernel.org>
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170327082936.6830-2-hch@lst.de>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 27, 2017 at 1:59 PM, Christoph Hellwig <hch@lst.de> wrote:
> Remove the deprecated pci_enable_msix API in favour of it's successor.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/net/ethernet/cavium/thunder/nic_main.c | 75 ++++++--------------------
>  1 file changed, 15 insertions(+), 60 deletions(-)
> -       nic->num_vec = pci_msix_vec_count(nic->pdev);
> -
> -       ret = pci_enable_msix(nic->pdev, nic->msix_entries, nic->num_vec);
> -       if (ret) {
> +       /* Enable MSI-X */
> +       ret = pci_alloc_irq_vectors(nic->pdev, nic->num_vec, nic->num_vec,
> +                       PCI_IRQ_MSIX);
nic->num_vec will always be zero here.

> +       while (--i >= 0)
> +               free_irq(pci_irq_vector(nic->pdev, i), nic);
> +       pci_free_irq_vectors(nic->pdev);
>         return ret;
IRQ handlers are not registered for all vectors to free them unconditionally

> +       int i;
> +
> +       for (i = 0; i < nic->num_vec; i++)
> +               free_irq(pci_irq_vector(nic->pdev, i), nic);
> +       pci_free_irq_vectors(nic->pdev);
>  }
Same as here.

How urgent is this ?
Can we comeup with a proper patch to fix this in couple of weeks, instead of
going with these untested patches ?

From: Paul Gortmaker <paul.gortmaker@gmail.com>
Subject: Re: [PATCH] r8169: Randomise invalid MAC addresses
Date: Mon, 23 Jan 2012 15:53:05 -0500
Message-ID: <CAP=VYLqpUun0FtCs4VWDeLm-mAri=+UV3psRA12eVbV1So_c-Q@mail.gmail.com>
References: <1327343540-30348-1-git-send-email-torne@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nic_swsd@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Torne (Richard Coles)" <torne@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327343540-30348-1-git-send-email-torne@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 23, 2012 at 1:32 PM, Torne (Richard Coles) <torne@google.co=
m> wrote:
> From: "Torne (Richard Coles)" <torne@google.com>
>
> If the default MAC address stored in the card is invalid, replace it
> with a random address and complain about it.

You might want to have a look at this thread and its outcome.

https://lkml.org/lkml/2012/1/14/75

Paul.

>
> Signed-off-by: Torne (Richard Coles) <torne@google.com>
> ---
> =A0drivers/net/ethernet/realtek/r8169.c | =A0 =A08 ++++++++
> =A01 files changed, 8 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ether=
net/realtek/r8169.c
> index 7a0c800..ec5ebbb 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -4103,6 +4103,14 @@ rtl8169_init_one(struct pci_dev *pdev, const s=
truct pci_device_id *ent)
> =A0 =A0 =A0 =A0/* Get MAC address */
> =A0 =A0 =A0 =A0for (i =3D 0; i < ETH_ALEN; i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->dev_addr[i] =3D RTL_R8(MAC0 + i);
> +
> + =A0 =A0 =A0 if (!is_valid_ether_addr(dev->dev_addr)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Report it and use a random ethernet =
address instead */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev, "Invalid MAC address: %=
pM\n", dev->dev_addr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 random_ether_addr(dev->dev_addr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_info(dev, "Using random MAC addr=
ess: %pM\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->dev_addr);
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
>
> =A0 =A0 =A0 =A0SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
> --
> 1.7.7.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html

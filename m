From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-2.6] ixgbe: fix panic when shutting down system with
	WoL enabled
Date: Wed, 16 Jun 2010 16:54:22 -0700
Message-ID: <AANLkTimSGrmLjkEaEli1T2U0XAHtTWysFrV2RcMH89IC@mail.gmail.com>
References: <20100616200102.GP7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:36810 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406Ab0FPXyX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 19:54:23 -0400
Received: by iwn9 with SMTP id 9so6218491iwn.19
        for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 16:54:23 -0700 (PDT)
In-Reply-To: <20100616200102.GP7497@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 16, 2010 at 13:01, Andy Gospodarek <andy@greyhouse.net> wro=
te:
>
> This patch added to 2.6.34:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0commit 5f6c01819979afbfec7e0b15fe52371b8ee=
d87e8
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Author: Jesse Brandeburg <jesse.brandeburg=
@intel.com>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Date: =C2=A0 Wed Apr 14 16:04:23 2010 -070=
0
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ixgbe: fix bug with vlan str=
ip in promsic mode
>
> among other things added a function called ixgbe_vlan_filter_enable.
> This new function wants to access and set some rx_ring parameters, bu=
t
> adapter->rx_ring has already been freed. =C2=A0This simply moves the =
free
> until after the access and makes __ixgbe_shutdown look more like
> ixgbe_remove.
>
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
> =C2=A0drivers/net/ixgbe/ixgbe_main.c | =C2=A0 =C2=A03 ++-
> =C2=A01 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe=
_main.c
> index ce30c62..e237748 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -5195,7 +5195,6 @@ static int __ixgbe_shutdown(struct pci_dev *pde=
v, bool *enable_wake)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ixgbe_free_all=
_tx_resources(adapter);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ixgbe_free_all=
_rx_resources(adapter);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 ixgbe_clear_interrupt_scheme(adapter);
>
> =C2=A0#ifdef CONFIG_PM
> =C2=A0 =C2=A0 =C2=A0 =C2=A0retval =3D pci_save_state(pdev);
> @@ -5230,6 +5229,8 @@ static int __ixgbe_shutdown(struct pci_dev *pde=
v, bool *enable_wake)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*enable_wake =3D !!wufc;
>
> + =C2=A0 =C2=A0 =C2=A0 ixgbe_clear_interrupt_scheme(adapter);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ixgbe_release_hw_control(adapter);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_disable_device(pdev);
> --
> 1.6.2.5
>

Thanks Andy, I have added the patch to my queue.

--=20
Cheers,
Jeff

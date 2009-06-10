From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: return PCI_ERS_RESULT_DISCONNECT on permanent
	error
Date: Wed, 10 Jun 2009 15:53:31 -0700
Message-ID: <9929d2390906101553q742f2d9v28f09e8880527df8@mail.gmail.com>
References: <200906051540.56392.adetsch@br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	mmlnx@us.ibm.com
To: Andre Detsch <adetsch@br.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:44953 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755687AbZFJWxa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 18:53:30 -0400
Received: by an-out-0708.google.com with SMTP id d40so1872793and.1
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 15:53:32 -0700 (PDT)
In-Reply-To: <200906051540.56392.adetsch@br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 5, 2009 at 11:40 AM, Andre Detsch<adetsch@br.ibm.com> wrote=
:
> PCI drivers that implement the io_error_detected callback
> should return PCI_ERS_RESULT_DISCONNECT if the state
> passed in is pci_channel_io_perm_failure. =C2=A0This state is
> not checked in many of the network drivers.
>
> This patch fixes the omission in the e1000 driver.
>
> Based on Mike Mason's similar patch for e1000e.
>
> Signed-off-by: Andre Detsch <adetsch@br.ibm.com>
> Cc: Mike Mason <mmlnx@us.ibm.com>
> ---
> =C2=A0drivers/net/e1000/e1000_main.c | =C2=A0 =C2=A03 +++
> =C2=A01 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000=
_main.c
> index 05e87a5..df1d5ca 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -4816,6 +4816,9 @@ static pci_ers_result_t e1000_io_error_detected=
(struct pci_dev *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct e1000_adapter *adapter =3D netdev_p=
riv(netdev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_device_detach(netdev);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (state =3D=3D pci_channel_io_perm_failure)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return PCI_ERS_RES=
ULT_DISCONNECT;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (netif_running(netdev))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0e1000_down(ada=
pter);
> --

Thanks, I have added this to my queue and will push it with the e1000e =
fix.

--=20
Cheers,
Jeff
